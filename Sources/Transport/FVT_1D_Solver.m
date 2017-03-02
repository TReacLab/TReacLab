% Like ohter 1D solver. This one is not going to be extra complex. It uses
% a TVD approach.
% - The boundary conditions of this class are considered as constant.

classdef FVT_1D_Solver < Solve_Engine
    properties
        meshFVT
        BC_class
        transport_species
        velocity
        diffusion
        Mdiffc
        FL
        b_modOH
        u
    end
    
    methods
        function this = FVT_1D_Solver (Morphology, Equation, Initial_Field)
            Par=Equation.Get_Parameters();
            % Problem Transport defintion
            P_T_D=Par{1};
            %fvt struct
            FVTstruct = Par{2};
            this.b_modOH = FVTstruct.b_modOH;
            % bc
            this.BC_class = P_T_D.Boundary_Condition;
            % Geometry
            dx = Morphology.Get_Mesh_Discretization_Value;
            L = Morphology.Get_Distance;
            Ncells = L/dx;
            this.meshFVT = createMesh1D(Ncells, L);
            
            % velocity & diffusion
            this.velocity = P_T_D.T_P_P.velocity_aqueous;
            this.diffusion = (P_T_D.T_P_P.solid_properties.Tortuosity_Liquid_Saturated_MillingtonQuirk()* P_T_D.T_P_P.molecular_diffusion_liquid)+...
                P_T_D.T_P_P.Calculate_Saturated_Directional_Dispersion_1D;

            % List
            this.transport_species = Initial_Field.Get_Transport_Elements;
            D = createCellVariable(this.meshFVT, this.diffusion);
            D_face=harmonicMean(D);
            this.Mdiffc=diffusionTerm(D_face);
            
            % Flux limiter (suposse constant during the whole simulation)
            stringfl = FVTstruct.FL;
            this.FL=fluxLimiter(stringfl);
            %
            this.u = createFaceVariable(this.meshFVT, this.velocity);
        end
        
        function C_n1  = Time_Stepping (this, parm)
            d = length(this.transport_species);
            % {dt, Constant_Storage_Term, rows, columns, A};
            C_n = parm {5};
            c = parm {4};
            r = parm {3};
            Constant_Storage_Term = parm {2};
            dt = parm {1};
            
            %
            C_n1 = C_n;
            
            % Boundary conditions
            % BCs = this.Create_BCs (this.transport_species, BC_class);
            BCs = Create_BCs (this, this.BC_class, C_n(1,:), C_n(end, :) );
            
            assert(d==c, '[FVT_1D_Solver/Time_Stepping] There is obviously a problem here.')
            
            
            phi = createCellVariable(this.meshFVT, Constant_Storage_Term);
            for z = 1 : d
                [Mbcc, RHSbcc] = boundaryCondition(BCs{z});
                
                
                
                c_old = createCellVariable(this.meshFVT, C_n(:, z), BCs{z});
                c_val = c_old;
                
                sub_dt = dt/10;
                for j =sub_dt:sub_dt:dt
                    [Mtransc, RHStransc] = transientTerm(c_old, sub_dt, phi);
                    for i = 1:10
                        [Mconvc, RHSconv]=convectionTvdTerm(this.u, c_val, this.FL);
                        Mc=-this.Mdiffc+Mconvc+Mbcc+Mtransc;
                        RHSc=RHSbcc+RHStransc+RHSconv;
                        c_val=solvePDE(this.meshFVT, Mc, RHSc);
                    end
                    c_old=c_val;
                    
                    i=i+1;
                end
                C_n1(:, z) = c_old.value(2:end-1);
            end
        end 
        
        
        
        
        
        
        
        
        % The BC in FVT are defined by:
        % a*div(phi)*n + b*phi = c
        %
        % where phi is the variable, a, b, and c are parameters that must
        % be given, and n is normal vector.
        function BCs = Create_BCs (this, BC_class, first_row_matrix, last_row_matrix)
            d = length(this.transport_species);
            BCs = cell(d, 1);
            % The BC_class is the default class of TReacLab in case of
            % changes.
            type_up = BC_class.Get_Inputnode_Type;
            type_down = BC_class.Get_Outputnode_Type;
            
            % types: 'closed' 'inflow' 'open_boundary' 'outflow' 'simmetry'.
            
            % up boundary
            if strcmpi(type_up, 'inflow') || strcmpi(type_up, 'concentration')
                inputnode_parameters = BC_class.Get_Inputnode_Parameters;
                if isempty(inputnode_parameters)
                    inputnode_parameters= {};
                    for i = 1:d
                        inputnode_parameters = [inputnode_parameters this.transport_species{i} double2str(first_row_matrix)];
                    end
                end
                for i = 1:d
                    [b, ind ] = ismember(this.transport_species{i},inputnode_parameters);
                    if b == true
                        BC = createBC(this.meshFVT);
                        BC.left.a = 0; BC.left.b = 1; BC.left.c = str2double(inputnode_parameters{ind+1}); % left boundaryBC.
                        BCs{i} = BC; 
                    else
                        error('[FVT_1D_Solver/Create_BCs] Apparently, there is a component %s that must be transport without boundary condition.\n', this.transport_species{i});
                    end
                end
            elseif strcmpi(type_up, 'closed') || strcmpi (type_up, 'simmetry')
                for i = 1:d
                    BC = createBC(this.meshFVT);
                    BC.left.a = this.diffusion; BC.left.b = this.velocity; BC.left.c = 0; % left boundaryBC.
                    BCs{i} = BC;
                end
            elseif strcmpi(type_up, 'openboundary')
                if this.velocity >=0
                    for i = 1:d
                        BC = createBC(this.meshFVT);
                        BC.left.a = this.diffusion; BC.left.b = 0; BC.left.c = 0; % left boundaryBC.
                        BCs{i} =BC;
                    end
                else
                    inputnode_parameters = BC_class.Get_Inputnode_Parameters;
                    for i = 1:d
                        [b, ind ] = ismember(this.transport_species{i},inputnode_parameters);
                        if b == true
                            BC = createBC(this.meshFVT);
                            BC.left.a = 0; BC.left.b=1; BC.left.c=str2double(inputnode_parameters{ind+1}); % left boundaryBC.
                            BCs{i} =BC;
                        else
                            error('[FVT_1D_Solver/Create_BCs] Apparently, there is a component %s that must be transport without boundary condition.\n', this.transport_species{i});
                        end
                    end
                end
            elseif strcmpi(type_up, 'flux') 
                inputnode_parameters = BC_class.Get_Inputnode_Parameters;
                if isempty(inputnode_parameters)
                    inputnode_parameters= {};
                    for i = 1:d
                        inputnode_parameters = [inputnode_parameters this.transport_species{i} double2str(first_row_matrix*this.velocity)];
                    end
                end
                for i = 1:d
                    [b, ind ] = ismember(this.transport_species{i},inputnode_parameters);
                    if b == true
                        BC = createBC(this.meshFVT);
                        BC.left.a = this.diffusion; BC.left.b = this.velocity; BC.left.c = str2double(inputnode_parameters{ind+1}); % left boundaryBC.
                        BCs{i} = BC;
                    else
                        error('[FVT_1D_Solver/Create_BCs] Apparently, there is a component %s that must be transport without boundary condition.\n', this.transport_species{i});
                    end
                end
            end
            
            % down boundary
            if strcmpi(type_down, 'inflow') || strcmpi(type_down, 'concentration')
                outputnode_parameters = BC_class.Get_Outputnode_Parameters;
                if isempty(outputnode_parameters)
                    outputnode_parameters= {};
                    for i = 1:d
                        outputnode_parameters = [outputnode_parameters this.transport_species{i} double2str(last_row_matrix)];
                    end
                end
                for i = 1:d
                    [b, ind ] = ismember(this.transport_species{i},outputnode_parameters);
                    if b == true
                        BCs{i}.right.a = 0; BCs{i}.right.b = 1; BCs{i}.right.c = str2double(outputnode_parameters{ind+1}); % left boundaryBC.
                    else
                        error('[FVT_1D_Solver/Create_BCs] Apparently, there is a component %s that must be transport without boundary condition.\n', this.transport_species{i});
                    end
                end
            elseif strcmpi(type_down, 'closed') || strcmpi (type_down, 'simmetry')
                for i = 1:d
                    BCs{i}.right.a = this.diffusion; BCs{i}.right.b = this.velocity; BCs{i}.right.c = 0; % left boundaryBC.
                end
            elseif strcmpi(type_down, 'openboundary')
                if this.velocity >=0
                    for i = 1:d
                        BCs{i}.right.a = this.diffusion; BCs{i}.right.b = 0; BCs{i}.right.c = 0; % left boundaryBC.
                    end
                else
                    outputnode_parameters = BC_class.Get_Outputnode_Parameters;
                    for i = 1:d
                        [b, ind ] = ismember(this.transport_species{i},outputnode_parameters);
                        if b == true
                            BCs{i}.right.a = 0; BCs{i}.right.b=1; BCs{i}.right.c=str2double(outputnode_parameters{ind+1}); % left boundaryBC.
                        else
                            error('[FVT_1D_Solver/Create_BCs] Apparently, there is a component %s that must be transport without boundary condition.\n', this.transport_species{i});
                        end
                    end
                end
            elseif strcmpi(type_down, 'flux') || strcmpi(type_down, 'outflow')
                outputnode_parameters = BC_class.Get_Outputnode_Parameters;
                if isempty(outputnode_parameters)
                    outputnode_parameters = {};
                    for i = 1:d
                        outputnode_parameters = [outputnode_parameters this.transport_species{i} num2str(last_row_matrix(i)*this.velocity)];
                    end
                end
                for i = 1:d
                    [b, ind ] = ismember(this.transport_species{i}, outputnode_parameters);
                    if b == true
                        BCs{i}.right.a = this.diffusion; BCs{i}.right.b = this.velocity; BCs{i}.right.c = str2double(outputnode_parameters{ind+1}); % left boundaryBC.
                    else
                        error('[FVT_1D_Solver/Create_BCs] Apparently, there is a component %s that must be transport without boundary condition.\n', this.transport_species{i});
                    end
                end
            end
        end
        
        
        function b = Get_modHO(this)
            b = this.b_modOH;
        end
    end
end