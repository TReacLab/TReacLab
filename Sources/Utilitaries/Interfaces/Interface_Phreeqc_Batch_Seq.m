classdef Interface_Phreeqc_Batch_Seq < Interface 
    properties
        prev_data
        row_bc
        data
        listSol
        listSolid 
        li
        r
        dataneg
    end
    
    methods
        
        function this = Interface_Phreeqc_Batch_Seq (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
            this.prev_data = varargin{1};
            this.li = this.prev_data.Get_List_Identifiers;
            this.listSol   = this.li.Get_List_Names ('Solution');
            this.listSolid = this.li.Get_List_Names ('PrecipitationDissolution');
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin) 
            this.data = Data;
            [rows_chem] = Data.Rows_ArraySolution_Different(this.prev_data, 1e-10);
            
            if ~isempty (rows_chem)
            parm = Coupler2SolveEngine (this, Data, Time, rows_chem);
            out  = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, out);
            else
                this.prev_data = Data;
                Data = Data;
            end
        end
        
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            this.data= Data;
            dt=Time.Get_Time_Interval;
            final_time=Time.Get_Final_Time;
            rows_chem = varargin{1};
            this.row_bc = Data.Get_Array_Field_Part (1);
            DataMol = Data.Multiply_Concentration_with_Volumetric_Water_Content;
            [Datapos, this.dataneg]=Data.Remove_Negative_Values;
             Old_Array=Data.Get_Array;
             
            A_Sol_Class=Datapos.Get_Desired_Array('Solution');
            A_Sol = A_Sol_Class.Get_Array;
            
            [this.r, ~] = size(A_Sol);
            
            B_Solid_Class=Data.Get_Desired_Array ('PrecipitationDissolution');
            B_Solid=B_Solid_Class.Get_Array;
            
            [index_h2o, index_o, index_h, index_cb]=this.IndexSearch(this.listSol);
            
            parm = {final_time,dt, rows_chem, this.listSol, this.listSolid, A_Sol, B_Solid,index_h2o, index_o, index_h, index_cb };
        end
        
        
        function Data = SolveEngine2Coupler (this, out)
            Array=Get_Ini_val_HOcb_Array(this.li.Get_List_Id, out);
            Array=this.Update_Hydraulic_Properties ( Array, this.data);
            
            D = this.row_bc;
            D=D.Multiply_Concentration_with_Volumetric_Water_Content;
            D=D.Multiply_Gas_Concentration_with_Volumetric_Gas_Content;
            D=D.Divide_List_with_Column(this.listSol, 'water');
            Old_Array=D.Get_Array;
            
             Array=[Old_Array(1,:); Array];
             
              % add negative
            [b, ind]=ismember('water', this.data.Get_List_Ide);
            if b~=1
                fprintf('[Phreeqc_Batch_Seq/Time_Stepping] Check me.');
            else
                A0=zeros(this.r,1);
                Cneg = this.dataneg;
                Cneg=Cneg.Update_Array_Element (Array(:,ind), 'water');
                Cneg=Cneg.MolesSolutes_Over_Water;
                Cneg=Cneg.Update_Array_Element (A0, 'water');
            end
            neg= Cneg.Get_Array;
            Array=Array+neg;
            
            Data=Array_Field(this.li, Array);
            Data = Data.InitializationRV_mol_litre_afterPhreeqcCalculation_Noporchange;
            this.prev_data=Data;
        end
                
        
        
        function [index_h2o, index_o, index_h, index_cb]=IndexSearch(this, ListSol)
            [b_h2o, index_h2o] = ismember('H2O', ListSol);
            [b_o, index_o] = ismember('O', ListSol);
            [b_h, index_h] = ismember('H', ListSol);
            [b_cb, index_cb] = ismember('cb', ListSol);
            assert(b_h2o==b_o && b_h==b_cb && b_o==b_cb,'[Phreeqc_Batch_Seq/IndexSearch]');
        end
        
        function Array=Update_Hydraulic_Properties (this, Array, C)
            Old_Val=C.Get_Array;
            Old_Val=Old_Val(2:end, : );
            Li = C.Get_List_Identifiers;
            lc=Li.Get_List_Id; 
            lh=Li.Get_List_Names ('HydraulicProperty');
            for i=1:length(lh)
                [b, ind]=ismember(lh{i},lc);
                if b==1
                    Array(:,ind)=Old_Val(:,ind);
                else
                    fprintf('[Phreeqc_Batch_Seq\Update_Hydraulic_Properties] fail\n');
                end
            end
        end
    end
end
