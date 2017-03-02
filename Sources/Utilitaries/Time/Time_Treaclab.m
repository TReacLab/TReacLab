%   This class contains the time discretization of the Operator Splitting
%   methods that will be used.


classdef Time_Treaclab < Time
    properties (Access=private)
        nt              % double given the number of iterations (it does no take in account the values inside the list_time)
        dt              % double given the discretization time (it does no take in account the values inside the list_time)
        list_time       % [1.4 2.5 3.2] list that indicates that points of time where the user wants to drawn the values (Fields).
        time_all        % boolean states if as output, the user wants the results at each time point (true case) or just at the points
                        % inside the list_time (false case)
    end

    methods

        %   Instantiate a Time class. 

        function this=Time_Treaclab( Initial_Time, Final_Time, List_Time, Time_All)
            assert(Initial_Time<=Final_Time,'[TIME/Time] final_time should be bigger or equal than initial_time');
            this = this@Time(Initial_Time, Final_Time);
            this.list_time=List_Time;
            this.time_all=Time_All;
        end

        %   It returns a boolean, it will be true if the two classes are equal.

        function boolean = Equal (this, Time)
            if this.initial_time~=Time.Get_Initial_Time()
                boolean=false;
            elseif this.final_time~=Time.Get_Final_Time()
                boolean=false;
            elseif this.nt~=Time.Get_nt()
                boolean=false;
            elseif this.dt~=Time.Get_dt()
                boolean=false;
            elseif this.list_time~=Time.Get_List_Time
                boolean=false;
            elseif this.time_all~=Time.Get_Time_All
                boolean=false;
            else
                boolean=true;
            end
        end
        
        
        %   It returns the difference between the properties "final_time"
        %   and "intial_time".

        function At=Get_Time_Interval(this)
            At=this.final_time-this.initial_time;
        end
        
        %   it returns a Time class with the same properties values than
        %   the older one, but changing the final_time propertie value.

        function this=Change_Final_Time(this, New_Final_Time)
            this.final_time=New_Final_Time;
        end

        %   The time step and interval of iterations are fixed.

        function this = Fix_Dt(this, Dt)
            this.dt=Dt;
            this.nt=(this.Get_Time_Interval/this.dt);
        end
        
        %   The interval of iterations and time step  are fixed.

        function this = Fix_Nt(this, Nt)
            this.nt=Nt;
            this.dt=this.Get_Time_Interval/this.nt;
        end

        %   It returns the property 'nt'
        
        function nt=Get_Nt(this)
            nt=this.nt;
        end

        %   this methods creates a time discretization that will be used by
        %   the coupler for carrying out the operator splitting methods.
        %
        %   Precondition: There must be an initial dt; this dt can be given
        %   using Fix_dt or Fix_nt methods.

        function [time_class_list,time_list, storage_points]=Get_Nt_And_DtList (this)
            if ~isempty(this.dt)
                v1=this.initial_time:this.dt:this.final_time;
                v=[v1, this.final_time, this.list_time];
            else
                v=[this.list_time];
            end
            time_list=unique(v);
            r=find(time_list==this.final_time);    %Check that the last value of the time_list is smaller than the final time of the time class.
            time_list=time_list(1,1:r);
            dt_list=diff(time_list);
            if this.time_all==true
                storage_points(1,1:length(dt_list))=true;
            else
                n=1;
                list_time_sort=sort(this.list_time);
                storage_points=zeros(1,length(dt_list));
                for i=2:length(time_list)
                    if n<=length(list_time_sort) && (time_list(1,i)==list_time_sort(1,n)) 
                        storage_points(1,i-1)=true;    
                        n=n+1;
                    else
                        storage_points(1,i-1)=false;
                    end
                end
            end
            time_class_list=cell(1,length(dt_list));
            for i=1:length(dt_list)
                time_class_list{1,i}=Time_Treaclab(time_list(1,i), time_list(1,i+1),[],false);
                time_class_list{1,i}=time_class_list{1,i}.Fix_Dt(dt_list(1,i));
            end
        end

        function [time_class_list,time_list]=Get_Nt_And_DtList_Ref(this)
            [~,time_list_os, storage_points_os]=Get_Nt_And_DtList (this);
            n=sum(storage_points_os);
            time_class_list=cell(1,n);
            time_list=zeros(1,n+1);
            j=1;
            time_list(j)=time_list_os(1);
            for i=1:length(storage_points_os)
                if storage_points_os(i)==1
                    time_list(j+1)=time_list_os(i+1);
                    time=Change_Final_Time(this, time_list_os(i+1));
                    time_class_list{j}=time;
                    j=1+j;    
                end
            end
        end

        %   It returns the property 'dt'

        function dt=Get_Dt(this)
            dt=this.dt;
        end


        %   It returns the property 'list_time'

        function list_time=Get_List_Time(this)
            list_time=this.list_time;
        end
        
        %   It returns the property 'time_all'

        function time_all=Get_Time_All(this)
            time_all=this.time_all;
        end

        %   It returns two Time class that together constitued your initial
        %   time class. This means that our time class is subdivided in two
        %   Time classes.

        function [time_1, time_2]=Divide_Two_Intervals (this)
            time_middle=(this.Get_Time_Interval()/2);
            time_1=Time_Treaclab(this.initial_time, time_middle+this.initial_time,[],false);
            time_1=time_1.Fix_Dt(time_middle);
            time_2=Time_Treaclab(time_middle+this.initial_time, this.final_time,[],false);
            time_2=time_2.Fix_Dt(time_middle);
        end
        
    end
end