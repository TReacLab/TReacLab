classdef COMSOL_Interface_1D < Solve_Engine
    properties (Access=protected)
        P_T_D                           % Problem transport Definition [contains 'Transport_Physical_Parameters' and 'Boundary Conditions' class]
        morpho                          % It stores the spatial nodes where the initial concentration must be given.
        model                           % It stores the model in Comsol
        b_modOH
    end
    methods (Abstract)
        Setting_Equations_Comsol(this, model)
        Setting_Parameters_Transport (this, model, P_T_D, list_elements_transport)
        Study_Solver_Active_Equations(this, model)
        [st, z]=Boundary_Condition_Transport (this, P_T_D, I);
        b=BC_Transport_Equal_1D(this, P_T_D)
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
        %   output: 1) COMSOL_Interface_1D class.
        %   
        %   Instantiation of the COMSOL_Interface_1D class.
        %
        % ======================================================================
        function this = COMSOL_Interface_1D (Morphology, Equation, Initial_Field, varargin)
            list_transp_elements=Initial_Field.Get_List_Identifiers.Get_Mobile_Species;
            Parameters=Equation.Get_Parameters();
            this.P_T_D=Parameters{1}; 
            this.model = this.Creating_Model_Comsol (varargin{1});
            this.morpho=Morphology;
            d = this.morpho.Get_Edges_Domain();
%             this.morpho.Write_Geometry_In_Comsol(this.model);  %#D: Quizas se debe pasar el modelo como argumento
%             this.morpho.Write_Mesh_2_In_Comsol(this.model);
            this.Write_Geometry_In_Comsol(d);
            vect = this.morpho.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges;
            this.Write_Mesh_In_Comsol(vect);
            this.Creating_Interpolation_1D_Comsol(list_transp_elements);
            this.Creating_Physics_1D_Comsol( list_transp_elements, Parameters{1});
            this.Creating_StudySolver_1D_Comsol();
            if length(Parameters) >=2
                this.b_modOH = Parameters{2};
            else
                this.b_modOH = true;
            end
        end
        
        % ======================================================================
        %
        % Time Stepping --> C2=Time_Stepping (this, C1, Time)
        %
        %   inputs: 1) your COMSOL_Interface_1D class
        %           2) Array_Field class
        %           3) Time class.
        %  
        %   output: 1) Array_Field class
        %   
        %   It outputs a new Array_Field class after one time step.
        %
        % ======================================================================
        function pd=Time_Stepping (this, parm)
