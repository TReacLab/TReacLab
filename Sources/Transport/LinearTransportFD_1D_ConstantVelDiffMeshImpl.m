classdef LinearTransportFD_1D_ConstantVelDiffMeshImpl < Solve_Engine
    properties 
        dx
        L
        velocity
        dispersion_diffusion
        M
        transport_species
        BC
        T_P_P
        q_x0
        q_xend
    end
    methods 
        function this = LinearTransportFD_1D_ConstantVelDiffMeshImpl (Morphology, Equation, Initial_Field)
            Par=Equation.Get_Parameters();
            P_T_D=Par{1};
            %
            this.dx = Morphology.Get_Mesh_Discretization_Value;
            this.L = Morphology.Get_Distance;
            number_cells = this.L/this.dx;
            sparse_boolean= 'true';
            % velocity is constant
            this.velocity=P_T_D.T_P_P.velocity_aqueous;
            Adv = Linear_Operator_Advection_FD_1D;
            Madv = Adv.Loperator_SecondOrderCentral_ConstantVelocity (this.velocity, this.dx, sparse_boolean,  number_cells);
%             Madv = Adv.Loperator_FirstOrderUpwind_ConstantVelocity (velocity, dx, sparse_boolean,  number_cells);
            
            % diff is constant
            this.dispersion_diffusion=(P_T_D.T_P_P.solid_properties.Tortuosity_Liquid_Saturated_MillingtonQuirk()* P_T_D.T_P_P.molecular_diffusion_liquid)+...
                                                P_T_D.T_P_P.Calculate_Saturated_Directional_Dispersion_1D;
            D = Linear_Operator_Diffusion_FD_1D;
            Mdiff = D.Loperator_SecondOrderCentral_ConstantDiffusion (this.dispersion_diffusion, this.dx, sparse_boolean,  number_cells);
            
            % sum 
            this.M = Mdiff + Madv;
            
            this.transport_species=Initial_Field.Get_Transport_Elements;
            this.BC=P_T_D.Boundary_Condition;
            this.T_P_P=P_T_D.T_P_P;
        end
        
        %
        % It solves the transport equation with an first order forward
        % explicit scheme. The spatial discretization is central second
        % order for diffusion and for advection.
        %
        
        
        function  C_n1 = Time_Stepping (this, parm)
            dt  = parm{1};
            C_n = parm{2};
            r   = parm{3}; 
            c   = parm{4};
            R   = parm{5};
            Constant_Storage_Term = parm{6};
            
            % BC one way
%             if isempty(this.q_x0) && isempty(this.q_xend)
                [this.q_x0, this.q_xend ]= this.BC_create(C_n(1:2, :),C_n(end-1:end, :));
%             end
            % Bc two way
            
            q= zeros(r,c);
            q(1,:) = this.q_x0;
            q(end, :) = this.q_xend;
            
            
            inv_E = inv(diag(Constant_Storage_Term));
            
            C_n1 = zeros(r, c);
            
            % C_n1 = C_n + inv(E)*(dT*(M*C_n+q))
            I= eye(r);
            A=inv(I-(inv_E*dt*this.M));
            for i = 1:c
                C_n1 (:, i) = A*(C_n(:, i) + (inv_E*dt*q(:,i)) + R(:, i));
            end
            
        end
        
        
        function  [a, b] = BC_create (this, C_n0, C_nend)
            str_inpt = this.BC.Get_Inputnode_Type;
            list_in = this.BC.Get_Inputnode_Parameters;
            list_ele_in = list_in(1:2:end-1);
            list_val_in = list_in(2:2:end);
            val_vect_ord_i=[];
            if ~isempty(list_ele_in)
                assert(isempty(setxor(list_ele_in,this.transport_species )), '[LinearTransportFD_1D_ConstantVelDiffMesh\BC_create]')
                val_vect_ord_i=this.Order_List (list_val_in, this.transport_species, list_ele_in);
            end
            
            if strcmpi (str_inpt, 'inflow' )
                a = this.BC_Dirichlet_Const ('+', val_vect_ord_i)    ;              % This conditions is only valide for a second order centered spatial discretization
            elseif strcmpi (str_inpt, 'closed' ) || strcmpi (str_inpt, 'no flux' )                                 % Just like the manual of Phreeqc Cn-1 == Cn
                a = this.BC_Neuman_zero ('+', C_n0, val_vect_ord_i) ;
