#!/bin/sh

ANY_ERRORS=0

for FILE in `find /home/y/lib/perl5/site_perl/Yahoo/ -type f -name "*.pm"`; do
    echo -n "Checking syntax of $FILE..."
    perl -C $FILE
    if [[ $? -eq 0 ]]; then
        echo " [ OK ]"
    else
        ANY_ERRORS=1
    fi
done

exit $ANY_ERRORS
