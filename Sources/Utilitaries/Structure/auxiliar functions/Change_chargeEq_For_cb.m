% given a cell of strings, the function will return the same cell changing
% 'charge(eq)' (if it exists in the cell) for 'cb'.
% E.g.
% {'d' 'charge(eq)'} --> f() --> {'d' 'cb'}

function d=Change_chargeEq_For_cb(First_Row_Output_Reaction)

d=First_Row_Output_Reaction;
ind=find(strcmp(d, 'charge(eq)'));
if ~isempty(ind)
    d{ind}='cb';
end
end