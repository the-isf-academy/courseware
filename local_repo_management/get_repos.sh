#!/bin/bash
FRONT_URL="https://github.com/the-isf-academy/"
LAB_PREFIX="$2_"
BACK_URL=".git"
FOLDER="./~/Desktop/"
mkdir projects
grep . $1 | while read LINE ; do 
    #Strip new line from LINE
    # echo "$FRONT_URL$LAB_PREFIX${LINE//[$'\t\r\n ']}$BACK_URL" $FOLDER$LAB_PREFIX${LINE//[$'\t\r\n ']}
    cd projects
    git clone "$FRONT_URL$LAB_PREFIX${LINE//[$'\t\r\n ']}$BACK_URL"
    cd ..
done
