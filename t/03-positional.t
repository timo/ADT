use Test;
use ADT;

plan 8;

{
    my %res = create_adt("Positionals = One Str one1 | Two Str a, Str b | Three Str x, Str y, Str z | Five Str f1, Str f2, Str f3, Str f4, Str f5 | Eight Str e1, Str e2, Str e3, Str e4, Str e5, Str e6, Str e7, Str e8");
    my \Positionals = %res<Positionals>;

    my \One = %res<One>;
    my \Two = %res<Two>;
    my \Three = %res<Three>;
    my \Five = %res<Five>;
    my \Eight = %res<Eight>;

    my $one    = Positionals.new-one:    <black>;
    ok $one ~~ One, "positional constructors";

    my $two    = Positionals.new-one:    <then>;
    ok $two ~~ One;

    my $three  = Positionals.new-two:    <white are>;
    ok $three ~~ Two;

    my $four   = Positionals.new-three:  <all I see>;
    ok $four ~~ Three;

    my $five   = Positionals.new-five:   <in my in fan cy>;
    ok $five ~~ Five;

    my $six    = Positionals.new-eight:  <red and yel low then came to be>;
    ok $six ~~ Eight;

    my $seven  = Positionals.new-five:   <rea ching out to me>;
    ok $seven ~~ Five;

    my $eight  = Positionals.new-three:  <lets me see>;
    ok $eight ~~ Three;
}
