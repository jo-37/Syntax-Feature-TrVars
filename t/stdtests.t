#!perl -T

use 5.006;
use Test2::V0;

use String::Compile::Tr;
use Scalar::Util 'tainted';

plan 5;

like dies {trgen('', '', 'x')}, qr/options invalid/, 'invalid option';

subtest 'run on arg' => sub {
    my $x = 'abc';
    my $y = '123';
    my $s = 'edcba';
    my $tr;

    plan 4;
    ok lives {$tr = trgen($x, $y)}, 'compile', $@;
    ref_ok $tr, 'CODE', 'is sub';
    ok lives {$tr->($s)}, 'call', $@;
    is $s, 'ed321', 'result';
};

subtest 'run on default' => sub {
    my $x = 'abc';
    my $y = 'ABC';
    my $tr;
    my @arr = qw(axy bxy cxy);

    plan 3 + @arr;
    ok lives {$tr = trgen($x, $y)}, 'compile', $@;
    ref_ok $tr, 'CODE', 'is sub';
    ok lives {$tr->()}, "call on $_" for @arr;
    is [@arr], [qw(Axy Bxy Cxy)], 'result';
};

subtest 'use options' => sub {
    my $x = 'abc';
    my $s = 'fedcb';
    my $tr;

    plan 4;
    ok lives {$tr = trgen($x, '', 'dc')}, 'compile', $@;
    ref_ok $tr, 'CODE', 'is sub';
    ok lives {$tr->($s)}, 'call', $@;
    is $s, 'cb', 'result';
};

subtest 'run on tainted' => sub {
    my $tainted = substr $ENV{PATH}, 0, 0;
    my $x = 'abc' . $tainted;
    my $y = '123' . $tainted;
    my $opt = 's' . $tainted;
    my $s = 'eeddccbbaa'. $tainted;
    my $tr;

    plan 6;
    ok tainted($x), 'x is tainted';
    ok tainted($opt), 'opt is tainted';
    ok lives {$tr = trgen($x, $y, $opt)}, 'compile', $@;
    ref_ok $tr, 'CODE', 'is sub';
    ok lives {$tr->($s)}, 'call', $@;
    is $s, 'eedd321', 'result';
};
