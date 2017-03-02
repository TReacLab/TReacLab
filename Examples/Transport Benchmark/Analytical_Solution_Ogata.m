
%   governing differential equation:
%       
%      R*(dC/dt)=D*(d^2C/dx^2)-v*(dC/dx)
%
%   C is the concentration
%   v is the seepage velocity (Darcy velocity/porosity)
%   D is the sum of Dispersion + Difussion
%   R is the retardation factor 
%   t is time
%   x is distance
%
%   d represent a partial derivation here.
%
%   Initial and Boundary Conditions:
%
%       C(x,0)=Ci
%
%       C(0, t)= C0,    0 < t < t0
%       C(0, t)= 0,      t >t0
%  
%       dC/dx(infinite, t) = 0
%
%    Ci is the initial concentrationand constant value with distance. (Not suitable for Operator Splitting, as the values will not be constant.)
%    C0 is the inflow of the concentration at the inlet
%
%   The Analytical Solution for this equation is given by Lapidus and
%   Amundson 1952, Ogata and Banks 1961:
%
%   C(x, t)=Ci+(C0-Ci)A(x,t)                            0 < t < t0
%   C(x, t)=Ci+(C0-Ci)A(x,t)-C0A(x, t-t0)               t > t0
%
%   where
%   
%   A(x,t)=0.5*erfc[(R*x-v*t)/2*(D*R*t)^0.5]+0.5*exp(v*x/D)erfc[R*x+v*t/2*(D*R*t)^0.5]
%
%   This equation can be found in the following reference:
%   Titel: Analytical Solutions of the
%   One-Dimensional Convective-Dispersive Solute Transport Equation
%   Authors: M. Th. van Gencuhten and W. J. Alves. 
%   year: 1982
%   Journal: U.S.Department of Agriculture, Technical Bulletin No. 1661,
%   151p.
%
%   Note: The equation belongs to the section A (Solutions for No
%   Produciton or Decay) and it is the first one (A1 equation). This
%   solution is attributable to Lapidus and Amundson 1952 and Ogata and
%   Banks 1961.
%
%   Note_2: time0 corresponds to the time at which the boundary condition
%   of constant flow is removed from the system, namely no more
%   inflow of the element is given.


function R = Analytical_Solution_Ogata (P_T_D, t, Initial_Field, Morpho)





Time0 = 1000000;

C=Initial_Field;
matrix_t=Initial_Field.Get_Array;
values=zeros(size(matrix_t,1), 1);
list_new_values=cell(1,length(t));
vec_distance= Morpho.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges ;
for j=1:length(t)
    for i=1:size(matrix_t,1)
        values(i,1)=Analytical_Ogata(vec_distance(1,i), t(j), Time0, matrix_t(i,1), str2num(P_T_D.Boundary_Condition.Get_Inputnode_Parameters{2}), ...
            P_T_D.T_P_P.molecular_diffusion_liquid, P_T_D.T_P_P.retardation, P_T_D.T_P_P.velocity_aqueous);
        %     if z==1
        %         values(i,1)=this.Analytical_Ogata(vec_distance(1,i), t(j), Time0, matrix_t(i,j), str2num(P_T_D.Boundary_Condition.Get_Inputnode_Parameters{2}), ...
        %           P_T_D.T_P_P.dispersion, P_T_D.T_P_P.retardation, P_T_D.T_P_P.velocity_aqueous);
        %     else
        %         values(i,1)=this.Analytical_Ogata(vec_distance(1,i), t(j), Time0, matrix_t(i,j), 0, P_T_D.T_P_P.dispersion, P_T_D.T_P_P.retardation,  P_T_D.T_P_P.velocity_aqueous);
        %     end
    end
    C = C.Update_Array_Element(values, 'C');
    list_new_values{j,1}=C;
    
end


R=Results (list_new_values, t);

end

function conc=Analytical_Ogata (Length, Time, Time0, Intconc, Concpoint0,D,R, Velocity)
if D~=Length
if Time>0 && Time<Time0
    conc=Intconc+(Concpoint0-Intconc)*functionA(Length, Time,D,R,Velocity);
elseif Time>Time0
    conc=Intconc+((Concpoint0-Intconc)*functionA(Length, Time,D,R, Velocity))-Concpoint0*functionA(Length, (Time-Time0),D,R);
else
    conc=Intconc;
end
else
    conc=Intconc;
end
end


function value=functionA(Length, Time,D,R, Velocity)
lok=((R*Length)-(Velocity*Time))/(2*(D*R*Time)^(0.5));
A1=0.5*erfc(lok);
lok=((R*Length)+(Velocity*Time))/(2*(D*R*Time)^(0.5));
exponential=exp((Velocity*Length)/D);
A2=0.5*erfc(lok);
if exponential==Inf && A2==0
    B=0;
else
    B=A2*exponential;
end
value=A1+B;
end