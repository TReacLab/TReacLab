% given a cell of strings, the function will remove the three first letters
% of a string containing 'k_'
% E.g.
% {'d' 'k_Dolomite' 'D_k_react'} --> f() --> {'d' 'Dolomite' 'k_react'}

function d=Remove_k( First_Row_Output_Reaction)
L=length(First_Row_Output_Reaction);
d=cell(1,L);
for i=1:L
    z=strfind(First_Row_Output_Reaction{1,i},'k_');
    if (~isempty(z))
        d{1,i}=First_Row_Output_Reaction{1,i}(3:end);
    else
        d{1,i}=First_Row_Output_Reaction{1,i};
    end
end
end