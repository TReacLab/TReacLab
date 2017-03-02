% The aim of this class is to evaluated the result for different OS
% methods, as well as compare the OS method with another solution method.


classdef Evaluation
    
    properties (Access=private)
        coupling_methods_list   % Cell containing the string with the OS that want to be tried.
        results_test            % Cell containing a result class
        results_reference       % Cell containing reference values
    end
    
    methods
          
        %   Instantiate a Evaluation class. The Coupling_Methods_List is a
        %   cell of strings given a proper string related to a different
        %   method.

        function this = Evaluation(Coupling_Methods_List)
            if nargin ==0
            else
            this.coupling_methods_list=Coupling_Methods_List;
            end
        end
        
        %   It fix/set the property results_test with a given input
        
        function this = Fix_Results_Test (this, Results_Test)
            this.results_test = Results_Test;
        end
        
        % Append the results_test property of another evaluation class into
        % other evaluation class
        
        function this = Append_Results_of_Test (this, Eval_2)
            this.results_test=[this.results_test Eval_2.Get_Results_Test];
            this=this.Append_List(Eval_2.Get_Coupling_List);
        end

        %   It fix/set the results of the results_reference property with a
        %   given input

        function this = Fix_Results_Reference (this, Results_Reference)
            this.results_reference = Results_Reference;
        end
        
        %   It deletes all the saved values in its 'results_test' property
        
        function this=Clear_Results_Test(this)
            this.results_test={};
        end
 
        %   It changes the 'coupling_methods_list' property for a new given
        %   one
        
        function this=New_Method_List(this, List)
            this.coupling_methods_list=List;
        end

        %   It appends new OS method (strings) to the 'coupling_methods_list' 
        %   property
        
        function this=Append_List(this, List)
            for i=1:length(List)
                this.coupling_methods_list{1,end+1}=List{1,i};
            end
        end

        %   It solves the Problem saved in 'solver' property for the 
        %   diferent methods contained in the 'coupling_methods_list'. The
        %   different Results will be saved in the 'results_test' property.

        function this=Coupling_Solution(this, Solver)
            this.results_test=cell(1,length(this.coupling_methods_list)); 
            for i=1:length(this.coupling_methods_list)
                this.results_test{1,i}=Solver.Solve(this.coupling_methods_list{1,i});
                fprintf('The test %s has been completed.\n', this.coupling_methods_list{1,i});
            end
        end

        %   It solves the Problem saved in 'solver' property for the 
        %   direct method.

        function this=Test_Solution(this, Solver)
            this.results_test=Solver.Solve();
        end

        %   It solves the process class with the initial values and time 
        %   of the 'coupler' property and save the results, as a Result 
        %   class, in the 'reference' property.

        function this = Reference_Solution (this, Solver)
            this.results_reference=Solver.Solve();
        end
        
        %   It returns the 'results_test' property of the Evaluation class
        
        function d=Get_Results_Test(this)
            d=this.results_test;
        end
        
        %   It returns the 'coupling_methods_list' property of the Evaluation class
        
        function d=Get_Coupling_List (this)
            d=this.coupling_methods_list;
        end
        
        function z=Get_ResultfromCouplingMethod(this, Coupling_Method)
            [v,d]=ismember(Coupling_Method, this.coupling_methods_list);
            if v==true
                z=this.results_test{d};
            else
                fprintf('[Evaluation/Norm_Ref_Coup_Difference_0D_Scalar ] The given list %s is not inside the evaluation class.\n', Coupling_Method);
            end
        end
 
        %   It returns the 'results_reference' property of the Evaluation class
        
        function d=Get_Results_Reference(this)
            d=this.results_reference;
        end
        
        %   It gives the norm (max value or average) as well as the
        %   occurence time for the saved set of test in the 'results_test'
        %   property according the elements (list_identifiers_desired)
        %   specified by the user. 
        %   #########
        %                 Sequential      Strang    Additive
        %   'C'            5                7           8
        %   'T'            7                1           3
        %   'Calcite'      4                2           7
        %
        %   Precondition: The properties 'reference' and 'results_test' of the
        %   Evalution class may not be empty.

        function [norm_matrix,time_norm_matrix]=Norm_Matrix (this, List_Identifiers_Desired, Averag_Max, P)
            a=length (this.results_test);
            b=length(List_Identifiers_Desired);
            norm_matrix=zeros(b,a);
            time_norm_matrix=zeros(b,a); 
            for i=1:a
                for j=1:b
                    [norm_matrix(j,i),time_norm_matrix(j,i)]=this.results_test{1,i}.Norm_time(this.results_reference, List_Identifiers_Desired{1,j}, Averag_Max, P);
                end
            end
        end
  
        %   It returns a vector containing the mean of the difference of
        %   the norm of the different operator splitting methods used.
        %   Using this methods is possible to check the method with the
        %   small norm, and consequently, the best one.
        %
        %   Precondition: The properties 'reference' and 'results_test' of the
        %   Evalution class may not be empty
        
        function d= Final_Scalar_Norm_for_methodsincoupled(this, List_Identifiers_Desired, Averag_Max, P)
            [a,~]=this.Norm_Matrix (List_Identifiers_Desired,Averag_Max, P);
            d=zeros(1,length(this.coupling_methods_list));
            for i=1:size(a,2)
                d(1,i)=mean(a(1:end,i));
            end
        end


        %   returns a vector of 0s and 1s. If 1 the method used is suitable
        %   if 0, it is not suitable to do the calculations.
        %
        %   Note: this method requires an non-empty 'results_test' and
        %   'reference' properties

        function vector_true_false=Threshold(this, Averag_Max, P)
            v=this.Final_Scalar_Norm_for_methodsincoupled(this.coupling_methods_list, Averag_Max, P);
            f=length(v);
            vector_true_false=ones(1,f);
            for i=1:f
                if (v(1,i)>this.Constant_Threshold(this.coupling_methods_list{1,i}))
                    vector_true_false(1,i)=0;
                end
            end
        end
 
        %   The method returns a value regarding the inputed string. This
        %   string must be the name of one of the OS methods contained in
        %   OS coupler
        
        function Constant= Constant_Threshold (this, String)
            if strcmpi(String,'Strang_method_121')
                Constant=1e-12;
            elseif strcmpi(String,'Strang_method_212')
                Constant=1e-12;
            elseif strcmpi(String,'Sequential_12')
                Constant=1e-12;
            elseif strcmpi(String,'Sequential_21')
                Constant=1e-12;
            elseif  strcmpi(String,'Additive_method')
                Constant=1e-12;
            elseif  strcmpi(String,'Symmetrically_Weighted_method')
                Constant=1e-12;
            end
        end
        
        %   It plots the values of a method for different given times and
        %   elements in comparison with the reference
        
        function Plot_Results_Test_1D (this, Time_List, Method_List, Element_List, vector_x)
            for j=1:length(Method_List)
                [v,~]=ismember(Method_List{1,j},this.coupling_methods_list);
                if (v==true)
                    Result_test_method=this.results_test{1,j};
                    Result_test_method.Print_Result_Test_1D(Time_List, Method_List{1,j}, Element_List, vector_x);
                end
            end
        end
        
        
        function Plot_Results_Ref_1D (this, Time_List, Element_List, vector_x)
            this.results_reference.Print_Result_Test_1D(Time_List, 'Direct', Element_List, vector_x);
        end

        %   It plots the values of a method for different given times and
        %   elements in comparison with the reference
        
        function Plot_Comp_OS_R_For_Tlist_1D(this, Time_List, Method_List, Element_List,vector_test_x, vector_ref_x, relative_error)
            if nargin == 6
                R_E=false;
            else
                R_E=relative_error;
            end
                for j=1:length(Method_List)
                    [v,ind]=ismember(Method_List{1,j},this.coupling_methods_list);
                    if (v==true)
                        Result_test_method=this.results_test{1,ind};
                        Result_test_method.Plot_Comp_Result_1D(this.results_reference, Time_List, Element_List, Method_List{1,j}, vector_test_x, vector_ref_x, R_E);
                    end
                end
        end

        %   It plots the values of a method for different given times and
        %   elements in comparison with the reference
        
        function Plot_Comp_Test_R_For_Tlist_1D(this, Time_List, Element_List,vector_test_x, vector_ref_x, relative_error)
            if nargin == 5
                R_E=false;
            else
                R_E=relative_error;
            end
            Result_test_method=this.results_test;
            Result_test_method.Plot_Comp_Result_1D(this.results_reference, Time_List, Element_List, 'Test', vector_test_x, vector_ref_x, R_E);
        end

        %   It plots the scalar values of a method for different given times
        
        function Print_Comp_OS_R_For_Tlist_0D (this, Time_List, Method_List)
            for j=1:length(Method_List)
                [v,~]=ismember(Method_List{1,j},this.coupling_methods_list);
                if (v==true)
                    Result_test_method=this.results_test{1,j};
                    Result_test_method.Print_Comp_Result_0D (this.results_reference, Time_List, Method_List{1,j})
                else
                    fprintf('[Evaluation/Print_Comp_OS_R_For_Tlist_0D] there is not solution for the method %s. \n', Method_List{1,j});
                end
            end
        end
        
        %   It plots the matrix values of a method for different given times
        
        function Print_Comp_OS_R_For_Tlist_0D_matrix (this, Time_List, Method_List)
            for j=1:length(Method_List)
                [v,~]=ismember(Method_List{1,j},this.coupling_methods_list);
                if (v==true)
                    Result_test_method=this.results_test{1,j};
                    Result_test_method.Print_Comp_Result_0D_matrix (this.results_reference, Time_List, Method_List{1,j})
                else
                    fprintf('[Evaluation/Print_Comp_OS_R_For_Tlist_0D] there is not solution for the method %s. \n', Method_List{1,j});
                end
            end
        end
        
        %   If the 'norm_or_max' input is 'norm', the method gives the norm
        %   of the difference, between the saved values of the properties
        %   'reference' and 'results_test', for that methods in the
        %   'list_methods' input that are in the 'coupling_methods_list'
        %   property as well. Otherwise, it gives the values at which the
        %   maximum difference occurs.
        %
        %   Precondition: The properties 'reference' and 'results_test' of the
        %   Evalution class may not be empty.
        
        function norm_d=Norm_Ref_Coup_Difference_0D_Scalar (this, Method_List, Norm_Or_Max, P)
            switch nargin
                case 1
                    Method_List=this.coupling_methods_list;
                    Norm_Or_Max='norm';
                    P=2;
                case 2
                    Norm_Or_Max='norm';
                    P=2;
                case 3
                    P=2;
            end
            n=1;
            for j=1:length(Method_List)
                [v,i]=ismember(Method_List{1,j},this.coupling_methods_list);
                if (v==true)
                    [vec_absdiff, time_vec]=this.results_test{i}.Abs_Diff_Ref_Coup_0D(this.results_reference);
                    norm_d{1,n}=Method_List{1,j};
                else
                    fprintf('[Evaluation/Norm_Ref_Coup_Difference_0D_Scalar ]the %s method has not been calculated by the coupler.\n', Method_List{j});
                end
                if strcmpi(Norm_Or_Max,'norm')
                    if (sum(vec_absdiff)~=0)
                        norm_d{2,n}=sum(abs(vec_absdiff).^P)^(1/P);  %This is the norm equation. If you apply you will get an error message (matlab problem.)
                    else
                        norm_d{2,n}=0;
                    end
                elseif strcmpi(Norm_Or_Max,'max')
                    nm=max(vec_absdiff);
                    norm_d{2,n}=nm;
                    norm_d{3,n}=time_vec(find(vec_absdiff==nm));
                else
                    fprintf('[Evaluation/Norm_Ref_Coup_Difference_0D_Scalar ] The input must contain a string such as: ''norm'' or ''max''.\n'); 
                end
                n=n+1;
            end
        end
        %            cell with the first row containing the method and
        %               second containing the norm of the difference. In
        %               case or 'max' there is  third row given the time
        %               step of the max absolute difference  
 
        function norm_d=Norm_Ref_Coup_Difference_0D_Matrix (this, Method_List, Norm_Or_Max, P)
            switch nargin
                case 1
                    Method_List=this.coupling_methods_list;
                    Norm_Or_Max='norm';
                    P=2;
                case 2
                    Norm_Or_Max='norm';
                    P=2;
                case 3
                    P=2;
            end
            n=1;
            for j=1:length(Method_List)
                [v,i]=ismember(Method_List{1,j},this.coupling_methods_list);
                if (v==true)
                    [vec_absdiff, ~]=this.results_test{i}.Abs_Diff_Ref_Coup_0D(this.results_reference);
                    norm_d{1,n}=Method_List{1,j};
                else
                    fprintf('[Evaluation/Norm_Ref_Coup_Difference_0D_Scalar ]the %s method has not been calculated by the coupler.\n', Method_List{j});
                end
                d=length(vec_absdiff{1});
                vec_mat=cell2mat(vec_absdiff);
                cell_var=cell(1,d);
                matrix_norms=zeros(1,d);
                for  i=1:d
                    cell_var{1,i}=vec_mat(i:d:end);
                end
           
                if strcmpi(Norm_Or_Max,'norm') 
                    for i=1:d
                        matrix_norms(1,i)=sum(abs(cell_var{1,i}).^P)^(1/P); %This is the norm equation. If you apply you will get an error message (matlab problem.)
                    end
                    norm_d{2,n}=mean(matrix_norms);  %This is the norm equation. If you apply you will get an error message (matlab problem.)

                elseif strcmpi(Norm_Or_Max,'max')
                    nm_list=zeros(1,d);
                    for i=1:d
                        nm_list(1,i)=max(cell_var{1,i}); %This is the norm equation. If you apply you will get an error message (matlab problem.)
                    end
                    
                    norm_d{2,n}=max(nm_list);
                    
                else
                    fprintf('[Evaluation/Norm_Ref_Coup_Difference_0D_Scalar ] The input must contain a string such as: ''norm'' or ''max''.\n'); 
                end
                n=n+1;
            end
            
        end

        %   It returns a 1 if the test has been passed and zero if not.
        %   Furthermore, it writes if the test has been passed or not and
        %   which coupling method has failed
        
        function success= Passed_Test(this, Averag_Max, P, Name_Test, Coupling_Methods_List)
            d=this.Threshold(Averag_Max, P);
            dime=length(d);
            if sum(d)==dime
                success=1;
                fprintf('%s passed the test.\n', Name_Test);
            else
                fprintf ('%s has not passsed the test.\n', Name_Test);
                for i=1:dime
                    if d(1,i)==0
                        fprintf('the test %s did not pass.\n',Coupling_Methods_List{1,i} );
                    end
                end
            end
        end

        %   Plots the time evolution of a list of species, or mineral, or
        %   hydraulic parameter, etc. For a given position list and for a
        %   given list of methods
        
        function Plot_EvolutionTime_Test_Postion_1D (this, List_Methods, List_Element, List_Position,dt)
            if nargin<5
                dt=1;
            end
            len1=length(List_Methods);
            len2=length(List_Position);
            len3=length(List_Element);
            for i=1:len1
                [v,b]=ismember(List_Methods{i},this.coupling_methods_list);
                if (v==true)
                    Result_Test_for_Plot=this.results_test{b};
                    for j=1:len2
                        for z=1:len3
                            Result_Test_for_Plot.Plot_EvolutionTime_Test_Position_1D(dt, List_Methods{i}, List_Position(j), List_Element{z})
                        end
                    end
                else
                    fprintf('[Evaluation/Plot_EvolutionTime_Test_Postion_1D ]the %s method has not been calculated by the coupler.\n', List_Methods{i});
                end
            end
        end
        
        function Plot_EvolutionTime_Ref_Postion_1D (this, List_Element, List_Position,dt)
            if nargin<3
                dt=1;
            end
            s='Test';
            len2=length(List_Position);
            len3=length(List_Element);
            Result_Test_for_Plot=this.results_reference;
            if ~isempty(Result_Test_for_Plot)
                for j=1:len2
                    for z=1:len3
                        Result_Test_for_Plot.Plot_EvolutionTime_Test_Position_1D(dt, s, List_Position(j), List_Element{z})
                    end
                end
            else
                fprintf('[Evaluation/Plot_EvolutionTime_Test_Postion_1D ]the %s method has not been calculated by the coupler.\n', s);
            end
            
        end
        
        function Plot_EvolutionTime_RefvsTest_Position_1D (this, List_Methods, List_Element, Position_Ref, Position_Test, dt )
            if nargin<6
                dt=1;
            end
            len1=length(List_Methods);
            len2=length(List_Element);
            for i=1:len1
                [v,b]=ismember(List_Methods{i},this.coupling_methods_list);
                if (v==true)
                    Result_Test_for_Plot_Test=this.results_test{b};
                    for z=1:len2
                        Vector_Values_Position_and_Element_for_each_Time_Ref= this.results_reference.Vector_Values_Position_and_Element_for_each_Time( Position_Ref, List_Element{z});
                        Result_Test_for_Plot_Test.Plot_EvolutionTime_RefvsTest_Position_1D(Vector_Values_Position_and_Element_for_each_Time_Ref, dt, List_Methods{i}, Position_Test, List_Element{z})
                    end
                    
                else
                    fprintf('[Evaluation/Plot_EvolutionTime_Test_Postion_1D ]the %s method has not been calculated by the coupler.\n', List_Methods{i});
                end
            end
        end
        
        %
        % If the results of a given method (Sequential, reference, etc)
        % exist in the Evaluation class. The method will return a vector of
        % array field classes, that are the difference between time for the
        % given list of elements.
        %
        function r=Get_Difference_Results_Method_And_Element (this, Method_Coupling,List_Elements)
            [bool, index]=ismember(Method_Coupling, this.coupling_methods_list);
            if bool
                r=this.results_test{index}.Get_Array_Field_Difference_Between_Time_Step_Elements(List_Elements);
            elseif strcmpi('Reference',Method_Coupling)
                r=this.results_reference.Get_Array_Field_Difference_Between_Time_Step_Elements(List_Elements);
            else
                fprintf('[Evaluation/Get_Difference_Results_Method_And_Element ]the %s method has not been calculated by the coupler.\n', Method_Coupling);
            end
            
        end
        
        %
        %
        % Plots the difference between the reference and test values for a
        % giveng list of coupling methods, and specific time. Furthermore,
        % if request the values of this difference can be obtained.
        %
        %
