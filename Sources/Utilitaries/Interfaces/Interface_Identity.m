classdef Interface_Identity < Interface 
    properties
    end
    methods
        function this = Interface_Identity (Solve_Engine ,varargin)
        this = this@Interface(Solve_Engine ,varargin); 
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin) 
            parm = Coupler2SolveEngine (this, Data, Time, varargin);
            outp = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, outp);
        end
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            parm = Data;
        end
        function Data = SolveEngine2Coupler (this, varargin)
            Data = varargin{1};
        end
    end
end