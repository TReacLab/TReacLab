dt=4e-3; % 3 differents according to the paper dt = 4e-4, 2e-3, 4e-3.
iter=125;  % respecting the 3 different dt, the number of iterations will be respectively 1250, 250, 125
Time_List=iter*dt;
Method_List=Coupler.Partial_Methods_1 ();
Method_List=Coupler.Sequential_12 ();
% Method_List={'SIA_TC'};
Method_List={'AlternatingOS', 'Sequential_12', 'Additive_method', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% Method_List={'Symmetrically_Weighted_method'};
Element_List={'C'};

% Method_List={'Strang_method_121'};

n_rows21=15;
Length=6; % 5.5 cm
dx=Length/15;
Morpho1=Morphology_1D (Length, dx);
% 
% 
% load('MatAna_15_Batch_125_Iteration_0.004_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_centeredDiscretization_Points, Morpho1.Get_Vector_Regular_centeredDiscretization_Points)

% load('Eulerexpl_15_Batch_125_Iteration_0.004_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges, Morpho1.Get_Vector_Regular_centeredDiscretization_Points)
% 
% load('MatAna_15_Batch_1250_Iteration_0.0004_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_centeredDiscretization_Points, Morpho1.Get_Vector_Regular_centeredDiscretization_Points)