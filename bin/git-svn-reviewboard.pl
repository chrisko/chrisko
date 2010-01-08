#!/usr/bin/perl
use strict;
use warnings;
my $branch = shift;
my $head = `git rev-list --date-order --max-count=1 $branch`;
my $svnrev = `git svn find-rev $head`;
my $diff = `git diff --find-copies-harder --no-prefix $branch...`;
 
my $space = "   ";
chomp $svnrev;
my @lines = split /\n/, $diff;
for (my $i = 0; $i < scalar @lines; $i++) {
    my $line = $lines[$i];
    if ($line =~ m{^--- /dev/null.*}) {
        my ($newfile) = $lines[$i + 1] =~ m{^\+\+\+ (.+)\s*$};
        $line =~ s{/dev/null.*$}{$newfile$space(revision 0)};
        print "$line\n";
        next;
    }
    $line =~ s/^(--- .*)/$1$space(revision $svnrev)/;
    $line =~ s/^(\+\+\+ .*)/$1$space(working copy)/;
    print "$line\n";
}
