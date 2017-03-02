%   given two matrices and a weight value, the first matrix is multiplied
%   by the weight value, and the second one by the difference of 

function c_fin=Weight(weight_value, C_Fin_Prima1, C_Fin_Prima2, C1)
assert( weight_value>=0 || weight_value<=1, 'Weight value no correct, it should be between 0 and 1.')
if strcmpi(class(C_Fin_Prima1),'Array_Field') && strcmpi(class(C_Fin_Prima2),'Array_Field')
    C_Fin_Prima1=C_Fin_Prima1.Get_Array;
    C_Fin_Prima2=C_Fin_Prima2.Get_Array;
    Array=(weight_value.*C_Fin_Prima1+(1-weight_value).*C_Fin_Prima2);
    c_fin=Array_Field(C1.Get_List_Identifiers, Array);
else
    c_fin=(weight_value.*C_Fin_Prima1+(1-weight_value).*C_Fin_Prima2);
end
end