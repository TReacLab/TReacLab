classdef Interface_TransportSNIA_PDEPEmod < Interface 
    properties
        data
    end
    methods
        function this = Interface_TransportSNIA_PDEPEmod (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin)  
            parm = Coupler2SolveEngine (this, Data, Time, varargin);
            out  = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            this.data = Data;
            
            C=Data.Get_Desired_Array ('Solution');

            C=C.SumDiff_Array ('H', 'H2O', '-');
            C=C.SumDiff_Array ('H', 'H2O', '-');
            C=C.SumDiff_Array ('O', 'H2O', '-');
            
            % Do matrix T(n)
            C_Aqueous=C.Get_Desired_Array ('Solution');  % working just with solution
            T_n=C_Aqueous.Get_Array; %(rows are the nodes, columns are the mesh position)
            
            t=Time.Get_Initial_Time:(Time.Get_Dt/30):Time.Get_Final_Time;
             At=Time.Get_Time_Interval;
            
            Porosity_Vec=Data.Get_Vector_Field('porosity');
            Saturation_Liquid_Vec=Data.Get_Vector_Field('liquid_saturation');
            Constant_Storage_Term=Saturation_Liquid_Vec.*Porosity_Vec;
            
            parm = {t, At, T_n, Constant_Storage_Term};
        end
        
        function Data = SolveEngine2Coupler (this, out)
              Data = this.data;
              l_t = this.data.Get_Transport_Elements;
              for i=1:length(l_t)
                Data = Data.Update_Array_Element ( out(:,i), l_t{i});
              end
              Data = Data.SumDiff_Array ('H', 'H2O', '+');
              Data = Data.SumDiff_Array ('H', 'H2O', '+');
              Data = Data.SumDiff_Array ('O', 'H2O', '+');
        end
        
    end
end
