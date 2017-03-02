classdef Equation_Phreeqc_BatchPar < Equation
    properties 
    end
    methods
        function this = Equation_Phreeqc_BatchPar (Parameters)
            this=this@Equation (@Phreeqc_Batch_Par, Parameters);
        end        
    end
end
