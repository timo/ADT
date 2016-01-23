use Test;

eval-lives-ok q{
    use ADT "Tree = Branch Tree left, Tree right | Leaf Str storage";
    my $a = Tree.new-leaf("Hello");
}, "single ADT from EXPORT";

eval-lives-ok q{
    use ADT "Maybe = Just Str data | Nothing";
    my $a = Maybe.new-just("Hello");
}, "single ADT from EXPORT number 2";

eval-lives-ok q{
    use ADT "Maybe = Just Str data | Nothing", "Tree = Branch Tree left, Tree right | Leaf Str storage";
    my $a = Maybe.new-just("Hello");
    my $b = Tree.new-leaf("Goodbye"); 
}, "two ADTs from EXPORT";

done-testing;