%              list_elements_transport=C1.Get_List_Identifiers.Get_Mobile_Species;
%              list_elements_transport=Working_Element_List_1(list_elements_transport);
            Array = parm{1};
            list_elements_transport = parm{2};
            ini_t = parm{3};
            dt = parm{4};
            fin_t = parm{5};
            
            
             this.Setting_Ini_Values( Array);
             this.Change_Time_And_Run(ini_t, dt, fin_t)
             pd=mpheval(this.model, list_elements_transport);
        end
        
        
        %
        %
        %
        function Setting_Ini_Values(this, Matrix_Initialvalues_System)
            for i=1:size(Matrix_Initialvalues_System,2)
                s=strcat('init',num2str(i, 20));
                for j=1:size(Matrix_Initialvalues_System, 1)
                    this.model.func(s).setIndex('table', Matrix_Initialvalues_System(j,i), j-1, 1);
                end
            end
        end
        
        %
        %
        %
        function Change_Time_And_Run(this, ini_t, dt, fin_t)
            or=sprintf('range(%s, %s, %s)', num2str(ini_t, 20), num2str(dt/10, 20), num2str(fin_t, 20)); %#D: Remove or not the 10from Time.Get_DT
            this.model.study('std1').feature('time').set('tlist', or);
            this.model.study('std1').run;
        end
        % ======================================================================
        %
        % Create Comsol Com --> model=Creating_Model_Comsol (this)
        %
        %   inputs: 1) COMSOL_Interface class
        %  
        %   output: 1) COM model
        %   
        %   This function creates a Comsol model into the COMSOL Server.
        %
        % ======================================================================
        function model=Creating_Model_Comsol (this, varargin)
            s='Model';
            if ~isempty(varargin)
                s = num2str(varargin{1});
            end
            
            %Import Livelink
            import com.comsol.model.*
            import com.comsol.model.util.*
            
            % Import model
            model = ModelUtil.create(s);
            model.hist.disable
        end
        
        % ======================================================================
        %
        % Interpolation funciton Frame Comsol --> Creating_Interpolation_1D_Comsol(this, list_element_transport)
        %
        %   inputs: 1) COMSOL_Interface class
        %   
        %   This function creates the frame of functions that are going to
        %   be used in Comsol as initial values for each mesh point.
        %
        % ======================================================================
        function Creating_Interpolation_1D_Comsol(this, list_element_transport)
            list_element_transport=Working_Element_List_1(list_element_transport);
            Mesh=this.morpho.Get_Vector_Regular_centeredDiscretization_Points;
            for i=1:size(list_element_transport,2) 
                s=strcat('init',num2str(i, 20));
                this.model.func.create(s, 'Interpolation');
                this.model.func(s).model('mod1');
                d=strcat(s,'_',list_element_transport{i});
                this.model.func(s).set('funcname', d);
                this.model.func(s).set('defvars', 'on');
                this.model.func(s).set('frame', 'mesh');
                for j=1:length(Mesh)
                    this.model.func(s).setIndex('table', num2str(Mesh(j),20), j-1, 0);  %# Try in the constructor.
                end
            end
        end
        
        % ======================================================================
        %
        % Interpolation funciton Frame Comsol --> Creating_Interpolation_1D_Comsol(this, list_element_transport)
        %
        %   inputs: 1) COMSOL_Interface class
        %   
        %   This function creates the frame of functions that are going to
        %   be used in Comsol as initial values for each mesh point.
        %
        % ======================================================================
        function Creating_Physics_1D_Comsol( this, list_elements_transport, P_T_D)
            list_elements_transport=Working_Element_List_1 (list_elements_transport);
            this.Setting_Equations_Comsol (this.model);
            this.Setting_Parameters_Transport (this.model, P_T_D, list_elements_transport);
            this.Creating_BC_Transport (P_T_D, list_elements_transport);
        end
        
        function Creating_BC_Transport (this, P_T_D, List_Elements_Transport)
            b=this.BC_Transport_Equal_1D(P_T_D);
            if b==true
                Creating_Same_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport);
            else
                Creating_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport, 1)
                Creating_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport, 2)
            end
        end
