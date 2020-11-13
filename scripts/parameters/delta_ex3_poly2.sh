#models = the list of names of .pp files in sourceDirectory.
models=( c_1_1 c_1_2 c_1_3 c_2_1 c_2_2 c_2_3 c_3 c_4 c_5 )

#martingale = martingale technique to be used. 
#choose from: gammaSclSubM, deltaNNRepSupM, epsilonRepSupM  
martingale="deltaNNRepSupM"

#sourceDirectory = the directory where .pp files are located. 
sourceDirectory="models/PP/Experiment3"

#inputDirectory = the directory where a solver-ready translation of .pp files will be located. 
inputDirectory="models/solverReady/Experiment3/"$martingale"_poly2"

#outputDirectory = the directory where the log files of solver execution will be located.
outputDirectory="outputFiles/Experiment3/"$martingale"_poly2"

#tableDirectory = the directory where a summary of the log files will be located.
tableDirectory="tables"

#optional parameters.
#
#gamma = the gamma parameter. required when:  martingale="gammaSclSubM"
#template = the template of martingale. required when:  martingale="deltaNNRepSupM";  choose from: lin, poly
#deg = the maximal degree of martingale. required when:  martingale="deltaNNRepSupM" and template="poly"
#epsilon = the epsilon parameter. requred when:  martingale="epsilonRepSupM"
#kappa = the kappa parameter. requred when:  martingale="epsilonRepSupM"
template="poly"
deg=2