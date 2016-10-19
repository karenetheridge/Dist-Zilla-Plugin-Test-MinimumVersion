use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::Test::MinimumVersion;
# ABSTRACT: Release tests for minimum required versions
# VERSION

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::TextTemplate',
    'Dist::Zilla::Role::PrereqSource',
    ;

sub register_prereqs {
    my $self = shift @_;

    $self->zilla->register_prereqs(
        { phase => 'develop' },
        'Test::MinimumVersion' => 0,
    );

    return;
}

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

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 SYNOPSIS

In C<dist.ini>:

    [Test::MinimumVersion]
    max_target_perl = 5.10.1

=begin :prelude

=for test_synopsis BEGIN { die "SKIP: Synopsis isn't Perl code" }

=for Pod::Coverage register_prereqs

=end :prelude

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing a
L<Test::MinimumVersion> test:

  xt/release/minimum-version.t - a standard Test::MinimumVersion test

You should provide the highest perl version you want to require as
C<target_max_version>. If you accidentally use perl features that are newer
than that version number, then the test will fail, and you can go change
whatever bumped up the minimum perl version required.

=cut

__DATA__
___[ xt/release/minimum-version.t ]___
#!perl

use Test::More;

eval "use Test::MinimumVersion";
plan skip_all => "Test::MinimumVersion required for testing minimum versions"
  if $@;
{{ $version
    ? "all_minimum_version_ok( qq{$version} );"
    : "all_minimum_version_from_metayml_ok();"
}}
