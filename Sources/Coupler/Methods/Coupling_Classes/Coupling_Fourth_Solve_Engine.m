% This class is in charge of applying different Operator Splitting methods
% with four solve engines.

classdef Coupling_Fourth_Solve_Engine
    properties
        solve_engine_1            % A Solve Engine class.
        solve_engine_2            % A Solve Engine class.
        solve_engine_3            % A Solve Engine class.
        solve_engine_4            % A Solve Engine class.
        results                   % A Solve Engine class.
    end
    methods
        
        %   Instantiate a Coupling_Fourth_Solve_Engine class. 

        function this=Coupling_Fourth_Solve_Engine(SolveEngine1, SolveEngine2, SolveEngine3, SolveEngine4, Ini_Field)
                    this.solve_engine_1=SolveEngine1;
                    this.solve_engine_2=SolveEngine2;
                    this.solve_engine_3=SolveEngine3;
                    this.solve_engine_4=SolveEngine4;
                    if (strcmpi(class(Ini_Field),'Array_Field'))
                        this.results=Results_1D({},[]);
                    else
                        this.results=Results_0D({},[]);
                    end
        end

        %   it applies the Strang method for one splitting time step, 
        %   applying the First solve engine, Second solve engine, Third
        %   solve engine and Fourth solve engine. 

        function c_fin=Sequential_1234(this, C1, Time)
            u_1=this.process_1.Time_Stepping( C1,Time);
            u_2=this.process_2.Time_Stepping( u_1,Time);
            u_3=this.process_3.Time_Stepping( u_2,Time);
            c_fin=this.process_4.Time_Stepping( u_3,Time);
        end
        
        %   This method solves a problem applying a splitting method for a
        %   whole interval of time, and stores the values in a Result class
        %   which is outputed.

        function r=Loop(this, Couplermethod, Problem)
            c=Problem.Get_Initial_Field();
            [time_class_list, time_list, storage_points]=Problem.Get_Time_Classes_and_Saving_Points();
            this.results=this.results.Append_Array_Field(c);
            this.results=this.results.Append_Time(time_list(1,1));
            n=1;
            for i=1:length(time_class_list)
                c=this.couplermethod_function(Couplermethod,c,time_class_list{1,i});
                if storage_points(1,i)==true
                    this.results=this.results.Append_Array_Field(c);
                    this.results=this.results.Append_Time(time_list(1,i+1));
                end
                fprintf('The %d step has been calculated.\n',n);
                n=n+1;
            end
            r=this.results;
            
        end
        
        %   It applies the coupling method for one step regarding the given
        %   string and outputs its result.

        function conc_f=couplermethod_function(this, Couplermethod, C1, Dt_Num)
            if(strcmpi(Couplermethod,'Sequential_1234'))
                conc_f=Sequential_1234(this,C1,Dt_Num);
            end
        end
    end
end