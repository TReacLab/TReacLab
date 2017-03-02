% Selected_Output_Array is a matlab cell class containing a first row with
% strings and various rows with numerical values. Selected_Output_Array is
% thought to be as the output given by the method of iphreeqc class:
% iphreeqc.GetSelectedOutputArray().
% The list_id is a cell like: {'Na' ... 'H' ... 'Dolomite'}
% 
% The function takes the first row of Selected_Output_Array which is a cell
% containing strings and does some modifications to some of the strings
% such as removing the label (mol/kgw) which is outputed for the master
% species of the solution. Afterwards, some of the numerical values of
% the last row of Selected_Output_Array will be placed in a vector
% following the order of List_Id.

function Element_Ini_Values=Get_Ini_val_HOcb(List_Id, Selected_Output_Array)

first_row_output_reaction=Selected_Output_Array(1, 1:end);
first_row_output_reaction=Remove_MOLKGW_String(first_row_output_reaction);
first_row_output_reaction=Remove_k(first_row_output_reaction);
first_row_output_reaction=Change_Mass_H20_For_Water(first_row_output_reaction);
first_row_output_reaction=Change_chargeEq_For_cb(first_row_output_reaction);
last_row_output_reaction=Selected_Output_Array(end,1:end);
L=length(List_Id);
Element_Ini_Values=zeros (1, L);
for i=1:L
    for j=1:length(first_row_output_reaction)
        if strcmpi(List_Id{1,i},first_row_output_reaction{1,j})
            Element_Ini_Values(1,i)=last_row_output_reaction{1,j};
        end
    end
end

end

