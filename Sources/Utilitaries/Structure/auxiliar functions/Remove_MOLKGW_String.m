% given a cell of strings, the function will return the same cell, altough
% (mol/kgw) will have removed from the strings.
% E.g.
% {'d' 'Ca(mol/kgw)' 'Na(mol/kgw)D'} --> f() --> {'d' 'Ca' 'Na'}

function d=Remove_MOLKGW_String( First_Row_Output_Reaction)
L=length(First_Row_Output_Reaction);
d=cell(1,L);
for i=1:L
    z=strfind(First_Row_Output_Reaction{1,i},'(mol/kgw)');
    if (~isempty(z))
        d{1,i}=First_Row_Output_Reaction{1,i}(1:z-1);
    else
        d{1,i}=First_Row_Output_Reaction{1,i};
    end
end
end