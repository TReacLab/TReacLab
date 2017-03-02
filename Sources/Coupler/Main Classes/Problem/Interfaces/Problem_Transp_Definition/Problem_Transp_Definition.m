%   The following class contains parameter related to the transport
%   problems such as retardation, porosity, dispersion, etc, inside the
%   T_P_P property and parameter related to the Boundary Conditions.

classdef Problem_Transp_Definition
    properties
        T_P_P                               % Physical Transport Parameters Class
        Boundary_Condition                  % Boundary Conditions Class   
    end
    
    methods
          
        %   Instantiate a Problem_Transp_Definition class.

        function this=Problem_Transp_Definition (Transport_Physical_Parameter, Boundary_Condition)
            this.T_P_P =Transport_Physical_Parameter;
            this.Boundary_Condition=Boundary_Condition;
        end
    end
end