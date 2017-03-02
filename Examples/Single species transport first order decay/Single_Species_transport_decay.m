%
%   The benchmarck is founded in the famous paper of Steefel and
%   MacQuarrie, named "Approaches to mpdeling of reactive transport in
%   porous media" Rew in Mineralogy and Geochemistry, vol. 34, pag- 85-129
%
%
%   This example they work with units of time in years, and it is a single
%   species.

function Single_Species_transport_decay (dt, n_iterations, n_rows2)
if nargin==0
    dt=4e-3; % 4 differents according to the paper dt = 2e-4, 4e-4, 2e-3, 4e-3.
    n_iterations=125;  % respecting the 4 different dt, the number of iterations will be respectively 2500, 1250, 250, 125
    n_rows2=15;          % if the length is 6, and the mesh is 0.4 meters, the number of rows cells is 15
end

%% Parameters
% Coupling Par. for Evaluation class
% coupling_methods_list=Coupler.Partial_Methods_1 ();
% coupling_methods_list= Coupler.Partial_Methods_1 ();
coupling_methods_list= {'AlternatingOS', 'Sequential_12', 'Additive_method', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% coupling_methods_list= {'AlternatingOS', 'Sequential_12', 'Additive_method', 'Strang_method_121'};
% coupling_methods_list= {'Sequential_12', 'Additive_method'};
% coupling_methods_list= {'Symmetrically_Weighted_method'};
% coupling_methods_list={'SIA_CC'};
% coupling_methods_list={'SIA_TC'};


% Time Par.
initial_time=0;
final_time=n_iterations*dt;

% Boundary condition Par.
% inputnode_parameters=list_elements_inflow;
inputnode_type='inflow';
outputnode_type='flux';
inputnode_parameters={'C' '1'};

% Morphology and Concentration par.
Length=6; % 6 m
dx=Length/n_rows2;

% Transport Physical par.
velocity_x=100; %(m/yr)
Dispersivity_x=0.2; %(m)
molecular_diffusion=0; % m2/s 

% chemie
k_rate =100; %yr
% string_t = 'Matlab';  % 'Analytical'/'Numerical'/'Matlab'



string_t = 'Numerical'; % 0(Explicit) <= theta <=1 (Implicit)
% string_t = 'Analytical'; % 0(Explicit) <= theta <=1 (Implicit)
% string_t = 'Matlab'; % 0(Explicit) <= theta <=1 (Implicit)



theta = 0; % 0(Explicit) <= theta <=1 (Implicit)
% theta = 0.5; % 0(Explicit) <= theta <=1 (Implicit)
% theta = 1; % 0(Explicit) <= theta <=1 (Implicit)


strg_matl = 'ode45';
% Solid properties class 
porosity=1; % dimensionless

%% Solid Properties class
S_P = Solid_Properties (porosity);

%% Transport_Physical_Parameters class
Transport_Physical_Parameter= Transport_Physical_Parameters(velocity_x, Dispersivity_x,molecular_diffusion, 0,0);
Transport_Physical_Parameter= Transport_Physical_Parameter.Set_Solid_Properties(S_P );

%% Master_Phreeqc class through reading text file 
Li = Create_List_Identifier_Class_From_Text ('List_IdentifiersporsatRV.txt');

%% Morphology class
Morpho=Morphology_1D (Length, dx);

%% Concentration class
li_txt = 'List_IdentifiersporsatRV.txt';
txt2='txt4matrix.txt';
txt = 'txtmatrix.txt';
c1 = Create_Array_Field_Txt (li_txt, txt, 'homogeneous');
c2 = Create_Array_Field_Txt (li_txt, txt2, 'homogeneous');
C=c1.Concatenate_Array_Field(c2);

txt2='txt3matrix.txt';
C = Create_Array_Field_Txt (li_txt, txt2, 'homogeneous');
%% Boundary Class
B_C=Boundary_Conditions_Transport_1D (inputnode_type , outputnode_type, inputnode_parameters);

%% Problem Transport Definition
Problem_Transp_Definitions=Problem_Transp_Definition (Transport_Physical_Parameter, B_C);

%% Equation
Eq1=Equation_G([],{Problem_Transp_Definitions});
% Eq2=Equation_Identity();
Eq2=Equation_FirstOrder_Decay_1Species({k_rate,string_t, theta});
% Eq2=Equation_FirstOrder_Decay_1Species({k_rate,string_t});
% Eq2=Equation_FirstOrder_Decay_1Species({k_rate,string_t,strg_matl});




%% Time Class
list_time=[];                                                                            % No add iterations.
time_all=true;                                                                           % All the concentrations of the simulated DT are saved.
t=Time_Treaclab(initial_time, final_time,list_time,time_all);
t=t.Fix_Dt(dt);


% %% Manager Class
% List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh'},{Eq2, 'Process_Identity'}};
List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh'},{Eq2, 'SimpleR_FirstOrder_Decay'}};
% List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh_v2'},{Eq2, 'SimpleR_FirstOrder_Decay'}};
% List_Equations_SolveEngine={{Eq1, 'COMSOL_1D'},{Eq2, 'SimpleR_FirstOrder_Decay'}};
% List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMeshImpl'},{Eq2,'SimpleR_FirstOrder_Decay'}}; % thisc coupling need 15 nodes, SIA_CC 
% List_Equations_SolveEngine={{Eq1, 'Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA'},{Eq2,'SimpleR_FirstOrder_Decay'}}; %this couple of software work need 17 nodes, and the coupling SIA_TC. Using Phreeqc_Batch_Seq seems it converges
Manag=Manager(List_Equations_SolveEngine);



%% Problem Class
Prob=Problem(t, C, Manag.Get_List_Equations);
Prob=Prob.Fix_Morphology(Morpho);              % For solving this problem, the class morphology must be given (the class include discrezitation of the domain)
Sol=Solver(Prob, Manag.Get_List_Solve_Engine);


%% Eval class
Eval=Evaluation( coupling_methods_list);
Eval=Eval.Coupling_Solution(Sol);
txt2='txt3matrix.txt';
C = Create_Array_Field_Txt (li_txt, txt2, 'homogeneous');
zerop = 0;
Results_Ref = Analytical_Solution_C5_BearGenutchen ( velocity_x, Dispersivity_x, k_rate, zerop, t, C, Morpho);
Eval=Eval.Fix_Results_Reference (Results_Ref);

%% Save in Matlab workspace
s=strcat('Eulerexpl_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat');

% s=strcat('EulerSemi_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat');
% s=strcat('Eulerimp_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat');
% s=strcat('Analytical_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat');
% s=strcat('Matlab0de45_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat');


save (s,'Eval')
end