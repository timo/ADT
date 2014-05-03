module ADT {
    grammar hs_adt {
        has @.typevars;
        rule TOP {
            $<name>=<.ident> <params> '=' <definers>
        }
        rule params {
            '[' ~ ']' [ '::' $<typevar>=<.ident> { @.typevars.push($<typevar>.Str) }]+ %% ',' | ''
        }
        rule parameters {
            '[' ~ ']' [$<typevar>=<.ident> { $0 ~~ @.typevars }]+ | ''
        }
        rule definers {
            '|' ? [ <definition> ]+ % '|'
        }
        rule definition {
            $<constructor>=<.ident> [ $<typedecl>=<.ident><parameters> $<attrname>=<.ident> ]* %% ','
        }
    }

    class hs_adt_actions {
        has @.attributes;
        method TOP($/) { make { name => $<name>.Str, params => $<params>.ast, definers => $<definers>.ast.Array }.item }
        method params($/) { make $/.Str ?? $<typevar>>>.Str.Array.item !! [].item }
        method parameters($/) { make $/.Str ?? make $<typevar>>>.Str.Array.item !! make [].item }
        method definers($/) { make $<definition>>>.ast.Array.item }
        method definition($/) {
            die "no two attributes may lowercase to the same string" if $<attrname>.lc ~~ @.attributes;
            push @.attributes, $<attrname>.lc;
            make { constructor => $<constructor>.Str, types => ($<typedecl>>>.Str Z $<attrname>>>.Str Z $<parameters>>>.ast).Array }.item
        }
    }

    # is parsed is NYI
    #macro create_adt is parsed <hs_adt> {
    #}

    # our ADT is made up of many parts:
    #
    # - a class that serves as kind of an entry point, called C<container-type> i.e. Tree
    # - an attribute for each constructor that handles the attributes of that constructor, i.E. Tree.branch handles <attr_a attr_b>
    # - a constructor method new-foo for each of the constructors, i.E. new-branch, new-tree
    #
    # - one class for each Constructor as part of the containing class, i.e. Tree::Branch, Tree::Leaf
    # - one subset for each Constructor of the container class that validates the .definedness of the constructor attribute

    our sub create_adt(Str $definition) is export {
        my $adt_parse_result = hs_adt.parse($definition, :actions(hs_adt_actions.new));

        die "could not parse adt definition:" ~ "\n" ~ $definition.indent(4) unless $adt_parse_result;

        my $adt = $adt_parse_result.ast;

        # create the type object for the containing class
        my $container-type := Metamodel::ClassHOW.new_type(name => $adt<name>);

        #| for each of the constructors, save what attribute names they have here
        my %handlers;

        my %resulting-types;

        my %collisions;
        sub collide($name, $original?) {
            die "Colliding definitions for name $name { $original ?? "(originally $original) " !! "" }in adt $adt<name>." if %collisions{$name}++;
        }

        #| create a class inside the container type for each of the constructors
        sub create_constructor($name, @attrs) {
            my $type := Metamodel::ClassHOW.new_type(:$name);

            for @attrs -> $atype, $aname, $type-params {
                # type-params is currently unused.
                $type.HOW.add_attribute($type, Attribute.new(
                        :name('$.' ~ $aname), :type(Any), # TODO: properly look up types :type(::{$atype}),
                        :has_accessor(1), :package($type)
                    ));
                push %handlers{$name}, $aname;
                collide($aname);
            }

            $type.HOW.compose($type);
            return $type;
        }

        # create each constructor class first
        my %constructors = do for @($adt<definers>) {
            $_<constructor> => create_constructor($_<constructor>, $_<types>)
        }

        # the default new method should just die.
        $container-type.HOW.add_method($container-type, 'new', method {
                die "cannot create a $adt<name> this way. try any of " ~ ("new-$_" for %constructors.keys>>.lc).join(', ') ~ ' instead.';
            });

        for %constructors.kv -> $name, $type {
            # create one attribute for each of the constructors.
            my $attr := Attribute.new(
                :name('$.' ~ $name.lc), :type(Any), #:type($type.WHAT),
                :has_accessor(1), :package($container-type));

            collide($name.lc, $name);
            $container-type.HOW.add_attribute($container-type, $attr);
            # the constructor attribute shall handle each of the constructor's attribute
            # in the containing class
            trait_mod:<handles>($attr, -> {
                        %handlers{$name}
                    }
                );

=begin comment
            # the following code causes a weeeeird error to happen.
            sub eas(Str $code) {
                say $code;
                my Mu $rv = eval $code;
                say $rv.perl;
                return $rv;
            }
            # also, create a new-foo method to create such a value.
            # this one takes named parameters and passes them on to the constructor of the
            # contained type
             {
                my $signature = ((':$' ~ $_) for @(%handlers{$name})).join(", ");
                $container-type.HOW.add_multi_method($container-type, "new-$name.lc()", eas
                        "method ($signature) \{\n" ~
                        "    say 'the named thingie was called';\n" ~
                        "    return self.bless(:" ~ $name.lc ~ "(::<$name>.new($signature)))\n" ~
                        "}"
                    );
            }

            # this new method takes positional parameters and passes them on as nameds.
            {
                my $pos-signature = ('$' ~ $_ for @(%handlers{$name})).join(", ");
                my $named-signature = (':$' ~ $_ for @(%handlers{$name})).join(", ");
                $container-type.HOW.add_multi_method($container-type, "new-$name.lc()", eas
                        "method ($pos-signature) \{\n" ~
                        "    say 'the positional thingie was called';\n" ~
                        "    return self.bless(:" ~ $name.lc ~ "(::<$name>.new($named-signature)))\n" ~
                        "}"
                    );
            }
=end comment

            # also, create a new-foo method to create such a value.
            # it should take named or positional arguments
            $container-type.HOW.add_multi_method($container-type, "new-$name.lc()", method (|c) {
                if +c.hash {
                    self.bless(|($name.lc => $type.new(|c)))
                } elsif c.list == %handlers{$name}.list {
                    my @args = c.list;
                    self.bless(|($name.lc => $type.new(|(%handlers{$name}.list Z=> @args).hash)))
                } elsif c.list == 1 {
                    if %handlers{$name}.list != 1 && c.list[0] ~~ Positional {
                        self.bless(|($name.lc => $type.new(|(%handlers{$name}.list Z=> @(c.list[0])).hash)))
                    } else {
                        die "The subtype $name has { +%handlers{$name}.list } parameters. The single parameter ought to be Positional, but it is { c.list[0].^name }";
                    }
                }
            });
        }

        # create a pretty-printer
        for <perl gist> -> $methname {
            $container-type.HOW.add_method($container-type, $methname, method {
                    for %constructors.keys {
                        if self."$_.lc()"().defined {
                            my $result = self."$_.lc()"()."$methname"();
                            substr-rw($result, 0, $_.chars + ".new".chars) = $adt<name> ~ ".new-$_.lc()";
                            return $result;
                        }
                    }
                    return;
                });
        }

        # it's imperative that we compose our class before we attempt to create the subsets.
        $container-type.HOW.compose($container-type);

        for %constructors.keys -> $name {
            # lastly, create a Subset of the containing class that checks for the definedness of our attribute.
            my Mu $refinee := $container-type;
            my $refinement = {$_."$name.lc()"().defined};
            %resulting-types{$name} = Metamodel::SubsetHOW.new_type(:$name, :$refinee, :$refinement);
        }

        %resulting-types{$adt<name>} = $container-type;

        return %resulting-types;
    }
}

our sub EXPORT(*@definitions) {
    my %result;
    for @definitions -> $def {
        my %adts := ADT::create_adt($def);
        %result.push: %adts;
    }
    return %result;
}
