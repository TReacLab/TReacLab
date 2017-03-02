classdef Interface_Phreeqc_Batch_Seq_v2 < Interface 
    properties
        prev_data
        Li
        ListTotal
        ListSol
        ListSolid
        data
        data1
        cell_for_RUNCELLS
        data_neg
    end
    
    methods
        
        function this = Interface_Phreeqc_Batch_Seq_v2 (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
            this.prev_data = varargin{1};
            this.Li = this.prev_data.Get_List_Identifiers;
            this.ListTotal = this.Li.Get_List_Id;
            this.ListSol = this.Li.Get_List_Names ('Solution');
            this.ListSolid = this.Li.Get_List_Names ('PrecipitationDissolution');
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
            [rows_chem] = varargin{1};
            dt = Time.Get_Time_Interval;
            final_time=Time.Get_Final_Time;
           
            this.cell_for_RUNCELLS = this.Separate_RunCells(rows_chem);
                
            [this.data1, this.data_neg] = Data.Remove_Negative_Values;
            Datamol = this.data1.Multiply_Concentration_with_Volumetric_Water_Content;
            
            A_Sol_Class=Datamol.Get_Desired_Array('Solution');
            A_Sol = A_Sol_Class.Get_Array;
            
            B_Solid_Class=Data.Get_Desired_Array ('PrecipitationDissolution');
            B_Solid=B_Solid_Class.Get_Array;
            
            [index_h2o, index_o, index_h, index_cb]=this.IndexSearch(this.ListSol);
            
            
            parm = {rows_chem, dt, final_time, this.cell_for_RUNCELLS, this.ListSol, this.ListSolid, A_Sol, B_Solid,index_h2o, index_o, index_h, index_cb };
        end
        
        
        
        
        function Data = SolveEngine2Coupler (this, out)
            Array=Get_Ini_val_HOcb_Array( this.ListTotal, out);
            
            % liquid saturation = vol_sol /(porosity *RV) ; In array I do
            % have neither porosity nor RV, consequently not liquid
            % saturation or volumetric water content.
            % units here mol/kgw
            Array = this.Add_HydraulicProp(this.ListTotal, this.data.Get_Vector_Field('porosity'), this.data.Get_Vector_Field('RV'), this.cell_for_RUNCELLS, Array);
            
            % units to mol/L
            Array = this.ChangeUnits_Kg_To_Liter(this.ListTotal, this.ListSol, Array);
            
            % The old must be update think about it
            Positive_Array_Before_Chem = this.data1.Get_Array;
            Positive_Array_After_Chem = this.Update_Array (Positive_Array_Before_Chem, this.cell_for_RUNCELLS, Array);
            Array = Positive_Array_After_Chem + this.data_neg.Get_Array;
            
            Data=Array_Field(this.Li, Array);
            this.prev_data = Data;
        end
        
            
            
        function cell_for_RUNCELLS = Separate_RunCells(this, rows_chem)
            d = numel(rows_chem);
            cell_for_RUNCELLS = {};
            counter =1;
            if d ==1  
                cell_for_RUNCELLS {counter} = rows_chem(1);
            else 
                x_0 = rows_chem(1);
                x_end = rows_chem(1);
                for i =2:d 
                   t = rows_chem(i-1) - rows_chem(i);
                   if t == -1
                       x_end = rows_chem(i);
                   else
                       if x_0 == x_end
                           cell_for_RUNCELLS{counter} = [x_0];
                       else
                           cell_for_RUNCELLS{counter} = [x_0 x_end];
                       end
                       counter = counter + 1;
                       x_0 = rows_chem(i);
                       x_end = rows_chem (i);
                   end
                end
                if x_0 == x_end
                    cell_for_RUNCELLS{counter} = [x_0];
                else
                    cell_for_RUNCELLS{counter} = [x_0 x_end];
                end
            end
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
        
        function Array = ChangeUnits_Kg_To_Liter(this, ListTotal, ListSol, Array)
            % getting index water mass
            [b, ind_wat]=ismember ('water',ListTotal);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v3] just work with porosity.')
            end
            
            % getting index volumetric content
            [b, ind_vwc]=ismember ('volumetricwatercontent',ListTotal);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v3] just work with porosity.')
            end
            
            % operations
            for i = 1:numel(ListSol)
                [b, ind_sol] = ismember(ListSol{i}, ListTotal);
                if b == 1
                    Array(:, ind_sol) = (Array(:, ind_sol).*Array(:, ind_wat))./Array(:, ind_vwc);
                else
                    error('[Phreeqc_Batch_Seq_v3\ChangeUnits_Kg_To_Liter] Wow!!! you forgot a solute?')
                end
            end
        end
        
        function Positive_Array_After_Chem = Update_Array (this, Positive_Array_Before_Chem,cell_for_RUNCELLS, Array)
            counter = 1;
            for i = 1:numel(cell_for_RUNCELLS)
                        if numel(cell_for_RUNCELLS{i}) == 1
                            Positive_Array_Before_Chem(cell_for_RUNCELLS{i}, :) = Array(counter, :);
                            counter = counter + 1;
                        elseif numel(cell_for_RUNCELLS{i}) == 2
                            diff= - cell_for_RUNCELLS{i}(1) + cell_for_RUNCELLS{i}(2);
                            Positive_Array_Before_Chem(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2), :) = Array(counter:counter+diff, :);
                            counter = counter + diff + 1;
                        else
                            error('[Phreeqc_Batch_Seq_v3\ChangeUnits_Kg_To_Liter] cell_for_RUNCELLS is getting out of hands')
                        end
            end
            Positive_Array_After_Chem =       Positive_Array_Before_Chem;  
        end
        
        function Array = Add_HydraulicProp(this, List_id, Vector_porosity, Vector_RV, cell_for_RUNCELLS, Array)
            % getting index liquid saturation
            [b, ind_lq]=ismember ('liquid_saturation',List_id);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v2] just work with liquid_saturation.')
            end
            % getting index water volumetric content
            [b, ind_vwc]=ismember ('volumetricwatercontent',List_id);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v3] just work with porosity.')
            end
            % getting index porosity
            [b, ind_por]=ismember ('porosity',List_id);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v3] just work with porosity.')
            end
            % getting index RV
            [b, ind_RV]=ismember ('RV',List_id);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v3] just work with RV.')
            end
            % getting partial vol_sol
            [b, ind_vol]=ismember ('vol_sol',List_id);
            if b ~=1
                error('[Phreeqc_Batch_Seq_v3] just work with vol_sol which correspondes to the solution of volume in the Phreeqc batch.')
            else
                v_p_volsol = Array(:,ind_vol);
            end
            % Now I have to work with cell_for_RUNCELLLS
            counter = 1;
            for i=1:numel(cell_for_RUNCELLS)
                if numel(cell_for_RUNCELLS{i}) == 1
                    %add porosity
                    Array(counter, ind_por) = Vector_porosity(cell_for_RUNCELLS{i});
                    % add RV
                    Array(counter, ind_RV) = Vector_RV(cell_for_RUNCELLS{i});
                    % calculate liquid sat (liquid saturation = vol_sol /(porosity *RV) )
                    Array(counter, ind_lq) = v_p_volsol(counter) /(Vector_porosity(cell_for_RUNCELLS{i})*Vector_RV(cell_for_RUNCELLS{i}));
                    % calculate volumetric water content
                    Array(counter, ind_vwc) = Vector_RV(cell_for_RUNCELLS{i})*Vector_porosity(cell_for_RUNCELLS{i})*Array(counter, ind_lq);
                    
                    counter = counter + 1;
                elseif numel(cell_for_RUNCELLS{i}) == 2
                    diff= - cell_for_RUNCELLS{i}(1) + cell_for_RUNCELLS{i}(2);
                    %add porosity
                    Array(counter:counter+diff, ind_por) = Vector_porosity(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2));
                    % add RV
                    Array(counter:counter+diff, ind_RV) = Vector_RV(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2));
                    % calculate liquid sat (liquid saturation = vol_sol /(porosity *RV) )
                    Array(counter:counter+diff, ind_lq) = v_p_volsol(counter:counter+diff) ./(Vector_porosity(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2)).*Vector_RV(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2)));
                    % calculate volumetric water content
                    Array(counter:counter+diff, ind_vwc) = Vector_RV(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2)).*Vector_porosity(cell_for_RUNCELLS{i}(1):cell_for_RUNCELLS{i}(2)).*Array(counter:counter+diff, ind_lq);
                
                    counter = counter + diff + 1;
                end
            end
        end
    end
    
end