% This class defines the Boundaries conditions for the flow problem, where
% Richards' equation are in use.

classdef Boundary_Conditions_Richards_1D
    properties (Access=private)
        inputnode_type             % char class; 
        outputnode_type            % char class; 
        inputnode_parameters       % three posibilities
        outputnode_parameters      % three posibilities
    end
    methods
        
        %   Instantiate a Boundary_Conditions class. The input node and
        %   output node are strings and the inputnode parameters and
        %   outputnode parameters are cell of strings.

        function this=Boundary_Conditions_Richards_1D (Inputnode_Type , Outputnode_Type, Inputnode_Parameters, Outputnode_Parameters)
            switch nargin
                case 2
                    this.inputnode_type=Inputnode_Type;
                    this.outputnode_type=Outputnode_Type;
                case 3
                    this.inputnode_type=Inputnode_Type;
                    this.outputnode_type=Outputnode_Type;
                    this.inputnode_parameters=Inputnode_Parameters;
                case 4
                    this.inputnode_type=Inputnode_Type;
                    this.outputnode_type=Outputnode_Type;
                    this.inputnode_parameters=Inputnode_Parameters;
                    this.outputnode_parameters=Outputnode_Parameters;
            end
        end
        
        %   It returns the 'outputnode_type' property, which should be a
        %   string
        
        function outputnodetype = Get_Outputnode_Type (this)
            outputnodetype=this.outputnode_type;
        end

        %   It returns the 'inputnode_type' property, which should be a
        %   string
        
        function inputnodetype = Get_Inputnode_Type (this)
            inputnodetype=this.inputnode_type;
        end

        %   It returns the saved 'inputnode_parameters' property
        
        function inputnode_cell = Get_Inputnode_Parameters (this)
            inputnode_cell=this.inputnode_parameters;
        end

        %   It returns the saved 'inputnode_parameters' property
        
        function outputnode_cell = Get_Outputnode_Parameters (this)
            outputnode_cell=this.outputnode_parameters;
        end
        
        
    end
end