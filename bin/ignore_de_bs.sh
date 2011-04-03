#!/bin/zsh

if [[ -e ~/src/de_ss ]]; then
    for DIR in public private/boost private/Pegasus/src/External/apsdk; do
        (cd ~/src/de_ss/$DIR && git ls-files -z | xargs -0 git update-index --assume-unchanged)
    done
fi
