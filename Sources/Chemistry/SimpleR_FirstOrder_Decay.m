%
% The class represent a first order decay reaction:
%
%   dA/dt = -KA             (eq 1)
%
%   A is the concentration; K is the rate constant
%
%   The solution of such equation is given by:
%
%   ln A = -K*t + ln A0             (eq 2)
%
%   t is the interval of time, and A0 is the initial value
%
%   The equation can also be expressed by:
%       A = A0*exp(-kt)
%   
%   The exact time integration can be substituted by a theta method
%   numerical integration:
%
%   A = A0 + (-kt) * ((1-theta)*A0 + theta*A)
%
%   which turns out to be:
%
%   A = (A0 + (-kt)*(1-theta)*A0) / (1 - theta*t*(-k))
%
%   if theta = 1 the method is implicit, if theta is 0 the method is
%   explicit. Otherwise, it will be semiimplicit.
%

classdef SimpleR_FirstOrder_Decay  < Solve_Engine
    properties
        k                   % rate constant
        string              % 'Analytical'/'Numerical'/'Matlab', indicates what kind of integration are we willing to use.
        theta               % In the case of Numerical, the theta values must be given. (1 = Implicit, 0 = Explicit)
        string_matlab       % In the case of using a Matlab ode set
        equation
    end
 
    methods
        function this = SimpleR_FirstOrder_Decay ( Equation, Initial_Field)
            % For the Par (parameter) different possibilities exist (K must always being specified)
            % Par = {K, 'Analytic'}
            % Par = {K, 'Numerical', theta}
            % Par = {K, 'Matlab', string_matlab }
            this.equation = Equation;
            Par=Equation.Get_Parameters();
            this.k = Par{1};
            
            if strcmpi(Par{2}, 'Analytical')
                this.string = Par{2};
            elseif strcmpi(Par{2}, 'Numerical')
                this.string = Par{2};
                assert(Par {3} >=0 && Par {3} <=1 ,'[SimpleR_FirstOrder_Decay/ SimpleR_FirstOrder_Decay] Theta must be between 0 and 1.\n')
                this.theta  = Par {3};
            elseif strcmpi(Par{2}, 'Matlab')
                this.string = Par{2};
                this.Assert_ODE_Matlab(Par{3});
                this.string_matlab = Par{3};
            else
                error ('[SimpleR_FirstOrder_Decay/ SimpleR_FirstOrder_Decay] The second parameter must be an string as ''Analytical''/''Numerical''/''Matlab''.\n');
            end
            
        end
        
        function Assert_ODE_Matlab (this, str_mat)
            assert(strcmpi(str_mat, 'ode45') || strcmpi(str_mat, 'ode23') || strcmpi(str_mat, 'ode113'), '[SimpleR_FirstOrder_Decay/ SimpleR_FirstOrder_Decay] Implemeted ode45, ode23 and ode113.\n')
        end
        
        
        function C_n = Time_Stepping (this, parm)
            
            ini_t = parm{1};
            dt = parm{2};
            fin_t = parm{3};
            C_n = parm{4};
            
            if strcmpi(this.string, 'Analytical')                
                C_n = C_n.*exp(-this.k*dt);
            elseif strcmpi(this.string, 'Numerical')
                C_n = (C_n.*(1- (1-this.theta)*this.k*dt))/(1 + this.theta*this.k*dt);
            elseif strcmpi (this.string, 'Matlab')
                if strcmpi (this.string_matlab, 'ode45')
                     y = ode45(this.equation.Get_Func, [ini_t, fin_t], C_n,[], this.k);
                elseif strcmpi (this.string_matlab, 'ode23')
                    y = ode23(this.equation.Get_Func, [ini_t, fin_t], C_n,[], this.k);
                elseif strcmpi (this.string_matlab, 'ode113')
                    y = ode113(this.equation.Get_Func, [ini_t, fin_t], C_n,[], this.k);
                end
                C_n = y.y(:, end);
            end
            
        end
    end
end