% The main aim of this class is to save the Field (values) for the
% different integration steps of the Operator Splitting Method.
%
% Note: The vector_fields cell and the vector_time must have the
% same dimension so as to have a coherence in the class, but the class
% allows some manipulations that can broke this agreement. Consequently,
% the user must be aware.
%
% This class is a daughther of the 'Results' class. It will be used if the
% 'initial_field' property of Problem in the coupler is not a
% Array_Field class.

classdef Results_0D <Results
    properties
    end
    
    methods

        %   Instantiate a Results_0D class. 
        %
        %   Note: the two inputs are not compulsory.
        
        function this = Results_0D ( Vector_Fields, Vector_Time)
            this=this@Results(Vector_Fields,Vector_Time);
        end

        %   this method is an accessor, it returns your Results class as
        %   output.

        function t=Get_Results(this)
            t=Results_0D(this);
        end

        %   It plots the results and relative error for an scalar at different 
        %   time points and elements. It is used in rare cases, where the
        %   splitting operator is applied for an scalar and no physical
        %   dimension intervenes.

        function Plot_Comp_Result_0D (this, Reference_Result_Class, Time_List, Method)
            value_coup=[];
            value_ref=[];
            time_list_temp=[];
            a=this.Get_Vector_Time;
            b=Reference_Result_Class.Get_Vector_Fields;
            c=this.Get_Vector_Fields();
            assert(isempty(setxor(a, Reference_Result_Class.Get_Vector_Time)), '[Results_0D/Print_Comp_Result_0D] The time vector of Results and Reference are diferent.\n')
            n=1;
            for i=1:length(Time_List)
                [v,z]=ismember(Time_List(1,i),a);
                if v==1
                    value_coup(1,n)=c{z,1};
                    value_ref(1,n)=b{i,1};
                    time_list_temp(1,n)=Time_List(1,i);
                    n=n+1;
                else
                    fprintf('there is value at the time %d ',Time_List(1,i));
                end
            end
            if ~isempty(value_coup)
                ref=log(value_ref);
                coup=log(value_coup);
                pre=norm(value_ref-value_coup);
                figure
                 subplot(1,2,1)
                 hold on
                 set(gca,'FontSize',14)   
                 plot(time_list_temp,ref,'r-','LineWidth',2,'MarkerSize',10)
                 plot(time_list_temp,coup,'bx','LineWidth',2,'MarkerSize',10)
                 plot(pre,'gd', 'MarkerSize',10)
                 h_legend=legend('reference','coupler', 'norm difference');
                 set(h_legend,'FontSize',14);
                 xlabel('time','FontSize',14);
                 ylabel('Log (value)','FontSize',14);
                 title(sprintf('log values for %s', stringmethod(Method)), 'FontSize',14);
                 
                 subplot(1,2,2)
                 set(gca,'FontSize',14)
                 plot(time_list_temp,abs((value_ref-value_coup)./value_ref),'LineWidth',2,'MarkerSize',10)
                 xlabel('time','FontSize',14);
                 ylabel('Value','FontSize',14);
                 title(sprintf('relative error for %s', stringmethod(Method)), 'FontSize',14);
                 hold off
            else
                fprintf('[Results_0D/Print_Comp_Result_0D] there is no value to plot.\n');
            end
        end
        
        %   It plots the results and relative error for an matrix of scalars
        %   at different  time points and elements. It is used in rare cases, 
        %   where the splitting operator is applied for an matrix and no physical
        %   dimension intervenes.

        function Plot_Comp_Result_0D_matrix (this, Reference_Class, Time_List, Method)
            value_coup=[];
            value_ref=[];
            time_list_temp=[];
            a=this.Get_Vector_Time;
            b=Reference_Class.Get_Vector_Fields;
            c=this.Get_Vector_Fields;
            assert(isempty(setxor(a, Reference_Class.Get_Vector_Time)), '[Results_0D/Print_Comp_Result_0D] The time vector of Results and Reference are diferent\n')
            for j=1:length(c{1,1})
                n=1;
                for i=1:length(Time_List)
                    [v,z]=ismember(Time_List(1,i),a);
                    if v==1
                        value_coup(1,n)=c{z,1}(j);
                        value_ref(1,n)=b{i,1}(j);
                        time_list_temp(1,n)=Time_List(1,i);
                        n=n+1;
                    else
                        fprintf('there is value at the time \n%d ',Time_List(1,i));
                    end
                end
                if ~isempty(value_coup)
                    ref=(value_ref);
                    coup=(value_coup);
                    pre=norm(value_ref-value_coup);
                    figure
                    subplot(1,2,1)
                    hold on
                    set(gca,'FontSize',14)  
                    plot(time_list_temp,ref,'r-','LineWidth',2,'MarkerSize',10)
                    plot(time_list_temp,coup,'bx','LineWidth',2,'MarkerSize',10)
                    plot(pre,'gd','MarkerSize',10)
                    h_legend=legend('reference','coupler', 'norm difference');
                    set(h_legend,'FontSize',14);
                    xlabel('time','FontSize',14);
                    ylabel('Value','FontSize',14);
                    title(sprintf('values for %s variable %s', stringmethod(Method),num2str(j)), 'FontSize',14);
                    
                    subplot(1,2,2)
                    set(gca,'FontSize',14)  
                    plot(time_list_temp,abs((value_ref-value_coup)./value_ref),'LineWidth',2,'MarkerSize',10)
                    xlabel('time','FontSize',14);
                    ylabel('Value','FontSize',14);
                    title(sprintf('relative error for %s variable %s', stringmethod(Method),num2str(j)),'FontSize',14);
                    hold off
                else
                    fprintf('[Results_0D/Print_Comp_Result_0D_matrix] there is no value to plot.\n');
                end
            end
        end
        
        %   It gives the aboluste difference for every time step saved
        %   in the Result class.
        %
        %   Precondition: the 'vector_time' property must be the same so as
        %   to proceed with the absolute difference. The saved values of
        %   the 'vector_fields' property must be double (float/int) classes.

        function [vec_absdiff, time_vec]=Abs_Diff_Ref_Coup_0D(this, Ref_Result)
            assert(isempty(setxor(this.Get_Vector_Time , Ref_Result.Get_Vector_Time)), '[Results_0D/Absdiff_Ref_Coup_0D] The time vector of Results and Reference are diferent\n')
            time_vec=this.Get_Vector_Time;
            a=Ref_Result.Get_Vector_Fields;
            b=this.Get_Vector_Fields;
            vec_abs=cellfun(@minus, a, b, 'Un', 0);
            if length(vec_abs{1})==1
                vec_abs=cellfun(@abs,vec_abs);
            else
                vec_abs=cellfun(@abs,vec_abs,'Un', 0);
            end
            vec_absdiff=vec_abs;
        end
    end
    
end