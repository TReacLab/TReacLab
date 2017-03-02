% This class contains the Problem to be solved.

classdef Problem
    properties (Access=private)
        initial_field            % usually a Array_Field class, though it can be a matrix or scalar. It contains the initial values
        time                     % time class
        morphology               % Morphology class
        equation_list            % list of equations (class cell)
    end
    methods
           
        %   Instantiate a Problem class. Inputs: Time class, Array_Field
        %   class or matrix initial values, cell list containing the
        %   equations classes for each process.

        function this=Problem(Time, Initial_Field, Equation_list)
                    this.time=Time;
                    this.initial_field=Initial_Field;
                    this.equation_list = Equation_list;
        end
  
        %   The Morphology class is given and saved in the 'morphology'
        %   property

        function this = Fix_Morphology(this, Morphology)
            this.morphology=Morphology;
        end
        
        %   it returns the saved "initial_field" property of the
        %   Problem class
        
        function c1 = Get_Initial_Field(this)
            c1=this.initial_field;
        end
        
        %   it returns the saved "time" property of the
        %   Problem class.

        function c1 = Get_Time(this)
            c1=this.time;
        end
        
        %   it returns the saved "morphology" property of the
        %   Problem class.

        function c1 = Get_Morphology(this)
            c1=this.morphology;
        end

        %   it returns the saved "equation_list" property of the
        %   Problem class
        
        function c1 = Get_Equation_List(this)
            c1=this.equation_list;
        end
                
        %   It call the function 'Get_Nt_And_DtList()' of the 'time'
        %   property
        
        function [time_class_list, time_list, storage_points] = Get_Time_Classes_and_Saving_Points (this)
            [time_class_list,time_list, storage_points]=this.time.Get_Nt_And_DtList();
        end
        
        %   It call the function 'Get_Nt_And_DtList_Ref()' of the 'time'
        %   property
        
        function [time_class_list,time_list] = Get_Time_Classes_Dir(this)
            [time_class_list,time_list]=this.time.Get_Nt_And_DtList_Ref();
        end
        
        %   it changes the saved "time" property of the Problem class for a
        %   new given one time class
        
        function this = Change_Time_Class(this, New_Time_Class)
            assert(strcmpi(class(New_Time_Class),'Time'), '[Problem/Change_Time_Class] the given input must be a time class');
            this.time=New_Time_Class;
        end

        %   it creates a list (cell class of strings) containing differents
        %   solve engines

        function solve_engine_list = Instantiate_List_Of_Interface_and_Solve_Engines (this, List, CouplerMethod)
            l=length(List);
            solve_engine_list=cell(l,1);
            for i=1:l
                solve_engine_list{i}=this.Instantiate_Interface_Solve_Engine(List{i}, i,  CouplerMethod);
            end
        end

        %   it creates a Solve_Engine according the given 'solve_engine_name', which
        %   is a string
        
        function solve_engine=Instantiate_Interface_Solve_Engine (this, Solve_Engine_Name, I, CouplerMethod)
            solve_engine = Interface_Solve_Engine_Creator (this.morphology, this.equation_list{I}, this.initial_field, Solve_Engine_Name, CouplerMethod);
        end

    end
end