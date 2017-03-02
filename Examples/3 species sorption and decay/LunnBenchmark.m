% The following problem is withdrawn from:
% M.Lunn, R.J. Lunn, R. Mackay "Determining analytic solutions of multiple species contaminant transport, with sorption and decay" Journal of Hydrology 180 (1996) 195-210.
% T.P. Clement, Y.Sun, B.S. Hooker, and J.N. Petersen "Modeling multispecies reactive transport in ground water"
%
% In order to run the simulation the LinearTransportFD_1D_ConstantVelDiffMesh solver is going to be modified
% To do so, three porosities are going to be added. The porosity is going to play the role of the retardation factor of the Lunn article.
% Also a solver for the chemistry part must be developed.


function LunnBenchmark
% time parameters
dt = 4;                           % 0.5, 2, 4
n_iterations = 50;                 % 400, 100, 50
initial_time = 0;
final_time = n_iterations*dt;       % 0.5*400 = 200 hours
list_time = [];
time_all = true;

%Geometry values
n_rows2=80; 
% n_rows2=40;
Length= 40;                         % 40 cm
dx=Length/n_rows2;                  % 40/80 = 0.5 cm

% The parameters of the chemistry system are the three decay rates. The
% chemistry system is an homogeneous linear ordinary differential equations
% with constant coefficients. Hence, they might be interpreted as dc/dt = A*c 
% where A is a matrix, c is the vector of concentrations and dc/dt is the
% time variation. So, we will give just the matrix as a parameter. It is
% assume that c always look like c = [c1,c2,c3]', at each point of the
% node.
k1 = 0.05; %hr-1
k2 = 0.03; %hr-1
k3 = 0.02; %hr-1
A = [-k1 0 0; k1 -k2 0; 0 k2 -k3];
% hydraulic parameters
velocity_x = 0.1;                   % cm/h
dispersivity_x = 0.18;              % cm
molecular_diffusion = 0;            % cm2/s

% Coupling method
% coupling_methods_list=Coupler.Sequential_12 ();
% coupling_methods_list=Coupler.Strang_121;
coupling_methods_list= { 'Additive_method', 'Sequential_12', 'AlternatingOS', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% Boundary condition Par.
inputnode_parameters={'c1' '1' 'c2' '0' 'c3' '0'};
inputnode_type='inflow';
outputnode_type='flux';

% Parameters for building the array field class
li_txt = 'List_IdentifiersporsatRV.txt';
txt2='matrix_info.txt';

%% The Array Field class 
% The values of each row must coincide with the name in li_text variable.
Data = Create_Array_Field_Txt (li_txt, txt2, 'homogeneous');

%% Morphologia class
Morpho=Morphology_1D (Length, dx);

%% Boundary class
B_C=Boundary_Conditions_Transport_1D (inputnode_type , outputnode_type, inputnode_parameters);

%% Solid Properties class
S_P = Solid_Properties (1);

%% Transport_Physical_Parameters class
Transport_Physical_Parameter= Transport_Physical_Parameters(velocity_x, dispersivity_x,molecular_diffusion, 0,0);
Transport_Physical_Parameter= Transport_Physical_Parameter.Set_Solid_Properties(S_P );

%% this=Problem_Transp_Definition (Transport_Physical_Parameter, Boundary_Condition)
Problem_Transp_Definitions=Problem_Transp_Definition (Transport_Physical_Parameter, B_C);

%% Equation
Eq1 = Equation_G([],{Problem_Transp_Definitions});
% Eq2=Equation_Identity ();
Eq2 = Equation_Lunn_Benchmark({A});

%% Here choose Solvers
List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh_modLunnbench'},{Eq2,'Lunn_Bench_Chemistry'}}; %this couple of software work need 100 nodes, the edges are not added. 

Manag_1=Manager(List_Equations_SolveEngine);


% Time_Class def class
t=Time_Treaclab(initial_time, final_time,list_time,time_all);
t=t.Fix_Dt(dt);


Prob1=Problem(t, Data, Manag_1.Get_List_Equations);
Prob1=Prob1.Fix_Morphology(Morpho);
Sol1=Solver(Prob1, Manag_1.Get_List_Solve_Engine);


Eval=Evaluation( coupling_methods_list);
Eval=Eval.Coupling_Solution(Sol1);

Results_Ref = Analytical_Solution_Lunn_Bench ( velocity_x, dispersivity_x , t, Data, Morpho);
% Results_Ref =Analytical_Solution_Cho_Bench( velocity_x, dispersivity_x , t, Data, Morpho);
Eval=Eval.Fix_Results_Reference (Results_Ref);
%% Save in Matlab workspace
s=strcat('All_LunnBench_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval', '-v7.3')

end