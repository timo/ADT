use Test;
use ADT;
plan 7;

{
    my %res = create_adt("Tree = Branch Tree left, Tree right | Leaf Str storage");
    my \Tree = %res<Tree>;

    my $in-out = 'Tree.new-branch(left => Tree.new-branch(left => Tree.new-leaf(storage => 1), right => Tree.new-leaf(storage => 2)), right => Tree.new-leaf(storage => 3))';

    my $t = Tree.new-branch(left => Tree.new-branch(left => Tree.new-leaf(storage => 1), right => Tree.new-leaf(storage => 2)), right => Tree.new-leaf(storage => 3));

    is $t.gist, $in-out, "evaling a construction gists out exactly the same again.";
    is $t.perl, $in-out, "evaling a construction perls out exactly the same again.";

    my $t2 =
        Tree.new-branch(
            Tree.new-branch(
                Tree.new-leaf(1),
                Tree.new-leaf(2)),
            Tree.new-leaf(3));
    is $t2.gist, $in-out, "positional args for constructors work, too";

    my \Branch = %res<Branch>;
    my \Leaf = %res<Leaf>;
    sub treemap($t, *&code) {
        given $t {
            when Branch { return Tree.new-branch(treemap($t.left, &code), treemap($t.right, &code)) }
            when Leaf { return Tree.new-leaf(code($t.storage)) }
        }
    }
    $t2 = treemap($t2, * * 10);
    my $counter;
    treemap($t2, { $counter += $^val; $^val });
    is $counter, 60, "example treemaps work";

    ok $t ~~ Tree, "smartmatch against container class";
    ok $t ~~ Branch, "smartmatch against one constructor";
    ok $t.right ~~ Leaf, "smartmatch against another constructor";
}
