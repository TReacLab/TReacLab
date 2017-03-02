classdef Equation_Phreeqc_BatchSeq < Equation
    properties 
    end
    methods
        function this = Equation_Phreeqc_BatchSeq (Parameters)
            this=this@Equation (@Phreeqc_Batch_Seq, Parameters);
        end        
    end
end