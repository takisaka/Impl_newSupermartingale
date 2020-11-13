#!/bin/bash

##########################
# This script calls the following variables.
# $1 = a name of parameter .sh file. The .sh file should be at ./parameter
#      It should contain the values of models, martingale, sourceDirectory, inputDirectory and other parameters
# 
# sample commands: "./read_logs.sh delta_ex1_lin"
##########################

. ./env.sh
. parameters/$1.sh

cd $myRoot/
mkdir -p $tableDirectory
OUTPUT=$tableDirectory/$1".csv"


if [[ $template == "poly" ]] ; then
    echo -e "Model,Bound,Time,numerr" > $OUTPUT

    for m in ${models[@]}; do

        echo "extracting data from $m.log..." 

        #extract bound
        lineRead="sol ="
        bound=$(grep -s -A 2 "$lineRead" $outputDirectory/$m.log | tail -1 | tr -d '\r')

        #extract computation time
        lineReadTime="Elapsed time is"
        lineTime=$(grep -s "$lineReadTime" $outputDirectory/$m.log | tail -1)
        time=$(echo "$lineTime" | tr -d " " | cut -d 's' -f 3)

        #extract termination code
        lineReadTerm="termination code"
        lineTerm=$(grep -s "$lineReadTerm" $outputDirectory/$m.log | tail -1)
        term=$(echo "$lineTerm" | tr -d " " | cut -d '=' -f 2)

        echo -e "$m,$bound,$time,$term" >> $OUTPUT
    done

else #if template = lin
    echo -e "Model,Bound,Time - glpk,Time - real,Time - user,Time - sys" > $OUTPUT

    for m in ${models[@]}; do

    echo "extracting data from $m.log..." 

    #extract bound
    lineRead="obj ="
    line=$(grep -s "$lineRead" $outputDirectory/$m.log | tail -1)
    bound=$(echo "$line" | tr -d " " | cut -d '=' -f 2 | cut -d 'i' -f 1)


    #extract computation time
    lineReadGlpkTime="Time used:"
    lineReadReal="real"
    lineReadUser="user"
    lineReadSys="sys"

    lineGlpkTime=$(grep -s "$lineReadGlpkTime" $outputDirectory/$m.log | tail -1)
    lineReal=$(grep -s "$lineReadReal" $outputDirectory/$m.log | tail -1)
    lineUser=$(grep -s "$lineReadUser" $outputDirectory/$m.log | tail -1)
    lineSys=$(grep -s "$lineReadSys" $outputDirectory/$m.log | tail -1)

    glpkTime=$(echo "$lineGlpkTime" | tr -d " " | cut -d ':' -f 2 | cut -d 's' -f 1)
    real=$(echo "$lineReal" | tr -d " " | cut -d 'm' -f 2 | cut -d 's' -f 1)
    user=$(echo "$lineUser" | tr -d " " | cut -d 'm' -f 2 | cut -d 's' -f 1)
    sys=$(echo "$lineSys" | tr -d " " | cut -d 'm' -f 2 | cut -d 's' -f 1)

    #print output
    echo -e "$m,$bound,$glpkTime,$real,$user,$sys" >> $OUTPUT
    done
fi
