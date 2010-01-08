#!/usr/local/bin/perl

use strict;
use warnings;

use URI::Escape;

while (<>) {
    chomp;
    print uri_escape($_) . "\n";
}
