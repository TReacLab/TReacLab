%
% The following Solve engine does the transport part of the reactive
% transport equation (formulation TC) (Caroline de Dieuleveult, These"Un modele numerique global et performat pour le couplage geochimietransport"):
%
%       dC/dt = d d^2C/dx^2
%
% It is considered that the operator is linear
%
% Remember 1_D
%
classdef Linear_Operator_Diffusion_FD_1D
    properties
    end
    methods
        function this = Linear_Operator_Diffusion_FD_1D
        end
        
        % Linear operator for diffusion with constant diffusion
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer
        %
        
        function A = Loperator_SecondOrderCentral_ConstantDiffusion (this, diffusion, dx, sparse_boolean,  number_cells)
            % The equation is suppose to be like u_t = d u_xx
            %    u_t = d u_xx
            %    u_t_i = (d/(h*h))*(u_i-1 - 2*u_i + u_i+1) + O(h^2) i is the node 
            %
            % The matrix will look
            %       | -2 1 0 0 0 | 
            %   L = | 1 -2 1 0 0 | times a/h
            %       | 0 1 -2 1 0 | 
            %       | 0 0 1 -2 1 | 
            %       | 0 0 0 1 -2 | 
            %
            % Notice that it is not a circulant matrix, if not It will be
            % like : 
            %
            %       | -2 1 0 0 1 | 
            %   L = | 1 -2 1 0 0 | times a/h
            %       | 0 1 -2 1 0 | 
            %       | 0 0 1 -2 1 | 
            %       | 1 0 0 1 -2 |  
            %
            %   Due to the symmetry the matrix A has real eigenvalues.
            %
            %
            %
            a_h =diffusion /(dx*dx); %remember constant velocity
            
            %
            
            if sparse_boolean == true
                A = sparse(diag (ones(number_cells-1, 1), 1) + diag((-2).*ones(number_cells, 1)) + diag (ones(number_cells-1, 1), -1));
            else
                A = diag (ones(number_cells-1, 1), 1) + diag((-2).*ones(number_cells, 1)) + diag (ones(number_cells-1, 1), -1);
            end
            
           A = a_h.* A;
            
        end
        
        % Diffusion with variable coefficients
        % book : Numerical Solution of Time-Dependent Advection Diffusion
        % Reaction Equations - Hundsdorfer and Verwer (pag. 82 _ )
        %
        function u_t = Ut_SecondOrderCentral_FluxForm (this, diffusion, dx, sparse_boolean, concentrations)
            % mass consrvative, flux form
            % the equation looks like:
            %
            % u_t = (d(x)*u_x)x
            % results in:
            %
            % u_t = (1/h^2)*(d(x_i-1/2)*(u_i-1 - u_i) - d(x_i+1/2)*(u_i - u_i+1))
            %
            d=length(diffusion)-1;
            u_t = zeros(d, 1);
            for i = 1 : d
                % the i of the vector of concentrations i actually i-1;
                u_t(i) = (1/dx*dx)*(diffusion(i)*(concentrations(i)-concentrations(i+1)) - diffusion(i+1)*(concentrations(i+1)-concentrations(i+2)));
            end
        end
        
% % % % % % % % % %         function A = Loperator_SecondOrderCentral_FluxForm (this, diffusion, dx, sparse_boolean,  number_cells)
% % % % % % % % % %             % mass consrvative, flux form
% % % % % % % % % %             % the equation looks like:
% % % % % % % % % %             %
% % % % % % % % % %             % u_t = (d(x)*u_x)x
% % % % % % % % % %             % results in:
% % % % % % % % % %             %
% % % % % % % % % %             % u_t = (1/h^2)*(d(x_i-1/2)*(u_i-1 - u_i) - d(x_i+1/2)*(u_i - u_i+1))
% % % % % % % % % %             %
% % % % % % % % % %             a_h = 1 /(dx*dx);
% % % % % % % % % %             
% % % % % % % % % %             if sparse_boolean == true
% % % % % % % % % %                 A = sparse(diag (diag(velocity(2:end-1), -1) + diag(-velocity(1:end-1) - velocity(2:end)) + diag(velocity(2:end-1), 1));
% % % % % % % % % %             else
% % % % % % % % % %                 A = diag (ones(number_cells-1, 1), 1) + diag((-2).*ones(number_cells, 1)) + diag (ones(number_cells-1, 1), -1);
% % % % % % % % % %             end
% % % % % % % % % %             
% % % % % % % % % %            A = a_h.* A;
% % % % % % % % % %            
% % % % % % % % % %         end
    end
end