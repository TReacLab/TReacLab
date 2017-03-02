

classdef Transport_Physical_Parameters
    properties 
        velocity_aqueous                % Vector with the aqueous velocity [vx, vy, vz]
        velocity_gas                    % Vector with the gas velocity [vx, vy, vz]
        dispersivity                    % it is a dispersivity 
        molecular_diffusion_liquid      % it is a vector with the diffusion values [Dc Dh Db Df] or a constant liquid
        dispersion                      % It is the dispersion or a constant
        disp_diff                       % it is a vector with different dispersion// maybe in the future it can be calculated using this class.
        retardation                     % Retardation value
        solid_properties                % like density, permeability, viscosity, porosity saturation
        fluid_properties                % fluid properties
        richard_parameters              % Richards Parameters
        molecular_diffusion_gas         % it is a vector with the diffusion values [Dc Dh Db Df] or a constant gas
        a                               % parameter MillingtonQuirk Diffusion Porosity
        b                               % parameter MillingtonQuirk Diffusion Saturation
    end
    
    methods

        %   Instantiate a Transport_Physical_Parameters class.

        function this=Transport_Physical_Parameters (Velocity, Dispersivity, Molecular_Diffusion_Liquid, Dispersion, Retardation)
            this.velocity_aqueous=Velocity;
            this.dispersivity=Dispersivity;
            this.molecular_diffusion_liquid= Molecular_Diffusion_Liquid;
            this.dispersion=Dispersion;
            this.retardation=Retardation;
        end 
        
        % Add gas diffusion
        
        function this= Add_Gas_Diffusion (this, Diffusion_Gas)
            this.molecular_diffusion_gas=Diffusion_Gas;
        end
        
        % Add gas velocity
        
        function this= Add_Gas_velocity (this, velocity_gas)
            this.velocity_gas=velocity_gas;
        end
        
        % Set Richards' parameters
        
        function this = Set_Richard_Parameters(this, Richard_Parameters)
            this.richard_parameters =Richard_Parameters;
        end
        
        % Set solid properties class
        
        function this = Set_Solid_Properties (this, Solid_Properties)
            this.solid_properties = Solid_Properties;
        end
        
        % Set fluid properties class
        
        function this = Set_Fluid_Properties (this, Fluid_Properties)
            this.fluid_properties = Fluid_Properties;
        end
        
        % Calculate the dispersion tensor for a 1D problem using a
        % directional dispersivity.
        
        function dispersion=Calculate_Saturated_Directional_Dispersion_1D (this)
            dispersion=this.dispersivity*abs(this.velocity_aqueous);
        end
        
        % Add the Millington and Quirk parameters related to the diffusion
        % of liquid and gases
        
        function this = Add_MillingtonQuirk_Diffusion_Parameters (this, parameter_porosity, parameter_saturation)
            this.a = parameter_porosity;
            this.b = parameter_saturation;
        end
        
        % Calculate the effective Millington and Quirk diffusion regarding
        % if it is gas or liquid
        
        function Def = Effective_Diffusion_MillingtonQuirk (this, Saturation_Phase, porosity, phasestring)
            if strcmpi(phasestring,'liquid')
                a=this.molecular_diffusion_liquid;
            elseif strcmpi(phasestring,'gas')
                a=this.molecular_diffusion_gas;
            end
            if isempty(a)
                error('[Transport_Physical_Parameters/Effective_Diffusion_MillingtonQuirk] No effective diffusion parameter for effective diffusion calculation');
            end
            %
            % Def=a.*(porosity.^(this.a)).*(Saturation_Phase.^(this.b));
            % the above statement was wrong since I did a typo forgetting
            % the number 1 in the exponent of the porosity.
            %
            
            %
            % A negative saturation value can output imaginary numbers,
            % therefore a round about trick must be use.
            %
            Saturation_Phase(Saturation_Phase<0)=0;
            %
            Def=a.*(porosity.^(1+this.a)).*(Saturation_Phase.^(this.b));
        end
    end
    
end