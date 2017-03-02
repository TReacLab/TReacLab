% This function solve a decay chain withdraw from:
% M.Lunn, R.J. Lunn, R. Mackay "Determining analytic solutions of multiple species contaminant transport, with sorption and decay" Journal of Hydrology 180 (1996) 195-210.
% T.P. Clement, Y.Sun, B.S. Hooker, and J.N. Petersen "Modeling multispecies reactive transport in ground water"

classdef Interface_Lunn_Bench_Chemistry < Interface 
    properties
        prev_data
    end
    methods
        function this = Interface_Lunn_Bench_Chemistry (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin)  
            parm = Coupler2SolveEngine(this, Data, Time, varargin);
            out  = this.solve_engine.Time_Stepping (parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm = Coupler2SolveEngine(this, Data, Time, varargin)
            this.prev_data = Data;
            dt=Time.Get_Time_Interval;
            C=Data.Get_Desired_Array ('Solution');
            C_ini = C.Get_Array;
            [n_cells, col] = size(C_ini);
            % This interface has been done specific for the Lunn bench,
            % where there are 3 solutes. It is assumed that C_ini looks
            % like --> C_ini = [C1 C2 C3], where Ci is a vector i = 1, 2 ,3
            
            % check if the columns of C_ini is equal to 3
            assert(col == 3,'[Interface_Lunn_Bench_Chemistry\Coupler2SolveEngine] Too many solutes. Check me!\n')
     
            parm = {C_ini, dt, n_cells};
        end
        
        function Data = SolveEngine2Coupler (this, out)
            Data = this.prev_data;
            li = this.prev_data.Get_Transport_Elements;
            for i=1:length(li)
                 Data = Data.Update_Array_Element ( out(:,i), li{i});
            end
        end
    end
end