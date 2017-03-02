classdef COMSOL_1D <  COMSOL_Interface_1D
    properties
    end
    methods
        
        % ======================================================================
        %
        % Constructor --> this=COMSOL_Interface_1D(Morphology, Equation, Initial_Field )
        %
        %   inputs: 1) Morphology class
        %           2) Equation class.
        %           3) Array Field class.
        %  
        %   output: 1) COMSOL_1D class.
        %   
        %   Instantiation of the COMSOL_1D class.
        %
        % ======================================================================
        function this = COMSOL_1D (Morphology, Equation, Initial_Field, varargin)
            if ~isempty(varargin)
                n=varargin{1};
            else
                n = 'Model';
            end
            this=this@COMSOL_Interface_1D(Morphology, Equation, Initial_Field,n);
        end
        
        
        
        % ======================================================================
        %
        % Equations --> Setting_Equations_Comsol(this)
        %
        %   inputs: 1) double class.
        %           2) double class.
        %           3) Problem_Transp_Definition class.
        %  
        %   output: 1) COMSOL_1D_Column class.
        %   
        %   Instantiation of the COMSOL_1D_Column class.
        %
        % ======================================================================
        function Setting_Equations_Comsol(this, model)
            model.physics.create('esst', 'SoluteTransport', 'geom');
        end
        
        % ======================================================================
        %
        % Richards --> Variation_List_Richards(this, list_elements_transport)
        %
        %   Not applicable
        %
        % ======================================================================
        function Setting_Parameters_Transport (this, model,P_T_D, list_elements_transport)
            model.physics('esst').field('massconcentration').component(list_elements_transport);
            model.physics('esst').feature('mlis1').set('DispersionTensor', 'DispersivityShared');
            model.physics('esst').feature('mlis1').set('alpha', [P_T_D.T_P_P.dispersivity,0,0]);
            model.physics('esst').feature('mlis1').set ('u', [P_T_D.T_P_P.velocity_aqueous,0,0]);
            model.physics('esst').feature('mlis1').set('thetas', P_T_D.T_P_P.solid_properties.pore_volume_fraction);
            %
%             model.physics('esst').feature('mlis1').set('FluidPhaseTortuosityType', 1, 'UserDefined');
%             model.physics('esst').feature('mlis1').set('tauL', 1, '1');
            %Loop for the diffusion variables
            for i=1:size(list_elements_transport,2)
                model.physics('esst').feature('mlis1').set(strcat('DL_', num2str(i-1)), 1, P_T_D.T_P_P.molecular_diffusion_liquid());
                model.physics('esst').feature('mlis1').set('tauL', i, '1');
            end
            % Setting initial values
            for i=1:size(list_elements_transport,2)
                s=strcat('init',num2str(i), '_', list_elements_transport{i});
                model.physics('esst').feature('init1').set(list_elements_transport{1,i}, 1, s);
            end
            
        end
        
        
        %
        %
        %
        %
        function Study_Solver_Active_Equations(this, model)
            model.study('std1').feature('time').activate('esst', true);
        end
        
        %
        % st=type
        %  z=parametrs
        function [st, z]=Boundary_Condition_Transport (this, P_T_D, I)
            if I==1
                st=P_T_D.Boundary_Condition.Get_Inputnode_Type;
                z=P_T_D.Boundary_Condition.Get_Inputnode_Parameters;
            else
                st=P_T_D.Boundary_Condition.Get_Outputnode_Type;
                z=P_T_D.Boundary_Condition.Get_Outputnode_Parameters;
            end
        end
        %
        % Compare that the upstream and downstream have the same boundary
        % condition.
        %
        function b= BC_Transport_Equal_1D(this, P_T_D)
            b=strcmpi(P_T_D.Boundary_Condition.Get_Inputnode_Type, P_T_D.Boundary_Condition.Get_Outputnode_Type);
        end

    end
end