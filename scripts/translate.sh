#!/bin/bash

##########################
# This script calls the following variables, and should be called by run_benchmark.sh.
#
# $1 = pp file name
# $2 = Martingale
# $3 = pp file directory (relative to $myRoot)
# $4 = output directory (relative to $myRoot)
# $5~ = options (see the code below)
##########################

#Environment
if [[ $2 == "gammaSclSubM" ]] ; then
  codeName="main_gammaSclSubM"
elif [[ $2 == "deltaNNRepSupM" ]] ; then
  codeName="main_deltaNNRepSupM"
elif [[ $2 == "epsilonRepSupM" ]] ; then
  codeName="main_epsilonRepSupM"
fi

martingaleName="$2"
codeDirectory="code/$martingaleName"

#Execution
if [[ $2 == "gammaSclSubM" ]] ; then
  #$5 = gamma
  $codeDirectory/$codeName $3/$1.pp -lin -gamma $5 -o $4/$1.mod

elif [[ $2 == "deltaNNRepSupM" ]] ; then
  #$5 = template, $6 = deg. of polynomial (only used when $5 = poly)
  if [[ $5 == "lin" ]] ; then
    $codeDirectory/$codeName $3/$1.pp -lin -delta 0 -o $4/$1.mod
  elif [[ $5 == "poly" ]] ; then
    $codeDirectory/$codeName $3/$1.pp -poly -deg $6 -delta 0 -solver SDPT3 -o $4/$1_SL.m   #"_SL" is added to avoid error in Matlab
  fi

elif [[ $2 == "epsilonRepSupM" ]] ; then
  if [[ $6 == "min" ]] ; then
    #$5 = epsilon
    $codeDirectory/$codeName $3/$1.pp -epsilon $5 -kappamin -o $4/$1-kappa.mod > /dev/null
  else
    #$5 = epsilon, $6 = kappa
    $codeDirectory/$codeName $3/$1.pp -epsilon $5 -kappa $6 -o $4/$1.mod > /dev/null
  fi
fi