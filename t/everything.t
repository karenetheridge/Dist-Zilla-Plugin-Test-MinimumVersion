use strict;
use warnings;
use Test::More 0.96 tests => 2;
use autodie;
use Test::DZil;
use Moose::Autobox;

subtest 'explicit version' => sub {
    plan tests => 2;

    my $tzil = Builder->from_config(
        { dist_root => 'corpus/DZ1' },
        {
            add_files => {
                'source/dist.ini' => simple_ini(
                    ('GatherDir', ['Test::MinimumVersion' => { max_target_perl => '5.10.1' }])
                ),
            },
        },
    );
    $tzil->build;
    END { # Remove (empty) dir created by building the dists
        require File::Path;
        File::Path::rmtree('tmp') if -d 'tmp';
    }

    my ($test) = map { $_->name eq 'xt/release/minimum-version.t' ? $_ : () } $tzil->files->flatten;
    ok $test, 'minimum-version.t exists'
        or diag explain [ map { $_->name } $tzil->files->flatten ];

    like $test->content => qr{\Q5.10.1\E}, 'max_target_perl used in test';
};

subtest 'version from metayml' => sub {
    plan tests => 2;

    my $tzil = Builder->from_config(
        { dist_root => 'corpus/DZ1' },
        {
            add_files => {
                'source/dist.ini' => simple_ini(
                    ('GatherDir', 'Test::MinimumVersion')
                ),
            },
        },
    );
    $tzil->build;
    END { # Remove (empty) dir created by building the dists
        require File::Path;
        File::Path::rmtree('tmp') if -d 'tmp';
    }

    my ($test) = map { $_->name eq 'xt/release/minimum-version.t' ? $_ : () } $tzil->files->flatten;
    ok $test, 'minimum-version.t exists'
        or diag explain [ map { $_->name } $tzil->files->flatten ];

    like $test->content => qr{metayml}, 'metayml used in test';
};