classdef Equation_FirstOrder_Decay_1Species < Equation
    properties 
    end
    methods
        function this =  Equation_FirstOrder_Decay_1Species (Parameters)
            this=this@Equation(@FirstOrder_Decay_1Species, Parameters);
        end
    end
end