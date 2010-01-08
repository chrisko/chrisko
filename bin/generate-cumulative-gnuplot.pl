#!/usr/local/bin/perl
use strict; use warnings;

use List::Util qw(first max sum);

# grep {$_ > 0} if you want to filter out the zeroes.
my @data_points = sort {$a <=> $b} <>;
chomp foreach @data_points;

my $total_points = scalar(@data_points);
my $greatest_value = max(@data_points);

my $average = sum(@data_points) / scalar(@data_points);
my $print_average = sprintf("%.2f", $average);

my $bin_size = 5;
my %bin_frequencies = ();
foreach my $point (@data_points) {
    my $bin = $bin_size * int($point / $bin_size);
    $bin_frequencies{$bin} ||= 0;
    $bin_frequencies{$bin}++;
}
my $largest_bin_size = (sort {$a <=> $b} values %bin_frequencies)[-1];


print <<"END_OF_GNUPLOT";
set terminal png medium size 1200,800

set title "title title title"

set boxwidth $bin_size absolute

set xrange [0:$greatest_value]
set yrange [-.2:1]

set xlabel "something"
set xtics nomirror out 5
set ytics nomirror out 0,0.05
set grid

set pointsize 0.01

set style line 1 linewidth 2 linecolor rgbcolor "black"
set arrow from $average,0 to $average,.02 nohead front linestyle 1
set label "avg:$print_average" at first $average,0 front offset .5,.6

# If it's an integer value, try "(\$1 + (rand(0) - 0.5))" in column 1.
plot '-' using (\$1 + (rand(0) - 0.5)):(0.2 * rand(0) - 0.2) title " ", \\
  '-' using 1:(1/$total_points.) smooth cumulative title "cumulative", \\
  '-' using 1:(.98*\$2/$largest_bin_size.) smooth frequency title "frequency" with boxes
END_OF_GNUPLOT


# The first plot takes a sampling of the data points:
my $sampling_factor = 1;
foreach my $point (@data_points) { print "$point\n" if (rand() < $sampling_factor); }
print "e\n";

# The second plot takes, necessarily, all data points:
foreach my $point (@data_points) { print "$point\n"; }
print "e\n";

# The third plot command takes the bins and their respective frequency counts:
foreach my $bin (sort {$a <=> $b} keys %bin_frequencies) {
    print "$bin\t$bin_frequencies{$bin}\n";
}
print "e\n";
