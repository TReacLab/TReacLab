classdef List_Batch_Reaction
    properties
        list_models
        num_rows
    end
    methods
        function this=List_Batch_Reaction(list_models, num_rows)
            this.list_models=list_models; 
            if length(num_rows)==1
            this.num_rows=num_rows;
            else
                this.num_rows=num_rows(1):1:num_rows(2);
            end
        end
        
        
        % ======================================================================
        %
        % Time_Stepping --> c2=Time_Stepping (this, C1, Time)
        % 
        %
        %   inputs: 1) your Org_Phreeqc class.
        %           2) Array_Field class.
        %           3) Time class.
        %
        %   outputs: 1) Array_Field class.
        %
        %   The method returns a Array_Fields class after applying a
        %   time step. 
        %   For every row of the array of the initial Array_Field class
        %   (c1) a Array_Field class is created and saved in a cell,
        %   thanks to the 'DivideField' method of the Array_Field
        %   class. The length of this cell, which is equal to the length of
        %   the rows in the array of the initial Array_Field class, must
        %   be equal to the number of process saved in the 'cell_models'
        %   property of Org_Phreeqc class, otherwise Org_Phreeqc set the
        %   'cell_models' property as a cell with length equal to the
        %   number of rows in the array of the initial Array_Field class,
        %   and with 'first_model' as value for every position of the cell.
        %   After, the time steps for every proces in 'cell_models' have
        %   been carried out, there is a merging of values to obtain the
        %   Array_Field class output.
        %
        % ======================================================================
        function c2=Time_Stepping (this, C1, Time)
            r=C1.Get_Array;
            d=size(r,1);
            subcell_fields=C1.DivideArrayField(d);
            cell_subfields_output=cell(1, d);
            for i=1:d
                [boolean, index]=ismember(i,this.num_rows);
                if boolean 
                    cell_subfields_output{1,i}=this.list_models.Time_Stepping(subcell_fields{1,i},Time);
                else
                    cell_subfields_output{1,i}=subcell_fields{1,i};
                end
            end
            c2=C1.MerginArrayField(cell_subfields_output);
%             c2.Get_List_Ide
%             c2.Get_Array
            fprintf ('ListMadeupBatchReaction Iteration.\n');
        end
    end
    
end