#!/bin/bash


for i in 1 5 10 20 30 40 50
do
    output="concepts-$i.json"
    content=`cat concepts-$i.txt | awk '{ print "[\"" $3 $4 "\"]," }' | sed 's/,/","/'`

    echo "{\"concepts\": [" > $output
    echo $content | sed 's/,$//' >> $output
    echo "]}" >> $output

    cat $output | jq > tmp.json

    mv tmp.json $output
done
