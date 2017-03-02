%
% This class contains the values of the nodes as well as a List Identifiers
% class and the number of the rows nodes. It could be considered a corner
% stone of the software.
%
% ======================================================================
%> brief  Spatial Field (defined in Morphology) stored in a template
%
%
%> (rows)   1 (pH)           2 (Ca)                    no (list_identifiers.list_id)
%>    1    Array(1,1)      Array(1,2)
%>    2    Array(2,1)      Array(2,2)
%> .........................


classdef Array_Field < Data

    properties (Access=private)
        list_identifiers        % is a List_Identifiers class.
        rows                   % rows vector with dimension (Nrows x 1) containing the diferent values
    end
    
    methods
        
        %   It creates an array field from a given list of identifiers and a
        %   numerical array. 
        %   The values in Array must be coherent with list_identifiers.
        %   The order of id_list in list_identifiers must be the same
        %   order uses in Array.
        %   The rows of the Array correspond to node points.
        %
        %   Another way to create an Array is using the functions
        %   Create_Array_Field_From_Phreeqc_File_vers2 and similar (comment must be completed)
       
        
        function this= Array_Field(List_Identifiers, Array)
            this = this@Data(Array);
            this.list_identifiers=List_Identifiers;
            this.rows=1:1:size(Array, 1);
        end
        
        %   It returns a boolean,it will be true if the two classes are equal.
        
        function boolean = Equal (this, Array_Field)
            if ~this.list_identifiers.Equal(Array_Field.Get_List_Identifiers())
                boolean=false;
            elseif ~isequal(this.Array, Array_Field.Get_Array())
                boolean=false;
            elseif ~isequal(this.rows, Array_Field.Get_Rows())
                boolean=false;
            else
                boolean=true;
            end
        end
        
        %   it returns the saved List_Identifiers class, which is a
        %   property of Array_Field class.
        
        function list = Get_List_Identifiers(this)
            list=this.list_identifiers;
        end
        
        %   it returns the saved List_Id property from the list_identifiers class, 
        %   which is a property of Array_Field class.
        %
        %   Every string of the returned list (cell) of string corresponds
        %   to the column values of the matrix.
        
        function list=Get_List_Ide (this)
            list=this.list_identifiers.Get_List_Id;
        end
        
        %   it returns the saved list_mobil_elements property from the
        %   list_identifiers class,  which is a property of Array_Field class.
        
        function list=Get_List_Ide_MobileSpecies (this)
            list=this.list_identifiers.Get_Mobile_Species;
        end
        
        %   it returns the mobile components from the list_identifiers
        %   class,  which is a property of Array_Field class
        
        function list= Get_Transport_Elements (this)
            list=this.list_identifiers.Get_List_Names('Solution');
        end

        
        %   it returns the saved property "rows" (a increasing vector
        %   giving the number of the rows, which is equal to the amount of
        %   nodes) 
         
        function vector= Get_Rows(this)
            vector=this.rows;
        end
        
        %   This new Array Field class has the same saved
        %   properties than the old one, but it increase the length of
        %   the mesh and adds the values for this new given mesh points(Array)
        %
        %   This method can be interpretated as an incrementation of the rows
        %   points and hence the matrix where the values of this points
        %   have been saved
        %
        %   Precondition: The values of the rows should not be already in
        %   your Array_Field class
        
        function this=Concatenate_Array_Field(this, C1)
            
            if this.list_identifiers.Equal(C1.Get_List_Identifiers)
                C1=C1.Change_Order_Array_Columns(this.Get_List_Ide);
                this.Array=[this.Array; C1.Get_Array];
                this.rows=1:1:size(this.Array, 1);
            else
                this=this.Concatenate_Array_Field_Different_Identifiers (C1);
            end
        end
        
        % It concatenates two Array_Field class which contain different
        % identifiers. It will create values zeros where the component does
        % not exist in the media. Could be helpful for heterogeneous
        % mineral compositions

        function this=Concatenate_Array_Field_Different_Identifiers (this, C1)
            % n_rows
            n1=this.rows;
            n2=C1.Get_Rows;
            % look for the different elements
            list_diff1=setdiff(this.list_identifiers.Get_List_Id, C1.Get_List_Ide);
            list_diff2=setdiff(C1.Get_List_Ide, this.list_identifiers.Get_List_Id);
            % Remove the different elements
            C2=this.Remove_Elements_Array_Field(list_diff1);
            C3=C1.Remove_Elements_Array_Field(list_diff2);
            % Concatenate the equal elements matrix
            C4=C2.Concatenate_Array_Field(C3);
            if ~isempty(list_diff1) && ~isempty(list_diff2)
            % Separate different elements
            C5=this.Separate_Elements_Array_Field(list_diff1);
            C6=C1.Separate_Elements_Array_Field(list_diff2);
            % Expand the separate concentrations (add 0 where the element is not)
            C5=C5.Concatenate_Array_Field(Array_Field(C5.Get_List_Identifiers, zeros(length(n2),length(C5.Get_List_Ide))));
            C7=Array_Field(C6.Get_List_Identifiers, zeros(length(n1),length(C6.Get_List_Ide)));
            C7=C7.Concatenate_Array_Field(C6);
            % Append the new concentrations
            this=C4.Append_New_Element(C5);
            this=this.Append_New_Element(C7);
            elseif isempty(list_diff1) && ~isempty(list_diff2)
            % Separate different elements  
            C6=C1.Separate_Elements_Array_Field(list_diff2);
            % Expand the separate concentrations (add 0 where the element is not)
            C7=Array_Field(C6.Get_List_Identifiers, zeros(length(n1),length(C6.Get_List_Ide)));
            C7=C7.Concatenate_Array_Field(C6);
            %Append the new concentrations
            this=C4.Append_New_Element(C7);
            end
        end
        
        % Remove all the elements of the inputed list that are in Array_Field.
        
        function this = Remove_Elements_Array_Field(this, list_remove)
            for i=1:length(list_remove)
                [boolean, index]=ismember(list_remove{i}, this.list_identifiers.Get_List_Id);
                if boolean==true
                    this=this.Remove_Element_Array_Field(index);
                end
            end
        end
        
        % Remove an element of the array field given an specific index
        % position. (the index position is coherent with a column.)
        
        function this=Remove_Element_Array_Field(this, index)
            this.Array(:, index)=[];
            this.list_identifiers=this.list_identifiers.Remove_Element_List_Identifiers(index);
        end
        
       % Creates an Array_Field class drawing the element columns (list_diff) from other
       % Array_Field class.

        function new_array_field = Separate_Elements_Array_Field (this, list_diff)
            n=1;
            for i=1:length(list_diff)
                [boolean, index]=ismember(list_diff{i}, this.Get_List_Ide);
                if boolean==true
                    this_temp=Separate_Element_Array_Field (this, index);
                    if n==1
                        new_array_field=this_temp;
                    else
                        new_array_field=new_array_field.Append_New_Element(this_temp);
                    end
                    n=n+1;
                end
            end
        end
        
        % It returns an Array_Field class (compose just by one component)
        % for a given index from an other Array_Field class.

        function this=Separate_Element_Array_Field (this, index)
            this.Array=this.Array(:, index);
            this.list_identifiers=this.list_identifiers.Separate_Element_List_Identifiers(index);
        end
        
        %   This new Array Field class has the same saved
        %   properties than the old one, but it adds new elements in
        %   List_Identifiers class as well as its corresponding values in
        %   the Array.
        %
        %   Note: The elements of each Array Field class must be different
        %   (List_Identifiers --> list_id). Otherwise the method will
        %   crush.
        
        function this=Append_New_Element(this, C1)
            assert (length(this.rows)==length(C1.Get_Rows), '[Array_Field/Append_New_Element] The number of rows must be equal.\n');
            name_list_ext = C1.Get_List_Ide;
            name_list_int = this.Get_List_Ide;
            assert (length(setxor(name_list_ext, name_list_int))==(length(name_list_ext)+length(name_list_int)), '[Array_Field/Append_New_Element] the elements must be different');
            this.Array=[this.Array C1.Get_Array];
            this.list_identifiers=this.list_identifiers.Append_New_Element(C1.Get_List_Identifiers);
        end
        
        %   splits the array of concentraitons and stores the new 
        %   Array Field class inside a cell class with dimension 
        %   {1,n_GPUs}.
        
        function subfieldarray_cell= DivideArrayField(this,N_GPUs)
            vector_of_division=this.Vectordivision(N_GPUs);
            subfieldarray_cell=cell(1,N_GPUs);
            n=1;
            for i=1:N_GPUs
                subfieldarray_cell{1,i}=Array_Field(this.list_identifiers, this.Array(n:n+vector_of_division(1,i)-1,1:end));
                n=n+vector_of_division(1,i);
            end
        end
        
        %   it returns a vector of double/int classes. The numbers
        %   represent the number of rows points that have to be assembled
        %   in each division given by n_GPUs number.    
        
        function vector_of_division = Vectordivision(this, N_GPUs)
            [row,~]=this.Array_Size();
            div_conc_number=floor(row/N_GPUs);
            vector_of_division=zeros(1,N_GPUs);
            for i=1:N_GPUs
                vector_of_division(1,i)=div_conc_number;
                if (i==N_GPUs)
                    vector_of_division(1,i)=div_conc_number+(row-(N_GPUs*div_conc_number));
                end
            end
        end

        %   it returns two numbers which are the number of rows and
        %   columns, respectively.

        function [row,col]=Array_Size(this)
            [row,col]=size(this.Array);
        end
        
        %   It merge all the Array_Field classes inside the given cell
        %   list.
        %
        %   Precondition: There should be a coherence between the stored
        %   classes in the cell list. 
        %   For instance, the rows property value have to be different for
        %   each matrix, otherwise it would be a redundancy or conflict
        %   between different values for the same points in the rows.
        %   Furthermore, all the saved Array_Field classes, inside the
        %   cell, should have the same List_Identifiers property.
   
        function arrayfield_f=MerginArrayField(this, Cell_SubArrayField_Output)
            array1=Cell_SubArrayField_Output{1,1}.Get_Array;
            list_id= Cell_SubArrayField_Output{1,1}.Get_List_Identifiers();
            arrayfield_f=Array_Field(list_id, array1);
            for i=2:length(Cell_SubArrayField_Output)
                arrayfield_f=arrayfield_f.Concatenate_Array_Field(Cell_SubArrayField_Output{1,i});
            end
        end
        

        %   It gets the vector of an element ("identifier") which must be
        %   contained in both Array_Field classes ("this" &
        %   "array_reference"), makes the difference and returns
        %   the norm ("p") of the difference, unless the difference is zero. In
        %   that case it return an emptycell.
        %
        %   Precondition: The List_Identifiers property must be the same
        %   for both Array_Field classes.

        function nor=Norm_Vector(this, Array_Field_Ref, Identifier, P)
            assert(strcmpi(class(Array_Field_Ref),'Array_Field'),'[Array_Field/ Norm_Vector]; The vector reference must be Array_Field class')
            d=cellfun(@strcmp,Array_Field_Ref.Get_List_Identifiers.Get_List_Id, this.Get_List_Identifiers.Get_List_Id);
            assert(length(d)==sum(d),'[Array_Field/ Norm_Vector]; the identifiers list of reference and the arrayfield evaluated are not equal')
            nor=0;
            [boolean,n]=this.Identifier_Position(Identifier);
            if (boolean==true)
                a=this.Get_Array;
                b=Array_Field_Ref.Get_Array;
                a=a(1:end,n);
                b=b(1:end,n);
                diff=abs(b-a);
                if (sum(diff)~=0)
                    nor=norm(diff,P);
                end
            end
        end
        
        %   If the boolean is false, it means that the wanted element
        %   ("identifier", for instance "C") is not in the 
        %   Array_Field class and n==0. Otherwise, the method will return
        %   true as boolean and the column where the values of the element
        %   are saved (this values are in the Array property).

        function [boolean,n]=Identifier_Position(this, Identifier)
            boolean=false;
            n=0;
            while boolean==false && n<length(this.list_identifiers.Get_List_Id)
                n=n+1;
                if (strcmp(this.list_identifiers.Get_List_Id{1,n},Identifier))
                    boolean=true;
                end
            end
            if (boolean==false)
                n=0;
            end
        end
        
        %   It plots for a given method and time, the comparision between 
        %   two Array_Field classes for the same element. Being the
        %   horizontal axis the rows points and the vertical axis the
        %   field values. Moreover, it plots the relative error
        %   between this two values of filds for the whole rows
        %   points.
        %
        %
        %   Precondition: Both, Array_Field classes, have the same
        %   rows and list_identifiers properties.
   
        function Plot_Comparison_1D(this, C1, Element, Time, Method, vector_test_x, vector_ref_x, relative_error)
