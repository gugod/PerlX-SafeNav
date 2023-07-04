use Test2::V0;
use safenav;

package O {
    sub a { $_[0]->{a} }
    sub b () { undef }
};

subtest "begin and end", sub {
    my $o = bless {
        a => [undef, undef],
        h => {},
    }, 'O';
    $o->{a}[1] = $o;
    $o->{h}{o} = $o;

    subtest "undef upon array fetch", sub {
        my $ret = $o
            -> safenav::begin()
            -> a()
            -> [0] # undef
            -> b()
            -> safenav::end();
        is $ret, U();
    };

    subtest "undef upon hash fetch", sub {
        my $ret = $o
            -> safenav::begin()
            -> {h}
            -> {x} # undef
            -> b()
            -> safenav::end();
        is $ret, U();
    };

    subtest "undef upon method calls", sub {
        my $ret = $o
            -> safenav::begin()
            -> a()
            -> [1]
            -> b() # undef
            -> c()
            -> safenav::end();
        is $ret, U();
    };
};

subtest "wrap and unwrap", sub {
    my $o = bless {
        a => [undef, undef],
        h => {},
    }, 'O';
    $o->{a}[1] = $o;
    $o->{h}{o} = $o;

    subtest "undef upon array fetch", sub {
        my $ret = $o
            -> safenav::wrap()
            -> a()
            -> [0] # undef
            -> b()
            -> safenav::unwrap();
        is $ret, U();
    };

    subtest "undef upon hash fetch", sub {
        my $ret = $o
            -> safenav::wrap()
            -> {h}
            -> {x} # undef
            -> b()
            -> safenav::unwrap();
        is $ret, U();
    };

    subtest "undef upon method calls", sub {
        my $ret = $o
            -> safenav::wrap()
            -> a()
            -> [1]
            -> b() # undef
            -> c()
            -> safenav::unwrap();
        is $ret, U();
    };
};

done_testing;
