%   it substitutes '(x)' for '_x' inside every string contained by
%   the cell. 
%   This function was created due to the fact that the
%   characters '(x)', inside a variable, in Comsol are not allowed.
%   For instance, 'CO2(g)' is a forbidden variable name, but
%   'CO2_g' is allowed.


function list_ele=Working_Element_List_1( List_Elements_Transport)
d=length(List_Elements_Transport);
list_ele=cell(1,d);
for i=1:length(List_Elements_Transport)
    % For gas --> (g)
    list_ele{i}=strrep(List_Elements_Transport{i}, '(g)', '_g');
    % For element with difference valence states such as C(4) C(-4) etc
    b=strfind(list_ele{i}, '(');
    lengthstring=length(list_ele{i});
    if ~isempty(b)
        % neutral or positive (Even if positive if will be written as neutral)
        if lengthstring-b == 2
            list_ele{i}=strcat(List_Elements_Transport{i}(1:b-1),'_neu', List_Elements_Transport{i}(b+1));
        else
         % negative or positive   
            if strcmpi(List_Elements_Transport{i}(b+1), '+')
                list_ele{i}=strcat(List_Elements_Transport{i}(1:b-1),'_pos', List_Elements_Transport{i}(b+2));
            else
                list_ele{i}=strcat(List_Elements_Transport{i}(1:b-1),'_neg', List_Elements_Transport{i}(b+2));
            end
        end
    end
end
end