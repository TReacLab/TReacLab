% Abstract Class [Application of Dependency Inversion Principle]
%
%   No properties
%



classdef (Abstract) Data 
    properties 
        Array
    end
    methods
        %constructor
        function this = Data(Array)
            this.Array = Array;
        end
        
        %getter
        function array= Get_Array(this)
            array=this.Array;
        end
        
        % setter
        function this= Set_Array(this, Array)
            this.Array=Array;
        end
    end
    
end
