#!/bin/bash

model=gemma
URL=http://localhost:8040/eval/ml/similarity/llm
mkdir -p results/llm/$model
echo "concept_size,run,time" > results/llm/$model/results.csv
for N in 1 5 10 20 30 40 50
do
    curl -s -X POST $URL \
        -H "Content-Type: application/json" \
        -d "@data/concepts/concepts-1.json" > /dev/null
    echo "warm-up request done"

    for RUN in 1 2 3 4 5
    do
        START=$(date +%s%N)

        curl -s -X POST $URL \
            -H "Content-Type: application/json" \
            -d "@data/concepts/concepts-$N.json" > results/llm/$model/concepts-$N-$RUN.json 

        END=$(date +%s%N)
        ELAPSED=$(awk "BEGIN {printf \"%.3f\", ($END - $START) / 1000000000}")
        echo "$N,$RUN,$ELAPSED"
        echo "$N,$RUN,$ELAPSED" >> results/llm/$model/results.csv
    done
done
