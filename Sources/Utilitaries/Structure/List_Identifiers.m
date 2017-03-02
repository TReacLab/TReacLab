% This Class is an structural class of Array_Field Class, namely it will
% be used by field. Its aim is to provide a list of all the
% variables of interest for the user as well as indicated which variables will 
% undergo transport (list_mobile_elements)

classdef List_Identifiers
    properties (Access = private)
        list_id                                             % List of all the elements in the system from precipitation, dissolution,etc.           L_id= {'C' 'pH' 'pe' 'B' 'Cr' 'Calcite'}
        list_solution_elements                              % list of 1 and 0; 1 --> "solution" 0 --> "not solution"  l=[1 0 0 1 .... 1]
        list_precipitation_dissolution_elements             % list of 1 and 0; 1 --> "precipitates or dissolves" 0 --> "not precipitates or dissolve" l=[1 0 0 1 .... 1]
        list_gaseous_elements                               % list of 1 and 0; 1 --> "it is a gas" 0 --> "not a gas" l=[1 0 0 1 .... 1]
        list_ionexchange_elements                           % list of 1 and 0; 1 --> "it is uses as an exchange element" 0 --> "it is not uses as an exchange element" l=[1 0 0 1 .... 1]
        list_kineticreactants_elements                      % list of 1 and 0; 1 --> "it is kinetic precipitation or dissolution" 0 --> "it is not uses as an exchange element" l=[1 0 0 1 .... 1] 
        list_hydraulic_properties                           % list of 1 and 0; 1 --> "it is hydraulic properties list" 0 --> "it is not uses as an hydraulic element" l=[1 0 0 1 .... 1] 
        list_data_chem                                      % parameters that are interesting to draw but not important
    end
    
    methods
        

        % Constructor: Initiate a List of Identifiers. Only the property
        % "list_id" is included, the other list should be included handly
        % by the "Add_List" method. We highly recommend to use the function
        % Create_List_Identifier_Class_From_Text in order to start the
        % List_Identifiers class
        
        function this = List_Identifiers (List_Id)
            assert(isa(List_Id,'cell'), '[Class List_Identifiers/Constructor] List_Id must be cell.\n' );
            this.list_id=List_Id;
        end
        
        % If the User does not want to use the function
        % Create_List_Identifier_Class_From_Text. He can add property list
        % with the following method into the class.
        %
        % The way to add is defined as follows:
        %
        %       Reactions -----------------> List_Reaction_Elements
        %       ----------------------------------------------------
        %
        %       'Solution' -----------------> list_solution_elements
        %  'PrecipitationDissolution'-----------> list_precipitation_dissolution_elements
        %       'Gas'      ----------------->  list_gaseous_elements
        %       'Ion_Exchange' -------------->  list_ionexchange_elements
        %       'Kinetics' -------------------> list_kineticreactants_elements
        %       'HydraulicProperty' ---------> list_hydraulic_properties
        %       'Data_Chem'  ---------> list_data_chem
        %
        %   Note: Careful, do not rewrite or eliminate a list that you want
        %   to save, unless you want
        %
        
        function this = Add_List (this, List_Elements, Type)
            assert(length(this.list_id)==length(List_Elements), '[Class List_Identifiers/Add_List] The added list must have the same length that List_Id.\n' );
            this.CheckAll_0_Or_1 (List_Elements)
            this.Check_No_Redundancy(List_Elements)
            if strcmpi(Type,'Solution')
                this.list_solution_elements=List_Elements;
            elseif strcmpi(Type,'PrecipitationDissolution')
                this.list_precipitation_dissolution_elements=List_Elements;
            elseif strcmpi(Type,'Gas')
                this.list_gaseous_elements=List_Elements;
            elseif strcmpi(Type,'Ion_Exchange')
                this.list_ionexchange_elements=List_Elements;
            elseif strcmpi(Type,'Kinetics')
                this.list_kineticreactants_elements=List_Elements;
            elseif strcmpi(Type,'HydraulicProperty')
                this.list_hydraulic_properties=List_Elements;
            elseif strcmpi(Type,'Data_Chem')
                this.list_data_chem=List_Elements;
            else
                fprintf('[Class List_Identifiers/Add_List] The %s reaction is not defined.\n', Type);
            end
                
        end
        
        % The function checks that all the values on the
        % List_Reaction_Elements are zero or one. Otherwise, an error arise
        % and the simulation crush
        
        function CheckAll_0_Or_1 (this, List_Reaction_Elements)
            for i=1:length(List_Reaction_Elements)
                assert(List_Reaction_Elements(i)==0 || List_Reaction_Elements(i)==1,'[Class List_Identifiers/CheckAll_0_Or_1] There is one element in the list that is not 0 or 1.\n ');
            end
        end
        
        % The function checks that no element has been defined twice in the
        % list. That means, an element can only belong to one list of the
        % different options: 'gas', 'Solution', 'IonExchange', ...
        
        function Check_No_Redundancy (this, List_Reaction_Elements)
            r=[List_Reaction_Elements];
            if ~isempty (this.list_solution_elements)
                r=[r;this.list_solution_elements];
            end
            if ~isempty (this.list_precipitation_dissolution_elements)
                r=[r;this.list_precipitation_dissolution_elements];
            end
            if ~isempty (this.list_gaseous_elements)
                r=[r;this.list_gaseous_elements];
            end
            
            if ~isempty (this.list_ionexchange_elements)
                r=[r;this.list_ionexchange_elements];
            end
            
            if ~isempty (this.list_kineticreactants_elements)
                r=[r;this.list_kineticreactants_elements];
            end
            
            if ~isempty (this.list_hydraulic_properties)
                r=[r;this.list_hydraulic_properties];
            end
            lr=size(r,1);
            if lr>1
                t=sum(r);
