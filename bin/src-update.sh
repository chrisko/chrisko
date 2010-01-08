#!/bin/sh

for DIR in `ls ~/src`; do
    (cd ~/src/$DIR && git svn fetch &> /dev/null)
done
