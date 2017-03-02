classdef Interface_LinearTransportFD_1D_ConstantVelDiffMesh_modLunnbench < Interface 
    properties
        data
        b_modOH
    end
    methods
        function this = Interface_LinearTransportFD_1D_ConstantVelDiffMesh_modLunnbench (Solve_Engine ,varargin)
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
            
            
            Porosity_Vec1=Data.Get_Vector_Field('porosity1');
            Porosity_Vec2=Data.Get_Vector_Field('porosity2');
            Porosity_Vec3=Data.Get_Vector_Field('porosity3');
            Saturation_Liquid_Vec=Data.Get_Vector_Field('liquid_saturation');
            Porosity_Vec = [Porosity_Vec1 Porosity_Vec2 Porosity_Vec3];
            Constant_Storage_Term = zeros(r,3);
            for     i = 1:3
                Constant_Storage_Term(:,i) = Saturation_Liquid_Vec.*Porosity_Vec(:,i);
            end
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
    end
end