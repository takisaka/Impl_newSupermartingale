#!/bin/bash

##########################
# This script calls the following variables.
# $1 = a name of parameter .sh file. The .sh file should be at ./parameter
#      It should contain the values of models, martingale, sourceDirectory, inputDirectory and other parameters
# 
# sample commands: "./run_benchmarks.sh delta_ex1_lin"
##########################

. ./env.sh
. parameters/$1.sh

cd $myRoot/
mkdir -p $outputDirectory

if [[ $martingale == "gammaSclSubM" ]] ; then
    for m in ${models[@]}; do
        echo "synthesizing linear gammaSclSubM for model "$m"..."
        (time glpsol -m $inputDirectory/$m.mod) > $outputDirectory/$m.log 2>&1
    done

elif [[ $martingale == "deltaNNRepSupM" ]] ; then
    for m in ${models[@]}; do
        if [[ $template == "lin" ]] ; then
            echo "synthesizing linear deltaNNRepSupM for model "$m"..."
            (time glpsol -m $inputDirectory/$m.mod) > $outputDirectory/$m.log 2>&1
        elif [[ $template == "poly" ]] ; then
            echo "synthesizing polynomial deltaNNRepSupM for model "$m"..."
            m_SL=$m"_SL"
            rm $outputDirectory/$m.log  #erase the old log, the diary function of matlab appends the current log to the old one.
            matlab -nojvm -nodisplay -nosplash -r "addpath(genpath('$myRootMatlab/code/matlab'), genpath('$myRootMatlab/$inputDirectory')); cd $myRootMatlab/$outputDirectory; diary $m.log; tic; $m_SL; toc; diary off; exit"
            sleep 120 #ad hoc way to execute matlab sequentially
        fi
    done

elif [[ $martingale == "epsilonRepSupM" ]] ; then
    for m in ${models[@]}; do
        echo "synthesizing linear epsilonRepSupM for model "$m"..."
        (time glpsol -m $inputDirectory/$m.mod) > $outputDirectory/$m.log 2>&1
    done
fi