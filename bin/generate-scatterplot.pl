#!/usr/local/bin/perl
use strict; use warnings;

my @data_points = <>;
chomp foreach @data_points;

print <<"END_OF_GNUPLOT";
set terminal png medium size 1200,800

set title "YSFE Ad Results vs. YSFE Time"

set xrange [-2:102]
set xlabel "# of ads"
set ylabel "time (ms)"
#set grid

set pointsize .2

# If it's an integer value, try "(\$1 + (rand(0) - 0.5))" in column 1.
plot '-' using (\$1 + (rand(0) - .5)):2 title " "
END_OF_GNUPLOT

foreach my $point (@data_points) { print "$point\n"; }
print "e\n";