%
%         function Creating_BC_Transport (this, P_T_D, List_Elements_Transport)
%             Creating_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport, 1)
%             Creating_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport, 2)
%         end

        
        function Creating_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport, I)
            [st, z]=this.Boundary_Condition_Transport (P_T_D, I);
            
            if strcmpi(st, 'outflow')
                this.model.physics('esst').feature.create('out1', 'Outflow', 0);
                this.model.physics('esst').feature('out1').selection.set([I]);
                
            elseif strcmpi(st, 'inflow')
                this.model.physics('esst').feature.create('in1', 'Inflow', 0);
                this.model.physics('esst').feature('in1').selection.set([I]);
                for I=1:(size(z, 2)/2) % Input inflow
                    s=strrep(z{((2*I)-1)}, '(g)', '_g');
                    [~,v]=ismember(s,List_Elements_Transport);
                    this.model.physics('esst').feature('in1').set('c0', v, z{2*I});
                end
            elseif strcmpi(st, 'closed') || strcmpi(st,'simmetry') % For Comsol simmetry and closed have the same formula the only difference resides
                this.model.physics('esst').feature.create('sym1', 'Symmetry', 0);
                this.model.physics('esst').feature('sym1').selection.set([I]);
            elseif strcmpi(st, 'open_boundary')
                this.model.physics('esst').feature.create('open1', 'OpenBoundary', 0);
                this.model.physics('esst').feature('open1').selection.set([I]);
                for I=1:(size(z, 2)/2)
                    s=strrep(z{((2*I)-1)}, '(g)', '_g');
                    [~,v]=ismember(s,List_Elements_Transport);
                    this.model.physics('esst').feature('open1').set('c0', v, z{2*I});
                end
            elseif strcmpi(st, 'flux')
                this.model.physics('esst').feature.create('flux1', 'Flux0', 0);
                this.model.physics('esst').feature('flux1').selection.set([I]);
            elseif strcmpi (st, 'no_flux')
                this.model.physics('esst').feature.create('nflx1', 'NoFlux', 0);
                this.model.physics('esst').feature('nflx1').selection.set([I]);
            end
        end
        
        
        function Creating_Same_BC_Node_Transport_1D(this, P_T_D, List_Elements_Transport)
            [st, z1]=this.Boundary_Condition_Transport (P_T_D, 1);
            [~, z2]=this.Boundary_Condition_Transport (P_T_D, 2);
            
            if strcmpi(st, 'outflow')
                this.model.physics('esst').feature.create('out1', 'Outflow', 0);
                this.model.physics('esst').feature('out1').selection.set([1]);
                this.model.physics('esst').feature('out1').selection.set([2]);
            elseif strcmpi(st, 'inflow')
                this.model.physics('esst').feature.create('in1', 'Inflow', 0);
                this.model.physics('esst').feature('in1').selection.set([1]);
                for I=1:(size(z1, 2)/2) % Input inflow
                    s=strrep(z1{((2*I)-1)}, '(g)', '_g');
                    [~,v]=ismember(s,List_Elements_Transport);
                    this.model.physics('esst').feature('in1').set('c0', v, z1{2*I});
                end
                this.model.physics('esst').feature.create('in2', 'Inflow', 0);
                this.model.physics('esst').feature('in2').selection.set([2]);
                for I=1:(size(z2, 2)/2) % Input inflow
                    s=strrep(z2{((2*I)-1)}, '(g)', '_g');
                    [~,v]=ismember(s,List_Elements_Transport);
                    this.model.physics('esst').feature('in1').set('c0', v, z2{2*I});
                end
            elseif strcmpi(st, 'closed') || strcmpi(st,'simmetry') % For Comsol simmetry and closed have the same formula the only difference resides
                this.model.physics('esst').feature.create('sym1', 'Symmetry', 0);
                this.model.physics('esst').feature('sym1').selection.set(1);
                this.model.physics('esst').feature('sym1').selection.set(2);
            elseif strcmpi(st, 'open_boundary')
                this.model.physics('esst').feature.create('open1', 'OpenBoundary', 0);
                this.model.physics('esst').feature('open1').selection.set(1);
                for I=1:(size(z1, 2)/2)
                    s=strrep(z1{((2*I)-1)}, '(g)', '_g');
                    [~,v]=ismember(s,List_Elements_Transport);
                    this.model.physics('esst').feature('open1').set('c0', v, z1{2*I});
                end
                this.model.physics('esst').feature.create('open2', 'OpenBoundary', 0);
                this.model.physics('esst').feature('open2').selection.set(2);
                for I=1:(size(z2, 2)/2)
                    s=strrep(z2{((2*I)-1)}, '(g)', '_g');
                    [~,v]=ismember(s,List_Elements_Transport);
                    this.model.physics('esst').feature('open2').set('c0', v, z2{2*I});
                end
            elseif strcmpi(st, 'flux')
                this.model.physics('esst').feature.create('flux1', 'Flux0', 0);
                this.model.physics('esst').feature('flux1').selection.set(1);
                if ~isempty(z1)
                    for I=1:(size(z1, 2)/2)
                        this.model.physics('esst').feature('flux1').set('species', I, '1');
                        this.model.physics('esst').feature('flux1').set('N0', I, z1{2*I});
                    end
                end
                this.model.physics('esst').feature.create('flux2', 'Flux0', 0);
                this.model.physics('esst').feature('flux2').selection.set(2);
                if ~isempty(z2)
                    for I=1:(size(z2, 2)/2)
                        this.model.physics('esst').feature('flux2').set('species', I, '1');
                        this.model.physics('esst').feature('flux2').set('N0', I, strcat('-',z2{2*I}));
                    end
                end
            elseif strcmpi(st, 'no_flux')
                this.model.physics('esst').feature.create('nflx1', 'NoFlux', 0);
                this.model.physics('esst').feature('nflx1').selection.all;
            end
        end
        
        
        
        function Creating_StudySolver_1D_Comsol(this)
            this.model.study.create('std1');
            this.model.study('std1').feature.create('time', 'Transient');
            this.model.study('std1').feature('time').set('rtolactive', 'on');
            this.model.study('std1').feature('time').set('rtol', '1e-9');
            this.Study_Solver_Active_Equations(this.model);
            sol1=this.model.sol.create('sol1');
            sol1.study('std1');
            sol1.feature.create('st1', 'StudyStep');
            sol1.feature('st1').set('study', 'std1');
            sol1.feature('st1').set('studystep', 'time');
            sol1.feature.create('v1', 'Variables');
            sol1.feature('v1').set('control', 'time');
            sol1.feature.create('t1', 'Time');
            sol1.feature('t1').set('tlist', 'range(0,0.1,1)');
            sol1.feature('t1').set('plot', 'off');
            sol1.feature('t1').set('plotfreq', 'tout');
            sol1.feature('t1').set('probesel', 'all');
            sol1.feature('t1').set('probes', {});
            sol1.feature('t1').set('probefreq', 'tsteps');
            sol1.feature('t1').set('control', 'time');
            sol1.feature('t1').feature.create('fc1', 'FullyCoupled');
            sol1.feature('t1').feature.remove('fcDef');
            this.model.sol('sol1').feature('t1').set('atolglobal', '0.0000000000010');
            % BDF
