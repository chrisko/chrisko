#!/bin/sh

for NUM in `seq 0 9`; do
    setterm -term linux -blank 0 > /dev/tty$NUM 2> /dev/null
    setterm -term linux -blank 0 > /dev/pts$NUM 2> /dev/null
    setterm -term linux -powersave off > /dev/tty$NUM 2> /dev/null
    setterm -term linux -powersave off > /dev/pts$NUM 2> /dev/null
    setterm -term linux -powerdown 0 > /dev/tty$NUM 2> /dev/null
    setterm -term linux -powerdown 0 > /dev/pts$NUM 2> /dev/null
done
