#!/bin/bash

SRCd="training/"
DSTd="$SRCd""apart/"

while read p; do
    p_arr=($p)
    if [ "${p_arr[0]}" == "0" ]; then
	cp "$SRCd""${p_arr[1]}" "$DSTd""spam/"
    else
	cp "$SRCd""${p_arr[1]}" "$DSTd""ham/"
    fi
done <SPAMTrain.label
