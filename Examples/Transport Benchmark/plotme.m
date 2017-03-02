dt=20; 
iter=20;  
Time_List=iter*dt;
Method_List=Coupler.Sequential_12 ();
Element_List={'C'};

n_rows2=100;
Length=5.6;
dx=Length/n_rows2;
Morpho1=Morphology_1D (Length, dx);


load('Comsol_100_Batch_20_Iteration_20_Dt.mat')
Eval1.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_centeredDiscretization_Points, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges)

load('FVT_100_Batch_20_Iteration_20_Dt.mat')
Eval2.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_centeredDiscretization_Points, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges)

load('FD_100_Batch_20_Iteration_20_Dt.mat')
Eval3.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_centeredDiscretization_Points, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges)

load('Pdepe_100_Batch_20_Iteration_20_Dt.mat')
Eval4.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges)
