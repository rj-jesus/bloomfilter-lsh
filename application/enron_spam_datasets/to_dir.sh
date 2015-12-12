#!/bin/bash

if [ $# -ne 1 ]; then
    echo $0": Expecting 1 argument."
    exit 1
fi

n=1

find "$1" -type f -name "*.txt" | while read -r file;
do 
    n_file=$(printf "%05d.txt" "$n")
    mv "$file" "$1""$n_file"
    ((n++))
done
