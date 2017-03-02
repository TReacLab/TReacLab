% This function solve a decay chain withdraw from:
% M.Lunn, R.J. Lunn, R. Mackay "Determining analytic solutions of multiple species contaminant transport, with sorption and decay" Journal of Hydrology 180 (1996) 195-210.
% T.P. Clement, Y.Sun, B.S. Hooker, and J.N. Petersen "Modeling multispecies reactive transport in ground water"


classdef Lunn_Bench_Chemistry < Solve_Engine
    properties
        Matrix_Sys
        funk
    end
    methods
        % Constructor
        function this = Lunn_Bench_Chemistry(Equation, Initial_Concentration)
            this.Matrix_Sys = Equation.Get_Parameters{1};
            this.funk = Equation.Get_Func;
        end
        
        % time stepping
        function C_n1  = Time_Stepping (this, parm)
            % parm = {C_ini, dt, n_cells}
            C_ini = parm{1};
            C_n1 = C_ini;
            dt = parm{2};
            n_cells = parm{3};
            % ode45(this.equation.Get_Func, [Time.Get_Initial_Time, Time.Get_Final_Time], C1,[],a)
            for i = 1:n_cells
                a = ode45(this.funk, [0, dt], C_ini(i, :)',[], this.Matrix_Sys);
                C_n1(i, :) = a.y(:, end)';
            end
        end
    end
end