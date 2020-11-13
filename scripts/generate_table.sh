#!/bin/bash

##########################
# This script calls the following variables.
# $1: specify the paramater set in script/paremters/ 
#     or use "all" to execute exhaustive synthesis appears in the paper
# sample commands: "./generate_table.sh gamma_ex1_loose", "./generate_table.sh all"
##########################

#exhaustive execution
if [[ $1 == "all" ]] ; then

#linear template synthesis
for expNum in 1 2 3 ; do
    for mt in  delta gamma epsilon; do
        if [[ $mt == "delta" ]] ; then
            echo "==START: "$mt"_ex"$expNum"_lin=="
            ./generate_inputs.sh $mt"_ex"$expNum"_lin"
            ./run_benchmarks.sh $mt"_ex"$expNum"_lin"
            ./read_logs.sh $mt"_ex"$expNum"_lin"

        elif [[ $mt == "gamma" ]] ; then
            if [[ $expNum == 1 || $expNum == 2 ]] ; then
                for labelG in  loose tight ; do
                    echo "==START: "$mt"_ex"$expNum"_"$labelG"=="
                    ./generate_inputs.sh $mt"_ex"$expNum"_"$labelG
                    ./run_benchmarks.sh $mt"_ex"$expNum"_"$labelG
                    ./read_logs.sh $mt"_ex"$expNum"_"$labelG
                done
            fi

        elif [[ $mt == "epsilon" ]] ; then
            if [[ $expNum == 3 ]] ; then
                echo "==START: "$mt"_ex"$expNum"_heur=="
                ./eRepSupM_heuristics.sh $mt"_ex"$expNum"_heur"
            fi    
        fi
    done
done

#polynomial template synthesis
for deg in 2 4 ; do
    echo "==START: delta_ex3_poly"$deg"=="
    ./generate_inputs.sh "delta_ex3_poly"$deg
    ./run_benchmarks.sh "delta_ex3_poly"$deg
    ./read_logs.sh "delta_ex3_poly"$deg
done


#execution with a single parameter file
else
    ./generate_inputs.sh $1
    ./run_benchmarks.sh $1
    ./read_logs.sh $1
fi