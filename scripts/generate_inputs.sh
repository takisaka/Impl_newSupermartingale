#!/bin/bash

##########################
# This script calls the following variables.
# $1 = a name of parameter .sh file. The .sh file should be at ./parameter
#      It should contain the values of models, martingale, sourceDirectory, inputDirectory and other parameters
# 
# sample commands: "./generate_inputs.sh delta_ex1_lin"
##########################

. ./env.sh
. parameters/$1.sh

cd $myRoot/
mkdir -p $inputDirectory

if [[ $martingale == "gammaSclSubM" ]] ; then
    for m in ${models[@]}; do
        echo "translating "$m".pp..."
        scripts/translate.sh $m $martingale $sourceDirectory $inputDirectory $gamma 
    done

elif [[ $martingale == "deltaNNRepSupM" ]] ; then
    for m in ${models[@]}; do
        echo "translating "$m".pp..."
        if [[ $template == "lin" ]] ; then
            scripts/translate.sh $m $martingale $sourceDirectory $inputDirectory $template
        elif [[ $template == "poly" ]] ; then
            scripts/translate.sh $m $martingale $sourceDirectory $inputDirectory $template $deg
        fi
    done

elif [[ $martingale == "epsilonRepSupM" ]] ; then
    for m in ${models[@]}; do
        echo "translating "$m".pp..."
        scripts/translate.sh $m $martingale $sourceDirectory $inputDirectory $epsilon $kappa 
    done
fi
