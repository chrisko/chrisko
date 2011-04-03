#!/bin/sh

if [[ -e ~/.jenkins/jobs && -e ~/src/ckoenig/jenkins/conf ]]; then
    for JENKINS_JOB in `ls ~/.jenkins/jobs`; do
        CONFIG_FILE=~/.jenkins/jobs/$JENKINS_JOB/config.xml
        if [[ -e $CONFIG_FILE ]]; then
            cp $CONFIG_FILE ~/src/ckoenig/jenkins/conf/$JENKINS_JOB.config.xml
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
