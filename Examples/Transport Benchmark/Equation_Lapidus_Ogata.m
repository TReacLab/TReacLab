classdef Equation_Lapidus_Ogata < Equation

   properties 
    end
    methods
        function this = Equation_Lapidus_Ogata (Parameters)
            this=this@Equation(@Analytical_Transport_1D_Column_ConstantProfile, Parameters);
        end        
    end
end