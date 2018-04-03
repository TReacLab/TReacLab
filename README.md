# TReacLab
Generic coupler for using operators splitting approaches in reactive transport modeling

It is related to : 
https://www.sciencedirect.com/science/article/pii/S0098300417302510

https://tel.archives-ouvertes.fr/tel-01661536/document

The classical startup.m file is found in Source folder.



The software is used to link different software to solve reactive transport problems applying operator splitting approaches. 

Principally, if you want to use the basic just focus on the "Coupler" class. Anyway, in order to solve reactive transport problems a whole code is created around the "Coupler" class, and several classes such as "Morphology", "Evaluation", "Solve Engine", or "Time" play a role. Please feel free to modify them or to do new classes in order to fit better your purposes.

Although, it is not difficult to plug different software, we recommend to look at the test folder where some benchmarks can be found. Run them, see when they fail, and modify them. Some software have been coupled thinking in a specific method, therefore remember when using the example test than if you modify the method you might also have to modify the solver. 

Usually the solvers are for chemistry and for transport, but you might uses an approach where you have advection reaction in one solver and diffusion in other.

Here it has been used as external software iPhreeqc, PhreeqcRM, COMSOL, and FVTool. We do not provide any of these software:

you can find iPhreeqc and PhreeqcRM in https://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc/.

FVTool in https://github.com/simulkade

COMSOL is a comercial software, so if you want it, you should buy it: https://www.comsol.com/, and also the languague of this code which is MATLAB www.matlab.com. I have heard about other options such as Octave, and Scilab but I do not know if they will work with object-oriented programming.

The used version of MATLAB is R2013b, for Comsol is 4.3b, for PhreeqcRM is (v3.3.9) and iPhreeqc is (v3.3.7). Not sure about FVTool sorry.

If any problem please write to TReacLabv1@gmail.com or leave here a message.
