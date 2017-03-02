
% List_Element={'C'  'Cl' 'Na' 'K' 'Ca' 'Mg'  'Mn' 'S'  'Fe' 'Si' 'Al'  'P' 'Br' 'F' 'O' 'H' 'H2O' 'cb'...
%     'Calcite' 'Pyrite' 'Illite' 'Albite' 'K-feldspar' 'porosity' 'liquid_saturation' 'RV' 'volumetricwatercontent'...
%     'dens' 'vol_sol' 'C(-4)' 'C(4)'  'pe' 'pH' 'water' 'Alk(eq/kgw)' 'HS-' 'S-2' 'SO4-2' 'H2S' 'FeOH+' 'FeCl+' 'FeCO3' 'Fe+2' 'S(6)' 'S(-2)' 'Fe(2)' 'Fe(3)'};
List_Element={'C'  'Cl' 'Na' 'K' 'Ca' 'Mg'  'Mn' 'S'  'Fe' 'Si' 'Al'  'P' 'Br' 'F' 'O' 'H' 'H2O' 'cb'};
% List_Element={ 'C'  'Cl' 'Na' 'K' 'Ca' 'Mg'  'Mn' 'S'  'Fe' 'Si' 'Al'  'P' 'Br' 'F'};
% List_Element={ 'Calcite'};
% List_Element={ 'pH' 'pe'};
% List_Element = {'pe'};
% List_Element={'k_Calciet' 'k_Pyrite' 'k_Illite' 'k_Albite' 'k_K-feldspar'};
% List_Element={'Activ_H+' 'MOLO2' 'MOLFE3+' 'MOLFE+2' 'MOLH+' 'SIKFELDSPAR' 'SI_Illite' 'SI_Albite' 'SI_Pyrite' 'SI_Calcite'};


n_iterations = 20;
dt=720;
Time_List=dt*n_iterations;
Method_List={'Symmetrically_Weighted_method'};
% Method_List={'Symmetrically_Weighted_method'};
% Method_List= {'AlternatingOS', 'Sequential_12', 'Additive_method', 'Strang_method_121',  'Symmetrically_Weighted_method'};
% Method_List={'SIA'};
% Method_List=Coupler.Partial_Methods_1;
% Method_List={'SIA_TC'};
% Method_List={'SIA_CC'};
n_rows2=80;
Length=0.08; % 5.5 cm
dx=Length/n_rows2;
Morpho1=Morphology_1D (Length, dx);
n_rows2=40;
dx=Length/n_rows2;
dx_prh=dx/2:dx:Length;


% load('Mat_40_Batch_360_Iteration_240_Dt.mat')

% For all the transport process with pdepe matlab
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges , dx_prh)

% For the finite difference use (FD)
% load('Mat_80_Batch_120_Iteration_720_Dt.mat')
load('MAT_80_Batch_960_Iteration_90_Dt.mat');
Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)


% load('Mat_40_Batch_120_Iteration_720_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)
% 
% load('Mat_40_Batch_360_Iteration_240_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)
% 
% load('Mat_40_Batch_480_Iteration_180_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)
% 
% load('Mat_40_Batch_600_Iteration_144_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)

%
%
%gif
%

% filename = 'tryme.gif';
% 
% for i = 1 : n_iterations
%     Eval.Plot_Comp_OS_R_For_Tlist_1D(dt*i, Method_List, List_Element, Morpho1.Get_Vector_Regular_centeredDiscretization_Points , dx_prh)
%     drawnow
%     frame = getframe(1);
%       im = frame2im(frame);
%       [imind,cm] = rgb2ind(im,256);
%       if i == 1;
%           imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%       else
%           imwrite(imind,cm,filename,'gif','WriteMode','append');
%       end
%       close
% end
