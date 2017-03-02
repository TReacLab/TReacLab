% The following problem is not compared with Phreeqc, since the chemistry
% software is other.
% We will work with a binary system of two aqueous species and a mineral.
% One side of the boundary conditions is a Neumann boundary condition (no
% flux) and the other side is a Dirichlet boundary condition where the
% value of the species is 0.


function BinarySystem
% time parameters
dt = 50;
n_iterations = 200;
initial_time = 0;
final_time = n_iterations*dt;
list_time = [];
time_all = true;

%Geometry values
n_rows1=1;    % The first row is needed for the TransportSNIA_PDEPEmod solver egine class (solvers that need the boundary condition namely if we have 100 grids, the solver might need more nodes)
               
n_rows2=100;
Length=0.055; % 5.5 cm
dx=Length/n_rows2;

% hydraulic parameters
velocity_x = 0;  % m/s
dispersivity_x = 0; %(m)
porosity = 1;  % dimesionless
molecular_diffusion = 3e-10;  %m2/s

% Coupling method (Some couplings work just with specific solvers in our approach)
coupling_methods_list = {'Additive_method', 'Sequential_12', 'AlternatingOS', 'Strang_method_121', 'Symmetrically_Weighted_method'};
% coupling_methods_list = Coupler.Sequential_12 ();
% coupling_methods_list = {'SIA_TC'}; 
% coupling_methods_list = {'SIA_CC'};   

% Boundary condition Par.
inputnode_parameters={'Soluteone' '0' 'Solutetwo' '0'};
inputnode_type='inflow';
outputnode_type='no flux';

% Parameters for building the array field class
database='wateq4f.dat';
% % case 1
txt_in='inputwaterbc.txt';
txt='initialwaterdomain.txt';
li_txt = 'List_IdentifiersporsatRV.txt';
txt2='txt3matrix.txt';
txt2_bc='txt3matrix_v2_bc.txt';
txt2_ic='txt3matrix_v2_ic.txt';

%% The Array Field class 
% It can be computed by different approaches, here we expose them. In case
% that you use Phreeqc, we recommend the use of Create_Array_Field_From_Phreeqc_File
porosity=1; % dimensionless
vector_porosity=porosity*ones(n_rows2, 1);
% start with something saturated (from 1 to 0)
liquid_saturation=1;
vector_liquid_saturation=liquid_saturation*ones(n_rows2, 1);

% Rv
representative_volume=1;
vector_representative_volume=representative_volume*ones(n_rows2, 1);

% volumetircwatercontent
vector_volumetricwatercontent=representative_volume.*porosity.*liquid_saturation.*ones(n_rows2, 1);

Array_hydraulic_properties=[vector_porosity vector_liquid_saturation vector_representative_volume vector_volumetricwatercontent];
Li = Create_List_Identifier_Class_From_Text (li_txt);

% The function Create_Array_Field_From_Phreeqc_File gave some problems for
% this problem, therefore a roundabout was needed. Usually, it should not
% be necesary to input the values of the solutes or liquid saturation.

% Data field 2 cases
% Case Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA and TransportSNIA_PDEPEmod
% c1 = Create_Array_Field_From_Phreeqc_File(database,txt_in, n_rows1, Li, Array_hydraulic_properties(1,:) );
% c2 = Create_Array_Field_From_Phreeqc_File(database,txt, n_rows2+1, Li, Array_hydraulic_properties(2,:));
% a=ones(102,1)*0.000126677106828696;
% a(1,1)=0;
% C=c1.Concatenate_Array_Field(c2);
% C=C.Update_Array_Element ( a, 'Soluteone');
% b=ones(102,1)*2.66771068294110e-05;
% b(1,1)=0;
% C=C.Update_Array_Element ( b, 'Solutetwo');
% C=C.Update_Array_Element ( ones(102,1), 'liquid_saturation');

