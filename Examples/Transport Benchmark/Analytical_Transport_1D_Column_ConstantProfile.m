%   This class solves transport analytically for 1D problems. The  boundary
%   conditions for this class are predifined, its input condition can be a
%   constant flux or zero, and its output is open. It is a semi-infinite
%   medium. This class is used just to be run with a direct method. (NO COUPLING)
%   
%   governing differential equation:
%       
%      R*(dC/dt)=D*(d^2C/dx^2)-v*(dC/dx)
%
%   C is the concentration
%   v is the seepage velocity (Darcy velocity/porosity)
%   D is the sum of Dispersion + Difussion
%   R is the retardation factor 
%   t is time
%   x is distance
%
%   d represent a partial derivation here.
%
%   Initial and Boundary Conditions:
%
%       C(x,0)=Ci
%
%       C(0, t)= C0,    0 < t < t0
%       C(0, t)= 0,      t >t0
%  
%       dC/dx(infinite, t) = 0
%
%    Ci is the initial concentrationand constant value with distance. (Not suitable for Operator Splitting, as the values will not be constant.)
%    C0 is the inflow of the concentration at the inlet
%
%   The Analytical Solution for this equation is given by Lapidus and
%   Amundson 1952, Ogata and Banks 1961:
%
%   C(x, t)=Ci+(C0-Ci)A(x,t)                            0 < t < t0
%   C(x, t)=Ci+(C0-Ci)A(x,t)-C0A(x, t-t0)               t > t0
%
%   where
%   
%   A(x,t)=0.5*erfc[(R*x-v*t)/2*(D*R*t)^0.5]+0.5*exp(v*x/D)erfc[R*x+v*t/2*(D*R*t)^0.5]
%
%   This equation can be found in the following reference:
%   Titel: Analytical Solutions of the
%   One-Dimensional Convective-Dispersive Solute Transport Equation
%   Authors: M. Th. van Gencuhten and W. J. Alves. 
%   year: 1982
%   Journal: U.S.Department of Agriculture, Technical Bulletin No. 1661,
%   151p.
%
%   Note: The equation belongs to the section A (Solutions for No
%   Produciton or Decay) and it is the first one (A1 equation). This
%   solution is attributable to Lapidus and Amundson 1952 and Ogata and
%   Banks 1961.
%
%   Note_2: time0 corresponds to the time at which the boundary condition
%   of constant flow is removed from the system, namely no more
%   inflow of the element is given.

