Algebraic Data Types
====================

This module implements algebraic data types inspired by the Haskell syntax.

Here's a code example for you:

    # define the algebraic data type
    my $adt = q{Tree = Branch Tree left, Tree right | Leaf Str storage}
    my %res = create_adt($adt);
    
    # capture the Tree class
    my \Tree = %res<Tree>;
    
    # create a tree using named parameters
    my $t =
        Tree.new-branch(
            :left(Tree.new-branch(
                :left(Tree.new-leaf(:storage(1))),
                :right(Tree.new-leaf(:storage(2))))),
            :right(Tree.new-leaf(:storage(3))));
    # pretty-print the tree
    say $t.gist;
    
    # create a tree using positional arguments
    my $t2 =
        Tree.new-branch(
            Tree.new-branch(
                Tree.new-leaf(1),
                Tree.new-leaf(2)),
            Tree.new-leaf(3));
    say $t2.gist;
    
    # capture the subtypes to pattern-match in a given block.
    my \Branch = %res<Branch>;
    my \Leaf = %res<Leaf>;
    
    # map over a whole tree changing all storages.
    sub treemap($t, *&code) {
        given $t {
            when Branch { return Tree.new-branch(treemap($t.left, &code), treemap($t.right, &code)) }
            when Leaf { return Tree.new-leaf(code($t.storage)) }
        }
    }
    
    # multiply every leaf node by 10
    say treemap($t2, * * 10).gist;


When rakudo gets proper EXPORT sub handling, it'll look like this:

    use ADT "data Tree = Branch Tree left, Tree right | Leaf Str storage";
    multi sub treemap(Branch $t, *&c) { ... }
    multi sub treemap(Leaf $l, *&c) { ... }

