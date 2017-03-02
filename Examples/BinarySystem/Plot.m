% clear all  % just in case

% Time_List=200*50;
Time_List=200*50;
List_Element={'Soluteone' 'Solutetwo' 'Mineral'};
Method_List = {'Additive_method', 'Sequential_12', 'AlternatingOS', 'Strang_method_121', 'Symmetrically_Weighted_method'};
% Method_List=Coupler.Sequential_12;
% Method_List={'SIA_TC'};
% Method_List={'SIA_CC'};

n_rows2=100;
Length=0.055; % 5.5 cm
dx=Length/n_rows2;
Morpho1=Morphology_1D (Length, dx);

name_file = 'BinarySMat_100_Batch_200_Iteration_50_Dt.mat';
load('BinarySMat_100_Batch_200_Iteration_50_Dt');
Eval.Plot_Results_Test_1D ( Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges)  % Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA and TransportSNIA_PDEPEmod
% Eval.Plot_Results_Test_1D ( Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points ) %LinearTransportFD_1D_ConstantVelDiffMesh, Comsol1D
% 


