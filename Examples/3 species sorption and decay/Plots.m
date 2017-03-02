List_Element={'c1' 'c2' 'c3'};
niter = 400;
Time_List=niter*0.5;
Method_List=Coupler.Sequential_12;
Method_List= { 'Additive_method', 'Sequential_12', 'AlternatingOS', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% Method_List=Coupler.Strang_121;
n_rows2=80;
% n_rows2=40; 
Length= 40;                         % 40 cm
dx=Length/n_rows2; 
Morpho1=Morphology_1D (Length, dx);
dx_prh = Morpho1.Get_Vector_Regular_centeredDiscretization_Points;


% load('All_LunnBench_80_Batch_50_Iteration_4_Dt.mat')
load('All_LunnBench_80_Batch_400_Iteration_0.5_Dt.mat')
Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element,dx_prh, dx_prh)