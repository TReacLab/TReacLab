classdef Fluid_Properties
    properties
        dynamic_viscosity
        density
    end
    methods
        
        % Constructor of the Fluid Property class, the dynamic viscosity
        % and density should be given. It is considered homogeneous
        % along the liquid.
        
        function this = Fluid_Properties (Dynamic_Viscosity, Density)
            this.dynamic_viscosity= Dynamic_Viscosity;
            this.density=Density;
        end
    end
end