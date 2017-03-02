% given a cell of strings, the function will return the same cell changing
% 'mass_H2O' (if it exists in the cell) for 'water'.
% E.g.
% {'d' 'mass_H2O'} --> f() --> {'d' 'water'}

function d=Change_Mass_H20_For_Water(First_Row_Output_Reaction)
            d=First_Row_Output_Reaction;
            ind=find(strcmp(d, 'mass_H2O'));
            if ~isempty(ind)
                d{ind}='water';
            end
end