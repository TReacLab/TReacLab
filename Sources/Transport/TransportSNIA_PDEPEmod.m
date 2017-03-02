% The following method computes a conservative solute transport equation
% for a saturated medium. Herein, we use a modified function of Matlab
% pdepe, so-called pdepevar. Pdepevar gives the resulting transport
% operator, K*C(n) from equation (1),using a simple piecewise nonlinear
% Galerkin/Petrov-Galerkin method [1]. Afterwards, a simple forward Euler
% method is applied for the discretisation of time.
%
% Computes the following equation: 
%
%   T(n+1) = T(n) + K*C(n)*dt        (1)
%
% Such scheme is useful to apply an explicit time discretization and
% Sequential Non-Iterative Approach (SNIA) in the field of reactive
% transport in a Darcy scale. Pdepe has been modified due to the fact that
% it uses an implicit time discretization which leads to mass balance errors
% when the SNIA is used, as commented in [2].
%
% For some numerical values inestabilites can arise. To control the
% inestabilities the Peclet grid number should be smaller than 2, the
% Courant grid number should be smaller than 1, and the Von Neumann grid
% number should be smaller than 1/2. 
%
% Some assumptions are made:
% - Isothermal transport.
% - Constant velocity and constant dispersion-diffusion tensor (Non multicomponent diffusion).
% - Constant porosity.
%
% -----------------------------------------
% [1] Skeel, R. D. and M. Berzins, "A Method for the Spatial Discretization
% of Parabolic Equations in One Space Variable" SIAM Journal on Scientific
% and Statistical Computing, Vol. 11, 1990, pp.1–32.  
%
% [2] de Dieuleveult, C., Erhel, J., and Kern, M. "A Global Strategy for
% Solving Reactive Transport Equations" Journal of Computational Physics,
% Vol. 228, 2009, pp. 6395-6410.

classdef TransportSNIA_PDEPEmod

    properties
        x
        velocity
        dispersion_diffusion
        transport_species
        BC
        T_P_P
        m
        ls
    end
    methods 
        
        % Constructor of TransportSolver_SNIA_Expl class. A Morphology
        % class, Equation class and Array_Field class must be provided.
        % 
        % The tortuosity is calculated using a Millington and Quirk
        % equation (porosity^1/3) for a saturated porous media.
        %
        % The dispersion is calculated by multiplying absolute value of
        % velocity with dispersivity.
        %
        
        function this = TransportSNIA_PDEPEmod (Morphology, Equation, Initial_Field)
            Par=Equation.Get_Parameters();
            P_T_D=Par{1};
            this.x=Morphology.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges ;
            this.velocity=P_T_D.T_P_P.velocity_aqueous;
            this.dispersion_diffusion=(P_T_D.T_P_P.solid_properties.Tortuosity_Liquid_Saturated_MillingtonQuirk()* P_T_D.T_P_P.molecular_diffusion_liquid)+...
                                                P_T_D.T_P_P.Calculate_Saturated_Directional_Dispersion_1D;
