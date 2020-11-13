#models = the list of names of .pp files in sourceDirectory.
models=( aaron2 ax complex counterex1c cousot9 easy1 easy2 exmini loops nd_loop ndecr nestedLoop perfect random1d random2d relation1 rsd sipma91 speedFails4 speedpldi2 speedpldi3 speedpldi4 terminate wcet1 wcet2 while2 wise )

#martingale = martingale technique to be used. 
#choose from: gammaSclSubM, deltaNNRepSupM, epsilonRepSupM  
martingale="gammaSclSubM"

#sourceDirectory = the directory where .pp files are located. 
sourceDirectory="models/PP/Experiment1/$martingale"

#inputDirectory = the directory where a solver-ready translation of .pp files will be located. 
inputDirectory="models/solverReady/Experiment1/"$martingale"_loose"

#outputDirectory = the directory where the log files of solver execution will be located.
outputDirectory="outputFiles/Experiment1/"$martingale"_loose"

#tableDirectory = the directory where a summary of the log files will be located.
tableDirectory="tables"

#optional parameters.
#
#gamma = the gamma parameter. required when:  martingale="gammaSclSubM"
#template = the template of martingale. required when:  martingale="deltaNNRepSupM";  choose from: lin, poly
#deg = the maximal degree of martingale. required when:  martingale="deltaNNRepSupM" and template="poly"
#epsilon = the epsilon parameter. requred when:  martingale="epsilonRepSupM"
#kappa = the kappa parameter. requred when:  martingale="epsilonRepSupM"
gamma=0.999