%             assert(isempty(setxor(this.list_identifiers.Get_List_Id,C1.Get_List_Ide)), '[Array_Field/Print_Comparison_1D] the list identifiers in Print_Comparison are different\n')
%             assert(isempty(setxor(this.rows,C1.Get_Rows)), '[Array_Field/Print_Comparison_1D] the rows in Print_Comparison are different.\n')
            if nargin == 7
                R_E=false;
            else
                R_E=relative_error;
            end
            if R_E==false
                this.Plot_Comparison_1D_No_Relative_Error (C1, Element, Time, Method, vector_test_x, vector_ref_x, 'Distance (m)')
            else
                this.Plot_Comparison_1D_Relative_Error (C1, Element, Time, Method, vector_test_x, vector_ref_x, 'Distance (m)')
            end

        end
        
        function Plot_Comparison_1D_No_Relative_Error(this, C1, Element, Time, Method, X1, X2, String_X)
            [v1,z1]=ismember(Element, this.list_identifiers.Get_List_Id);
            [v2,z2]=ismember(Element, C1.list_identifiers.Get_List_Id);
            if v1==1 && v2==1
                figure
                Y_ref_temp=C1.Get_Array;
                Y_ref=Y_ref_temp(1:end,z2)';
                Y_coup=this.Array(1:end, z1)';
                hold on
                set(gca,'FontSize',14) 
                plot(X2,Y_ref,'rx-', 'LineWidth',2,'MarkerSize',10)
                plot(X1,Y_coup,'b.-', 'LineWidth',2,'MarkerSize',10)
                xlabel('x','FontSize',14);
