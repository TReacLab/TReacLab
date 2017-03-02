classdef Interface_SimpleR_FirstOrder_Decay < Interface 
    properties
        data
    end
    
    methods
        
        function this = Interface_SimpleR_FirstOrder_Decay (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin) 
            parm = Coupler2SolveEngine (this, Data, Time);
            out  = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm = Coupler2SolveEngine (this, Data, Time)
            this.data = Data;
            
            ini_t = Time.Get_Initial_Time;
            dt = Time.Get_Time_Interval;
            fin_t = Time.Get_Final_Time;
            
            C_Aqueous=Data.Get_Desired_Array ('Solution');  % working just with solution
            C_n=C_Aqueous.Get_Array;
            
            parm = {ini_t, dt, fin_t, C_n};
        end
        
        function Data = SolveEngine2Coupler (this, out)
            li_sol = this.data.Get_Transport_Elements;
            Data = this.data;
             for i=1:length(li_sol)
                Data = this.data.Update_Array_Element ( out(:,i), li_sol{i});
                
             end
        end
    end
end