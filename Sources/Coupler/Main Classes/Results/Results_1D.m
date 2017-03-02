% The main aim of this class is to save the field (values) for the
% different integration steps of the Operator Splitting Method.
%
% Note: The vector_fields cell and the vector_time must have the
% same dimension so as to have a coherence in the class, but the class
% allows some manipulations that can broke this agreement. Consequently,
% the user must be aware.
%
% This class is a daughther of the 'Results' class. It is assumed that the
% values stored in the 'vector_fields' property of Results (father
% class of Results 1D) are Array_Field classes. 

classdef Results_1D <Results
    properties
    end
    
    methods
        
        %   Instantiate a Results_1D class. 
        %
        %   Note: the two inputs are not compulsory.

        function this = Results_1D (Vector_Fields, Vector_Time)
                    this=this@Results(Vector_Fields,Vector_Time);
        end

        %   this method is an accessor, it returns your Results class as
        %   output.

        function t=Get_Results(this)
            t=Results_1D(this);
        end
        
        %   The method returns a cell class containing matrices. Each
        %   matrix corresponds to the array of a Arrray_Field class. The
        %   matrices are ordered in time, from t0 until tend.

        function Cell_of_Array=Get_Cell_Array_Of_Each_Field_Class(this)
            Cell_of_Fields=this.Get_Vector_Fields;
            d=length(Cell_of_Fields);
            Cell_of_Array=cell(1,d);
            for i=1:d
                Cell_of_Array{i}=Cell_of_Fields{i}.Get_Array;
            end
        end
        
        %   This method does the  difference [Coupler-Reference] norms (norm of value p) 
        %   of an element ('identifier') for the different time points saved in the Results class.
        %   Afterwards, it will choose the average or max value, regarding the user specification, which will be
        %   outputed as scalar_vlue_drawn, and the time, at which this value is given.
        %
        %   Note: Maybe the function that should be used to discern between
        %   the different norms is maximum value instead of minimum value.

        function [scalar_value_drawn, time]=Norm_time(this, Reference, Identifier, Averag_Max, P)
            assert(strcmpi(class(Reference),'Results_1D'), '[Results_1D/ Norm_time] The reference must be a Results_1D class, to proceed with the comparison')
            assert(length(Reference.Get_Vector_Time)==length(this.Get_Vector_Time), '[Results_1D/ Norm_time] The vector of length must be equal')
            r=length(this.Get_Vector_Time);
            norm_for_each_time=zeros(1,r);
            coup_cell=this.Get_Vector_Fields;
            ref_cell=Reference.Get_Vector_Fields;
            for i=1:r
                norm_for_each_time(1,i)=coup_cell{i,1}.Norm_Vector(ref_cell{i,1}, Identifier, P);
            end
            time=-1;
            value=-1;
            if strcmpi(Averag_Max, 'average')|| strcmpi(Averag_Max, 'mean')
                [value]=mean(norm_for_each_time);
                time=-1;
            elseif strcmpi(Averag_Max, 'max')
                [value, index]=max(norm_for_each_time);
                time_te=this.Get_Vector_Time;
                time=time_te(index,1);
            else
                fprintf('[Results/Norm_time] ');
            end
            scalar_value_drawn=value;
        end

        %   It plots the results and relative error for different time 
        %   points and elements.

        function Plot_Comp_Result_1D(this, Results_Ref, Time_List, Element_List, Method, vector_test_x, vector_ref_x, relative_error)
            if nargin == 7
                R_E=false;
            else
                R_E=relative_error;
            end
            a1=this.Get_Vector_Time;
            a2=Results_Ref.Get_Vector_Time;
            b=this.Get_Vector_Fields;
            c=Results_Ref.Get_Vector_Fields;
