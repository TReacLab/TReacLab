classdef Equation_BinarySolution_PrecipitationDissolution < Equation
    properties 
    end
    methods
        function this =  Equation_BinarySolution_PrecipitationDissolution (Parameters)
            this=this@Equation(@TwoSpecies_Dissolution_Precipitation, Parameters);
        end
    end
end