List_Element={'O' 'H' 'cb'  'H2O' 'Ca' 'Cl' 'Na' 'N' 'K' 'CaX2' 'KX' 'NaX'};
Method_List= { 'Additive_method', 'Sequential_12','AlternatingOS', 'Strang_method_121',  'Symmetrically_Weighted_method'};
Time_List=20*720;
List_Element={'K'};
% Method_List=Coupler.Sequential_12;
Method_List={'SIA_CC'};
n_rows2=40;
Length=0.08; 
dx=Length/n_rows2;
Morpho1=Morphology_1D (Length, dx);
dx_prh=dx/2:dx:Length;


load('SiACC_40_Batch_200_Iteration_90_Dt.mat')
% Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element,Morpho1.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges, dx_prh)



Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element,dx_prh, dx_prh)

nn = 3;
filename = 'testnew51.gif';
for n = 1:nn
      Time_List = n*720;
      Eval.Plot_Comp_OS_R_For_Tlist_1D(Time_List, Method_List, List_Element,dx_prh, dx_prh)
      drawnow
      frame = getframe(1);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      if n == 1;
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
      else
          imwrite(imind,cm,filename,'gif','WriteMode','append');
      end
end