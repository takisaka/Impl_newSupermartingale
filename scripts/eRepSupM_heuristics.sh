#!/bin/bash

##########################
#**This script is exclusively for the heuristic EpsilonRepSupM synthesis in [Chatterjee+, POPL'17]. 
#  Use with the following conditions in parameter .sh file:
#    1) martingale = epsilonRepSupM
#    2) do not declare kappa
##########################

##########################
# This script calls the following variables.
# $1 = a name of parameter .sh file. The .sh file should be at ./parameter
#      It should contain the values of models, martingale, sourceDirectory, inputDirectory and other parameters
# 
# sample commands: "./eRepSupM_heuristics.sh epsilon_ex3_heur"
##########################

. ./env.sh
. parameters/$1.sh

cd $myRoot/
mkdir -p $inputDirectory
mkdir -p $outputDirectory
mkdir -p $tableDirectory

#Number of iteration
N=1000

for m in ${models[@]}; do

  OUTPUT=$tableDirectory/$m"_epsilon_heur.csv"
  echo -e "Kappa,Obj,Bound,Time - glpk,Time - real,Time - user,Time - sys" > $OUTPUT


  ### generate kappa_0, an initial kappa
  echo "finding an initial kappa for $m.pp..."

  #  generate input .mod file to generate kappa_0
  scripts/translate.sh $m "epsilonRepSupM" $sourceDirectory $inputDirectory $epsilon "min"
  
  #  run the solver to find kappa_0
  (time glpsol -m $inputDirectory/$m-kappa.mod) > $outputDirectory/$m-kappa.log 2>&1


  # go to next model if the solver fails to find kappa_0
  INFEAS1=$(grep -s "LP HAS NO PRIMAL FEASIBLE SOLUTION" $outputDirectory/$m-kappa.log | tail -1)
  INFEAS2=$(grep -s "PROBLEM HAS NO PRIMAL FEASIBLE SOLUTION" $outputDirectory/$m-kappa.log | tail -1)
  if [[ $INFEAS1 != "" || $INFEAS2 != "" ]] ; then
    echo "couldn't find an initial kappa, move to the next model."
    continue  
  fi


### an Old INFEAS decider. This does not work correctly when 
### glpk aborts due to "unable to recover undefined or non-optimal solution"
#
# lineKappa=$(grep -s "obj =" $outputDirectory/$m-kappa.log | tail -1)
#  if [[ $lineKappa == "" ]] ; then
#    echo "couldn't find initial kappa, move to the next model."
#    continue
#  fi


  # extract initial kappa
  lineKappa=$(grep -s "obj =" $outputDirectory/$m-kappa.log | tail -1)
  rawobjKappa=$(echo "$lineKappa" | tr -d " " | cut -d '=' -f 2 | cut -d 'i' -f 1)
  obj1Kappa=$(echo "$rawobjKappa" |cut -d 'e' -f 1)
  obj2Kappa=$(echo "$rawobjKappa" |cut -d '+' -f 2)
  kappa_0=$(echo "$obj1Kappa*10^$obj2Kappa" | bc -l | cut -d '.' -f 1) 
  echo "initial kappa found, kappa_0=$kappa_0"


  ###heuristics phase
  kappa_f=`expr $kappa_0 + $N`
  for kappa in `seq $kappa_0 $kappa_f`; do
    echo "kappa = $kappa"
  
    #generate_input
    echo "translating "$m".pp..."
    scripts/translate.sh $m $martingale $sourceDirectory $inputDirectory $epsilon $kappa 

    #run_benchmarks
    echo "synthesizing linear epsilonRepSupM for model "$m"..."
    (time glpsol -m $inputDirectory/$m.mod) > $outputDirectory/$m.log 2>&1

    #read_logs
    echo "extracting data from $m.log..." 

    #extract obj (the output of optimization)
    lineRead="obj ="

    line=$(grep -s "$lineRead" $outputDirectory/$m.log | tail -1)

    rawobj=$(echo "$line" | tr -d " " | cut -d '=' -f 2 | cut -d 'i' -f 1)
    obj1=$(echo "$rawobj" |cut -d 'e' -f 1)
    obj2=$(echo "$rawobj" |cut -d '+' -f 2)
    obj=$(echo "$obj1*10^$obj2" | bc -l)

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

    
    #compute bound from obj
    gamma=$(echo "e(-1*$epsilon^2/(2*($epsilon+$kappa)^2))" | bc -l)
    #echo "gamma = $gamma"

    alpha=$(echo "e($epsilon*$obj/(($epsilon+$kappa)^2))" | bc -l)
    #echo "alpha = $alpha"

    absceil=$(echo "scale=0;sqrt($obj^2)/$kappa+1" | bc -l)
    #echo "absceil = $absceil"

    bound=$(echo "$alpha*$gamma^$absceil/(1-$gamma)" | bc -l)
    #echo "bound = $bound"


    #print output
    echo -e "$kappa,$obj,$bound,$glpkTime,$real,$user,$sys" >> $OUTPUT
  done

done