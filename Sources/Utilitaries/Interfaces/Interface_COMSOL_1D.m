classdef Interface_COMSOL_1D < Interface 
    properties
        data_sol 
        data
        list_elements_transport
        b_modOH
    end
    methods
        
        % Constructor
        function this = Interface_COMSOL_1D (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
            this.b_modOH = this.solve_engine.Get_modOH ;
        end 
        
        % Time stepping
        function Data = Time_Stepping (this, Data, Time, varargin)
            parm = Coupler2SolveEngine (this, Data, Time, varargin);
            pd_comsol = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, pd_comsol);
        end
        
        
        
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            this.list_elements_transport=Data.Get_List_Identifiers.Get_Mobile_Species;
            list_elementstransport=Working_Element_List_1(this.list_elements_transport);
            
            this.data_sol = Data.Get_Desired_Array('Solution');
            this.data = Data;
            Data_Sol = this.data_sol;
            % Phreeqc case
            if this.b_modOH == true
                Data_Sol=this.data_sol.SumDiff_Array ('H', 'H2O', '-');
                Data_Sol=Data_Sol.SumDiff_Array ('H', 'H2O', '-');
                Data_Sol=Data_Sol.SumDiff_Array ('O', 'H2O', '-');
            end
            %
            Array = Data_Sol.Get_Array;
            
            % Time
            ini_t = Time.Get_Initial_Time();
            dt = Time.Get_Dt;
            fin_t = Time.Get_Final_Time();
            
            parm = {Array, list_elementstransport, ini_t, dt, fin_t};
        end
        
        
        function Data = SolveEngine2Coupler (this, pd_comsol)
            % comsol_result
            pdNames=fieldnames(pd_comsol);
            [r,c] = size(cell2mat(strfind(pdNames, 'd')));
            output = cell(1, r);
            d=1;
            for i=1:size(pdNames,1)
                if(strcmp(pdNames{i,1}(1),'d'))
                    field=getfield(pd_comsol,pdNames{i,1});
                    t=field(end,2:end-1);
                    output{1,d}=t';
                    d=d+1;
                end
            end
            
            % 
            this.data_sol = this.data_sol.Update_Field(output);
            
            %
            compl_list = this.data.Get_List_Ide;
            array_temp=this.data.Get_Array;
            array_temp_transp=this.data_sol.Get_Array;
            for i=1:size(this.list_elements_transport,2)
                [b,v]=ismember(this.list_elements_transport{1,i}, compl_list);
                if b==true
                    array_temp(1:end,v)=array_temp_transp(1:end,i);
                end
            end
            C_merge=Array_Field(this.data.Get_List_Identifiers, array_temp);
            
            if this.b_modOH == true
                C_merge=C_merge.SumDiff_Array ('H', 'H2O', '+');
                C_merge=C_merge.SumDiff_Array ('H', 'H2O', '+');
                C_merge=C_merge.SumDiff_Array ('O', 'H2O', '+');
            end
            Data = C_merge;
        end
        
    end
end