%             assert(isempty(setxor(a, Results_Ref.Get_Vector_Time)), '[Results_1D/Print_Comp_Result_1D] The vector of Results and Reference are diferent')
            for i=1:length(Time_List)
                [v1,z1]=ismember(Time_List(1,i),a1);
                [v2,z2]=ismember(Time_List(1,i),a2);
                if v1==true && v2==true
                    b1=b{z1,1};
                    c1=c{z2,1};
                    for l=1:length(Element_List)
                        b1.Plot_Comparison_1D( c1, Element_List{1,l}, Time_List(1,i), stringmethod(Method),vector_test_x, vector_ref_x, R_E)
                    end
                else
                    fprintf('there is not array field at the time %d. \n',Time_List(1,i));
                end
            end
        end
        
        %   the methods plots all the saved fields in the
        %   'vector_fields' property if time_boolean is true.
        %   Otherwise, it plots just the time values given in the
        %   time_list, which must also be saved in the 'vector_time'
        %   property.

        function Plot_Results_Test_1D (this, Time_Boolean, Ele, Time_List)
            cell_con=this.Get_Vector_Fields;
            vec_time=this.Get_Vector_Time;
            if Time_Boolean==true
                for i=1:length(cell_con)
                    cell_con{i}.Plot_C_1D(Ele, vec_time(i));
                end
            else
                for i=1:length(Time_List)
                    [b,ind]=ismember(vec_time, Time_List(i));
                    if b==1
                        cell_con{ind}.Plot_C_1D (Ele, this.vector_time(ind));
                    else
                        fprintf('[Results_1D/Plot_Results_1D] the time given is no inside the vector_time property.\n');
                    end
                end
            end
        end

        %   the methods plots all the saved fields in the
        %   'vector_fields' property for the accoding time and
        %   elements.

        function Print_Result_Test_1D (this, Time_List, Method_String, Element_List, vector_x)
            a=this.Get_Vector_Time;
            b=this.Get_Vector_Fields;
            convergence_relative_minvalue=1e-3;
            for i=1:length(Time_List)
                [v,z]=ismember(Time_List(1,i),a);
                if v==true
                    b{z}.Print_Result_Time( a(z), stringmethod ( Method_String ), Element_List, vector_x);
                else
                    [minvalue, position_minvalue]=min((abs(a-Time_List(1, i)))/Time_List(1, i));
                    if minvalue < convergence_relative_minvalue
                        b{position_minvalue}.Print_Result_Time( a(position_minvalue), stringmethod ( Method_String ), Element_List, vector_x);
                    else
                        fprintf('[Results_1D/Print_Result_Test_1D]there is not field array at the time %d.\n ',Time_List(1,i));
                    end
                end
                    
            end
        end

        %   Plots the time evolution of a species, or mineral, or hydraulic
        %   parameter, etc. For a given position and for a given Method.
        %   Except the initial value.

        function Plot_EvolutionTime_Test_Position_1D(this, dt, String_Name_Method, Node_Row_Position_Double, Field_ID)
            vector_fields=this.Get_Vector_Fields;
            len1=length(vector_fields);
            assert(len1~=0, '[Results_1D/Plot_EvolutionTime_Test_Position_1D] The vector field is empty')
            time_vector=this.Get_Vector_Time./dt;
            b1=vector_fields{1}.Check_Node_Row_Exist(Node_Row_Position_Double);
            b2=vector_fields{1}.Check_Field_Exist(Field_ID);
            if b1==false || b2==false
                if b1==false
                    fprintf('[Results_1D/Plot_EvolutionTime_Test_Position_1D] there is not field array at the row position %d.\n ',Node_Row_Position_Double);
                end
                if b2==false
                    fprintf('[Results_1D/Plot_EvolutionTime_Test_Position_1D] there is not field array at the Field Id %s.\n ',Field_ID);
                end
            else
                Vector_Values_Postion_Field=this.Vector_Values_Position_and_Element_for_each_Time (Node_Row_Position_Double, Field_ID);
                h=figure;
                plot (time_vector(1:end), Vector_Values_Postion_Field, 'kx-')
                xlabel('Time Evolution');
                ylabel(sprintf('Field of %s', Field_ID));
                
                title(sprintf('Field at position=%d for %s', Node_Row_Position_Double, stringmethod (String_Name_Method)));
              
                saveas(h,Field_ID,'fig')
            end
        end
        
        % Get the values of a species, mineral or hydraulic parameter for
        % an specific node, at every time iteration saved on the results.
        % Except the initial value.

        function Vector_Values_Postion_Field=Vector_Values_Position_and_Element_for_each_Time (this, Node_Row_Position_Double, Field_ID)
            vector_fields=this.Get_Vector_Fields;
            len1=length(vector_fields);
            Vector_Values_Postion_Field=zeros(1,len1);
                for i=1:len1
                    Vector_Values_Postion_Field(i)=vector_fields{i}.Get_Value_at_Position_and_Element(Node_Row_Position_Double, Field_ID);
                end     
        end
        
        function Plot_EvolutionTime_RefvsTest_Position_1D(this, vector_concentration_eachtime_reference, dt, String_Name_Method, Position_Test, Field_ID)
            vector_fields=this.Get_Vector_Fields;
            len1=length(vector_fields);
            assert(len1~=0, '[Results_1D/Plot_EvolutionTime_Test_Position_1D] The vector field is empty')
            time_vector=this.Get_Vector_Time./dt;
            b1=vector_fields{1}.Check_Node_Row_Exist(Position_Test);
            b2=vector_fields{1}.Check_Field_Exist(Field_ID);
            if b1==false || b2==false
                if b1==false
                    fprintf('[Results_1D/Plot_EvolutionTime_Test_Position_1D] there is not field array at the row position %d.\n ',Position_Test);
                end
                if b2==false
                    fprintf('[Results_1D/Plot_EvolutionTime_Test_Position_1D] there is not field array at the Field Id %s.\n ',Field_ID);
                end
            else
                Vector_Values_Postion_Field=this.Vector_Values_Position_and_Element_for_each_Time (Position_Test, Field_ID);
                figure
                hold on
                plot (time_vector(1:end), Vector_Values_Postion_Field, 'bx-', 'LineWidth',2,'MarkerSize',10)
                plot (time_vector(1:end), vector_concentration_eachtime_reference, 'rx-', 'LineWidth',2,'MarkerSize',10)
                xlabel('Time (s)');
                % hAz los plotting de
                % concentration!!!!!!!
                s= vector_fields{1}.Get_Units_Plot_Label (Field_ID);
                ylabel(s);
