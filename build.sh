#!/bin/bash

name=laser-sight

acc source/$name.acs acs/$name.o \
&& \
rm -f $name.pk3 \
&& \
zip $name.pk3 \
    acs/$name.o \
    source/*.acs \
    sprites/*.png \
    sprites/*.lmp \
    zscript/*.txt \
    *.md \
    *.txt \
    textures.blue \
    textures.green \
    textures.icons \
    textures.txt \
&& \
gzdoom -glversion 3 \
       \ #-iwad ~/Programs/Games/wads/doom/freedoom1.wad \
       -file \
       $name.pk3 \
       ~/Programs/Games/wads/maps/DOOMTEST.wad \
       "$1" "$2" \
       +map test \
       -nomonsters

       #-iwad ~/Programs/Games/wads/doom/HERETIC.WAD \
