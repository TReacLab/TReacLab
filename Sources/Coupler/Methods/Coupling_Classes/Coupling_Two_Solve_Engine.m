% This class is in charge of applying different Operator Splitting methods,
% with two process.

classdef Coupling_Two_Solve_Engine < Coupler 
    properties
        solve_engine_1            % A Process class.
        solve_engine_2            % A Process class
        results                   % A Results class.
        n_iter                    % Number of iterations
        opt                       % options structure [it contains: maximum number of fix point iterations, maximun time change]
    end

    methods

        %   Instantiate a Coupling_Two_Process class. 

        function this=Coupling_Two_Solve_Engine(Solve_Engine_1, Solve_Engine_2, Ini_Concentration, varargin)
                    this.solve_engine_1=Solve_Engine_1;
                    this.solve_engine_2=Solve_Engine_2;
                    if (strcmpi(class(Ini_Concentration),'Array_Field'))
                        this.results=Results_1D({},[]);
                    else
                        this.results=Results_0D({},[]);
                    end
                    this.n_iter=0;
                    if ~isempty(varargin)
                        this.opt = varargin{1};
                        this.Check_Options_Coupler(this.opt);
                    else
                        this.opt = Set_Coupler_Opt('Max_n_fixPoint', 25, 'Max_n_ReductionTime', 5, 'SIA_Convergence_Criteria', 1e-8);
                    end
        end
   
        %   it applies the Strang method for one splitting time step, 
        %   applying the First solve engine, Second solve engine and First solve engine.

        function c_fin=Strang_method_121(this, C1, Time)
            [time_1, time_2]=Time.Divide_Two_Intervals();
            u_1=this.solve_engine_1.Time_Stepping( C1,time_1);
            u_2=this.solve_engine_2.Time_Stepping( u_1,Time);
            c_fin=this.solve_engine_1.Time_Stepping( u_2,time_2);
        end
          
        %   it applies the Strang method for one splitting time step, 
        %   applying the Second solve engine, First solve engine and Second solve engine.

        function c_fin=Strang_method_212(this, C1, Time)
            [time_1, time_2]=Time.Divide_Two_Intervals();
            u_1=this.solve_engine_2.Time_Stepping( C1,time_1);
            u_2=this.solve_engine_1.Time_Stepping( u_1,Time);
            c_fin=this.solve_engine_2.Time_Stepping( u_2,time_2);  
        end
        
        %   it applies the Sequential method for one splitting time step, 
        %   applying the First solve engine and Second solve engine.

        function c_fin=Sequential_12(this, C1, Time)
            u_1=this.solve_engine_1.Time_Stepping( C1, Time);
            c_fin=this.solve_engine_2.Time_Stepping( u_1, Time);
        end
         
        %   it applies the Sequential method for one splitting time step, 
        %   applying the Second solve engine and First solve engine.

        function c_fin=Sequential_21(this, C1, Time)
            u_1=this.solve_engine_2.Time_Stepping( C1,Time);
            c_fin=this.solve_engine_1.Time_Stepping( u_1,Time);
        end
        
        %   it applies the additive splitting method for one splitting time step.

        function c_fin=Additive_method(this, C1, Time)
            u_1=this.solve_engine_1.Time_Stepping( C1,Time);
            u_2=this.solve_engine_2.Time_Stepping( C1,Time);
            c_fin=Difference(u_1,u_2,C1);
        end
        

        %   it applies the symmetrically weighted splitting method for one splitting time step.
        %
        % Since sometimes the solver will store information fourth solvers
        % are required.
        
        function c_fin=Symmetrically_Weighted_method(this, C1, Time)
            %c_fin_prima1=this.Sequential_12(C1,Time);
            u_1_prima1=this.solve_engine_1{1}.Time_Stepping( C1, Time);
            c_fin_prima1=this.solve_engine_2{1}.Time_Stepping( u_1_prima1, Time);
            
            %c_fin_prima2=this.Sequential_21(C1,Time);
            u_1_prima2=this.solve_engine_2{2}.Time_Stepping( C1, Time);
            c_fin_prima2=this.solve_engine_1{2}.Time_Stepping( u_1_prima2, Time);
            
            c_fin=Weight(0.5, c_fin_prima1, c_fin_prima2,C1);
        end
        
        %
        %
        function b = isSIA(this, string)
            b = strcmp(string,'SIA_TC')|| strcmp(string,'SIA_CC');
        end
        
        
        % These methos solve a problem applying a TC (T:total component
        % primary variable, C: mobile variables transport ) sequential
        % iterative approach for a whole interval of time, and stores the
        % value in a Result class which is outputed.
        %
        % The algorithm fix point tends to be written in the following way:
        % x (n+1) = g(x(n))
        % where n is the iteration step

        function Results = SIA (this, Problem, Couplermethod)
            c0=Problem.Get_Initial_Field();
            [time_class_list, time_list, storage_points]=Problem.Get_Time_Classes_and_Saving_Points();
            this.results=this.results.Append_Array_Field(c0);
            this.results=this.results.Append_Time(time_list(1,1));
            i=1;
            
            while i<=length(time_class_list)
                done = false;
                counter_reduction_time=0;
                % loop f time
                while ~done 
                    if strcmp(Couplermethod,'SIA_TC')
                    [c, done] = this.SIA_TC_Loop (c0, time_class_list{1,i});
                    elseif strcmp(Couplermethod,'SIA_CC')
                        [c, done] = this.SIA_CC_Loop (c0, time_class_list{1,i});
                    end
                    if done==true
                        if storage_points(1,i)==true
                            this.results=this.results.Append_Array_Field(c);
                            this.results=this.results.Append_Time(time_list(1,i+1));
                        end
                        c0=c;
                    else % reduce time step by a half if the convergence loop outputs a no convergence results of the fix point algorithm
                        [t1, t2]=time_class_list{1,i}.Divide_Two_Intervals;
                        counter_reduction_time = counter_reduction_time+1;
                        if i~=1 && i~=length(time_class_list)
                            time_class_list=[time_class_list(1,1:i-1) {t1 t2} time_class_list(1,i+1:end)];
                            time_list=[time_list(1,1:i) t1.Get_Final_Time time_list(1,i+1:end)];
                            storage_points=[storage_points 1];
                        elseif i==1
                            time_class_list=[{t1 t2} time_class_list(1,2:end)];
                            time_list=[time_list(1,1) t1.Get_Final_Time time_list(1,i+1:end)];
                            storage_points=[storage_points 1];
                        else
                            time_class_list=[time_class_list(1,1:end-1) {t1 t2}];
                            time_list=[time_list(1,1:end-1) t1.Get_Final_Time time_list(1,end)];
                            storage_points=[storage_points 1];
                        end
                    end
                    
                    % if time has been reduced X (this.opt.Max_n_ReductionTime, default 5) time for the same
                    % interval, the problem assumes that the fix point
                    % approach does not converge.
                    
                    if counter_reduction_time==this.opt.Max_n_ReductionTime
                        % The results are saving in a matlab workspace before the convergence crush in order to be analysed.
                        s=strcat('Result_before_crushing_due_convergence_problems.mat'); 
                        this_results = this.results;
                        save (s,'this_results', '-v7.3')
                        error('[Coupling_Two_Solve_Engine\SIA_TC] The time step has been reduced 5 times and not convergence have been reached, time to think about it.\n')
                    end
                    if time_class_list{1,i}.Get_Final_Time == time_list(end)
                        break
                    end
                end
                i=i+1;
            end
            Results = this.results;
        end

        % loop of convergence
        % with a TC formulation (where k is the time) and bc is the vector of boundary conditions, it looks like (for simplicity assume porosity equal to 1):
        %
        % T(k+1,n+1) = T(k) + dt(L(C(k+1,n)+bc(k,n))
        % C(k+1,n+1)+ F(k+1,n+1) = F(k) + C(k) + dt(L(C(k+1,n)+bc(k,n))
        %
        % This methods iterate over the mobile component
        
        function [c, done] = SIA_TC_Loop (this, c0, Time)
            counter=1;
            cn_i=c0;
            while counter<this.opt.Max_n_fixPoint
                % transp
                ctrans = this.solve_engine_1.Time_Stepping( c0,Time, cn_i);
                % chemi
                cchem = this.solve_engine_2.Time_Stepping( ctrans,Time); 
                % convergence?
                done=Convergence_Reached(cchem, cn_i,this.opt); 
                if done
                    break;
                end
                 cn_i = ChangeSolidValues(cchem,c0);
%                 % Convergence?
                counter = counter + 1;
            end
            if done==true
                c=cchem;
            else
                done=false;
                c=c0;
            end
        end
        
        % loop of convergence
        % with a CC formulation (where k is the time) and bc is the vector of boundary conditions, it looks like (for simplicity assume porosity equal to 1):
        % R (k) = - F(k+1,n) +F(k);
        %
        % T(k+1,n+1) = T(k) + dt(L(C(k+1,n)+bc(k,n))
        % C(k+1,n+1) = - F(k+1,n) +F(k) + C(k) + dt(L(C(k+1,n)+bc(k,n))
        %
        % This methods iterate over the fix component
        
        function [c, done] = SIA_CC_Loop (this, c0, Time)
            counter = 1;
            cn_i = c0;
            % for 1D 
            ct=c0.Get_Desired_Array ('Solution');
            [row,col] = ct.Array_Size;
            R=Initialize_ChemicalSourceSink('1D',[row,col]); % This function must innerly and outterly be modified to add 2D and 3D. In our cases so far, we use just 1D.
            while counter < this.opt.Max_n_fixPoint
                R0=R;
                % transp
                ctrans = this.solve_engine_1.Time_Stepping( cn_i,Time, R);
                % chemi
                cchem = this.solve_engine_2.Time_Stepping( ctrans,Time);
                % Get new R
                R = Get_Chemical_SourceSink(R, ctrans, cchem);

                % convergence?
                done=Convergence_Reached(cchem, ctrans,this.opt);

                cn_i = ChangeSolidValues(c0, cchem);
                if done
                    break;
                end
                counter = counter + 1;
            end

            if done == true
                c=cchem;
            else
                done=false;
                c=c0;
            end
        end

        
        % 

        %   This method solves a problem applying a splitting method for a
        %   whole interval of time, and stores the values in a Result class
        %   which is outputed.

        function r=Loop(this, Couplermethod, Problem)
            if this.isSIA(Couplermethod)
                r=SIA(this, Problem, Couplermethod);
            else
                c=Problem.Get_Initial_Field();
                [time_class_list, time_list, storage_points]=Problem.Get_Time_Classes_and_Saving_Points();
                this.results=this.results.Append_Array_Field(c);
                this.results=this.results.Append_Time(time_list(1,1));
                for i=1:length(time_class_list)
                    c=this.couplermethod_function(Couplermethod,c,time_class_list{1,i});
                    this.n_iter=this.n_iter+1;
                    if storage_points(1,i)==true
                        this.results=this.results.Append_Array_Field(c);
                        this.results=this.results.Append_Time(time_list(1,i+1));
                    end
                    fprintf(num2str(this.n_iter))
                    fprintf('\n')
                end
                r=this.results;
                this.Specific_Message(Couplermethod);
            end
        end


        %   This method outputs the cell Vector_Concentrations of the
        %   property 'results' of the Coupling_OS classes. This property 
        %   'results' is a Results class.
 
        function t=Get_Results_Vector_Concentrations(this)
            t=this.results.Get_Vector_Concentrations();
        end

        %   This method outputs the cell Vector_Time of the
        %   property 'results' of the Coupling_OS classes. This property 
        %   'results' is a Results class.

        function t=Get_Results_Vector_Time (this)
            t=this.results.Get_Vector_Time();
        end
  
        %   It applies the coupling method for one step regarding the given
        %   string and outputs its result.

        function conc_f=couplermethod_function(this, Couplermethod, C1, Dt_Num)
                    if (strcmpi(Couplermethod,'Strang_method_121'))
                        conc_f=Strang_method_121(this,C1,Dt_Num);
                    elseif(strcmpi(Couplermethod,'Strang_method_212'))
                        conc_f=Strang_method_212(this,C1,Dt_Num);
                    elseif(strcmpi(Couplermethod,'Sequential_12'))
                        conc_f=Sequential_12(this,C1,Dt_Num);
                    elseif(strcmpi(Couplermethod,'Sequential_21'))
                        conc_f=Sequential_21(this,C1,Dt_Num);
                    elseif(strcmpi(Couplermethod,'Additive_method'))
                        conc_f=Additive_method(this,C1,Dt_Num);
                    elseif(strcmpi(Couplermethod,'Symmetrically_Weighted_method'))
                        conc_f=Symmetrically_Weighted_method(this,C1,Dt_Num);
                    elseif (strcmpi(Couplermethod,'AlternatingOS'))
                        if mod(this.n_iter,2) == 0
                            conc_f =Sequential_12(this,C1,Dt_Num);
                        else
                            conc_f =Sequential_21(this,C1,Dt_Num);
                        end
                    end
        end
       
        % take care that three main parameter of the SIA approaches have
        % been define
        function Check_Options_Coupler(this, options)
            if isempty(options.Max_n_fixPoint) || ~isnumeric(options.Max_n_fixPoint)
                this.opt.Max_n_fixPoint = 25;
            end
            if isempty(options.Max_n_ReductionTime) || ~isnumeric(options.Max_n_ReductionTime)
                this.opt.Max_n_ReductionTime = 5;
            end
            if isempty(options.SIA_Convergence_Criteria) && (isempty(options.SIA_Conv_Criteria_Aqueous) || isempty(options.SIA_Conv_Criteria_Mineral))
                this.opt.SIA_Convergence_Criteria = 1e-8; 
            end
        end
        
        % Specific message at the end of the simulation
        function Specific_Message(this, Couplermethod)
            if mod(this.n_iter, 2) == 1 && strcmpi (Couplermethod,'AlternatingOS')
                fprintf ('The Alternative coupler method has been completed with an uneven number of iterations. \n');
            end
        end
    end
            

end

