#!/bin/bash
if [ -d output/ ]; then rm -rf output/*; fi

# Append here for colors (Color | Prefix | Hue)
declare -A colors
colors[0,0]="red";    colors[0,1]="";  colors[0,2]="100,100,100";
colors[1,0]="blue";   colors[1,1]="b"; colors[1,2]="100,100,0";
colors[2,0]="green";  colors[2,1]="g"; colors[2,2]="100,100,166";
colors[3,0]="pink";   colors[3,1]="p"; colors[3,2]="100,100,66.6";
colors[4,0]="violet"; colors[4,1]="v"; colors[4,2]="100,70,50";
colors[5,0]="yellow"; colors[5,1]="y"; colors[5,2]="100,115,115";

for c in 0 1 2 3 4 5
do
    export_arg="${export_arg} ( +clone -modulate ${colors[${c},2]} +clip-mask"

    # When adding a new resolution, just append the output size here.
    for size in 512 258 128 112 72 64 56 36 28 18
    do
        mkdir -p output/${colors[${c},0]}/${size}px/
        export_arg="${export_arg} ( +clone -resize ${size}X${size} -write output/${colors[${c},0]}/${size}px/${colors[${c},1]}[EMOTE] +delete )"
    done

    export_arg="${export_arg} +delete )"
done

for file in emotes/*
do
    emote=${file#*emotes/}
    mask="masks/${emote/\.png/Mask.png}"

    if [ -f ${mask} ]; then
        mask_arg="-clip-mask ${mask}"
    else
        unset mask_arg
    fi

    echo "Exporting: ${file}"

    emote_export_arg=${export_arg//\[EMOTE\]/${emote}}
    magick ${file} -filter Catrom ${mask_arg} ${emote_export_arg} NULL:
done
