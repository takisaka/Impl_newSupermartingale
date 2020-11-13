#models = the list of names of .pp files in sourceDirectory.
models=( a_1_1 a_1_2 a_2_1 a_2_2 a_3_1 a_3_2 b_1 b_2 )

#martingale = martingale technique to be used. 
#choose from: gammaSclSubM, deltaNNRepSupM, epsilonRepSupM  
martingale="gammaSclSubM"

#sourceDirectory = the directory where .pp files are located. 
sourceDirectory="models/PP/Experiment2"

#inputDirectory = the directory where a solver-ready translation of .pp files will be located. 
inputDirectory="models/solverReady/Experiment2/"$martingale"_tight"

#outputDirectory = the directory where the log files of solver execution will be located.
outputDirectory="outputFiles/Experiment2/"$martingale"_tight"

#tableDirectory = the directory where a summary of the log files will be located.
tableDirectory="tables"

#optional parameters.
#
#gamma = the gamma parameter. required when:  martingale="gammaSclSubM"
#template = the template of martingale. required when:  martingale="deltaNNRepSupM";  choose from: lin, poly
#deg = the maximal degree of martingale. required when:  martingale="deltaNNRepSupM" and template="poly"
#epsilon = the epsilon parameter. requred when:  martingale="epsilonRepSupM"
#kappa = the kappa parameter. requred when:  martingale="epsilonRepSupM"
gamma=0.999999