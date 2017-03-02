% 


function Transport_Bench
% time parameters
dt=20;    
n_iterations = 20;     % n_iterations 20 --> 400/20
initial_time = 0;
final_time = n_iterations*dt;
list_time = [];
time_all = true;

%Geometry 
               
n_rows2=100;
Length=5.6; % 5.6
dx=Length/n_rows2;   % dx=0.056;

% hydraulic parameters
velocity_x = 0.0028;  % m/s
dispersivity_x = 0; %(m)
porosity = 1;  % dimesionless
molecular_diffusion = 7.84e-5;  %m2/s

% Coupling method
coupling_methods_list=Coupler.Sequential_12 ();

% Boundary condition Par.
inputnode_parameters={'C' '30e-3'};
inputnode_type = 'inflow';
outputnode_type='flux';


%% Array Field
% Text 
li_txt = 'List_IdentifiersporsatRV.txt';
txt_bc='txtmatrix_bc.txt';
txt_ic='txtmatrix_ic.txt';
txt_ic2='txtmatrix_ic2.txt';
%
C_1 = Create_Array_Field_Txt (li_txt, txt_ic, 'homogeneous');           % Centered node no bc in the data structure C_1

c1_prima = Create_Array_Field_Txt (li_txt, txt_bc, 'homogeneous');
c2_prima = Create_Array_Field_Txt (li_txt, txt_ic2, 'homogeneous');
C_2=c1_prima.Concatenate_Array_Field(c2_prima);                    % Vertex node with bc in the data structure C_2



%%
% Morphologia class
Morpho=Morphology_1D (Length, dx);


%Boundary class
B_C=Boundary_Conditions_Transport_1D (inputnode_type , outputnode_type, inputnode_parameters);


%% Solid Properties class
S_P = Solid_Properties (porosity);

%% Transport_Physical_Parameters class
Transport_Physical_Parameter= Transport_Physical_Parameters(velocity_x, dispersivity_x,molecular_diffusion, 0, 1);
Transport_Physical_Parameter= Transport_Physical_Parameter.Set_Solid_Properties(S_P );
% %% this=Problem_Transp_Definition (Transport_Physical_Parameter, Boundary_Condition)
Problem_Transp_Definitions=Problem_Transp_Definition (Transport_Physical_Parameter, B_C);
%% Equation
Eq1=Equation_G([],{Problem_Transp_Definitions});
Eq2=Equation_Identity();

Eq1_p=Equation_G([],{Problem_Transp_Definitions, struct('b_modOH', true, 'FL','SUPERBEE')});
%% Here choose Solvers
List_Equations_SolveEngine1={{Eq1, 'COMSOL_1D'},{Eq2,'Process_Identity'}};    
List_Equations_SolveEngine2={{Eq1_p, 'FVT_1D_Solver'},{Eq2,'Process_Identity'}}; 
List_Equations_SolveEngine3={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh_v2'},{Eq2,'Process_Identity'}}; 
List_Equations_SolveEngine4={{Eq1, 'Saturated_Conservative_Transport_PDEPEMATLAB_1D'},{Eq2,'Process_Identity'}}; %this couple of software work need 102 nodes, and the coupling SIA_TC.

%
Manag_1=Manager(List_Equations_SolveEngine1);
Manag_2=Manager(List_Equations_SolveEngine2);
Manag_3=Manager(List_Equations_SolveEngine3);
Manag_4=Manager(List_Equations_SolveEngine4);

% Time_Class def class
t=Time_Treaclab(initial_time, final_time,list_time,time_all);
t=t.Fix_Dt(dt);


Prob1=Problem(t, C_1, Manag_1.Get_List_Equations);
Prob2=Problem(t, C_1, Manag_2.Get_List_Equations);
Prob3=Problem(t, C_1, Manag_3.Get_List_Equations);
Prob4=Problem(t, C_2, Manag_4.Get_List_Equations);

Prob1=Prob1.Fix_Morphology(Morpho);
Prob2=Prob2.Fix_Morphology(Morpho);
Prob3=Prob3.Fix_Morphology(Morpho);
Prob4=Prob4.Fix_Morphology(Morpho);

Sol1=Solver(Prob1, Manag_1.Get_List_Solve_Engine);
Sol2=Solver(Prob2, Manag_2.Get_List_Solve_Engine);
Sol3=Solver(Prob3, Manag_3.Get_List_Solve_Engine);
Sol4=Solver(Prob4, Manag_4.Get_List_Solve_Engine);

Eval1=Evaluation( coupling_methods_list);
Eval1=Eval1.Coupling_Solution(Sol1);
Eval2=Evaluation( coupling_methods_list);
Eval2=Eval2.Coupling_Solution(Sol2);
Eval3=Evaluation( coupling_methods_list);
Eval3=Eval3.Coupling_Solution(Sol3);
Eval4=Evaluation( coupling_methods_list);
Eval4=Eval4.Coupling_Solution(Sol4);

Results_Ref = Analytical_Solution_Ogata (Problem_Transp_Definitions,  initial_time:dt:final_time, C_2, Morpho);
Eval1=Eval1.Fix_Results_Reference (Results_Ref);
s=strcat('Comsol_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval1', '-v7.3')
Eval2=Eval2.Fix_Results_Reference (Results_Ref);
s=strcat('FVT_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval2', '-v7.3')
Eval3=Eval3.Fix_Results_Reference (Results_Ref);
s=strcat('FD_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval3', '-v7.3')
Eval4=Eval4.Fix_Results_Reference (Results_Ref);
s=strcat('Pdepe_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval4', '-v7.3')


end