%         function varargout= Absolute_Difference_TestvsRef_1D(this, Method_List, Time, Element_List,dx_test, dx_ref)
%             d1=length(Method_list);
%             Method_List_t={};
%             field1='Element';
%             field2='coupling method';
%             field3='calculated time';
%             field4='Field Difference';
%             for i=1:d1
%                 [bo, ind]=ismember(Method_List(i), this.coupling_methods_list);
%                 if bo==true
%                     Method_List_t=[Method_List_t Method_List(i)];
%                     []=this.results_test{index}.Absolute_Difference_TestvsRef_1D( Method_List, Time, Element,dx_test, dx_ref)
%                 else
%                     fprintf('[Evaluation/Absolute_Difference_TestvsRef_1D] The Method %s has not been calculated. \n',Method_List(i));
%                 end
%                 value1=Method_List_t;
%             end
%             if nargout == 1
%                 varargout{1}=struct(field1, value1, field2,)
%             end
%         end

        function Plot_OS_Ref_DeltaDissolutionWholeTime_1D(this, Method_List, List_Element, vec_dx_coup, vec_dx_ref)
            for j=1:length(Method_List)
                [v,~]=ismember(Method_List{1,j},this.coupling_methods_list);
                if (v==true)
                    Result_test_method=this.results_test{1,j};
                    Result_test_method.Plot_OS_Ref_DeltaDissolutionWholeTime_1D (this.results_reference, Method_List{1,j}, List_Element, vec_dx_coup, vec_dx_ref)
                else
                    fprintf('[Evaluation/Plot_OS_Ref_DeltaDissolutionWholeTime_1D] there is not solution for the method %s. \n', Method_List{1,j});
                end
            end
        end
    end
end