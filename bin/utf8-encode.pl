#!/usr/local/bin/perl
use strict;
use warnings;

use Encode ();
while (<>) {
    Encode::encode_utf8($_);
    print;
}
