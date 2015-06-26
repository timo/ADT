use Test;
use ADT;
plan 5;

{
    dies-ok { create_adt("arghlebarghle") }, "sanity";

    ok create_adt(q:to/TREE/), "simple multiline";
        Tree = Branch Tree left, Tree right
             | Leaf Str storage
        TREE

    ok create_adt(q:to/TREE/), "| on the first line, too";
        Tree = | Branch Tree left, Tree right
               | Leaf Str storage
        TREE

    ok create_adt(q:to/TREE/), "newline after comma";
        Tree = | Branch
                    Tree left,
                    Tree right
               | Leaf
                    Str storage
        TREE

    ok create_adt(q:to/TREE/), "trailing comma";
        Tree = | Branch
                    Tree left,
                    Tree right,
               | Leaf
                    Str storage,
        TREE
}