%                 s= this.Get_Units_Plot_Label (Element);
                s = 'mol/L'
                ylabel(s, 'FontSize',14);
%                 ylabel('Concentration (mol/kgw)', 'FontSize',14);
                title(sprintf('T=%.2fs for %s. %s', Time, Element, Method), 'FontSize', 14)
                h_legend=legend ('Ref', 'OS');
                set(h_legend,'FontSize',14);
                hold off
            else
                fprintf ('[Array_Field/Print_Comparison] %s is not in the list of identifiers. \n', Element);
            end
        end
        
        function Plot_Comparison_1D_Relative_Error (this, C1, Element, Time, Method, X1, X2, String_X)
            [v1,z1]=ismember(Element, this.list_identifiers.Get_List_Id);
            [v2,z2]=ismember(Element, C1.list_identifiers.Get_List_Id);
            if v1==1 && v2==1
                figure
                Y_ref_temp=C1.Get_Array;
                Y_ref=Y_ref_temp(1:end,z2)';
                Y_coup=this.Array(1:end, z1)';
                subplot(1,2,1)
                hold on
                set(gca,'FontSize',14) 
                plot(X2,Y_ref,'rx-', 'LineWidth',2,'MarkerSize',10)
                plot(X1,Y_coup,'b.-', 'LineWidth',2,'MarkerSize',10)
                xlabel(String_X,'FontSize',14);
                s= this.Get_Units_Plot_Label (Element);
                ylabel(s, 'FontSize',14);
                title(sprintf('Field at t=%.2f for %s', Time, Element), 'FontSize', 14);
                h_legend=legend ('ref', 'OS');
                set(h_legend,'FontSize',14);
                
                subplot(1,2,2)
                err=abs((Y_coup-Y_ref)./Y_ref);
                set(gca,'FontSize',14) 
                plot(X1,err, 'gd', 'LineWidth',2,'MarkerSize',10)
                xlabel(String_X,'FontSize', 14);
                ylabel('Relative Error', 'FontSize', 14);
                title(sprintf('Relative Error at t=%.2f for %s', Time, Element), 'FontSize',14);
                suptitle(Method)
                hold off
