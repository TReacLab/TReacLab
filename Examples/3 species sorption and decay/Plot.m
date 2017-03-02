% Time_List=200*50;
Time_List=100*0.5;
% List_Element={'c1' 'c2' 'c3'};
List_Element={'c1'}
% Method_List=Coupler.Sequential_12;
Method_List=Coupler.Strang_121;
% Method_List={'SIA_TC'};
% Method_List={'SIA_CC'};

n_rows2=80;
Length=40; % 5.5 cm
dx=Length/n_rows2;
Morpho1=Morphology_1D (Length, dx);

name_file = 'str_LunnBench_80_Batch_400_Iteration_0.5_Dt.mat';
load(name_file );
Eval.Plot_Results_Test_1D ( Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points ) %LinearTransportFD_1D_ConstantVelDiffMesh, Comsol1D



