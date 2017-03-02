% This class is required when more than one boundary condition class is
% defined. For instance, when flow boundary conditions and transport
% boundary conditions should be defined in order to solve a problem.


classdef Set_Boundary_Conditions
    properties 
        boundary_transport_aqueous_phase
        boundary_transport_gas_phase
        boundary_richards
        boundary_flow_singlephase
        boundary_flow_multiphase
    end
    methods
        
        % instantiate the set boundaries
        
        function this = Set_Boundary_Conditions ()
        end
        
        % Set liquid transport boundaries
        
        function this = Set_Boundary_Conditions_Transport_Liquid (this, B_C)
            this.boundary_transport_aqueous_phase=B_C;
        end
        
        % Set gas transport boundaries
        
        function this = Set_Boundary_Conditions_Transport_Gas (this,B_C)
            this.boundary_transport_gas_phase=B_C;
        end
        
        % Set Richard flow boundaries
        
        function this = Set_Boundary_Conditions_Richards (this,B_C)
            this.boundary_richards=B_C;
        end
        
        % Set singlephase flow boundaries
        
        function this = Set_Boundary_Flow_SinglePhase (this,B_C)
            this.boundary_flow_singlephase=B_C;
        end
        
        % Set multiphase flow boundaries
        
        function this = Set_Boundary_Flow_MultiPhase (this,B_C)
            this.boundary_flow_multiphase=B_C;
        end
        
        % Get liquid transport boundaries
        
        function B_T = Get_Boundary_Transport_Liquid (this)
            B_T=this.boundary_transport_aqueous_phase;
        end
        
        % Get gas transport boundaries
        
        function B_T = Get_Boundary_Transport_Gas (this)
            B_T=this.boundary_transport_gas_phase;
        end
        
        % Get Richard flow boundaries
        
        function B_R = Get_Boundary_Richards (this)
            B_R=this.boundary_richards;
        end
        
        % Get singlephase flow boundaries
        
        function B_T = Get_Boundary_Flow_SinglePhase(this)
            B_T=this.boundary_flow_singlephase;
        end
        
        % Get multiphase flow boundaries
        
        function B_R = Get_Boundary_Flow_MultiPhase(this)
            B_R=this.boundary_flow_multiphase;
        end
    end
end