%before
% classdef Analytical_Transport_1D_Column_ConstantProfile < Process 
%
classdef Analytical_Transport_1D_Column_ConstantProfile < Solve_Engine
    properties (Access=private)
        morpho          % Morphology Class
        P_T_D           % Problem Transport Definition Class
        time0
    end
    
    methods
        
        % ======================================================================
        %
        % Constructor --> this= Analytical_Transport_1D_Column_ConstantProfile(Morphology, Equation)
        %
        %   inputs: 1) Morphology class
        %           2) Equation class
        %  
        %   output: 1) Analytical_Transport_1D_Column class.
        %   
        %   Instantiate an Analytical_Transport_1D_Column class.
        %
        %
        % ======================================================================
        function this= Analytical_Transport_1D_Column_ConstantProfile(Morphology, Equation)
            P_T_D_temp=Equation.Get_Parameters;
            P_T_D_temp=P_T_D_temp{1};
            this.P_T_D=P_T_D_temp;
            this.morpho=Morphology;     
            this.time0=P_T_D_temp.Boundary_Condition.Get_Time_Stop_Inflow;
        end
        
        
        % ======================================================================
        %
        % Time_Stepping --> c_fin=Time_Stepping (this, Initial_Field, Time)
        %
        %   inputs: 1) your Analytical_Transport_1D_Column class.
        %           2) Concentration class.
        %           3) Time class.
        %  
        %   output: 1) Concentration class.
        %   
        %   It solves the transport equation a whole interval of time.        
        %   initial_concentration have to be a matrix of identic values, it means
        %   c1=c2=...=cend 
        %
        % ======================================================================
        function c_fin=Time_Stepping (this, Initial_Field, Time, varargin)
            assert(Initial_Field.Constant_Profile()==true, '[Analytical_Transport_1D_Column_ConstantProfile/Time_Stepping ]Each element must have a constant profile.\n')
            matrix_t=Initial_Field.Get_Array;
            values=zeros(size(matrix_t,1), 1);
            list_new_values=cell(1,size(matrix_t,2));
            list_inflow=this.P_T_D.Boundary_Condition.Get_Inputnode_Parameters;
            d=this.morpho.Get_Edges_Domain;
            vec_distance=this.morpho.Get_Vector_Regular_Discretization_Points_Try ;
            for j=1:size(matrix_t,2)
                    [z,v_l]=ismember(Initial_Field.Get_List_Identifiers.Get_List_Id{1,j},list_inflow);
                for i=1:size(matrix_t,1)                        
                    if z==1
                        values(i,1)=this.Analytical_Ogata(vec_distance(1,i), Time.Get_Final_Time(), this.time0, matrix_t(i,j), str2num(this.P_T_D.Boundary_Condition.Get_Inputnode_Parameters{v_l+1}), ...
                            this.P_T_D.T_P_P.dispersion,this.P_T_D.T_P_P.retardation, this.P_T_D.T_P_P.velocity_aqueous);
                    else
                        values(i,1)=this.Analytical_Ogata(vec_distance(1,i), Time.Get_Final_Time(), this.time0, matrix_t(i,j), 0,this.P_T_D.T_P_P.dispersion,this.P_T_D.T_P_P.retardation, this.P_T_D.T_P_P.velocity_aqueous);
                    end
                end
                list_new_values{1,j}=values;
            end
            c_fin=Initial_Field.Update_Field(list_new_values);
        end
        
        % ======================================================================
        %
        % Equation --> conc=Analytical_Ogata (this, Distance, Time, Time0, Intconc, Concpoint0,D,R, Velocity)
        %
        %   inputs: 1) your Analytical_Transport_1D_Column class.
        %           2) double class. (float/int)    %#JR: what is the point of giving the type of the variables in Matlab? good quesiton.
        %           3) double class. (float/int)
        %           4) double class. (float/int)
        %           5) double class. (float/int)
        %           6) double class. (float/int)
        %           7) double class. (float/int)
        %           8) double class. (float/int)
        %           9) double class. (float/int)
        %  
        %   output: 1) double class. (float/int)
        %   
        %   the methods returns the obtained double after applying the
        %   equation of Lapidus and Amundson 1952 and Ogata and Banks 1961.
        %
        %   'distance' is the longitud at which we want the concentration
        %   value. 'time' is the time at which we want the concentration
        %   value. 'time0' establish when the inflow is stopped. 'intconc'
        %   is the initial concentration at the desired distance and time.
        %   'D' is the dispersion tensor (mechanical dispersion+diffusion),
        %   'R' is the retardation value and velocity is the flow velocity
        %   of the solution.
        %
        % ======================================================================
        function conc=Analytical_Ogata (this, Distance, Time, Time0, Intconc, Concpoint0,D,R, Velocity)
            if Time>0 && Time<Time0
                conc=Intconc+(Concpoint0-Intconc)*this.functionA(Distance, Time,D,R,Velocity);
            elseif Time>Time0
                conc=Intconc+((Concpoint0-Intconc)*this.functionA(Distance, Time,D,R, Velocity))-Concpoint0*functionA(Distance, (Time-Time0),D,R);
            else
                conc=Intconc;
            end
        end
        
        % ======================================================================
        %
        % function of Ogata --> value=functionA(this, Distance, Time,D,R, Velocity)
        %#JR: what is the exact reference? 
        %   inputs: 1) your Analytical_Transport_1D_Column class.
        %           2) double class. (float/int)
        %           3) double class. (float/int)
        %           4) double class. (float/int)
        %           5) double class. (float/int)
        %           6) double class. (float/int)
        %  
        %   output: 1) double class. (float/int)
        %   
        %   Sub-function of the 'Analytical_Ogata' method, it makes some
        %   calculation that are required to obtain the concentration value
        %   wanted in 'Analytical_Ogata' method.
        %
        % ======================================================================
        function value=functionA(this, Distance, Time,D,R, Velocity)
            lok=((R*Distance)-(Velocity*Time))/(2*(D*R*Time)^(0.5));
            A1=0.5*erfc(lok);
            lok=((R*Distance)+(Velocity*Time))/(2*(D*R*Time)^(0.5));
            exponential=exp((Velocity*Distance)/D);
            A2=0.5*erfc(lok);
            if exponential==Inf && A2==0
                B=0;
            else
                B=A2*exponential;
            end
            value=A1+B;
        end
        
    end
end