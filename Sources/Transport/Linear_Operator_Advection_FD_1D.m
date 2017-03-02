%
% The following Solve engine does the transport part of the reactive
% transport equation (formulation TC) (Caroline de Dieuleveult, These"Un modele numerique global et performat pour le couplage geochimietransport"):
%
%       dC/dt + a dC/dx = 0
%
% It is considered that the operator is linear
%
% Remember 1_D
%
classdef Linear_Operator_Advection_FD_1D
    properties
    end
    methods
        function this = Linear_Operator_Advection_FD_1D
        end
        
        % Linear operator for advection with constant velocity. (First_Order_Upwind)
        % velocity move from left to right, namely from node 0 to node 1, etc 
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.53 - eq (3.14))
        % This scheme has an artificial dispersion, with a further
        % development of the Taylor series, it is possible to see from were
        % it comes. (1/2*a*h)
        %
        
        function A = Loperator_FirstOrderUpwind_ConstantVelocity (this, velocity, dx, sparse_boolean,  number_cells)
            % The equation is suppose to be like u_t + a u_x = 0
            %    u_t = -a u_x
            %    u_t_i = (a/h)*(u_i-1 - u_i) + O(h) i is the node 
            %
            % The matrix will look
            %       | -1 0 0 0 0 | 
            %   L = | 1 -1 0 0 0 | times a/h
            %       | 0 1 -1 0 0 | 
            %       | 0 0 1 -1 0 | 
            %       | 0 0 0 1 -1 | 
            %
            % Notice that it is not a circulant matrix, if not It will be
            % like : 
            %
            %       | -1 0 0 0 1 | 
            %   L = | 1 -1 0 0 0 | times a/h
            %       | 0 1 -1 0 0 | 
            %       | 0 0 1 -1 0 | 
            %       | 0 0 0 1 -1 | 
            
            a_h = velocity/dx; %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag(-ones(number_cells, 1)) + diag (ones(number_cells-1, 1), -1));
            else
                A = diag(-ones(number_cells, 1)) + diag (ones(number_cells-1, 1), -1);
            end
            
           A = a_h.* A;
            
        end
        
        % Linear operator for advection with constant velocity. (second-order central)
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.53 - eq (3.16))
        
        function A = Loperator_SecondOrderCentral_ConstantVelocity (this, velocity, dx, sparse_boolean,  number_cells)
            % The equation is suppose to be like u_t + a u_x = 0
            %    u_t = -a u_x
            %    u_t_i = (a/2h)*(u_i-1 - u_i+1) + O(h^2) i is the node
            %
            % The matrix will look
            %       | 0 -1 0 0 0 | 
            %   L = | 1 0 -1 0 0 | times a/(2*h)
            %       | 0 1 0 -1 0 | 
            %       | 0 0 1 0 -1 | 
            %       | 0 0 0 1  0 | 
            %
            % Notice that it is not a circulant matrix, if not It will be
            % like : 
            %
            %       | 0 -1 0 0 1 | 
            %   L = | 1 0 -1 0 0 | times a/(2*h)
            %       | 0 1 0 -1 0 | 
            %       | 0 0 1 0 -1 | 
            %       |-1 0 0 1  0 |  
            
            a_h = velocity/(2*dx); %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag(-ones(number_cells-1, 1),1) + diag (ones(number_cells-1, 1), -1));
            else
                A = diag(-ones(number_cells-1, 1),1)+ diag (ones(number_cells-1, 1), -1);
            end
            
           A = a_h.* A;
            
        end
        
        % Linear operator for advection with constant velocity. (second-order upwind scheme)
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.70 - eq. 3.43)
        % Due to boundary conditions not really practical
        
        function A = Loperator_SecondOrderUpwind_ConstantVelocity (this, velocity, dx, sparse_boolean,  number_cells)
            % The equation is suppose to be like u_t + a u_x = 0
            %    u_t = -a u_x
            %    u_t_i = (a/h)*((-1/2)*u_i-2 + 2*u_i-1 - (3/2)*u_i) + O(h^2) i is the node
            %
            % The matrix will look
            %       | -3/2  0     0    0    0 | 
            %   L = | 2    -3/2   0    0    0 | times a/h
            %       | -1/2  2   -3/2   0    0 | 
            %       | 0   -1/2    2   -3/2  0 | 
            %       | 0    0     -1/2  2 -3/2 | 
            %
            % Notice that it is not a circulant matrix, if not It will be
            % like : 
            %
            %       | -3/2  0     0   -1/2  2  | 
            %   L = | 2   -3/2    0    0  -1/2 | times a/h
            %       | -1/2  2   -3/2   0    0  | 
            %       | 0   -1/2    2   -3/2  0  | 
            %       | 0    0     -1/2  2 -3/2  | 
            
            a_h = velocity/(dx); %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag((-1/2).*ones(number_cells-1, 1),-2) + diag (2.*ones(number_cells-1, 1), -1) + diag ((-3/2).*ones(number_cells, 1)));
            else
                A = diag((-1/2).*ones(number_cells-1, 1),-2) + diag (2.*ones(number_cells-1, 1), -1) + diag ((-3/2).*ones(number_cells, 1));
            end
            
            A = a_h.* A;
            
        end
        
        % Linear operator for advection with constant velocity. (second-order upwind-biased scheme) or Fromm scheme 
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.70 - eq. 3.44)
        % Due to boundary conditions not really practical
        
        function A = Loperator_SecondOrderUpwindBiased_ConstantVelocity (this, velocity, dx, sparse_boolean,  number_cells)
            % The equation is suppose to be like u_t + a u_x = 0
            %    u_t = -a u_x
            %    u_t_i = (a/h)*((-1/4)*u_i-2 + (5/4)*u_i-1 - (3/4)*u_1 - (1/4)*u_i+1) + O(h^2) i is the node
            %
            % The matrix will look
            %       | -3/4  -1/4     0     0        0 | 
            %   L = |  5/4  -3/4   -1/4    0        0 | times a/h
            %       | -1/4   5/4   -3/4   -1/4      0 | 
            %       | 0     -1/4    5/4   -3/4   -1/4 | 
            %       | 0       0    -1/4    5/4   -3/4 | 
            %
            % Notice that it is not a circulant matrix, if not It will be
            % like : 
            %
            %       | -3/4  -1/4     0    -1/4    5/4 | 
            %   L = |  5/4  -3/4   -1/4    0     -1/4 | times a/h
            %       | -1/4   5/4   -3/4   -1/4      0 | 
            %       | 0     -1/4    5/4   -3/4   -1/4 | 
            %       | -1/4    0    -1/4    5/4   -3/4 | 
            
            a_h = velocity/(dx); %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag((-1/4).*ones(number_cells-1, 1),-2) + diag ((5/4).*ones(number_cells-1, 1), -1) + diag ((-3/4).*ones(number_cells, 1)) + diag ((-1/4).*ones(number_cells-1, 1),1));
            else
                A = diag((-1/4).*ones(number_cells-1, 1),-2) + diag ((5/4).*ones(number_cells-1, 1), -1) + diag ((-3/4).*ones(number_cells, 1)) + diag ((-1/4).*ones(number_cells-1, 1),1);
            end
            
            A = a_h.* A;
            
        end
        
        
        % Conservative form
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.78 - eq. 4.14)
        % 
        function u_t = Ut_FluxForm (this, velocity, dx, sparse_boolean, concentration_middle)
            % It consider variable-coefficient advection problem
            % u_t = (a(x)*u)_x = 0
            % Its form is:
            % u_t_i = 1/h (a(x_i-1/2)*u_i-1/2 - a(x_i+1/2)*u_i+1/2)
            %
            % notice that the interfaces of the cell are shared therefore,
            % regarding the node, sometimes the value a(x_i+-1/2) will have
            % one sign or other, therefore here we cannot deliver a L
            % operator.
            %
            % x_mesh must contain the values of x at the interface.
            % a must be a vector with the values at the interface
            d=length (velocity) -1;
            u_t = zeros(d,1);
            for i=1:d
                u_t(i) = (1/dx)*(velocity(i)*concentration_middle(i) - velocity(i+1)*concentration_middle(i+1));
            end
            
        end
       
        
        
        % First Order Upwind Scheme in Flux form
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.79 - eq. 4.15)
        % 
        function u_t = Ut_FirstOrderUpwind_FluxForm (this, velocity, dx, sparse_boolean, concentrations)
            % It consider variable-coefficient advection problem
            % u_t = (a(x)*u)_x = 0
            % it considers that u_i+1/2 = u_i
            % Its form is:
            % u_t_i = (1/h)*(a(x_i-1/2)*u_i-1/2 - a(x_i+1/2)*u_i)
            %
            % The vector of concentration must be at the beginning of the
            % interface and at the middle for each cell. 
            % The velocit is at the interfaces.
            d=length (velocity) -1;
            u_t = zeros(d,1);
            for i= 1: d
                u_t(i) = (1/dx)*(velocity(i)*concentrations((2*i)-1) - velocity(i+1)*concentrations(2*i));
            end
            
        end
        
        
        
        % Second Order Central Scheme in Flux form
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.80 - eq. 4.17)
        % 
        function u_t = Ut_SecondOrderCentral_FluxForm (this, velocity, dx, sparse_boolean, concentrations)
            % It consider variable-coefficient advection problem
            % u_t = (a(x)*u)_x = 0
            % it considers that u_i+1/2 = (1/2)*(u_i+u_i+1)
            % Its form is:
            % u_t_i = (1/2*h)*(a(x_i-1/2)*(u_i-1 + u_i)- a(x_i+1/2)*(u_i+u_i+1))
            %
            d = length(velocity) - 1;
            u_t = zeros(d, 1);
            for i = 1 : d
                % the i of the vector of concentrations i actually i-1;
                u_t(i) = (1/2*dx)*(velocity(i)*(concentrations(i)+concentrations(i+1)) - velocity(i+1)*(concentrations(i+1)+concentrations(i+2)));
            end
        end
        
        function A = Loperator_SecondOrderCentral_FluxForm (this, velocity, dx, sparse_boolean,  number_cells)
            % It consider variable-coefficient advection problem
            % u_t = (a(x)*u)_x = 0
            % it considers that u_i+1/2 = (1/2)*(u_i+u_i+1)
            % Its form is:
            % u_t_i = (1/2*h)*(a(x_i-1/2)*(u_i-1 + u_i)- a(x_i+1/2)*(u_i+u_i+1))
            %
            a_h = 1/(2*dx); %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag(velocity(2:end-1), -1) + diag(velocity(1:end-1) - velocity(2:end)) - diag(velocity(2:end-1), 1));
            else
                A = diag(velocity(2:end-1), -1) - diag(velocity(1:end-1) - velocity(2:end)) - diag(velocity(2:end-1), 1);
            end
            
            A = a_h.* A;
        end
        
        % First order upwind advection form
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.81 - eq. 4.18)
        % 
        function u_t = Ut_FirstOrderUpwind_AdvectiveForm (this, velocity, dx, sparse_boolean, concentrations)
            % It consider variable-coefficient advection problem
            % u_t = a(x)*u_x = 0
            % the spatial discretization relies in the sign of the
            % velocity:
            %  a>0 u_t_i = (1/h)*a(x_i)(u_i-1 - u_i)
            %  a<0 u_t_i = (1/h)*a(x_i)(u_i - u_i+1)
            %
            %
            d = length(velocity);
            u_t = zeros(d, 1);
            for i = 1 : d
                % the i of the vector of concentrations i actually i-1;
                if velocity(i)>=0
                    u_t(i)=(1/dx)*velocity(i)*(concentrations(i+1) - concentrations(i));
                else
                    u_t(i)=(1/dx)*velocity(i)*(concentrations(i+1) - concentrations(i+2));
                end
            end
        end
        
        % SecondOrderCentral
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.81 - eq. 4.19)
        % 
        function u_t = Ut_SecondOrderCentral_AdvectiveFrm (this, velocity, dx, sparse_boolean, concentrations)
            % It consider variable-coefficient advection problem
            % u_t = a(x)*u_x = 0
            % results in:
            %u_t_i = (1/2*h)*a(i)*(u_i-1 - u_i+1)
            %
            d = length(velocity);
            u_t = zeros(d, 1);
            for i = 1 : d
                 % the i of the vector of concentrations i actually i-1;
                 u_t(i)=(1/2*dx)*velocity(i)*(concentrations(i) -  concentrations(i+2));
            end
        end
        
        % SecondOrderCentral
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag.81 - eq. 4.19)
        % 
        function A = Loperator_SecondOrderCentral_AdvectiveForm (this, velocity, dx, sparse_boolean,  number_cells)
            % It consider variable-coefficient advection problem
            % u_t = a(x)*u_x = 0
            % results in:
            %u_t_i = (1/2*h)*a(i)*(u_i-1 - u_i+1)
            %
            %       | 0   a1  0    0    0 | 
            %   L = | a2  0   a2   0    0 | times a/h
            %       | 0   a3  0    a3   0 | 
            %       | 0   0   a4   0   a4 | 
            %       | 0   0   0    a5   0 | 
            %
            a_h = 1/(2*dx); %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag(velocity(2:end), -1) - diag(velocity(1:end-1), 1));
            else
                A = diag(velocity(2:end), -1) - diag(velocity(1:end-1), 1);
            end
            
            A = a_h.* A;
        end
        
    end
end