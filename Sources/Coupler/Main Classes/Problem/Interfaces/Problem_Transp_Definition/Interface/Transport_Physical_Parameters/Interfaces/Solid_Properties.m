classdef Solid_Properties
    properties
        pore_volume_fraction                        % Volume fraction of fluid at saturation / Saturated liquid volume fraction / Pore volume fraction/ porosity
        liquid_volume_fraction                      % Liquid volume fraction/ volume fraction of fluid within the soil --> related with the C, Se, K
        saturation_liquid                           % Saturation_liquid is liquid_volume_fraction divided by pore_volume_fraction
        bulk_density                                %  mass of soil plus liquids/ volume as a whole
        hydraulic_conductivity_permeability         % cell containing a string that can be a)Hydraulic Conductivity b) Permeability and a value 
        residual_liquid_volume_fraction             %  Residual liquid volume fraction
        
        fluid_fraction_time_change                  % Property related to Comsol it has 3 possibilities
                                                    %          1) {'FluidFractionConstantInTime'}
                                                    %          2) {'TimeChangeInFluidFraction'   DO/dtvalue}
                                                    %          3)
                                                    %          {'TimeChangeInPressureHead' 'notuserdef/userdef'  Valueifuserdef if not value Cm  valuecm}
    end
    
    methods 
        
        % Instantiate the solid properties. The porosity should be given.
        
        function this = Solid_Properties (Pore_Volume_Fraction)
            this.pore_volume_fraction = Pore_Volume_Fraction;
        end
        
        % The liquid volume fraction is set and as well the saturation of
        % liquid. It is considered that the representative element volume
        % is equal to 1 liter.
        
        function this = Set_Liquid_Volume_Fraction (this, Liquid_Volume_Fraction)
            this.liquid_volume_fraction=Liquid_Volume_Fraction;
            this.saturation_liquid=Liquid_Volume_Fraction/this.pore_volume_fraction;
        end
        
        % Gives the tortuosity from a Millington and Quirk formulation
        % regarding the wetting or no wetting phase.
        
        function tortuosity = Tortuosity_Two_Phases_Gas_MillingtonQuirk (this, String)
            if strcmpi(String, 'wetting')
                tortuosity = (this.pore_volume_fraction.^(1/3)).*(this.saturation_liquid.^(7/3));
            elseif strcmpi(String, 'no_wetting')
                tortuosity = (this.pore_volume_fraction.^(1/3)).*((1-this.saturation_liquid).^(7/3));
            end
        end
        
        % Tortuosity when the liquid saturates the whole porous media
        
        function tortuosity = Tortuosity_Liquid_Saturated_MillingtonQuirk (this)
            tortuosity=this.pore_volume_fraction.^(1/3);
        end
        % set richards parameters (Comsol)
        
        function this = Set_Richard_Parameters(this, Hydraulic_Conductivity_Permeability, Residual_Liquid_Volume_Fraction )
            this.hydraulic_conductivity_permeability=Hydraulic_Conductivity_Permeability;
            this.residual_liquid_volume_fraction=Residual_Liquid_Volume_Fraction;
        end
        
        % Set parameter of Comsol for the use of Richards equations
        
        function this = Set_Fluid_Fraction_Time_Change_Comsol (this, A)
            this.fluid_fraction_time_change=A;
        end
        
        % Add the bulk density of the solid matrix
        
        function this=Added_Bulk_Density(Bulk_Density)
            this.bulk_density = Bulk_Density;
        end
    end
end