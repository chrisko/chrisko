#!/bin/bash

DAISYS_DESKTOP=dd01.sp1.yahoo.com
DATE=`date +"%Y%m%d"`
COLOS="ac2,sk1"

# Use today's noon log only if it's after 2pm:
if [ `date +"%H"` -gt 14 ]; then
    NOON_OR_MIDNIGHT="12"
else
    NOON_OR_MIDNIGHT="01"
fi

DD_DIRECTORY="/mnt/dd_data/rawlogs/$DATE$NOON_OR_MIDNIGHT/affiliate_production"

# The following commands do the following:
    # Stream the gzipped logs in their compressed form
    # Decompress them
    # Extract the URI part, adding a dummy hostname
    # Parse the URI query string, printing the value of the 'Keywords' parameter
    # Remove any empty lines
    # Uniq the queries in-place, without sorting
    # Make sure the output encoding is always utf8
#ssh $DAISYS_DESKTOP "cat $DD_DIRECTORY/access.*.{$COLOS}.yahoo.com.*.gz" \
ssh $DAISYS_DESKTOP "cat $DD_DIRECTORY/access.*.{$COLOS}.yahoo.com.*.gz" \
    | zcat \
    | perl -ne "/GET (.+?) HTTP/ or next; print \"http://affiliate\$1\n\";" \
    | perl -ne "use URI; use URI::QueryParam; chomp; my \$u = URI->new(\$_); print \$u->query_param('Keywords') . \"\n\";" \
    | perl -ne "print if /\S/;" \
    | perl -e "my %queries = (); while (<>){ print "\$_" unless (exists \$queries{\$_}); \$queries{\$_} ||= 1; }" \
    | perl -ne "binmode(STDIN, ':utf8'); binmode(STDOUT, ':utf8'); print;"

# List DD access logs:
#ssh $DAISYS_DESKTOP "ls /mnt/dd_data/rawlogs/$DATE$NOON_OR_MIDNIGHT/affiliate_production/access.*.{$COLOS}.yahoo.com.*.gz"
