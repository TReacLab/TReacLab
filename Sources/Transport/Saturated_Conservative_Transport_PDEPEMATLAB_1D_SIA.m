%
% Saturated transport equation using PDEPE Matlab
%
%   solution components that satisfy a system of npde equations of the form   
%
%   c(x,t,u,Du/Dx) * Du/Dt = x^(-m) * D(x^m * f(x,t,u,Du/Dx))/Dx + s(x,t,u,Du/Dx)
%    
%   c(x,t,u,Du/Dx)= porosity
%   f(x,t,u,Du/Dx)=advection+diffusion
%   s = source_term
%
%
%
classdef Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA < Solve_Engine 
    properties
        morpho
        Initial_Feld
        m
        velocity
        dispersion_diffusion
        porosity
        transport_species
        x
        BC
        ls
    end
    methods
        function this = Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA (Morphology, Equation, Initial_Field)
            this.m=0;
            Par=Equation.Get_Parameters();
            P_T_D=Par{1};
            this.velocity=P_T_D.T_P_P.velocity_aqueous;
            this.dispersion_diffusion=(P_T_D.T_P_P.solid_properties.Tortuosity_Liquid_Saturated_MillingtonQuirk()* P_T_D.T_P_P.molecular_diffusion_liquid)+...
                P_T_D.T_P_P.Calculate_Saturated_Directional_Dispersion_1D;
            this.porosity=P_T_D.T_P_P.solid_properties.pore_volume_fraction;
            this.transport_species=Initial_Field.Get_Transport_Elements;
            this.BC=P_T_D.Boundary_Condition;
            A = Initial_Field.Get_Desired_Array('Solution');
            this.ls = A.Get_List_Identifiers;
            this.morpho=Morphology;
            %             this.x=Morphology.Get_Vector_Regular_Discretization_Points;
            this.x=Morphology.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges;
            %             this.R=zeros(length(this.x),length(this.transport_species));
        end
        
        
         function C_nplusone_ihalf=Time_Stepping (this, parm)
            % The Iterative process has the following equation
            % T (n+1, i+1) = T(n) + dt*L(C(n+1, i))
            % where T = F + C
            % C(n+1, i+1) + F(n+1, i+1) = F(n) + C(n) + dt*L(C(n+1, i))
            % n is related to time, and i to iteration in SIA.
            % Here we calculate C(n)+dt*L(C(n+1, i)) = C(n+1, i+1/2)
            % The chemical solver takes charge as inputs C(n+1, i+1/2) and F(n) and
            % returns C(n+1, i+1) and F(n+1, i+1).
            t = parm{1};
            At = parm{2};
            C_n = parm{3};
            C_nplusone_i = parm{4};
            Constant_Storage_Term = parm{5};
            
            options=[]; % odeset, since we do not use the ode solver it has not sense
 
            [LC_nplusone_i] = pdepevar(this.m, @(x,t,u,DuDx) this.pdefun(x,t,u,DuDx,Constant_Storage_Term, this.velocity, this.dispersion_diffusion),...
                @(x) this.pdeicfun (x, this.x, C_nplusone_i), ...
                @(xl, ul, xr, ur, t) this.pdebcfun(xl, ul, xr, ur, t, C_nplusone_i, this.x(2)-this.x(1), this.x(end)-this.x(end-1)), ...
                this.x, t,options, false);
            % LC_nplusone_i --> The Columns are the node position in a 1D
            %          The Rows are the elements (in order stated in the function pde) that belong to the system.
            LC_nplusone_i(:,1)=zeros(length(this.transport_species),1);
            
            
            
            % Operations to Get T(n+1)
            C_nplusone_ihalf = C_n + At.*(LC_nplusone_i');
            
         end
        
        
        function [c,f,s] = pdefun(this, x,t,u,DuDx,Constant_Storage_Term, velocity, diffusion_dispersion)
            n_pde=length(this.transport_species);
            C_Value=interp1(this.x, Constant_Storage_Term, x, 'linear');
            c=ones(n_pde,1).*C_Value;
            f=diffusion_dispersion*DuDx-velocity*u;
            s=zeros(n_pde, 1);
        end
        
        function u0 = pdeicfun (this, x, xmesh, Array)
            n_pde=length(this.transport_species);
            vector_ini_values=zeros(n_pde,1);
            for i=1:n_pde
                vector_ini_values(i)=interp1(xmesh, Array(1:end, i), x, 'linear');
            end
            u0 = vector_ini_values;
        end
        
        %% As first try I supposed that the boundaries conditions are inflow and flux later it will be expanded
        function [pl, ql, pr, qr] = pdebcfun (this, xl, ul, xr, ur, t, Array, dx_ini, dx_fin)
            string_input=this.BC.Get_Inputnode_Type();
            string_output=this.BC.Get_Outputnode_Type();
            C_ini=Array_Field( this.ls,Array(1:2, 1:end));
            C_end=Array_Field( this.ls,Array(end-1:end, 1:end));
            [pl, ql]=this.BC_Equation(xl, ul, t, C_ini, string_input, this.BC.Get_Inputnode_Parameters, dx_ini);
            [pr, qr]=this.BC_Equation(xr, ur, t, C_end, string_output, this.BC.Get_Outputnode_Parameters, dx_fin);
        end
        
        %%% Boundary%%%%
        function [p, q]=BC_Equation (this, x, u, t, C, string, parameters,dx_fin_ini)
            if strcmpi(string, 'inflow')
                [p, q]=this.ConstantValuesBoundaryEquation( x, u, t, C, parameters);
            elseif strcmpi (string, 'flux')
                [p, q]=this.FluxValuesBoundaryEquation(x, u, t, C, parameters,dx_fin_ini);
            elseif strcmpi (string, 'no flux')
                [p, q]=this.NoFluxValuesBoundaryEquation(x, u, t, C, parameters);
            end
        end
        
        function [p, q] = ConstantValuesBoundaryEquation(this, x, u, t, C, parameters)
            vector_input_values=this.Values(C, parameters);
            p=u-vector_input_values;
            %             p=zeros(length(this.transport_species),1);
            q=zeros(length(this.transport_species),1);
        end
        
        function [p, q] = FluxValuesBoundaryEquation(this, x, u, t, C, parameters, dx)
            n_species=length(this.transport_species);
            Ca=C.Get_Array;
            Du=Ca(2,1:n_species)-Ca(1,1:n_species);
            p=-u.*this.velocity+ this.dispersion_diffusion*((Du')/dx);
            q=-ones(n_species, 1);
            %%%%%%%
            %             A=(C.Get_Array)';
            %             p=-this.dispersion_diffusion.*(A./dx)+A*this.velocity;
            %             p=-this.dispersion_diffusion.*(A./dx)+A*this.velocity;
            %             q=ones(n_species, 1);
            %               p=A;
            %               q=1/this.velocity;
        end
        function vector_values = Values(this, C, parameters)
            Li=C.Get_List_Identifiers;
            list_aqueous=Li.Get_List_Names ('Solution');
            d=length(list_aqueous);
            vector_values=zeros(d, 1);
            for i=1:d
                [b, index]=ismember(list_aqueous{i}, parameters);
                if b==true
                    vector_values(i)=str2num(parameters{index+1});
                end
            end
        end
        
        function [p, q] = NoFluxValuesBoundaryEquation(this, x, u, t, C, parameters)
            n_species=length(this.transport_species);
            p=zeros(n_species, 1);
            q=-ones(n_species, 1);
        end
    end
end