%                 ylabel('Concentration (mol/kgw)');
                h_legend=legend ( 'Comsol+Phreeqc', 'Phreeqc');
                set(h_legend,'FontSize',14);
                title(sprintf('%s  %s',   Field_ID, stringmethod (String_Name_Method)));
            end
        end

        % It returns a cell containing at position i, the difference
        % between Array_Field (i) - Array_Field (i-1). Position i is
        % refered to a position in the properties vector_fields or
        % vector_time. Therefore, position i is related to time as well.
        % So, we obtain the difference between two array field classes
        % which are one time step difference.

        function r=Get_Array_Field_Difference_Between_Time_Step (this)
            m=this.Get_Vector_Fields;
            d=length(m);
            r=cell(1,d-1);
            for i=1:(d-1)
                r{i}=m{i}.Get_Difference_Arrays_Field (m{i+1});
            end
        end

        % Like Get_Array_Field_Difference_Between_Time_Step but you chose
        % the elements that you want.

        function r=Get_Array_Field_Difference_Between_Time_Step_Elements (this, List_Elements)
            rt=this.Get_Array_Field_Difference_Between_Time_Step;
            d=length(rt);
            r=cell(1,d);
            for i=1:d
                r{i}=rt{i}.Separate_Elements_Array_Field (List_Elements);
            end
        end
        
        % Plots the amount of change of a component from the Array Field class
        % respect the initial profile of the component for the whole time
        % simulation.
        
        function Plot_OS_Ref_DeltaDissolutionWholeTime_1D (this, results_reference, String_Method, List_Element, vec_dx_coup, vec_dx_ref)
            %time vector must be equal
            assert(sum(this.Get_Vector_Time==results_reference.Get_Vector_Time)==length(this.Get_Vector_Time),'[Results_1D/Plot_OS_Ref_DeltaDissolutionWholeTime_1D] Problem')
            
            Coup_Fields=this.Get_Vector_Fields;
            Ref_Fields=results_reference.Get_Vector_Fields;
            for i=1:length(List_Element)
                Sum_delta_coup=0;
                Sum_delta_ref=0;
                for j=1:length(this.Get_Vector_Fields)
                    Sum_delta_coup=Sum_delta_coup+Coup_Fields{j}.Get_Vector_Field (List_Element{i});
                    Sum_delta_ref=Sum_delta_ref+Ref_Fields{j}.Get_Vector_Field (List_Element{i});
                end
                figure
                hold on
                plot (vec_dx_coup, Sum_delta_coup, 'bx-', 'LineWidth',2,'MarkerSize',10)
                plot (vec_dx_ref, Sum_delta_ref, 'rx-', 'LineWidth',2,'MarkerSize',10)
                xlabel('Length(m)');
                ylabel('Amount');
%                 ylabel('Concentration (mol/kgw)');
                h_legend=legend ( 'Comsol+Phreeqc', 'Phreeqc');
                set(h_legend,'FontSize',14);
                title(sprintf('%s  %s',   List_Element{i}, stringmethod (String_Method)));
            end
        end
    end
end
