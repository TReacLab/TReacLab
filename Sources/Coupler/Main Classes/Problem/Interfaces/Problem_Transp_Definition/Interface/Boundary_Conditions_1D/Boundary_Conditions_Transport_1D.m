% This class defines the Boundaries conditions for the transport problem.
%
%
classdef Boundary_Conditions_Transport_1D
    properties (Access=private)
        inputnode_type             % char class; 'closed' 'inflow' 'open_boundary' 'outflow' 'simmetry'.
        outputnode_type            % char class; 'closed' 'inflow' 'open_boundary' 'outflow' 'simmetry'.
        inputnode_parameters       % three posibilities--> {} empty list, no inflow; {'C' '2.5e-8'; 'T' '8'} constant inflow; {'C' 'f(t)'} variable inflow
        outputnode_parameters      % three posibilities--> {} empty list, no inflow; {'C' '2.5e-8'; 'T' '8'} constant inflow; {'C' 'f(t)'} variable inflow
        time_stop_inflow           % Time at which the inflow is stop.
    end
    methods
        
        %   Instantiate a Boundary_Conditions class. The input node and
        %   output node are strings and the inputnode parameters and
        %   outputnode parameters are cell of strings
        
        function this=Boundary_Conditions_Transport_1D (Inputnode_Type , Outputnode_Type, Inputnode_Parameters, Outputnode_Parameters)
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

        %   It returns the name of elements saved in the 'inputnode_parameters' property
        
        function list_cell=Get_Elements_Inputnode(this)
            r=size(this.inputnode_parameters,1);
            list_cell=cell(1,size(this.inputnode_parameters,1));
            for i=1:r
                list_cell{1,i}=this.inputnode_parameters{i,1};
            end
        end

        %   It returns the name of elements saved in the 'outputnode_parameters' property
        
        function list_cell=Get_Elements_Outputnode(this)
            r=size(this.outputnode_parameters,1);
            list_cell=cell(1,size(this.outputnode_parameters,1));
            for i=1:r
                list_cell{1,i}=this.outputnode_parameters{i,1};
            end
        end

        %   It returns a Boundary_Conditions_1D class with a given
        %   'time_stop_inflow'
        
        function this=Fix_Time_Stop_Inflow(this, Timed)
            this.time_stop_inflow=Timed;
        end

        %   It returns the saved 'time_stop_inflow' property
        
        function t=Get_Time_Stop_Inflow (this)
            t=this.time_stop_inflow;
        end
    end
end