classdef Interface_LinearTransportFD_1D_ConstantVelDiffMesh < Interface 
    properties
        data
        b_modOH
    end
    methods
        function this = Interface_LinearTransportFD_1D_ConstantVelDiffMesh (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
            this.b_modOH = this.solve_engine.Get_modHO();
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin)  
            parm = Coupler2SolveEngine(this, Data, Time, varargin);
            out  = this.solve_engine.Time_Stepping (parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            this.data = Data;
            C=Data.Get_Desired_Array ('Solution');
            %
            if this.b_modOH == true
                C=C.SumDiff_Array ('H', 'H2O', '-');
                C=C.SumDiff_Array ('H', 'H2O', '-');
                C=C.SumDiff_Array ('O', 'H2O', '-');
            end
            C_Aqueous=C.Get_Desired_Array ('Solution');  % working just with solution
            C_n=C_Aqueous.Get_Array;
            [r, c] = size(C_n);
            
            
            Porosity_Vec=Data.Get_Vector_Field('porosity');
            Saturation_Liquid_Vec=Data.Get_Vector_Field('liquid_saturation');
            Constant_Storage_Term=Saturation_Liquid_Vec.*Porosity_Vec;
            
            dt=Time.Get_Time_Interval;
            
            parm = {dt, Constant_Storage_Term, r, c, C_n};

        end
        
        function Data = SolveEngine2Coupler (this, out)
            li = this.data.Get_Transport_Elements;
            Data = this.data;
            for i=1:length(li)
                 Data = Data.Update_Array_Element ( out(:,i), li{i});
            end
            
            if this.b_modOH == true
                Data=Data.SumDiff_Array ('H', 'H2O', '+');
                Data=Data.SumDiff_Array ('H', 'H2O', '+');
                Data=Data.SumDiff_Array ('O', 'H2O', '+');
            end
        end
        
        function b = Get_modHO (this)
            b = this.b_modOH;
        end
    end
end
