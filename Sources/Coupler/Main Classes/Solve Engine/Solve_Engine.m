% Abstract Class [Application of Dependency Inversion Principle]
%
%   No properties
%
%   There are just one methods, Time_Stepping. 


classdef Solve_Engine < handle
    properties
    end
    methods
        %constructor
        function this=Solve_Engine()
        end
    end
    
    % Solve method for just one time step
    
    methods (Abstract)
        c2=Time_Stepping (this, varargin)  
    end

end
