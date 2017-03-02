function ResultsR = Analytical_Solution_Lunn_Bench ( velocity_x, Dispersivity_x,  Time, C, Morpho)

% Inflows (It might be modified)
c10 = 1;
c20 = 0;
c30 = 0;

v = velocity_x;
D =Dispersivity_x* velocity_x;

% sorption and cinematics (it might be modified)
Kd = 1;
k1 = 0.05;      % h^-1
k2 = 0.03;      % h^-1
k3 = 0.02;      % h^-1

%
dt = Time.Get_Dt;
tf = Time.Get_Final_Time;
t = [0 : dt : tf];

lt = length(t);

x = Morpho.Get_Vector_Regular_centeredDiscretization_Points;
lx = length(x);

Vector_Fields = cell(lt, 1);

T_C = cell(1,lt);

li = C.Get_Transport_Elements;
            
for j = 1:lt
    Data = C;
    C1 = zeros(lx,1);
    C2 = zeros(lx,1);
    C3 = zeros(lx,1);
    for i = 1:lx
        if x(i) == 0
            % Set the cs values
            c1 = c10;
            c2 = c20;
            c3 = c30;
        else
            if t(j) == 50
                a=1;
            end
            % Calculate the values at the precise time and position
            c1 = Calculatec1(c10, x(i), t(j), v, D, Kd, k1);
            c2 = Calculatec2(c10, c20, x(i), t(j), v, D, Kd, k1, k2);
            c3 = Calculatec3 (c10, c20, c30, x(i), t(j), v, D, Kd, k1, k2, k3);
        end
        % set the value at the position
        C1(i) = c1;
        C2(i) = c2;
        C3(i) = c3;
    end
    T= [C1 C2 C3];
    
    for i=1:length(li)
        Data = Data.Update_Array_Element ( T(:,i), li{i});
    end
    Vector_Fields{j} = Data;
end

ResultsR = Results (Vector_Fields, t);
end

% x = space, t = time, v = velocity, d = difusion/dispersion, A and lambda
% specif parameters. After equation 11c
function P = CalculateP (x, t, v, D, A, lambda)
A =exp(((v*x)/(2*D))-(x*sqrt(lambda)))*erfc((x/(sqrt(4*A*t)))-sqrt(A*lambda*t));
B =exp(((v*x)/(2*D))+(x*sqrt(lambda)))*erfc((x/(sqrt(4*A*t)))+sqrt(A*lambda*t));
P = 0.5* (A+B);
end

% calculate c1
function c1 = Calculatec1(c10, x, t, v, D, Kd, k1)
A = D/(1+Kd);
lam =((v^2)/(4*D))+k1;
lambda =(lam/(1+Kd))/A; 
P1 = CalculateP (x, t, v, D, A, lambda);
c1 = c10*P1;
end

% calculate c2
function c2 = Calculatec2(c10, c20, x, t, v, D, Kd, k1, k2)
% cal P1
A1 = D/(1+Kd);
lam1 =((v^2)/(4*D))+k1;
lam1 = (lam1/(1+Kd));
lambda1 =lam1/A1; 
P1 = CalculateP (x, t, v, D, A1, lambda1);
% Cal P2
A = D;
lam2 =((v^2)/(4*D))+k2;
lambda2 =lam2/D;
P2 = CalculateP (x, t, v, D, A, lambda2);
% Cal Pa

lambdaA=(lam2-lam1)/(D-A1);
Pa = CalculateP (x, t, v, D, A, lambdaA);

% Cal Pb
Pb = CalculateP (x, t, v, D, A1, lambdaA);

B=(k1*c10)/(k2-k1);
C = exp(((k2-k1)*t)/Kd);
c2 = c20*P2+B*(P1-P2+C*(Pa-Pb));
end

function c3 = Calculatec3 (c10, c20, c30, x, t, v, D, Kd, k1, k2, k3)
% cal P1
A1 = D/(1+Kd);
lam1 =((v^2)/(4*D))+k1;
lam1 = (lam1/(1+Kd));
lambda1 =lam1/A1; 
P1 = CalculateP (x, t, v, D, A1, lambda1);
% Cal P2
A2 = D;
lam2 =((v^2)/(4*D))+k2;
lambda2 =lam2/D;
P2 = CalculateP (x, t, v, D, A2, lambda2);
% Cal P3
A3 = D;
lam3 =((v^2)/(4*D))+k3;
lambda3 =lam3/D;
P3 = CalculateP (x, t, v, D, A3, lambda3);
% Cal Pa
lambdaA=(lam2-lam1)/(D-A1);
Pa = CalculateP (x, t, v, D, A2, lambdaA);
% Cal Pb
Pb = CalculateP (x, t, v, D, A1, lambdaA);
% Cal Pc
lambdaB=(lam3-lam1)/(D-A1);
Pc = CalculateP (x, t, v, D, A3, lambdaB);
% Cal Pd
Pd = CalculateP (x, t, v, D, A1, lambdaB);

B = (k2*c20)/(k3-k2);
C = (k1*k2*c10)/((k2-k1)*(k3-k1)*(k3-k2));
D = (k1*k2*c10)/((k2-k1)*(k3-k2));
E = (k1*k2*c10)/((k3-k1)*(k3-k2));
c3 = c30*P3 + B*(P2-P3)+C*((k2-k1)*P3+(k1-k3)*P2+(k3-k2)*P1)+D*exp(((k2-k1)*t)/Kd)* (Pa-Pb) - E*exp(((k3-k1)*t)/Kd)*(Pc-Pd);

end