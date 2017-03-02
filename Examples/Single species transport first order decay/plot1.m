dt=4e-3;
iter=125;
Time_List=iter*dt;
Method_List=Coupler.Partial_Methods_1 ();
Element_List={'C'};

n_rows21=15;
Length=6; % 5.5 cm
dx=Length/15;
Morpho1=Morphology_1D (Length, dx);


load('e2Mat_15_Batch_125_Iteration_0.004_Dt.mat')
Eval.Plot_Results_Test_1D ( Time_List, Method_List, Element_List, Morpho1.Get_Vector_Regular_centeredDiscretization_Points)
