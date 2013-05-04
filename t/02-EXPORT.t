use Test;

use ADT "foo bar";

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

done;
