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
classdef Saturated_Conservative_Transport_PDEPEMATLAB_1D < Solve_Engine 
    properties
        morpho
        Initial_Feld
        m
        velocity
        dispersion_diffusion
        porosity
        aqueous_primary_species
        x
        BC
        R
    end
    methods
        function this = Saturated_Conservative_Transport_PDEPEMATLAB_1D (Morphology, Equation, Initial_Field)
            this.m=0;
            Par=Equation.Get_Parameters();
            P_T_D=Par{1};
            this.velocity=P_T_D.T_P_P.velocity_aqueous;
            this.dispersion_diffusion=(P_T_D.T_P_P.solid_properties.Tortuosity_Liquid_Saturated_MillingtonQuirk()* P_T_D.T_P_P.molecular_diffusion_liquid)+...
                                                P_T_D.T_P_P.Calculate_Saturated_Directional_Dispersion_1D;
            this.porosity=P_T_D.T_P_P.solid_properties.pore_volume_fraction;
            this.aqueous_primary_species=Initial_Field.Get_Transport_Elements;
            this.BC=P_T_D.Boundary_Condition;
            
            this.morpho=Morphology;
%             this.x=Morphology.Get_Vector_Regular_Discretization_Points;
            this.x=Morphology.Get_Vector_Regular_CenteredDiscretization_Points_WithEdges;
            this.R=zeros(length(this.x),length(this.aqueous_primary_species));
        end
        
        % This class recieved the Array Field C from transport interface,
        % therefore just transport values are included in there.
        % It is assume that we have only solution and hydraulic properties
        % and it is also assumed that first solution and later hydarulic.
        % There are no changes in any hydraulic property.(Could be a problem?)
        function c2=Time_Stepping (this, C,time)
            n_species=length(this.aqueous_primary_species);
            t=time.Get_Initial_Time:(time.Get_Dt/30):time.Get_Final_Time;
            x=this.x;
            %
            Porosity_Vec=C.Get_Vector_Field('porosity');
            Saturation_Liquid_Vec=C.Get_Vector_Field('liquid_saturation');
            Constant_Storage_Term=Saturation_Liquid_Vec.*Porosity_Vec;
            %
            options=odeset('NonNegative',[], 'RelTol', 1e12);
          sol = pdepe(this.m,@(x,t,u,DuDx) this.pdefun(x,t,u,DuDx, Constant_Storage_Term, this.velocity, this.dispersion_diffusion),...
                @(x) this.pdeicfun (x, this.x,C)...
                ,@(xl, ul, xr, ur, t) this.pdebcfun(xl, ul, xr, ur, t, C, x(2)-x(1), x(end)-x(end-1))...
                ,this.x,t, options);
            Array=zeros(length(x),n_species);
            for i=1:n_species
                Array(:,i)=(sol(end, 1:end, i))';
            end
            Array_Complete_Old=C.Get_Array;
            Array_S_H=[Array Array_Complete_Old(:,n_species+1:end)];
            c2=Array_Field(C.Get_List_Identifiers, Array_S_H);
        end
        
        function [c,f,s] = pdefun(this, x,t,u,DuDx,Constant_Storage_Term, velocity, diffusion_dispersion)
            n_species=length(this.aqueous_primary_species);
            vector_R=zeros(n_species,1);
            for i=1:n_species
                vector_R(i)=interp1(this.x, this.R(1:end, i), x, 'linear');
            end
            C_Value=interp1(this.x, Constant_Storage_Term, x, 'linear');
            c=ones(n_species,1).*C_Value;
            f=diffusion_dispersion*DuDx-velocity*u;
            % - added?
            s=-vector_R;
        end
        
        function u0 = pdeicfun (this, x, xmesh,C_ini)
            n_species=length(this.aqueous_primary_species);
            Array=C_ini.Get_Array;
            vector_ini_values=zeros(n_species,1);
            for i=1:n_species
                vector_ini_values(i)=interp1(xmesh, Array(1:end, i), x, 'linear');
            end
            u0 = vector_ini_values;
        end
        
        %% As first try I supposed that the boundaries conditions are inflow and flux later it will be expanded
        function [pl, ql, pr, qr] = pdebcfun (this, xl, ul, xr, ur, t, C, dx_ini, dx_fin)
            string_input=this.BC.Get_Inputnode_Type();
            string_output=this.BC.Get_Outputnode_Type();
            A=C.Get_Array;
            C_ini=Array_Field( C.Get_List_Identifiers,A(1, 1:end));
            C_end=Array_Field( C.Get_List_Identifiers,A(end, 1:end));
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
            q=this.R;
        end
        
        function [p, q] = FluxValuesBoundaryEquation(this, x, u, t, C, parameters, dx)
            n_species=length(this.aqueous_primary_species);
            p=-u.*this.velocity;
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
            n_species=length(this.aqueous_primary_species);
            p=zeros(n_species, 1);
            q=-ones(n_species, 1);
        end
        
        
        %%%% SIA%%%
        function Update_Initial_Guess(this, u_2, u, Time) 
            dif_array_field_u2u=u_2.Get_Difference_Arrays_Field (u);
            r=zeros(length(this.x),length(this.aqueous_primary_species));
            for i=1:length(this.aqueous_primary_species)
                r(1:end,i)=dif_array_field_u2u.Get_Vector_Field (this.aqueous_primary_species{i});
            end
            this.R=this.R+(r/Time.Get_Time_Interval);
        end
        
        function Restart_Guess (this)
            [r, c]=size(this.R);
            this.R=zeros(r,c);
        end
    end
end