%                 s=strcat('valuesFieldRef_dt60_OS_Errorrela','_',num2str(Time),'_',Element);
%                 save(s,'Y_coup','Y_ref','err')
            else
                fprintf ('[Array_Field/Print_Comparison] %s is not in the list of identifiers. \n', Element);
            end
        end

        %   a new Concentrtion_Array where the values of the "Array" 
        %   property has been changed for the vectors in list_new_values.
        %
        %   Precondition: All the vectors inside the cell list should have
        %   the same length (Nx1) and it has to be equal to the number of
        %   rows of your Concentratrion_Array class "Array" property.
  
        function conc = Update_Field (this, List_New_Values)
            d=length(List_New_Values);
            assert (d==size(this.Array,2), '[Array_Field/ Update_Field] The dimensions of the new list does not match the old array');
            Array_temp=zeros(size(this.Array,1),d);
            for i=1:d
                Array_temp(1:end,i)=List_New_Values{1, i};
            end
            new_Array=Array_temp;
            conc=Array_Field(this.list_identifiers, new_Array);
        end
        
        %   The "new vector" would be placed inside the matrix in the position given.
        %   So that we are just modified the "Array" property in the
        %   given position (the position corresponds to a column number).
        %
        %   Precondition: the length of the "new_vector" must be coherent
        %   with the dimensions of the Array.
 
        function conc=Update_Array_Position (this, New_Vector, Position)
            assert(size(New_Vector, 2)==1, '[Array_Field/Update_Array_Position]')
            new_Array=this.Get_Array;
            new_Array(1:end,Position)=New_Vector;
            conc=Array_Field(this.list_identifiers, new_Array);
        end
        
        %   The "new vector" would be placed inside the matrix in the
        %   position of the given element. So that we are just modified the
        %   "Array" property in the given position of the given element
        %   (the position corresponds to a column number) 
        %
        %   Precondition: the length of the "new_vector" must be coherent
        %   with the dimensions of the Array.
        
        function conc=Update_Array_Element (this, New_Vector, Element)
            assert(size(New_Vector, 2)==1, '[Array_Field/Update_Array_Element]')
            new_Array=this.Get_Array;
            [bol, Position]=ismember(Element, this.Get_List_Ide);
            if bol==1
                new_Array(1:end,Position)=New_Vector;
                conc=Array_Field(this.list_identifiers, new_Array);
            else
                fprintf ('[Array_Field/Update_Array_Element] The Element is not in the Array_Field class.\n');
            end
        end
        
        %   If the values of the element content in the solution are saved in
        %   the Array_Field class, the method will return a 
        %   "vertical" vector containing its values for the whole rows. 
        %   Otherwise, it will return an error.

        function Vec_element=Get_Vector_Field (this, Element)
            [boolean,n]=this.Identifier_Position(Element);
            if boolean==true
                array=this.Get_Array;
                Vec_element=array(1:end, n);
            else
                  error('[Array_Field/Get_Vector_Field] The given element is not stored in the matrix.\n');
            end
        end
        
        % Plot the values of the given element respect the row position for
        % the given time. 

        function Plot_C_1D (this, Ele, Time)
            [i, ~]=ismember(Ele, this.Get_List_Ide); 
            if (i==true)
                b=this.Get_Vector_Field (Ele);
                figure
                plot(b,'r');
                title(sprintf('%f at time %d',Ele, Time));
            else
                fprintf('[Array_Field/Plot_C_1D] The given element does not belong to the list.\n');
            end
        end

        % Plot the values of the components inside the givenelement list
        % regarding the domain or the nodes for a given time. Method_String
        % is just a string indicating the method of the coupling.

        function Print_Result_Time( this, Time_Double, Method_String, Element_List, vector_x)
            if nargin==4
                x=this.rows;
                string_x='nodes';
            else
                x=vector_x;
                string_x='distance';
            end
            a=this.Get_List_Ide();
            for i=1:length(Element_List)
                [v,~]=ismember(Element_List{i},a);
                if v==true
                    figure
                    b=this.Get_Vector_Field (Element_List{i});
                    plot (x, b, 'kx-')
                    xlabel(string_x);
                    ylabel(sprintf('Field of %s', Element_List{i}));
                    title(sprintf('Field at t=%d for %s', Time_Double, Method_String));
                else
                    fprintf('the element %s is not in the Field array',Element_List{i});
                end
            end
        end
        
        %   It returns true if all the elements have a constant profile.
        %   For instance, Element1 has a constant profile of 3 in all its
        %   nodes and Element2 has a constant profile of 2 in all its
        %   nodes.

        function boolean=Constant_Profile (this)
            c=this.Get_Array;
            [row,col]=this.Array_Size;
            boolean=true;
            for i=1:col
                boolean=this.All_Values_Vector_True (c(1:end,i), boolean);
            end
        end
        
        %   It returns true if all the values in the vector are equal. The
        %   vector is perpendicular.
 
        function boolean = All_Values_Vector_True (this, Vector, B)
            c0=Vector(1);
            boolean=B;
            for i=1:length(Vector)
                if c0~=Vector(i)
                    boolean=false;
                end
            end
        end
        
        % It creates a new Array_Field class. This new class contains the
        % same fields than the old one, but its number of rows (nodes) have
        % been selected by the user. 
        
        function c = Get_Array_Field_Part (this, nodes)
            a=length(nodes);
            assert(a==1 ||a==2, '[Array_Field/Get_Array_Field_Part] The argument must be a Integer or a vector of two Integers.')
            if a==1
                c= Array_Field(this.list_identifiers, this.Array(nodes, :));
            else 
                c=Array_Field(this.list_identifiers, this.Array(nodes(1):nodes(2), :));
            end
        end
        
        %  Changes the order of the columns in the array according to the
        %  given List of Ide({'C' ... 'Calcite'}) 
        
        function C=Change_Order_Array_Columns(this, List_Ide)
            assert(isempty(setxor(List_Ide, this.Get_List_Ide)), '[Array_Field/Change_Order_Array_Columns] The list of Identifiers are not equal')
            [row,col]=Array_Size(this);
            C_Array=zeros(row, col);
            for i=1:col
                [~,z]=ismember(List_Ide{i}, this.Get_List_Ide);
                C_Array(1:end, i)=this.Array(1:end, z);
            end
            L=this.list_identifiers.Change_Order_Array_Columns (List_Ide);
            C=Array_Field(L, C_Array);
        end
        
        % Check if the row (an integer) exists in the Array_Field class.
        % This number of integer must be between 1 and the size of the
        % array's row.
        
        function b=Check_Node_Row_Exist(this, Row)
            [b,~]=ismember(Row, this.rows );
        end
        
        % It cheks whether a field ('Ca' 'Head Pressure' ...) exist in the
        % array field.
        
        function b=Check_Field_Exist(this, Field_ID)
            [b,~]=ismember(Field_ID, this.Get_List_Ide );
        end
        
        % Get the array value for a given field ('Ca' 'Head Pressure'
        % ...) and a given row position.

        function a=Get_Value_at_Position_and_Element(this, Node_Row_Position_Double, Field_ID)
            [~,t]=ismember(Field_ID, this.Get_List_Ide );
            a=this.Array(Node_Row_Position_Double, t);
        end
        

        % The user shoud give all the fields that he considers necessary to
        % the well run of the simulation. If the given list of fields and
        % the own list of the Array_Field class does not match an error
        % will pop.

        function Check_All_User_Desired_Fields_In (this, List_Fields)
            b= isempty(setxor(this.Get_List_Ide,List_Fields));
            assert(b==true, '[Array_Field/Check_All_User_Desired_Fields_In] The given fields and the fields contained in the class are different.')
            [~,col]=this.Array_Size;
            b=length(List_Fields)==col;
            assert(b==true, '[Array_Field/Check_All_User_Desired_Fields_In] The columns in the array is smaller than the given list.')
        end
        
        % Returns some units regarding the given Field (string)
        
        function s= Get_Units_Plot_Label (this, Field)
            s= this.list_identifiers.Get_Units_Plot_Label (Field);
        end
        
        % Create a table matlab type (class)

        function t= CreateMATLABTable(this)
            t=array2table(this.Array,'VariableNames',this.Get_List_Ide, 'RowNames',cellfun(@num2str, num2cell(this.rows), 'UniformOutput', false));
        end
        
        % Gives the array_field difference between 2 clases.
        % this.array-new.array=difference.array
        
        function Difference_Arrays_Field=Get_Difference_Arrays_Field (this, C_Array_Field)
            assert(isempty(setxor(this.Get_List_Ide, C_Array_Field.Get_List_Ide)),'[Array_Field/Get_Difference_Array_Field] the column elements are different')
            assert(all(this.rows==C_Array_Field.Get_Rows), '[Array_Field/Get_Difference_Array_Field] the number of rows is different.')
            C_Array_F=C_Array_Field.Change_Order_Array_Columns(this.Get_List_Ide);
            Difference_Array=this.Array-C_Array_F.Get_Array;
            Difference_Arrays_Field=Array_Field(this.Get_List_Identifiers, Difference_Array);
        end
        
        % Convergence_Criteria_Fullfield(u, convergence_criteria)
        
        function b=Convergence_Criteria_Fullfield(this, u, convergence_criteria)
            b=false;
            diff_array_field=this.Get_Difference_Arrays_Field (u);
            d_array=diff_array_field.Get_Array;
            [row, cols]=size(d_array);
            d_array_oneszeros=abs(d_array)<convergence_criteria;
            if sum(sum(d_array_oneszeros))==(row*cols)
                b=true;
            end
        end
        
        
        % It returns a cell list with the aqueous elemenst and values for a
        % position in the Array_Field.
        % {'C_pos4' '5e-9' 'Cl' '6e-7'.....} 
        
        function a = Boundary_Values_1D(this, inputnode_type, row_position,b_makediff_water_H_O ,varargin)
            if strcmpi(inputnode_type,'inflow')
                a=String_List_Aqueous_Elements_And_Value (this, row_position, b_makediff_water_H_O);
            elseif strcmpi(inputnode_type,'flux')
                vel = varargin{1};
                a=String_List_Aqueous_Elements_And_Value_Times_Velocity (this, row_position, vel, b_makediff_water_H_O);
            end
        end
        
        
        % It returns a cell list with the aqueous elemenst and values for a
        % position in the Array_Field.
        % {'C_pos4' '5e-9' 'Cl' '6e-7'.....}
        % It was called before String_List_Aqueous_Elements_Comsol, now it
        % is String_List_Aqueous_Elements_And_Value .

        function a=String_List_Aqueous_Elements_And_Value (this, row_position, b_makediff_water_H_O)
            a1=this.list_identifiers.Get_Mobile_Species;
            a1_change=Working_Element_List_1( a1);
            [~, indexh2o]=ismember('H2O',a1);
            length_list=length(a1);
            b=cell(1, length_list);
            for i=1:length_list
                if b_makediff_water_H_O
                    if strcmpi('H',a1{i})
                        b{i}=num2str((this.Get_Value_at_Position_and_Element(row_position, a1{i})-2*this.Get_Value_at_Position_and_Element(row_position, a1{indexh2o})), 16);
                    elseif strcmpi('O',a1{i})
                        b{i}=num2str(this.Get_Value_at_Position_and_Element(row_position, a1{i})-this.Get_Value_at_Position_and_Element(row_position, a1{indexh2o}), 16);
                    else
                        b{i}=num2str(this.Get_Value_at_Position_and_Element(row_position, a1{i}), 16);
                    end
                else
                    b{i}=num2str(this.Get_Value_at_Position_and_Element(row_position, a1{i}), 16);
                end
            end
            a=[a1_change; b];  %concatane vertically
            a=a(:)';            % flatten and transpose
        end
        
        % like String_List_Aqueous_Elements_And_Value but the values before
        % been written are multiplied by a constant.
        
        function a=String_List_Aqueous_Elements_And_Value_Times_Velocity (this, row_position, velo, b_makediff_water_H_O)
            a1=this.list_identifiers.Get_Mobile_Species;
            a1_change=Working_Element_List_1( a1);
            [~, indexh2o]=ismember('H2O',a1);
            length_list=length(a1);
            b=cell(1, length_list);
            for i=1:length_list
                if b_makediff_water_H_O
                    if strcmpi('H',a1{i})
                        b{i}=num2str( velo*((this.Get_Value_at_Position_and_Element(row_position, a1{i})-2*this.Get_Value_at_Position_and_Element(row_position, a1{indexh2o}))), 16);
                    elseif strcmpi('O',a1{i})
                        b{i}=num2str(velo*(this.Get_Value_at_Position_and_Element(row_position, a1{i})-this.Get_Value_at_Position_and_Element(row_position, a1{indexh2o})), 16);
                    else
                        b{i}=num2str(velo*(this.Get_Value_at_Position_and_Element(row_position, a1{i})), 16);
                    end
                else
                    b{i}=num2str(velo*(this.Get_Value_at_Position_and_Element(row_position, a1{i})), 16);
                end
            end
            a=[a1_change; b];  %concatane vertically
            a=a(:)';            % flatten and transpose
        end
        
        % Append a new column (element) with value zero.
        
        function C=C_ApendElementsData(this, l_i)
            len=length(l_i);
            Arr1=zeros(length(this.rows),len);
            L=[this.list_identifiers.List_Identifiers_Data(l_i)];
            LI=this.list_identifiers.Append_New_Element(L);
            Arr=[this.Array Arr1];
            C=Array_Field(LI, Arr);
            
        end
  
        %       The method gives the desired array from an inputed list of string
        %       which contains the name of different elements.
        %       {'C' 'Ca' ...}

        function C= Get_Desired_Array (this, Desiredlist)
            Listdesired=this.list_identifiers.Get_List_Names (Desiredlist);
            a=length(Listdesired);
            Arr=zeros(length(this.rows),a);
            for i=1:a
                Arr(1:end,i)=this.Get_Vector_Field (Listdesired{i});
            end
            LI=this.list_identifiers.Create_List_Identifiers_Desired ( Listdesired, Desiredlist);
            C=Array_Field(LI, Arr);
        end
        
        % sum some value to a component of the array.
        
        function C=Sum_To_Element (this, element, number)
            lide=this.Get_List_Ide;
            [a, b]=ismember(element, lide);
            A=this.Get_Array;
            if a==1
                A(1:end, b)=this.Array(1:end,b)+number;
            else
                fprintf('[Arraw_Field/Sum_To_Element] Not Element founded\n');
            end
            C=Array_Field(this.list_identifiers, A);
        end
        
        % Sum or makes the differences of two components (rows) of the
        % Array_Field.
        
        function C=SumDiff_Array (this, element1, element2, operatorstring)
            lide=this.Get_List_Ide;
            [a1, b1]=ismember(element1, lide);
            [a2, b2]=ismember(element2, lide);
            A=this.Get_Array;
            if a1==1 && a2==1
                if strcmpi('+',operatorstring)
                    A(1:end, b1)=this.Array(1:end,b1)+this.Array(1:end,b2);
                elseif strcmpi('-',operatorstring)
                    A(1:end, b1)=this.Array(1:end,b1)-this.Array(1:end,b2);
                end
            else
                fprintf('[Arraw_Field/Sum_To_Element] Not Element founded\n');
            end
            C=Array_Field(this.list_identifiers, A);
        end
        