%             elseif
            end
            
            str_outt = this.BC.Get_Outputnode_Type;
            list_out = this.BC.Get_Outputnode_Parameters;
            list_ele_out = list_out(1:2:end-1);
            list_val_out = list_out(2:2:end);
            
            val_vect_ord_o=[];
            if ~isempty(list_ele_out)
                assert(isempty(setxor(list_ele_out,this.transport_species )), '[LinearTransportFD_1D_ConstantVelDiffMesh\BC_create]')
                val_vect_ord_o=this.Order_List (list_val_out, this.transport_species, list_ele_out);
            end
            
            if strcmpi (str_outt, 'inflow' )
                b = this.BC_Dirichlet_Const ('-', val_vect_ord_o) ;                 % This conditions is only valide for a second order centered spatial discretization
            elseif  strcmpi (str_outt, 'closed' ) || strcmpi (str_outt, 'no flux' )
                b = this.BC_Neuman ('-', C_nend(end-1,:), val_vect_ord_o)   ;                            % Just like the manual of Phreeqc Cn-1 == Cn
            elseif strcmpi (str_outt, 'flux')
                b = this.BC_Flux_Const ('-', C_nend(end-1, :), val_vect_ord_o);
            end
        end
        
        
        % This conditions is only valide for a second order centered spatial discretization
        % Furthermore the bc does not vary with time.
        
        function val = BC_Dirichlet_Const (this, string, vect_val)
            if strcmpi('+', string)
                val = ((this.velocity/(2*this.dx))+(this.dispersion_diffusion/(this.dx*this.dx))).*vect_val';
            elseif strcmpi('-', string)
                val = ((this.velocity/(2*this.dx))-(this.dispersion_diffusion/(this.dx*this.dx))).*vect_val';
            end
        end
        
        % Not sure about this implementation Test cases needed
        
        function val = BC_Neuman(this,string, C, vect)
            if strcmpi('+', string)
                if isempty(vect)
                    val = ((this.dispersion_diffusion/(this.dx*this.dx))).*C';  % Maybe there is a lack of velocity
                    val = 0*C';
                else
                    c1 = C'- (vect.* (this.dx/this.dispersion_diffusion)); 
                    val = (this.dispersion_diffusion/(this.dx*this.dx)).*c1 ;
                end
            elseif strcmpi('-', string)
                if isempty(vect)
                    val = (this.dispersion_diffusion/(this.dx*this.dx)).*C'; %
                else
                    c1 = C'+ (vect.* (this.dx/this.dispersion_diffusion)); 
                    val = (this.dispersion_diffusion/(this.dx*this.dx)).*c1;
                end
            end
        end 
        
        % Not sure about this implementation Test cases needed
        
        function val = BC_Flux_Const (this, string, C, vect)
            if strcmpi('+', string)
                if isempty(vect)
                    val = ((this.velocity/(2*this.dx))+(this.dispersion_diffusion/(this.dx*this.dx))).*C';
                else
                end
%                 list = this.Bc.Get_Inputnode_Parameters;
%                 val = ((this.dispersion_diffusion/(this.dx*this.dx))).*C'; 
            elseif strcmpi('-', string)
                if isempty(vect)
                    val = (-(this.velocity/(2*this.dx))+(this.dispersion_diffusion/(this.dx*this.dx))).*C';
                else
                end
%                 list = this.Bc.Get_Outputnode_Parameters;
%                 val = (-(this.dispersion_diffusion/(this.dx*this.dx)).*C'; %
            end
        end 
        
        
        
        function list_order = Order_List (this, list_val, list_master, list_slave)
            d = length(list_val);
            list_order = zeros (1, d);
            for i =1:d
                [bol, ind] = ismember(list_slave(i), list_master);
                if bol ==1
                    list_order(i) = str2num(list_val{ind});
                else
                    error('[LinearTransportFD_1D_ConstantVelDiffMesh\Order_List]')
                end
            end
        end
    end
end