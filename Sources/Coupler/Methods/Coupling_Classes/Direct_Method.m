% This class is in charge of applying direct methods, without coupling.
classdef Direct_Method
    properties
        solve_engine
        results
    end
    methods
          
        %   Instantiate a Direct_Method class. 

        function this = Direct_Method (Solve_Engine, Ini_Concentration)
            this.solve_engine=Solve_Engine;
            if (strcmpi(class(Ini_Concentration),'Array_Field')) || strcmpi(Ini_Concentration,'1D')
                this.results=Results_1D({},[]);
            else
                this.results=Results_0D({},[]);
            end
        end
        
        %   It solves the problem and store the solution in the 'results'
        %   property, and the same time it inputs the solution.

        function r=Loop(this, Problem)
            c=Problem.Get_Initial_Field();
            [time_class_list, time_list]=Problem.Get_Time_Classes_Dir();
            this.results = this.results.Append_Array_Field(c);
            this.results = this.results.Append_Time(time_list(1,1));
            for i=1:length(time_class_list)
                c_t=this.solve_engine.Time_Stepping(c,time_class_list{1,i});
                this.results=this.results.Append_Array_Field(c_t);
                this.results=this.results.Append_Time(time_list(i+1));
            end
            r=this.results;
        end

    end
end