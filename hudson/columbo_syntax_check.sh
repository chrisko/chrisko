#!/bin/sh

SRC_DIRECTORY="/home/y/lib/perl5/site_perl/Yahoo/"
if [[ "$1" = "src" ]]; then
    SRC_DIRECTORY="/home/ckoenig/src/columbo/src/perl/Yahoo/"
fi

ANY_ERRORS=0
for FILE in `find $SRC_DIRECTORY -type f -name "*.pm"`; do
    perl -Xc $FILE
    if [[ $? -ne 0 ]]; then
        WRONG_FILES="$WRONG_FILES $FILE"
        ANY_ERRORS=1
    fi
done

if [[ "$ANY_ERRORS" = "1" ]]; then
    echo
    echo "Syntax check failed:"
    for FILE in $WRONG_FILES; do
        echo "  $FILE"
    done
fi

exit $ANY_ERRORS
