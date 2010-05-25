#!/bin/sh

if [[ -e ~/.hudson/jobs && -e ~/src/ckoenig/hudson/conf ]]; then
    for HUDSON_JOB in `ls ~/.hudson/jobs`; do
        CONFIG_FILE=~/.hudson/jobs/$HUDSON_JOB/config.xml
        if [[ -e $CONFIG_FILE ]]; then
            cp $CONFIG_FILE ~/src/ckoenig/hudson/conf/$HUDSON_JOB.config.xml
            [[ $? != 0 ]] && exit 1
        fi
    done
fi

if [[ -e ~/src && -e ~/src/ckoenig/git ]]; then
    for PROJECT in `ls ~/src/`; do
        if [[ -d ~/src/$PROJECT && -e ~/src/$PROJECT/.git/config ]]; then
            cp ~/src/$PROJECT/.git/config ~/src/ckoenig/git/$PROJECT.config
            [[ $? != 0 ]] && exit 1
        fi
    done
fi
