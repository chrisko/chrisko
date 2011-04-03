#!/bin/sh
[[ -z $1 ]] && { echo "DPK file required as an argument."; exit 1; }
FNAME=`cygpath -m $1`
sdpack.bat diff -du "$FNAME" | ~/src/ckoenig/bin/sd_diff_to_git_diff.pl
