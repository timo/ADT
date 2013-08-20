use Test;

eval_lives_ok q{
    use ADT "Tree = Branch Tree left, Tree right | Leaf Str storage";
    my Tree $a = Tree.new-leaf("Hello");
}, "single ADT from EXPORT";

eval_lives_ok q{
    use ADT "Maybe = Just Str data | Nothing";
    my Tree $a = Maybe.new-just("Hello");
}, "single ADT from EXPORT number 2";

eval_lives_ok q{
    use ADT "Maybe = Just Str data | Nothing", "Tree = Branch Tree left, Tree right | Leaf Str storage";
    my Maybe $a = Maybe.new-just("Hello");
    my Tree $b = Tree.new-leaf("Goodbye"); 
}, "two ADTs from EXPORT";

eval_lives_ok q{
    use ADT "Maybe = Just Str data | Nothing";
    multi do-it(Just $a) {
        say $a.data;
    }
    multi do-it(Nothing $a) {
        say $a;
    }
}, "use of our names in a multi";

eval_lives_ok q{
    use ADT "Maybe = Just Str data | Nothing";
    multi do-it(Just $a) {
        say $a.data;
    }
    multi do-it(Nothing $a) {
        say $a;
    }
    do-it(Maybe.new-nothing());
    do-it(Maybe.new-just("hi"));
}, "invocation of our multi.";

done;