% % Case LinearTransportFD_1D_ConstantVelDiffMesh solver or LinearTransportFD_1D_ConstantVelDiffMeshImpl
C = Create_Array_Field_From_Phreeqc_File(database,txt, n_rows2, Li, Array_hydraulic_properties(2,:));
a=ones(100,1)*0.000126677106828696;
C=C.Update_Array_Element ( a, 'Soluteone');
b=ones(100,1)*2.66771068294110e-05;
C=C.Update_Array_Element ( b, 'Solutetwo');
C=C.Update_Array_Element ( ones(100,1), 'liquid_saturation');

% Other way without using Phreeqc to instantiate the concentration.
C_prima1 = Create_Array_Field_Txt (li_txt, txt2, 'heterogeneous');

c1_prima = Create_Array_Field_Txt (li_txt, txt2_bc, 'homogeneous');
c2_prima = Create_Array_Field_Txt (li_txt, txt2_ic, 'homogeneous');
C_prima2=c1_prima.Concatenate_Array_Field(c2_prima);

% C_prima1 and C_prima2 are equal to C for the case
% TransportSNIA_PDEPEmod solver in order to get a difference

%%
% Morphologia class
Morpho=Morphology_1D (Length, dx);


%Boundary class
B_C=Boundary_Conditions_Transport_1D (inputnode_type , outputnode_type, inputnode_parameters);


%% Solid Properties class
S_P = Solid_Properties (porosity);

%% Transport_Physical_Parameters class
Transport_Physical_Parameter= Transport_Physical_Parameters(velocity_x, dispersivity_x,molecular_diffusion, 0,0);
Transport_Physical_Parameter= Transport_Physical_Parameter.Set_Solid_Properties(S_P );
% %% this=Problem_Transp_Definition (Transport_Physical_Parameter, Boundary_Condition)
Problem_Transp_Definitions=Problem_Transp_Definition (Transport_Physical_Parameter, B_C);
%% Equation
Eq1=Equation_G([],{Problem_Transp_Definitions});
d=C.Get_Vector_Field ('Mineral');
Eq2=Equation_BinarySolution_PrecipitationDissolution({10^-8.48,'Soluteone', 'Solutetwo', 'Mineral' });


%% Here choose Solvers
% List_Equations_SolveEngine={{Eq1, 'COMSOL_1D'},{Eq2,'SimpleBynaryChemistry_DissolutionPrecipitation'}};   % this couple of software work need 100 nodes, the edges are not added.  
% List_Equations_SolveEngine={{Eq1, 'TransportSNIA_PDEPEmod'},{Eq2,'SimpleBynaryChemistry_DissolutionPrecipitation'}}; %this couple of software work need 102 nodes. (boundary conditions must be added in the matrix of the data)
List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMesh'},{Eq2,'SimpleBynaryChemistry_DissolutionPrecipitation'}}; %this couple of software work need 100 nodes, the edges are not added. 
% List_Equations_SolveEngine={{Eq1, 'Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA'},{Eq2,'SimpleBynaryChemistry_DissolutionPrecipitation'}}; %this couple of software work need 102 nodes, and the coupling SIA_TC.
% List_Equations_SolveEngine={{Eq1, 'LinearTransportFD_1D_ConstantVelDiffMeshImpl'},{Eq2,'SimpleBynaryChemistry_DissolutionPrecipitation'}};  %this couple of software work need 100 nodes(no edges), and the coupling SIA_CC.

Manag_1=Manager(List_Equations_SolveEngine);


% Time_Class def class
t=Time_Treaclab(initial_time, final_time,list_time,time_all);
t=t.Fix_Dt(dt);


Prob1=Problem(t, C, Manag_1.Get_List_Equations);
% Prob1=Problem(t, C_prima2, Manag_1.Get_List_Equations);
Prob1=Prob1.Fix_Morphology(Morpho);
Sol1=Solver(Prob1, Manag_1.Get_List_Solve_Engine);


Eval=Evaluation( coupling_methods_list);
Eval=Eval.Coupling_Solution(Sol1);
%% Save in Matlab workspace
s=strcat('BinarySMat_', num2str(n_rows2),'_Batch_',num2str(n_iterations),'_Iteration_',num2str(dt),'_Dt.mat'); 
save (s,'Eval', '-v7.3')

end