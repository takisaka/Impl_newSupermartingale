. ./env.sh

code=( deltaNNRepSupM epsilonRepSupM gammaSclSubM )
for m in ${code[@]}; do
    cd $myRoot/code/$m
    make
done