%                 assert(any(t>=2),  '[Class List_Identifiers/Check_No_Redundancy] There is one element that is defined in more than two chemical reactions.')
            else
%                 assert(any(r>=2),  '[Class List_Identifiers/Check_No_Redundancy] There is one element that is defined in more than two chemical reactions.')
            end
        end
        
        % returns the 'list_id' property 
        function list_id= Get_List_Id (this)
            list_id=this.list_id;
        end

        %Returns the 'list_solution_elements' property
        function list_solution_elements= Get_Solution_Elements (this)
            list_solution_elements=this.list_solution_elements;
        end        
        
        %   Returns the 'list_precipitation_dissolution_elements' property
        function list_precipitation_dissolution= Get_Precipitation_Dissolution_Elements (this)
            list_precipitation_dissolution=this.list_precipitation_dissolution_elements;
        end   
        
        % Returns the 'list_gaseous_elements' property
        function list_gaseous_element= Get_Gaseous_Elements (this)
            list_gaseous_element=this.list_gaseous_elements;
        end   

        %   Returns the 'list_ionexchange_elements' property
        function list_ionexchange_element= Get_Ionexchange_Elements (this)
            list_ionexchange_element=this.list_ionexchange_elements;
        end 

        %   Returns the 'list_kineticreactants_elements' property
        function list_kineticreactants_elements= Get_KineticReactants_Elements (this)
            list_kineticreactants_elements=this.list_kineticreactants_elements;
        end 
        
        %   Returns the 'list_hydraulic_properties' property
        function list_hydraulic_properties= Get_Hydraulic_Properties (this)
            list_hydraulic_properties=this.list_hydraulic_properties;
        end 
        
        %   Returns the 'list_data' property
        function list_data= Get_Data_Chem (this)
            list_data=this.list_data_chem;
        end 
        
        %   It returns a boolean,it will be true if the two
        %   List_Identifiers classes are equal 
        function boolean = Equal (this, List_Identifiers_Class)
            if ~isempty(setxor(this.list_id,List_Identifiers_Class.Get_List_Id()))
                boolean=false;
            elseif ~isequal(this.list_solution_elements, List_Identifiers_Class.Get_Solution_Elements)
                boolean=false;
            elseif ~isequal(this.list_ionexchange_elements, List_Identifiers_Class.Get_Ionexchange_Elements)
                boolean=false;
            elseif ~isequal(this.list_gaseous_elements, List_Identifiers_Class.Get_Gaseous_Elements)
                boolean=false;
            elseif ~isequal(this.list_precipitation_dissolution_elements, List_Identifiers_Class.Get_Precipitation_Dissolution_Elements)
                boolean=false;
            elseif ~isequal(this.list_kineticreactants_elements, List_Identifiers_Class.Get_KineticReactants_Elements)
                boolean=false;
            elseif ~isequal(this.list_hydraulic_properties, List_Identifiers_Class.Get_Hydraulic_Properties)
                boolean=false;
            elseif ~isequal(this.list_data_chem, List_Identifiers_Class.Get_Data_Chem)
                boolean=false;
            else
                boolean=true;
            end
        end
        
        % Append another List_Identifiers into the an old List_identifiers.
        % Precondition:= It is assumed that the elements stored in the property
        % "list_id" of both List_Identifiers classes are different.  

        function this=Append_New_Element(this,Identifier)
            this.list_id={this.list_id{1:end} Identifier.Get_List_Id{1:end}};
            this.list_solution_elements=[this.list_solution_elements Identifier.Get_Solution_Elements];
            this.list_ionexchange_elements=[this.list_ionexchange_elements Identifier.Get_Ionexchange_Elements];
            this.list_gaseous_elements=[this.list_gaseous_elements Identifier.Get_Gaseous_Elements];
            this.list_precipitation_dissolution_elements=[this.list_precipitation_dissolution_elements Identifier.Get_Precipitation_Dissolution_Elements];
            this.list_kineticreactants_elements=[this.list_kineticreactants_elements Identifier.Get_KineticReactants_Elements]; 
            this.list_hydraulic_properties=[this.list_hydraulic_properties Identifier.Get_Hydraulic_Properties];
            this.list_data_chem=[this.list_data_chem Identifier.Get_Data_Chem];
        end
        
        % Get the string components of list_id for a list properties of
        % ones and zeros such as list_solution_elements,
        % list_hydraulic_properties, etc.
        
        function list_name = Get_List_Names (this, String_Name)
            a=this.Assign_List (String_Name);
            if isempty(a)
                list_name={};
            else
                d = length(this.list_id);
                list_name=cell(1,sum(a));
                n=1;
                for i=1:d
                    if (a (1,i) == 1)
                        list_name{1,n} = this.list_id{1,i};
                        n=n+1;
                    end
                end
            end
        end
        
        % returns the list properties such as list_solution_elements,
        % list_hydraulic_properties, etc. for a proper giving string.
        
        function a= Assign_List (this, String_Name)
            if strcmpi(String_Name,'Solution')
                a=this.list_solution_elements;
            elseif strcmpi(String_Name,'PrecipitationDissolution')
                a=this.list_precipitation_dissolution_elements;
            elseif strcmpi(String_Name,'Gas')
                a=this.list_gaseous_elements;
            elseif strcmpi(String_Name,'Ion_Exchange')
                a=this.list_ionexchange_elements;
            elseif strcmpi(String_Name,'Kinetics')
                a=this.list_kineticreactants_elements;
            elseif strcmpi(String_Name,'HydraulicProperty')
                a=this.list_hydraulic_properties;
            elseif strcmpi(String_Name,'Data_Chem')
                a=this.list_data_chem;
            else
                fprintf('[Class List_Identifiers/Assgin_List] The %s list is not defined.\n', String_Name);
            end
        end
        
        % Special case of Get_List_Names method, the function retuns
        % 'Solution' and 'Gas' list joint. 
        
        function l_mobile= Get_Mobile_Species (this)
            list_solution_names = this.Get_List_Names ('Solution');
            list_gaseous_names = this.Get_List_Names ('Gas');
