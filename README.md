# TReacLab
Generic coupler for using operators splitting approaches in reactive transport modeling

It is related to : (papers with useful documentation coming soon). 

The idea is to use this software to link different software to solve reactive transport problems with operator splitting approaches. Basically, if you want to use the baisc just focus on the coupler class. Anyway, In order to solve reactive transport problems a whole code is created around the coupler class, and several classes such as "Morphology", "Evaluation", "Solve Engine", "Time" play a role. Please feel free to modify them or to do new ones in order to better fit the purpouse of your work.

Although is not difficult to plug the different software, we recomment to look at the test folder where different benchmarks can be found. Run them, see when they fail, and modify them. Some software have been coupled thinking in an specific method, therefore remember when using the example test than if you modify the method you might also have to modify the solver. 

Usually the solvers are for chemistry and for transport, but you might uses an approach where you have advection reaction in one solver and diffusion in other.

Here it has been used as external software iPhreeqc, PhreeqcRM, COMSOL, FVTool. We do not provide any of these software:

you can find iPhreeqc and PhreeqcRM in https://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc/.

FVTool in https://github.com/simulkade

COMSOL is a comercial software, so if you want it, you pay it. https://www.comsol.com/ and also the languague of this code which is MATLAB www.matlab.com.

The version of MATLAB has been R2013b, for Comsol 4.3b, for PhreeqcRM (3.3.9) and iPhreeqc (3.3.7). Not sure about FVTool sorry.

If any problem please write to TReacLabv1@gmail.com or leavr here a message.
