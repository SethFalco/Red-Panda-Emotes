#!/bin/bash

# Build a giant string that represents the command we want to perform to build all emotes.
# This is done so each input is only loaded once to general all exports.
addcolor() { # COLOR, PREFIX, HUE
    EXPORT_ARG="${EXPORT_ARG} ( +clone -modulate ${2} +clip-mask"

    # When adding a new resolution, just append the output size here.
    for SIZE in 512 258 128 112 72 64 56 36 28 18
    do
        mkdir -p output/${0}/${SIZE}px/
        export_arg="${EXPORT_ARG} ( +clone -resize ${SIZE}X${SIZE} -write output/${0}/${SIZE}px/${1}[EMOTE] +delete )"
    done

    EXPORT_ARG="${EXPORT_ARG} +delete )"
}

exportmontage() { # GLOB, FILENAME
    montage                             \
        -background none                \
        -geometry +2+2                  \
        -tile 8x                        \
    output/${1}                         \
        -gravity north                  \
        -extent 128x144                 \
        -gravity south                  \
        -fill '#0008'                   \
        -draw 'rectangle 0,128,144,144' \
        -fill white                     \
        -pointsize 14                   \
        -font DejaVu-LGC-Sans-Mono      \
        -annotate +0+0 %t               \
    public/${2}.png
}

# Append here for colors (Color | Prefix | Hue)
addcolor "src",    "",  "100,100,100"
addcolor "blue",   "b", "100,100,0"
addcolor "green",  "g", "100,100,166"
addcolor "pink",   "p", "100,100,66.6"
addcolor "red",    "r", "100,90,79"
addcolor "violet", "v", "100,70,50"
addcolor "yellow", "y", "100,115,115"

# Delete the output folders contents if it exists.
if [ -d output/ ]; then rm -rf output/*; fi

# Iterate all emotes and export them in all colors and sizes.
for FILE in emotes/*
do
    EMOTE=${FILE#*emotes/}
    MASK="masks/${EMOTE/\.png/Mask.png}"

    if [ -f ${MASK} ]; then
        MASK_ARG="-clip-mask ${MASK}"
    else
        unset MASK_ARG
    fi

    echo "Exporting: ${FILE}"

    EMOTE_EXPORT_ARG=${EXPORT_ARG//\[EMOTE\]/${EMOTE}}
    magick ${FILE} -filter Catrom ${MASK_ARG} ${EMOTE_EXPORT_ARG} NULL:
done

# Make a public folder, things built here will get published on GitLab pages.
if [ -d public/ ]; then rm -rf public/*; fi
mkdir public

# Zip up all of the exported emotes into the public folder.
zip -rq public/emotes.zip output/ LICENSE

# Create montages by using a glob and name of the montage output
exportmontage "*/128px/*pandaAww.png" "colors"
exportmontage "src/128px/*"           "emotes"
