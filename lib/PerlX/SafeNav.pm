package PerlX::SafeNav;
use strict;
use warnings;
our $VERSION = '0.000';

use Exporter 'import';

our @EXPORT = ('$safenav', '$unsafenav');

our $safenav = sub {
    my $o = shift;
    bless \$o, 'PerlX::SafeNav::Object';
};

our $unsafenav = sub {
    ${ $_[0] }
};

package PerlX::SafeNav::Object;

use overload
    '@{}' => sub {
        my $self = shift;
        tie my @a, 'PerlX::SafeNav::ArrayRef', $$self;
        return \@a;
    },
    '%{}' => sub {
        my $self = shift;
        tie my %h, 'PerlX::SafeNav::HashRef', $$self;
        return \%h;
    };

sub AUTOLOAD {
    our $AUTOLOAD;
    my $method = substr $AUTOLOAD, 2 + rindex($AUTOLOAD, '::');

    my ($self, @args) = @_;

    (defined $$self) ?
        $$self -> $method(@args) -> $safenav :
        $self;
}

sub DESTROY {}

package PerlX::SafeNav::ArrayRef;
use Tie::Array;
our @ISA = ('Tie::Array');

sub TIEARRAY {
    my ($class, $o) = @_;
    return bless \$o, $class;
}

sub FETCH {
    my ($self, $i) = @_;
    @$$self[$i] -> $safenav;
}

sub FETCHSIZE {
    my ($self) = @_;
    @$$self
}

package PerlX::SafeNav::HashRef;
use Tie::Hash;
our @ISA = ('Tie::Hash');

sub TIEHASH {
    my ($class, $o) = @_;
    bless \$o, $class;
}

sub FETCH {
    my ($self, $k) = @_;
    $$self->{$k} -> $safenav;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

PerlX::SafeNav - Safe-navigation for Perl

=head1 SYNOPSIS

Wrap a chain of method calls to make it resilient on encountering C<undef> values in the middle:

    use PerlX::SafeNav ('$safenav', '$unsafenav');

    my $tire = $car -> $safenv
         -> wheels()
         -> first()    # undef, if no wheels at all
         -> tire()     # undef, if no tire on the wheel
         -> remove()
         -> $unsafenav;

    unlessd (defined $tier) {
        # The car either have no wheels, or the first wheel has no tire.
        ...
    }

=head1 DESCRIPTION

In many other languages, there is an operator (often C<?.>) doing
"Safe navigation", or "Optional Chaining".  The operator does a
method-call when its left-hand side (first operant) is an object.  But
when the left-hand side is an undefined value (or null value), the
operator returns but evaluates to C<undef>.

For perl there is currently an PPC: L<Optional Chaining|https://github.com/Perl/PPCs/blob/main/ppcs/ppc0021-optional-chaining-operator.md>

This module provides a mean of making chains of method call safe
regarding undef values. When encountering an C<undef> in the middle of
the chain, instead of dying with a "Can't call method on undefined
value" method, the entier chain of calls is reduced to C<undef>.

With C<PerlX::SaveNav> module, we could wrap a chain of calls and make
it safe. Say, we want to do this:

    $ret = $o->a()->b()->c();

... but theose methods C<a()>, C<b()>, C<c()>, they all have some
chances of returning C<undef>, perhaps as a way to signal the lack of
data. Without proper checking, this chain of calls may end up
erroring with a message like this:

    Can't call method "b" on an undefined value

Instead of rewriting this nice little call chain into several
statements and adding C<defined> to check the return value after each
method calls, we could do this instead:

    use PerlX::SafeNav ('$safenav', '$unsafenav');

    $ret = $o->$safenav->a()->b()->c()->$unsafenav;

This way, when any of C<a()>, C<b()>, C<c()> returns C<undef>, the
entire chain also evaluates to C<undef>.

Noticed that the imported symbols are both C<$>-sigiled, this is
purposely made so, so that they could be called as methods on
arbitrary objects. While being unconventional in their look, the
chance of having naming conflicts with methods from C<$o> should be very small.

However, be aware that C<$safenav> and C<$unsafenav> would be masked
by locally-defined variables with the same name.

=head1 AUTHOR

Kang-min Liu <gugod@gugod.org>

Toby Inkster <tobyink@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2023 Kang-min Liu C<< <gugod@gugod.org> >>.

This is free software, licensed under:

    The MIT License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