%             list_hydraulic_names = this.Get_List_Names ('HydraulicProperty');
            l_mobile=[list_solution_names list_gaseous_names];
        end
        
        %   Returns true if all the elements inside the given list are
        %   already saved in the list_id property and are mobile.
        
        function boolean= List_Belongs_To_Mobil_List(this, List_Element)
            boolean=true;
            for i=1:length(List_Element)
                b=Element_Belongs_To_Mobil_List (this, List_Element{i});
                if b==false
                    boolean=false;
                    break
                end
            end
        end

        %   Returns true if the given elements is already saved in 
        %   the list_id property and is mobile. 
        
        function b=Element_Belongs_To_Mobil_List (this, Element)
            r=this.Get_Mobile_Species;
            [b, ~]=ismember(Element, r);
        end
        
        %   Returns true if the given elements is already saved in 
        %   the list_id property and is immobile.
        
        function b=Element_Belongs_To_Immobil_List (this, Element)
            r=this.Get_Mobile_Species;
            [b, ~]=ismember(Element, r);
            b=~b;
        end
        
        % It removes fully an element of the List_Identifiers class.

        function this=Remove_Element_List_Identifiers(this, index)
            if ~isempty(this.list_id)
                this.list_id(index)=[];
            end
            if ~isempty(this.list_solution_elements)
                this.list_solution_elements(index)=[];
            end
            if ~isempty(this.list_ionexchange_elements)
                this.list_ionexchange_elements(index)=[];
            end
            if ~isempty(this.list_gaseous_elements)
                this.list_gaseous_elements(index)=[];
            end
            if ~isempty(this.list_precipitation_dissolution_elements)
                this.list_precipitation_dissolution_elements(index)=[];
            end
            if ~isempty(this.list_kineticreactants_elements)
                this.list_kineticreactants_elements(index)=[];
            end
            if ~isempty(this.list_hydraulic_properties)
                this.list_hydraulic_properties(index)=[];
            end
            if ~isempty(this.list_data_chem)
                this.list_data_chem(index)=[];
            end
        end
        
        % It creates a new List_Identifiers with just one field. The user
        % must give the position where the field is found, namely index
        % position in the list.
        
        function this=Separate_Element_List_Identifiers(this, index)
            if ~isempty(this.list_id)
                this.list_id=this.list_id(index);
            end
            if ~isempty(this.list_solution_elements)
                this.list_solution_elements=this.list_solution_elements(index);
            end
            if ~isempty(this.list_ionexchange_elements)
                this.list_ionexchange_elements=this.list_ionexchange_elements(index);
            end
            if ~isempty(this.list_gaseous_elements)
                this.list_gaseous_elements=this.list_gaseous_elements(index);
            end
            if ~isempty(this.list_precipitation_dissolution_elements)
                this.list_precipitation_dissolution_elements=this.list_precipitation_dissolution_elements(index);
            end
            if ~isempty(this.list_kineticreactants_elements)
                this.list_kineticreactants_elements=this.list_kineticreactants_elements(index);
            end
            if ~isempty(this.list_hydraulic_properties)
                this.list_hydraulic_properties=this.list_hydraulic_properties(index);
            end
            if ~isempty(this.list_hydraulic_properties)
                this.list_data_chem=this.list_data_chem(index);
            end
        end
        
        % a list (cell) of string with a new order is given to the
        % function. The function return the old List_Identifier class with
        % a new order.
        % 
        % Precondition: the given list of string must contain all the
        % strings of the property 'list_id'
        
        function new_ListIdentifers = Change_Order_Array_Columns (this, List_Ide)
            assert(isempty(setxor(List_Ide, this.list_id)), '[List_Identifiers/Change_Order_Array_Columns] The list of Identifiers are not equal')
            l={};
            addings={};
            i=1;
            if ~isempty(this.list_solution_elements)
                l{i}=this.list_solution_elements;
                addings{i}={'Solution'};
                i=1+i;
            end
            if ~isempty(this.list_ionexchange_elements)
                l{i}=this.list_ionexchange_elements;
                addings{i}={'Ion_Exchange'};
                i=1+i;
            end
            if ~isempty(this.list_gaseous_elements)
                l{i}=this.list_gaseous_elements;
                addings{i}={'Gas'};
                i=1+i;
            end
            if ~isempty(this.list_precipitation_dissolution_elements)
                l{i}=this.list_precipitation_dissolution_elements;
                addings{i}={'PrecipitationDissolution'};
                i=1+i;
            end
            if ~isempty(this.list_kineticreactants_elements)
                l{i}=this.list_kineticreactants_elements;
                addings{i}={'Kinetics'};
                i=1+i;
            end
            if ~isempty(this.list_hydraulic_properties)
                l{i}=this.list_hydraulic_properties;
                addings{i}={'HydraulicProperty'};
                i=1+i;
            end
            if ~isempty(this.list_data_chem)
                l{i}=this.list_data_chem;
                addings{i}={'Data_Chem'};
                i=1+i;
            end
            dime2=length(l);
            l2=cell(1,dime2);
            for j=1:length(List_Ide)
                [~,z]=ismember(List_Ide{j}, this.list_id);
                for m=1:dime2
                   l2{m}(j)=l{m}(z);
                end
            end
            new_ListIdentifers=List_Identifiers (List_Ide);
            for m=1:dime2
                new_ListIdentifers=new_ListIdentifers.Add_List (l2{m}, addings{m});
            end
        end
        
        % It returns a string for the units regarding if the element is
        % Solution, Gas, Hydraulic Property, etc.
        
        function s=Get_Units_Plot_Label (this, Field)
            S=this.Get_Type(Field);
            if strcmpi(S, 'Solution')
                s='Concentration (mol/kgw)';
            elseif strcmpi (S, 'Mineral') || strcmpi (S, 'Gas')
                s='Amount (mol)';
            elseif strcmpi(S,'IonExchange')
                s='Look at List_Identifiers/Get_Units_Plot_Label';
            elseif strcmpi (S, 'Hydraulic_Property')
                s='Hydraulic Property development units regarding Field';
            elseif strcmpi (S, 'Data_Chem')
                s='';
            end
        end
        
        % Given a field,it returns a string with the type of the field.
        
        function s=Get_Type(this, Field)
            [b, index]=ismember(Field, this.list_id);
            if b==true
                if this.list_solution_elements(index)==1
                    s='Solution';
                elseif this.list_precipitation_dissolution_elements(index)==1 
                    s='Mineral';
                elseif this.list_gaseous_elements(index)==1        
                    s='Gas';
                elseif this.list_ionexchange_elements(index)==1        
                    s='IonExchange';
                elseif this.list_kineticreactants_elements(index)==1             
                    s='Mineral';
                elseif this.list_hydraulic_properties(index)==1   
                    s='Hydraulic_Property';
                elseif this.list_data_chem(index)==1   
                    s='Data_Chem';
                else
                    fprintf('[Class List_Identifiers/Get_Type] Error.\n')
                end
            else
                fprintf('[Class List_Identifiers/Get_Type] The %s field is not defined.\n', Field)
            end
        end
        
        % Returns a matrix of 1s and 0s, created by the different list
        % properties of the List Identifier class
        
        function  A= Get_Matrix_Expl(this)
            A=[this.list_solution_elements];
            A=[A; this.list_precipitation_dissolution_elements];
            A=[A; this.list_gaseous_elements];
            A=[A; this.list_ionexchange_elements];
            A=[A; this.list_kineticreactants_elements];
            A=[A; this.list_hydraulic_properties];
            A=[A; this.list_data_chem];
        end
        
        % Create a list Identifier class just composed by data chemical
        % components.
        
        function L=List_Identifiers_Data_Chem (this, listId)
            len=length(listId);
            list_identifier=List_Identifiers (listId);
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Solution');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'PrecipitationDissolution');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Gas');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Ion_Exchange');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Kinetics');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'HydraulicProperty');
            L=list_identifier.Add_List(ones(1, len), 'Data_Chem');
        
        end
        
        % Create a list Identifier class just composed by solution
        % components. 
        
        function L=List_Identifiers_Solution (this, ListSol, ListHP)
            lensol=length(ListSol);
            lenhp=length(ListHP);
            len=lensol+lenhp;
            listId=[ListSol ListHP];
            list_identifier=List_Identifiers (listId);
            list_identifier=list_identifier.Add_List([ones(1, lensol) zeros(1, lenhp)], 'Solution');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'PrecipitationDissolution');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Gas');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Ion_Exchange');
            list_identifier=list_identifier.Add_List(zeros(1, len), 'Kinetics');
            list_identifier=list_identifier.Add_List([zeros(1, lensol) ones(1, lenhp)], 'HydraulicProperty');
            L=list_identifier.Add_List(zeros(1, len), 'Data_Chem');
        end
        
        % Creates a list identifiers class just of the desired component
        % such as Solution, PrecipitationDissolution, Gas, ...
        
        function L= Create_List_Identifiers_Desired (this, Listdesired, Desiredlist)
            L=List_Identifiers (Listdesired);
            d=length(Listdesired);
            L=this.Create_List_Identifiers_Desired_Matrix(d, L);
            if strcmpi(Desiredlist, 'Solution')
                L=L.Add_List(ones(1, d), 'Solution');
            elseif strcmpi(Desiredlist, 'PrecipitationDissolution')
                L=L.Add_List(ones(1, d), 'PrecipitationDissolution');
            elseif strcmpi(Desiredlist, 'Gas')
                L=L.Add_List(ones(1, d), 'Gas');
            elseif strcmpi(Desiredlist, 'Ion_Exchange')
                L=L.Add_List(ones(1, d), 'Ion_Exchange');
            elseif strcmpi(Desiredlist, 'Kinetics')
                L=L.Add_List(ones(1, d), 'Kinetics');
            elseif strcmpi(Desiredlist, 'HydraulicProperty')
                L=L.Add_List(ones(1, d), 'HydraulicProperty');
            elseif strcmpi(Desiredlist, 'Data_Chem')
                L=L.Add_List(ones(1, d), 'Data_Chem');
            end
        end
        
        % Adds all the possible list identifiers with zero values
        
        function L = Create_List_Identifiers_Desired_Matrix(this, d, L)
            L=L.Add_List(zeros(1, d), 'Solution');
            L=L.Add_List(zeros(1, d), 'PrecipitationDissolution');
            L=L.Add_List(zeros(1, d), 'Gas');
            L=L.Add_List(zeros(1, d), 'Ion_Exchange');
            L=L.Add_List(zeros(1, d), 'Kinetics');
            L=L.Add_List(zeros(1, d), 'HydraulicProperty');
            L=L.Add_List(zeros(1, d), 'Data_Chem');
        end 

    end
end