%             sol1.feature('t1').set('maxorder', '1');
%             sol1.feature('t1').set('minorder', '1');
            
            sol1.attach('std1');
            
        end
        
        function Creating_StudySolver_1D_Comsol_Explicit(this)
            this.model.study.create('std1');
            this.model.study('std1').feature.create('time', 'Transient');
            this.model.study('std1').feature('time').set('rtolactive', 'on');
            this.model.study('std1').feature('time').set('rtol', '1e-9');
            this.Study_Solver_Active_Equations(this.model);
            this.model.sol.create('sol1'); 
            this.model.sol('sol1').feature.create('st1', 'StudyStep');
            this.model.sol('sol1').feature('st1').set('study', 'std1');
            this.model.sol('sol1').feature('st1').set('studystep', 'time');
            this.model.sol('sol1').feature.create('v1', 'Variables');
            this.model.sol('sol1').feature('v1').set('control', 'time');
            this.model.sol('sol1').feature.create('tx1', 'TimeExplicit');
            this.model.sol('sol1').feature('tx1').set('control', 'time');
            this.model.sol('sol1').feature('tx1').set('tstepping', 'manual');
            this.model.sol('sol1').feature('tx1').set('rktimestep', '1.e-3');
            this.model.sol('sol1').feature('tx1').set('odesolver', 'erk');
            % order Runga-Kutta
            this.model.sol('sol1').feature('tx1').set('erkorder', '4');
            this.model.sol('sol1').feature('tx1').set('linsolver', 'dDef');
            
            this.model.sol('sol1').attach('std1');
        end
        
        % It writes the 1D geometry into the Comsol Com object
        % The input is the initial and final point of the segment.
        function Write_Geometry_In_Comsol(this, d)
            %Creating geometry
            geom=this.model.geom.create('geom', 1);
            Int=geom.feature.create('Int', 'Interval');
            Int.set('p2', d(2));  
            Int.set('p1', d(1));
            geom.runAll;
        end
        
        
        function Write_Mesh_In_Comsol(this, vect)
            mesh1=this.model.mesh.create('mesh1', 'geom');
            mesh1.automatic(false);
            mesh1.feature('size').set('custom','on');
            this.model.mesh('mesh1').feature('edg1').feature.create('dis1', 'Distribution');
            this.model.mesh('mesh1').feature('edg1').feature('dis1').set('type', 'explicit');
            this.model.mesh('mesh1').feature('edg1').feature('dis1').set('explicit', vect);
            this.model.mesh('mesh1').run('edg1');
            mesh1.run;
        end
        
        function b = Get_modOH (this)
            b = this.b_modOH;
        end
        
    end
end