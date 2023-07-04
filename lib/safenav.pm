package safenav;
use strict;
use warnings;
use PerlX::SafeNav ('$safenav', '$unsafenav', '&safenav');

use Exporter 'import';
our @EXPORT = ('&safenav');

*begin = *wrap = $safenav;
*end = *unwrap = $unsafenav;

1;

=pod

=encoding utf-8

=head1 NAME

safenav - Safe-navigation for Perl

=head1 SYNOPSIS

    use safenav;

    my $tire_age = $car
         -> safenav::wrap()
         -> wheels()
         -> [0]               # undef, if no wheels at all.
         -> tire()            # undef, if no tire on the wheel.
         -> {created_on}
         -> delta_days($now)
         -> safenav::unwrap();

    unless (defined $tire_age) {
        # The car either have no wheels, or the first wheel has no tire.
        ...
    }

=head1 DESCRIPTION

This C<safenav> pragma provides helper methods for wrapping a chain of calls and make it safe from encountering C<undef> values in the way. If any of sub-expressions yield C<undef>, instead of aborting the program with an error message, the entire chain yields C<undef> instead.

This pragma is part of L<PerlX::SafeNav>. It is just an alternative interface.

Say we have this chain, in which each part right after ther C<< -> >> operator may yield C<undef>:

    $o->a()->{b}->c()->[42]->d();

To make it safe from C<undef> values, we mark the beginning and the end with C<safenav::wrap()> and C<safenav::unwrap()>:

    $o-> safenav::wrap() -> a()->{b}->c()->[42]->d() -> safenav::unwrap();

Or alternatively, with C<safenav::begin()> and C<safenav::end()>:

    $o-> safenav::begin() -> a()->{b}->c()->[42]->d() -> safenav::end();

Whichever seems better for you.

=head1 SEE ALSO

L<PerlX::SafeNav>, L<results::wrap>

=cut
