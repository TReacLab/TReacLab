classdef Equation_PhreeqcRM_v1 < Equation
    properties 
    end
    methods
        function this = Equation_PhreeqcRM_v1 (Parameters)
            this=this@Equation (@PhreeqcRM_v1, Parameters);
        end        
        
        function C_n1  = Time_Stepping (this, parm)
            %
        end
    end
end