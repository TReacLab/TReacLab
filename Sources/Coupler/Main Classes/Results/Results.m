% The main aim of this class is to save the Array fields (values) for the
% different integration steps of the Operator Splitting Method.
%
% Note: The vector_fields cell and the vector_time must have the
% same dimension so as to have a coherence in the class, but the class
% allows some manipulations that can broke this agreement. Consequently,
% the user must be aware.
%

classdef Results
    
    properties (Access=private)
        vector_fields                   % this is a cell class {1:end, 1} (Nx1) containing, at each cell, the solution for a given time.
        vector_time                     % this vector contains the different time values at which the array field has been saved. (Nx1)
    end
    
    methods 
        
        %   Instantiate a Results class. 
        %
        %   Note: the two inputs are not compulsory

        function this=Results (Vector_Fields, Vector_Time)
            switch nargin
                case 0
                    this.vector_fields={};
                    this.vector_time=[];
                case 2
                    this.vector_fields=Vector_Fields;
                    this.vector_time=Vector_Time;
            end
        end

        %   this method is an accessor, it returns the property 
        %   "vector_fields" of your Results class as output

        function t=Get_Vector_Fields(this)
            t=this.vector_fields();
        end
        
        %   this method is an accessor, it returns the property 
        %   "vector_time" of your Results class as output
        
        function t=Get_Vector_Time(this)
            t=this.vector_time();
        end
        
        %   it returns a Results class which its property
        %   "vector_fields" is one cell longer, namely from {N,1} to
        %   {N+1,1}, owing to the insertion of a new field value at
        %   the end of the cell

        function this=Append_Array_Field(this, Conc)
            this.vector_fields{(size(this.vector_fields,1)+1),1}=Conc;
        end

        %   it returns a Results class which its property
        %   "vector_time" is longer, namely from (N,1) to (N+1,1), owing 
        %   to the insertion of a new time value at the end of the vector

        function this=Append_Time(this, Time)
            this.vector_time((size(this.vector_time,1)+1),1)=Time;
        end

        %   this method change the property "vector_time" for a new given 
        %   one
        
        function this=New_Vector_Time(this,List_Dt)
            this.vector_time=List_Dt;
        end

        %   this method change the property "vector_fields" for a
        %   new given one

        function this=New_Vector_Fields(this, List_Conc)
            this.vector_fields=List_Conc;
        end

        %   this method delete all the store values in the property "vector_time"

        function this=Clear_Vector_Time(this)
            this.vector_time=[];
        end

        %   this method delete all the store values in the property "vector_fields"

        function this=Clear_Vector_Fields(this)
            this.vector_fields=[];
        end
    end
end