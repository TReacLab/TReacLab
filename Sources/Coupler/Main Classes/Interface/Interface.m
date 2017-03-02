% Abstract Class [Application of Dependency Inversion Principle]
%
%   No properties
%



classdef Interface < handle
    properties 
        solve_engine
    end
    methods
        %constructor
        function this = Interface(Solve_Engine ,varargin)
            this.solve_engine = Solve_Engine;
        end
    end
    
    % Solve method for just one time step
    
    methods (Abstract)
        Data = Time_Stepping (this, Data, Time, varargin)  
        parm = Coupler2SolveEngine (this, Data, Time, varargin)
        Data = SolveEngine2Coupler (this, varargin)
    end

end