%
%  The following function is related to the outputs of Phreeqc. Phreeqc
%  gives you the outputs as mol/l. (Unless some manipulation has been done
%  to the selected output block). In order to keep some coherence between
%  the units of transport and the units of chemistry. We use the idea of
%  cells having a representative volume. (Parkhurst and Wissmeier, 2015)
%
%  volumetricwatercontent =Saturation x porosity x representative volume;
%
% This 4 parameter must be contained in the array, as well as the solution
% volume and the mass of water.
%
%
        function C=InitializationRV_mol_litre_afterPhreeqcCalculation_Noporchange(this)
            C=Array_Field(this.list_identifiers, this.Array);
            % assume units of the C are mol/l
            % assure that certain parameters are in the output (RV, volumetric water content, porosity, ...)
            Li=C.Get_List_Identifiers;
            
            this.Assert_Parameter_RV;
            % Once it has been assure, the solution species must be
            % transform into mol/l from mol/kgw. but before the liquid
            % saturation must be updated (if porosity change, it must also
            % be updated). If liquid saturation is updated, the volumetric
            % water content would be also modified.
            vector_vol_sol=C.Get_Vector_Field ('vol_sol');
            vector_RV=C.Get_Vector_Field ('RV');
            vector_porosity=C.Get_Vector_Field ('porosity');
            vector_liquid_saturation=vector_vol_sol./(vector_RV.*vector_porosity);
            C=Update_Array_Element (C, vector_liquid_saturation, 'liquid_saturation');
            vector_volumetricwatercontent=vector_liquid_saturation.*vector_porosity.*vector_RV;
            C=Update_Array_Element (C, vector_volumetricwatercontent, 'volumetricwatercontent');
            % transform species in solution
            ls=Li.Get_List_Names ('Solution');
            vector_water=C.Get_Vector_Field ('water');
            % Updated values
            for i=1:length(ls)
                vec_temp=C.Get_Vector_Field (ls{i});
                vec_temp=(vec_temp.*vector_water)./vector_vol_sol;
                vec_temp(isnan(vec_temp))=0;
                C=Update_Array_Element (C, vec_temp, ls{i});
            end
            % transform gas
            lg=Li.Get_List_Names ('Gas');
            % Updated values
            for i=1:length(lg)
                vec_temp=C.Get_Vector_Field (lg{i});
                vec_temp=vec_temp./((1-vector_liquid_saturation).*vector_porosity.*vector_RV);
                C=Update_Array_Element (C, vec_temp, lg{i});
            end
        end
 
        
        
        
        
        % Similar idea that before. Here the volumetric water content is
        % multiply by the concentration of the elements in solution. The
        % reason to do such thing is related to the transfer of
        % concentration (mol/l) after transport to be used as amount of
        % mass by Phreeqc.
        %
        %
        function C=Multiply_Concentration_with_Volumetric_Water_Content(this)
            C=Array_Field(this.list_identifiers, this.Array);
            % assure that certain parameters are in the output (RV, volumetric water content, porosity, ...)
            C.Assert_Parameter_RV;
            Li=C.Get_List_Identifiers;
            ls=Li.Get_List_Names ('Solution');
            vector_volumetricwatercontent=C.Get_Vector_Field ( 'volumetricwatercontent');
            for i=1:length(ls)
                vec_temp=C.Get_Vector_Field (ls{i});
                vec_temp=(vec_temp.*vector_volumetricwatercontent);
                C=Update_Array_Element (C, vec_temp, ls{i});
            end
        end
        
        % Same idea as Multiply_Concentration_with_Volumetric_Water_Content
        % although it is related to the gas content.
        
        function C=Multiply_Gas_Concentration_with_Volumetric_Gas_Content(this)
            C=Array_Field(this.list_identifiers, this.Array);
            this.Assert_Parameter_RV;
            lg=this.list_identifiers.Get_List_Names ('Gas');
            vec_liquid_sat=C.Get_Vector_Field ( 'liquid_saturation');
            vec_por=C.Get_Vector_Field ( 'porosity');
            vec_RV=C.Get_Vector_Field ( 'RV');
            vec_volumetricgascontent=(1-vec_liquid_sat).*vec_por.*vec_RV;
            for i=1:length(lg)
                vec_temp=this.Get_Vector_Field (lg{i});
                vec_temp=(vec_temp.*vec_volumetricgascontent);
                C=Update_Array_Element (C, vec_temp, lg{i});
            end
        end
        
        % the given list of elements is multiply with the volumetric water
        % content
        
        function C=Multiply_list_with_Volumetric_Water_Content(this,list)
            C=Array_Field(this.list_identifiers, this.Array);
           vector_volumetricwatercontent=C.Get_Vector_Field ( 'volumetricwatercontent');
           for i=1:length(list)
               vec_temp=this.Get_Vector_Field (list{i});
               vec_temp=(vec_temp.*vector_volumetricwatercontent);
                C=Update_Array_Element (C, vec_temp, list{i});
           end
        end
        
        % The method multiplies some columns with a reference one. The
        % reference one is the Column_d input and the givin list contains
        % the name of components (rows) contained in the Array_Field class
        % that will be multiplied.

        
        function C=Multiply_List_with_Column(this, list_elements, Column_d)
            C=Array_Field(this.list_identifiers, this.Array);
            vec_column=this.Get_Vector_Field ( Column_d );
            for i = 1:length(list_elements)
                vec_temp=this.Get_Vector_Field (list_elements{i});
                vec_temp=(vec_temp.*vec_column);
                C=Update_Array_Element (C, vec_temp, list_elements{i});
            end
        end
        
        % The method divides some columns with a reference one. The
        % reference one is the Column_d input and the givin list contains
        % the name of components (rows) contained in the Array_Field class
        % that will be multiplied. 
        
        function C=Divide_List_with_Column(this, list_elements, Column_d)
            C=Array_Field(this.list_identifiers, this.Array);
            vec_column=this.Get_Vector_Field ( Column_d );
            for i = 1:length(list_elements)
                vec_temp=this.Get_Vector_Field (list_elements{i});
                vec_temp=(vec_temp./vec_column);
                C=Update_Array_Element (C, vec_temp, list_elements{i});
            end
        end
        
        % Check if the parameters related to the representative volume are
        % in the Array_Field class.
        
        function Assert_Parameter_RV (this)
            Li=this.Get_List_Identifiers;
            list_ide=Li.Get_List_Id;
            assert(any(strcmpi('water',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
%             assert(any(strcmpi('dens',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
            assert(any(strcmpi('vol_sol',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
            assert(any(strcmpi('porosity',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
            assert(any(strcmpi('liquid_saturation',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
            assert(any(strcmpi('RV',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
            assert(any(strcmpi('volumetricwatercontent',list_ide)), '[Array_Field/InitializationRV_mol_litre] The following parameter must be in the array field');
        end
        
        % Charge balance is not setted to negative, all the other
        % parametes are setted to zero. It devides between two matrices,
        % the negative ones and the positives ones
        % It works in the array level.
        
        function [C_mod_nozero, C_negative] = Remove_Negative_Values(this)
            list_ide=this.Get_List_Ide;
            [b, ind]=ismember('cb', list_ide);
            assert(b~=0, '[Array_field/Remove_Negative_Values]/n');
            array=this.Array;
            array_copy=array;
            charge_balance_vector=array(1:end, ind);
            % elimination of negatives values
            array(array<0)=0;
            neg_array=array_copy-array;
            %setting charge balance
            array(1:end, ind)=charge_balance_vector;
            neg_array(1:end, ind)=0;
            % giving values
            C_mod_nozero=Array_Field(this.list_identifiers, array);
            C_negative=Array_Field(this.list_identifiers, neg_array);
        end
        
        % Divides the 'array' property of the elements that are mobile into
        % a negative part and a positive part.
        
        function [C_mod_nozero, C_negative] = Remove_Negative_Values_MobileElements(this)
            list_ide=this.Get_List_Ide;
            l_g_s=this.list_identifiers.Get_Mobile_Species;
            [r,c]=size(this.Array);
            neg_array=zeros( r, c);
            array=this.Array;
            neg_vect=zeros(r,1);
            pos_vect=zeros(r,1);
            for i=1:length(l_g_s)
                [b, ind]=ismember(l_g_s{i}, list_ide);
                if strcmpi(l_g_s{i}, 'cb')
                elseif b==1
                    vect=array(:,ind);
                    vect(vect<0)=0;
                    pos_vect=vect;
                    neg_array(:,ind)=array(:,ind)-vect;
                    array(:,ind)=pos_vect;
                else
                    error('[Array_Field/Remove_Negative_Values_MobileElements]')
                end
            end
            C_mod_nozero=Array_Field(this.list_identifiers, array);
            C_negative=Array_Field(this.list_identifiers, neg_array);
        end

        % Divide the array of the solute elements by the column of the
        % field water (kg of water in solution)
        
        function [C]=MolesSolutes_Over_Water (this)
            C=this;
            A=this.Array;
            ls=this.list_identifiers.Get_List_Names ('Solution');
            lt=this.list_identifiers.Get_List_Id;
            vec_water=C.Get_Vector_Field ('water');
            for i=1:length(ls)
                [b, ind]=ismember(ls{i}, lt);
                if b==1
                    upvector=A(:,ind)./vec_water;
                    upvector(isnan(upvector))=0;
                    C=C.Update_Array_Element (upvector, ls{i});
                else
                    fprintf('[Array_field/Remove_Negative_Values]Check me./n');
                end
            end
        end
        
        % It creates a cell with the title and values of the row.

        function A = Create_Cell_From_Array (this)
            A=this.Get_List_Ide;
            M=num2cell(this.Array);
            A=[A; M];
        end
        
        % It gives all the rows where the difference between two
        % concentration of solute between to Array class is higher than
        % some prescribed value.
        
        function rows = Rows_ArraySolution_Different(this, C, pres_value)
             %
             C_Solution=this.Get_Desired_Array('Solution');
             A_C_Sol=C_Solution.Get_Array;
             %
             C_Sol=C.Get_Desired_Array('Solution');
             A_C_Sol2=C_Sol.Get_Array;
             %
             matrix_abs_diff=abs(A_C_Sol-A_C_Sol2);
             logic_diff_matrix=matrix_abs_diff>pres_value;
             [~, c]=size(logic_diff_matrix);
             dd=[];
             for i=1:c
                 d=find(logic_diff_matrix(:,i));
                 dd=[dd; d];
                 dd=sort(dd);
                 dd=unique(dd);
             end
             rows=dd;
         end
    end
end