%
% the values of the vector c2 of the precipitation dissolution elements are
% going to be set in c0.
%
% Notice: not implemented for kinetics 

function c0_prima=ChangeSolidValues(c0,c2)
L0=c0.Get_List_Identifiers;
L2=c2.Get_List_Identifiers;
l0_solid=L0.Get_List_Names('PrecipitationDissolution');
l2_solid=L2.Get_List_Names('PrecipitationDissolution');

n_row_0=c0.Get_Rows;
n_row_2=c2.Get_Rows;
% check that the solids are the same for both, there should not be more or
% less elements related to dissolution and precipitation
assert(isempty(setxor(l0_solid, l2_solid)), 'Error: ChangeSolidValues: Elements different.')

% check that the size of arrays is the same
assert(length(n_row_0)==sum(n_row_0==n_row_2), 'Error: ChangeSolidValues: Size of Matrix different.');

c2_solid=c2.Get_Desired_Array ('PrecipitationDissolution');
c2_solid_A=c2_solid.Get_Array;

Li_0=c0.Get_List_Ide;

for i=1:length(l2_solid)
    [b, ~]=ismember(l2_solid{i}, Li_0);
    if b==true
        c0=c0.Update_Array_Element (c2_solid_A(1:end, i), l2_solid{i});
    else
        error('Error: in function : ChangeSolidValues: Ilogic')
    end
end
c0_prima=c0;
end