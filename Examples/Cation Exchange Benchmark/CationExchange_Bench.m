% The following script copes a reactive transport problem stated by
% Parkhurst, D.L., Appelo C.A.J.(2013). The Problem is solved using a SNIA
% approach. 

% Run the file to get a workspace with the results.

function CationExchange_Bench
%% Parameters
% The coupling method to be solved by the solver is chosen. We selected a
% Sequential approach first Transport and then Chemistry. Other
% approaches can be run. To do so, you can interchange the solvers of the
% List_Equations_SolveEngine variable or you can chose another approaches
% looking at the abstract Coupler class m.file.
% coupling_methods_list=Coupler.Sequential_12 ();
% coupling_methods_list={'SIA_TC'};
% coupling_methods_list={'SIA_CC'};
coupling_methods_list= { 'Additive_method', 'Sequential_12','AlternatingOS', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% The parameters related to the time class. (simulation time)
dt=360;                                  % OS discretization time
n_iterations=200;                       % loop iterations
initial_time=0;
final_time=n_iterations*dt;

% Boundary condition parameters
inputnode_type='inflow';
outputnode_type='flux';

% Parameters related to Phreeqc
database='phreeqc.dat';                 % Name of the database
txt_inflow='BWC.txt';                   % Name of the text file that will be use to get the input constant values
txt='IWC.txt';                          % Name of the file uses to get initial conditions of the system and to be used by the iphreeqc class

txt_rt='PhreeqcBatchseq.txt';           % Name of the text file that will be use by the solver that uses the software Phreeqc without coupling

% Morphology parameters
n_rows1=1;
n_rows2=40;                             % number of rows
Length=0.08;                            % 0.08 meters
dx=Length/n_rows2;                      % mesh = 0.002m, the distance of the first and last node is 0.001m. Therefore, 50 cells is equivalent to 42 nodes in our coupling.

% Transport Physical par.
velocity_x=(0.002/720);                 %(m/s)
Dispersivity_x=0.002;                   %(m)
molecular_diffusion=0;                  % m2/s 

% Solid properties class (porosity must be a vector)
porosity=1;                             % dimensionless. Since we compare our results with the results obtained by the transport solver of Phreeqc. We state a porosity
                                        % of 1, leaving the system as a column of water.
vector_porosity=porosity*ones(n_rows2+2, 1);
liquid_saturation=1;
vector_liquid_saturation=liquid_saturation*ones(n_rows2+2, 1);

% Rv
representative_volume=1;
vector_representative_volume=representative_volume*ones(n_rows2+2, 1);

% volumetircwatercontent
vector_volumetricwatercontent=representative_volume.*porosity.*liquid_saturation.*ones(n_rows2+2, 1);

Array_hydraulic_properties=[vector_porosity vector_liquid_saturation vector_representative_volume vector_volumetricwatercontent];

%% Solid Properties class
S_P = Solid_Properties (porosity);

%% Transport_Physical_Parameters class
Transport_Physical_Parameter= Transport_Physical_Parameters(velocity_x, Dispersivity_x,molecular_diffusion, 0,0);
Transport_Physical_Parameter= Transport_Physical_Parameter.Set_Solid_Properties(S_P );

%% Master_Phreeqc class through reading text file 
Li = Create_List_Identifier_Class_From_Text ('List_IdentifiersporsatRV.txt');   % The function Create_List_Identifier_Class_From_Text, creates a list identifiers class when the given file (string name)
                                                                                % has the same format than List_IdentifiersporsatRV.txt
%% Morphology class
Morpho=Morphology_1D (Length, dx);

%% Concentration class
% The following 3 lines create the Array_Field class through the iphreeqc class which creates concentrations classes. The first node is just the boundary conditions therefore the
% function Create_Array_Field_From_Phreeqc_File uses the txt_inflow. Furthermore, it calls n_row1 which has the value of 1, this is the number of nodes in system and rows in the array of
% the Array_Field class.
c1 = Create_Array_Field_From_Phreeqc_File (database,txt_inflow, n_rows1, Li, Array_hydraulic_properties(1,:) );
c2 = Create_Array_Field_From_Phreeqc_File  (database,txt, n_rows2+1, Li, Array_hydraulic_properties(2,:));
C=c1.Concatenate_Array_Field(c2);


% For the FD linear transport and Comsol
C = Create_Array_Field_From_Phreeqc_File(database,txt, n_rows2, Li, Array_hydraulic_properties(2,:));
%% Boundary Class
inputnode_parameters=C.String_List_Aqueous_Elements_And_Value (1,  1);                % The method of the Array_Field class String_List_Aqueous_Elements_And_Value creates a
                                                                                  % cell like {'Ca' '50' ... 'Na' '36'} for a given row position. Since we want the input values of elements
                                                                                  % we called it for the first node.

                                                                                  
% For the FD linear transport 
inputnode_parameters=c1.String_List_Aqueous_Elements_And_Value (1, 1);

B_C=Boundary_Conditions_Transport_1D (inputnode_type , outputnode_type, inputnode_parameters);

%% Problem Transport Definition
Problem_Transp_Definitions=Problem_Transp_Definition (Transport_Physical_Parameter, B_C);

%% Equation
fvt_struct = struct('b_modOH', true, 'FL', 'SUPERBEE'); 
Phreeqc_options=Set_Phreeqc_Extras('OutputFile', true);
Eq1=Equation_G([],{Problem_Transp_Definitions});
% Eq1=Equation_G([],{Problem_Transp_Definitions, fvt_struct});
Eq2=Equation_Phreeqc_BatchSeq({database, txt,n_rows2+2, Phreeqc_options});

%% Time Class
list_time=[];                                           % No add iterations.                                                                            % No add iterations.
time_all=true;                                          % All the concentrations of the simulated DT are saved.                                % All the concentrations of the simulated DT are saved.
t=Time_Treaclab(initial_time, final_time,list_time,time_all);
t=t.Fix_Dt(dt);

% Manager Class
% List_Equations_SolveEngine={{Eq1, 'FVT_1D_Solver'},{Eq2,'Phreeqc_Batch_Seq_v2'}};
% List_Equations_SolveEngine={{Eq1, 'COMSOL_1D'},{Eq2,'Phreeqc_Batch_Seq_v2'}}; %this couple of software work need 50 nodes. 
% List_Equations_SolveEngine={{Eq1, 'TransportSNIA_PDEPEmod'},{Eq2,'Phreeqc_Batch_Seq'}}; %this couple of software work need 52 nodes. 
List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh'},{Eq2,'Phreeqc_Batch_Seq_v2'}}; %this couple of software work need 50 nodes, the edges are not added. 
% List_Equations_SolveEngine={{Eq1, 'Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA'},{Eq2,'Phreeqc_Batch_Seq'}}; %this couple of software work need 52 nodes, and the coupling SIA_TC.
% List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMeshImpl'},{Eq2,'Phreeqc_Batch_Seq_v2'}}; % thisc coupling need 50 nodes, SIA_CC 
Manag=Manager(List_Equations_SolveEngine);


%% Problem Class
Prob1=Problem(t, C, Manag.Get_List_Equations);
Prob1=Prob1.Fix_Morphology(Morpho);              % For solving this problem, the class morphology must be given (the class include discrezitation of the domain)
Sol1=Solver(Prob1, Manag.Get_List_Solve_Engine);

%% Eval class
Eval=Evaluation( coupling_methods_list);
Eval=Eval.Coupling_Solution(Sol1);
Results_Ref = PhreeqcTransport_Direct (database, txt_rt, C.Get_List_Identifiers);
Eval=Eval.Fix_Results_Reference (Results_Ref);

%% Save in Matlab workspace
% finally we solve the results in a workspace variable of matlab to plot
% the results see the Plots.m file.
s=strcat('Mat_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval')
end