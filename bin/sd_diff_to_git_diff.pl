#!/usr/bin/perl
use strict;
use warnings;

# use IPC::Run3 qw();

# my $dpk_filename = $ARGV[0];
# die "SDPack DPK filename required." unless ($dpk_filename);
# die "File \"$dpk_filename\" does not exist." unless (-e $dpk_filename);
# $dpk_filename = `cygpath -m $dpk_filename`;
# chomp $dpk_filename;
# 
# my ($stdout, $stderr);
# my $command = "sdpack.bat diff -du \"$dpk_filename\"";
# my $rc = IPC::Run3::run3($command, undef, $stdout, $stderr);
# if ($rc != 0 || $stderr) {
#     print "Command \"$command\" returned $rc.\n" if ($rc != 0);
#     print $stderr if ($stderr);
#     exit 1;
# }

$/ = "\r\n";
while (my $line = <>) {
    chomp $line;
    if ($line =~ m{^==== //depot/DeliveryEngine/([^/]+)/(\S+)\#(\S+) - //depot/DeliveryEngine/([^/]+)/(\S+)\#(\S+) ====}) {
        my ($branch1, $file1, $rev1, $branch2, $file2, $rev2) = ($1, $2, $3, $4, $5, $6);
        die "unhandled case" unless ($file1 eq $file2);

        if ($rev1 eq "none") {
            print "--- /dev/null\n";
        } else {
            print "--- a/$file1\n";
        }

        die "unhandled case" if ($rev2 eq "none");
        print "+++ b/$file2\n";
    } else {
        die "unhandled" if ($line =~ /placeholder for zero-byte text file /);

        print "$line\n";
    }
}
