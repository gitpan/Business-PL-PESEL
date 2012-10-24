# Copyright (C) 2012 by Tomasz Konojacki
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

package Business::PL::PESEL;

our $VERSION = '0.08';

use strict;
use warnings;
use utf8;

use Time::Piece;

sub new {
    my($class, %args) = @_;

    die 'PESEL number not specified in constructor' unless defined $args{-pesel};

    my $self = {
        %args
    };

    return bless $self, $class;
}

sub is_valid {
    my $self = shift;
    my %args = @_;

    my($checksum, $month, $range);

    return 0 unless defined $self->{-pesel};

    # Calculate checksum
    return 0 unless $self->{-pesel} =~ /^(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)$/;
    $checksum = (1 * $1) + (3 * $2) + (7 * $3) + (9 * $4) + (1 * $5) + (3 * $6) + (7 * $7) + (9 * $8) + (1 * $9) + (3 * $10);
    $checksum %= 10;
    $checksum = 10 - $checksum unless $checksum == 0;
    return 0 unless ($11 == $checksum);

    unless ($args{-dont_check_date}) {
        # Check whether date is valid
        eval {
            $self->birth_date
        } or return 0;
    }

    # No errors, this is valid PESEL
    return 1;
}

sub is_male {
    my $self = shift;

    die 'PESEL number not specified' unless defined $self->{-pesel};

    return 0 unless defined $self->{-pesel};
    return 0 unless $self->is_valid || die 'Invalid PESEL';
    return 0 unless $self->{-pesel} =~ /^\d{9}(\d)\d$/;
    return 0 if $1 % 2 == 0;
    return 1;
}

sub is_female {
    my $self = shift;

    die 'PESEL number not specified' unless defined $self->{-pesel};

    return 0 unless defined $self->{-pesel};
    return 0 unless $self->is_valid || die 'Invalid PESEL';
    return 0 unless $self->{-pesel} =~ /^\d{9}(\d)\d$/;
    return 1 if $1 % 2 == 0;
    return 0;
}

sub birth_date {
    my $self = shift;

    my($year, $month, $day, $tp, $date);

    die 'PESEL number not specified' unless defined $self->{-pesel};
    die 'Invalid PESEL' unless $self->is_valid(-dont_check_date => 1) ;
    die 'Invalid PESEL' unless ($year, $month, $day) = $self->{-pesel} =~ /^(\d{2})(\d{2})(\d{2})\d{5}$/;

    if ($month - 80 > 0) {
        $month -= 80;
        $year = 18 . $year;
    }
    elsif ($month - 60 > 0) {
        $month -= 60;
        $year = 22 . $year;
    }
    elsif ($month - 40 > 0) {
        $month -= 40;
        $year = 21 . $year;
    }
    elsif ($month - 20 > 0) {
        $month -= 20;
        $year = 20 . $year;
    }
    else {
        $year = 19 . $year;
    }

    $date = "$day-$month-$year";

    eval {
        $tp = Time::Piece->strptime($date, '%d-%m-%Y');
    } or die 'Invalid PESEL: invalid date!';

    die 'Invalid PESEL: invalid date!' if ($date ne $tp->strftime('%d-%m-%Y'));

    return $tp;
}

1;

__END__

=pod

=head1 NAME

Business::PL::PESEL - Validate Polish Universal Electronic System for Registration
of the Population ID

=head1 VERSION

version 0.08

=head1 SYNOPSIS

    use Business::ID::PESEL;
    my $pesel = Business::PL::PESEL->new(-pesel => 49040501580);
    print $pesel->birth_date->month;

=head1 DESCRIPTION

This module can be used to validate and analyze PESEL number. All methods
(except ->is_valid) die on failure.

=head1 METHODS

=head2 new(-pesel=>$pesel_number)

Create a new C<Business::PL::PESEL> object.

=head2 is_valid()

Check whether supplied PESEL number is valid. Returns 1 on success and 0 on
failure.

=head2 is_male()

Check if supplied PESEL numbers belongs to male person. Returns 1 if true, 0
if false.

=head2 is_female()

Check if supplied PESEL numbers belongs to female person. Returns 1 if true, 0
if false.

=head2 birth_date()

Returns birth date (Time::Piece object) of person identified by supplied PESEL
ID.

=head1 BUGS

None known.

=head1 GIT REPOSITORY

    git://git.savannah.nongnu.org/perl-pesel.git
    Mirror: git://github.com/xenu/business-pl-pesel.git

=head1 AUTHOR

  Tomasz Konojacki <xenu@poczta.onet.pl>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Tomasz Konojacki.

This is free software; you can redistribute it and/or modify it under
the terms of MIT license.

=cut

