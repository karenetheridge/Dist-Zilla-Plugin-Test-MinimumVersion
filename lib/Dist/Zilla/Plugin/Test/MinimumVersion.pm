use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::Test::MinimumVersion;
# ABSTRACT: Author tests for minimum required versions

our $VERSION = '2.000009';

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::TextTemplate',
    'Dist::Zilla::Role::PrereqSource';

has max_target_perl => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_max_target_perl',
);

around add_file => sub {
    my ($orig, $self, $file) = @_;
    $self->$orig(
        Dist::Zilla::File::InMemory->new({
            name => $file->name,
            content => $self->fill_in_string(
                $file->content,
                { (version => $self->max_target_perl)x!!$self->has_max_target_perl }
            ),
        })
    );
};

=for Pod::Coverage register_prereqs

=cut

sub register_prereqs {
    my $self = shift;
    $self->zilla->register_prereqs(
        {
            type  => 'requires',
            phase => 'develop',
        },
        'Test::MinimumVersion' => 0,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 SYNOPSIS

In C<dist.ini>:

    [Test::MinimumVersion]
    max_target_perl = 5.10.1

=for test_synopsis
1;
__END__

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing a
L<Test::MinimumVersion> test:

  xt/author/minimum-version.t - a standard Test::MinimumVersion test

You should provide the highest perl version you want to require as
C<target_max_version>. If you accidentally use perl features that are newer
than that version number, then the test will fail, and you can go change
whatever bumped up the minimum perl version required.

=cut

__DATA__
___[ xt/author/minimum-version.t ]___
#!perl

use Test::More;

use Test::MinimumVersion;
{{ $version
    ? "all_minimum_version_ok( qq{$version} );"
    : "all_minimum_version_from_metayml_ok();"
}}
