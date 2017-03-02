% This process does not apply any modification to the input, namely f(x)=x.

classdef Process_Identity<Solve_Engine
    properties
    end
    methods
        
        % Constructor
        function this=Process_Identity()
        end
        
        % Time Stepping
        
        function c2=Time_Stepping (this, C1,Time)
            c2=C1;
        end
        

    end
end