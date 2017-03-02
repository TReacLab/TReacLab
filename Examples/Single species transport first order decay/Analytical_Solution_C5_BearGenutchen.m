%
% The Analytical solution is obtained from 'Analytical Solutions of the
% One-Dimensional Convective-Dispersice Solute Transport Equation' M. Th.
% van Genuchten and W. J. Alves. United States Deparment of Agriculture.
% Agricultural Research Service. Technical Bulletin Number 1661.
%
%

function Results_Ref = Analytical_Solution_C5_BearGenutchen ( velocity_x, Dispersivity_x, k_rate, zerop, Time, C, Morpho)

lambda = zerop;
mu = k_rate;
v = velocity_x;
D = velocity_x*Dispersivity_x;
Co= 1;               % it must be modified
R=1;                % It must be modified
lm = lambda/mu;

dt = Time.Get_Dt;
tf = Time.Get_Final_Time;
t = [0 : dt : tf];

Vector_Fields = cell(length(t), 1);

Cim= C.Get_Desired_Array('Solution');
Ci = Cim.Get_Array;

x = Morpho.Get_Vector_Regular_centeredDiscretization_Points;

for i = 1:length(t)
    C = zeros(length(x), 1);
    for j = 1:length(x)
    
    A = exp((-mu*t(i))/R)*(1 - 0.5*erfc((R*x(j) - v*t(i))/(2*sqrt(D*R*t(i)))) - 0.5*exp((v*x(j))/D)*erfc((R*x(j) + v*t(i))/(2*sqrt(D*R*t(i)))));
    u = v * sqrt(1+((4*mu*D)/(v*v)));
    B = 0.5*exp(((v-u)*x(j))/(2*D))*erfc((R*x(j) - u*t(i))/(2*sqrt(D*R*t(i)))) + 0.5*exp(((v+u)*x(j))/(2*D))*erfc((R*x(j) + u*t(i))/(2*sqrt(D*R*t(i))));
    
    C(j) = lm + (Ci(j) - lm)*A+(Co - lm)*B;
    end
    
    Cm = Cim.Update_Array_Element ( C, {'C'});
    
    Vector_Fields{i} = Cm;
end

Results_Ref=Results (Vector_Fields, t);
end