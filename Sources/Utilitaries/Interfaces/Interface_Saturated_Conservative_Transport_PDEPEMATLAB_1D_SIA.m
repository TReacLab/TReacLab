classdef Interface_Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA < Interface 
    properties
        data
    end
    methods
        function this = Interface_Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin)  
            parm = Coupler2SolveEngine (this, Data, Time, varargin);
            out  = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            this.data = Data;
            
            t=Time.Get_Initial_Time:(Time.Get_Dt/30):Time.Get_Final_Time;
            At=Time.Get_Time_Interval;
            
            Data=Data.SumDiff_Array ('H', 'H2O', '-');
            Data=Data.SumDiff_Array ('H', 'H2O', '-');
            Data=Data.SumDiff_Array ('O', 'H2O', '-');
            
            
            % Get C(n)
            C_Aqueous=Data.Get_Desired_Array ('Solution');  % working just with solution
            C_n=C_Aqueous.Get_Array; %(rows are the nodes, columns are the mesh position)
            
            % The porosity  and saturation will be the one from the initial values
            % and not the ones from Cn+1,i
            Porosity_Vec=Data.Get_Vector_Field('porosity');
            Saturation_Liquid_Vec=Data.Get_Vector_Field('liquid_saturation');
            Constant_Storage_Term=Saturation_Liquid_Vec.*Porosity_Vec;
            
            
            % Get the matrix L(C(n+1, i))
            FieldArray_nplusone_i=varargin{1}{1};
            C_Aqueous_nplusone_i=FieldArray_nplusone_i.Get_Desired_Array ('Solution');
            %
            C_Aqueous_nplusone_i=C_Aqueous_nplusone_i.SumDiff_Array ('H', 'H2O', '-');
            C_Aqueous_nplusone_i=C_Aqueous_nplusone_i.SumDiff_Array ('H', 'H2O', '-');
            C_Aqueous_nplusone_i=C_Aqueous_nplusone_i.SumDiff_Array ('O', 'H2O', '-');
            %
            C_nplusone_i=C_Aqueous_nplusone_i.Get_Array;
            
%             
            parm = {t, At, C_n, C_nplusone_i, Constant_Storage_Term};
        end
        
        function Data = SolveEngine2Coupler (this, out)
            
            Data=this.data;
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
