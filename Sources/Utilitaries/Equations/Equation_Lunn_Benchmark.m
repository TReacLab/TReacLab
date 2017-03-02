classdef Equation_Lunn_Benchmark < Equation
    properties 
    end
    methods
        function this = Equation_Lunn_Benchmark (Parameters)
            this=this@Equation (@ODE_linearhomogeneous_constantcoeff, Parameters);
        end        
    end
end