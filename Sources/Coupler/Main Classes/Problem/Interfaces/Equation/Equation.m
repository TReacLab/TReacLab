% Equation class.
%   It contains the differential_fuction and the parameters of this
%   function.
%
%

classdef (Abstract) Equation 
    properties (Access=private)
        parameters                  % Different for each equation and process to be used.
        differential_function       % differential function that must be solved.
    end
    methods
        
        %   Instantiate a Problem class. The differential function can be
        %   nothing, a string or a function. The parameters vary according
        %   to the equation
        
        function this =  Equation (Differential_Function, Parameters)
            this.differential_function = Differential_Function;
            this.parameters= Parameters;
        end

        %   Gets the function stored in the 'differential_function'
        %   property. 

        function  funk= Get_Func (this)
            funk=this.differential_function;
        end

        %   Returns the 'parameters' property 

        function  parameters= Get_Parameters (this)
            parameters=this.parameters;
        end

        %   Instantiate the parameters according the string saved in the
        %   differential equation.

        function a=Instantiate_Parameters (this)
            a=Instantiate_Parameters_According_To_Name(this.differential_function, this.parameters);
        end
        
    end
end