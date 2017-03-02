The following benchmark have widely been applied to benchmark different reactive transport codes such as PHREEQC.
It is drawn from example 11 (Transport and Cation Exchange) of the manual:
---------
Parkhurst, D.L., Appelo C.A.J. Description of Input and Examples for PHREEQC Version 3 – A Computer Program for Speciation, Batch-Reaction, 
One – Dimensional Transport, and Inverse Geochemical Calculations. U.S. Geological Survey Techniques and Methods 6–A43 (2013)
---------

The 1D column contains a sodium-potassium-nitrate solution in equilibrium with the exchanger. A continuously flush of an aqueous solution made up 
of calcium chloride is inputted. Calcium, potassium and sodium will react with the exchanger to reach an equilibrium

-----------------------------------------------------------------------------------------------------------------------------------------------

The reactive transport problem will be solved using an explicit time and sequential non iterative approach. Such approach solve the problem sequentially
calling the transport solver and chemistry solver for each time step. 

The transport solver will be the class "TransportSolver_SNIA_Expl" (it uses a modified pdepe of Matlab) and the chemistry solver will be the class
"Phreeqc_Batch_Seq" which requires the setup of the iphreeqc COM server 

(for more info look into the m. file of the commented classes)

-----------------------------------------------------------------------------------------------------------------------------------------------

The file BWC.txt serves to get the boundary conditions for the solution in the input, since they are constant values for these case. The file has 
a Phreeqc format with three data block: 'Solution', 'Selected_Output', and 'User_Punch'. The 'Solution' data block defines the solution and the
other two datablocks ('Selected_Output', and 'User_Punch') serve to retrieve valuable information for the simulation.

The file IWC.txt serves to get the initial values of the solution at each cell of the domain. It also have a Phreeqc format, the 'Solution' and
'Equilibrium_phases' define the cell and 'Selected_Output', and 'User_Punch' retrieve valuable information after the batch reaction.

The file phreeqc.dat is the database that will be used by Phreeqc.

---------

The file List_IdentifiersporsatRV.txt serves to define the components that will be saved into the Arrray_Field class. The user must known the 
components of the system and which are important for the simulation. 

In our problem the components in the solution are Ca Cl Na N K which would be called master species in Phreeqc. Furthermore, in order to use 
the Solution_Modify datablock required by Phreeqc and provided by the class "Phreeqc_Batch_Seq" the total O, H, H2O and cb (charge balance) must 
be also provided and categorised inside the list_solution_elements.

There are not gaseous elements since the problem is completely saturated, there are not species related to list_precipitation_dissolution_elements, 
and there are not kinetic reactions. Consequently all these list will be left empty.

The hydraulic properties: 'porosity' 'liquid_saturation' 'RV' 'volumetricwatercontent' are required for the coupling approach using phreeqc. Since
it is based on the article:

Parkhurst, D.L., Wissmeier, L.'PhreeqcRM: A reaction module for transport simulators based on the geochemical model PHREEQC' Advances in Water 
Resources, vol. 83, pg:- 176-189 (2015)

The list_data_chem correspond to interesting and useful data such as vol_sol (solution volume) that are drawn from Phreeqc.

Although there are some components in list_ionexchange_elements CaX2 KX NaX NH4X. They can also be called placed in list_data_chem, like we do here.

All the components (for these case) in the file List_IdentifiersporsatRV.txt should be in the selected_output and/or user_punch datablock, except 
the components that have been defined in the list_hydraulic_properties.


-----------------------------------------------------------------------------------------------------------------------------------------------

As follows, we recommend to peek the Explicit_SNIA_CationExchange_Bench.m file.