%             this.dispersion_diffusion=P_T_D.T_P_P.molecular_diffusion_liquid;
%             The above line ilustrate a dispersion diffusion where the value corresponds just to the molecular diffusion value.
            this.transport_species=Initial_Field.Get_Transport_Elements();
            A = Initial_Field.Get_Desired_Array('Solution');
            this.ls = A.Get_List_Identifiers;
            this.BC=P_T_D.Boundary_Condition;
            this.T_P_P=P_T_D.T_P_P;
            this.m = 0;
        end
        
        % Time stepping method
        function T_n1=Time_Stepping (this,parm)
            t = parm{1};
            At = parm{2};
            T_n = parm{3};
            Constant_Storage_Term = parm{4};
            
            % Get_Matrix K*C_n
            % pdepevar(m,pde,ic,bc,xmesh,t,options, Resolt_bolean,varargin);
            options=[]; % odeset, since we do not use the ode solver of the function pdepe of Matlab it has not sense

            [KC_n] = pdepevar(this.m, @(x,t,u,DuDx) this.pdefun(x,t,u,DuDx,Constant_Storage_Term, this.velocity, this.dispersion_diffusion),...
                @(x) this.pdeicfun (x, this.x, T_n), ...
                @(xl, ul, xr, ur, t) this.pdebcfun(xl, ul, xr, ur, t, T_n, this.x(2)-this.x(1), this.x(end)-this.x(end-1)), ...
                this.x, t,options, false);
            
            % THIS STEP CAN BE DISCUSSED
            KC_n(:,1)=zeros(length(this.transport_species),1);
            
            % Operations to Get T(n+1)
            T_n1 = T_n + At.*(KC_n'); 

        end
        
        
        % Method required by pdepevar function. It returns the discretizated values c, f and s of
        % the following equation:
        %
        %   c(x, t,u,DuDx)*DuDt = x^(-m)* D(x^(m)*f(x,t,u, DuDx))Dx +s(x, t, u, DuDx)

        function [c,f,s] = pdefun(this, x,t,u,DuDx,Constant_Storage_Term, velocity, diffusion_dispersion)
            n_pde=length(this.transport_species);
            C_Value=interp1(this.x, Constant_Storage_Term, x, 'linear');
            c=ones(n_pde,1).*C_Value;
            f=diffusion_dispersion*DuDx-velocity*u;
            s=zeros(n_pde, 1);
        end
        
        % Method required by pdepevar function. It returns the initial conditions of
        % the form:
        %
        % u(x, t0) = U0(x)
        
        function u0 = pdeicfun (this, x, xmesh,Array)
            n_pde=length(this.transport_species);
            vector_ini_values=zeros(n_pde,1);
            for i=1:n_pde
                vector_ini_values(i)=interp1(xmesh, Array(1:end, i), x, 'linear');
            end
            u0 = vector_ini_values;
        end
        
        % Method required by pdepevar function. It returns the values p and q of the
        % following equation:
        %
        % p(x, t, u) + q(x, t) * f(x, t, u, DuDx) = 0
        
        function [pl, ql, pr, qr] = pdebcfun (this, xl, ul, xr, ur, t, T_n, dx_ini, dx_fin)
            string_input=this.BC.Get_Inputnode_Type();
            string_output=this.BC.Get_Outputnode_Type();
     
            C_ini=Array_Field( this.ls,T_n(1, 1:end));
            C_end=Array_Field( this.ls,T_n(end, 1:end));
            [pl, ql]=this.BC_Equation(xl, ul, t, C_ini, string_input, this.BC.Get_Inputnode_Parameters, dx_ini);
            [pr, qr]=this.BC_Equation(xr, ur, t, C_end, string_output, this.BC.Get_Outputnode_Parameters, dx_fin);
        end
        
        % The method is related to pdebcfun method. It returns p and q. 
        
        function [p, q]=BC_Equation (this, x, u, t, C, string, parameters,dx_fin_ini)
            if strcmpi(string, 'inflow')
                [p, q]=this.ConstantValuesBoundaryEquation( x, u, t, C, parameters);
            elseif strcmpi (string, 'flux')
                [p, q]=this.FluxValuesBoundaryEquation(x, u, t, C, parameters,dx_fin_ini);
            elseif strcmpi (string, 'no flux')
                [p, q]=this.NoFluxValuesBoundaryEquation(x, u, t, C, parameters);
            end    
        end
        
        % The method is related to BC_Equation method. It returns p and q
        % when the boundary condition is constant values.
        
        function [p, q] = ConstantValuesBoundaryEquation(this, x, u, t, C, parameters)
            vector_input_values=this.Values(C, parameters);
            p=u-vector_input_values;
            p(p <1e-15) = 0;
            q=zeros(length(this.transport_species),1);
        end
        
        % The method is related to BC_Equation method. It returns p and q
        % when the boundary condition is flux values.
        
        function [p, q] = FluxValuesBoundaryEquation(this, x, u, t, C, parameters, dx)
            n_species=length(this.transport_species);
            p=-u.*this.velocity;
            q=-ones(n_species, 1);

        end
        
        % The method get the values stored in the parameter input.
        % parameter input looks like c= {'Component1 (e.g. Ca)' 'Value2 (e.g. 5)' ... 'ComponentN' 'ValueN'}
        
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
        
        % The method is related to BC_Equation method. It returns p and q
        % when the boundary condition is no flux.
        function [p, q] = NoFluxValuesBoundaryEquation(this, x, u, t, C, parameters)
            n_species=length(this.transport_species);
            p=zeros(n_species, 1);
            q=-ones(n_species, 1);
        end
    end
end