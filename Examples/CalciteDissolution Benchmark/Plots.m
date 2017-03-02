List_Element={'C' 'Ca' 'Cl' 'Mg' 'O' 'H' 'H2O' 'cb' 'dens' 'vol_sol' 'C(-4)' 'C(4)' 'pe' 'pH' 'water' 'Alk(eq/kgw)' 'Calcite' 'Dolomite(ord)'};
% List_Element={ 'Calcite' 'Dolomite(ord)'};
Time_List=50*200;
% Method_List=Coupler.Sequential_12 ();
% Method_List={'Symmetrically_Weighted_method'};
% Method_List= {'AlternatingOS', 'Sequential_12', 'Additive_method', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% Method_List={'SIA'};
% Method_List=Coupler.Partial_Methods_1;
Method_List={'SIA_TC'};
% Method_List={'SIA_CC'};
n_rows2=50;
Length=0.5; % 5.5 cm
dx=Length/n_rows2;
Morpho1=Morphology_1D (Length, dx);
dx_prh=dx/2:dx:Length;


load('SIATC_50_Batch_20_Iteration_500_Dt.mat')

% For all the transport process with pdepe matlab
Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges , dx_prh)

% For the finite difference use (FD)
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)
