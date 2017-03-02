The following benchmark have widely been applied to benchmark different reactive transport codes such as PHT3D.
It is drawn from:
---------
Kipp, K.L., Engesgaard, P .A Geochemical Transport Model for Redox-controlled Movement of Mineral Fronts 
in Groundwater Flow Systems: A Case of Nitrate Removal by Oxidation of Pyrite. Water Resources Research, vol. 28, n° 10, pg:- 2829-2843 (1992)
---------

The problem consist in a 1D column, initially, containing calcite mineral is continuously flushed with water that contains magnesium chlorine. 
The movement of the water front dissolves calcite and creates dolomite temporarily.

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

The file NAPSI_290502(260802).dat is the database that will be used by Phreeqc.

---------

The file List_IdentifiersporsatRV.txt serves to define the components that will be saved into the Arrray_Field class. The user must known the 
components of the system and which are important for the simulation. 

In our problem the components in the solution are C, Ca, Cl, Mg which would be called master species in Phreeqc. Furthermore, in order to use 
the Solution_Modify datablock required by Phreeqc and provided by the class "Phreeqc_Batch_Seq" the total O, H, H2O and cb (charge balance) must 
be also provided and categorised inside the list_solution_elements.

Besides, there are two minerals Calcite and Dolomite which should be placed in list_precipitation_dissolution_elements. 

There are not gaseous elements since the problem is completely saturated, there are not species related to ion exchange, and there are not kinetic 
reactions. Consequently all these list will be left empty.

The hydraulic properties: 'porosity' 'liquid_saturation' 'RV' 'volumetricwatercontent' are required for the coupling approach using phreeqc. Since
it is based on the article:

Parkhurst, D.L., Wissmeier, L.'PhreeqcRM: A reaction module for transport simulators based on the geochemical model PHREEQC' Advances in Water 
Resources, vol. 83, pg:- 176-189 (2015)

The list_data_chem correspond to interesting and useful data such as vol_sol (solution volume) that are drawn from Phreeqc.


All the components (for these case) in the file List_IdentifiersporsatRV.txt should be in the selected_output and/or user_punch datablock, except 
the components that have been defined in the list_hydraulic_properties.


-----------------------------------------------------------------------------------------------------------------------------------------------

As follows, we recommend to peek the ExplicitT_SNIA_CalciteDissolution_Bench.m file.
