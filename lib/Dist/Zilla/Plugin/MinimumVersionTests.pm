use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::MinimumVersionTests;
# ABSTRACT: Release tests for minimum required versions

our $VERSION = '2.000011';

use Moose;
extends 'Dist::Zilla::Plugin::Test::MinimumVersion';

use namespace::autoclean;

=head1 SYNOPSIS

In C<dist.ini>:

    [Test::MinimumVersion]

=cut

before register_component => sub {
    warn '!!! [MinimumVersionTests] is deprecated and will be removed in a future release; replace it with [Test::MinimumVersion]';
};

__PACKAGE__->meta->make_immutable;
1;
