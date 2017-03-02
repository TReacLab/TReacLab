 function R = Get_Chemical_SourceSink(R, cbeforechem, cafterchem)
C_sol_b=cbeforechem.Get_Desired_Array ('Solution');
C_sol_a=cafterchem.Get_Desired_Array ('Solution');

% Vwc_b=cbeforechem.Get_Vector_Field('volumetricwatercontent');
% Vwc_a=cafterchem.Get_Vector_Field('volumetricwatercontent');


% list identifiers
Li_b = cbeforechem.Get_List_Identifiers;
Li_a = cafterchem.Get_List_Identifiers;

list_sol_b = Li_b.Get_List_Names ('Solution');
list_sol_a = Li_a.Get_List_Names ('Solution');
d=length(list_sol_a);
dR=zeros(length(C_sol_b.Get_Rows),d);
assert(isempty( setxor(list_sol_b, list_sol_a)));
for i=1:d
    C_b=C_sol_b.Get_Vector_Field(list_sol_b{i});
    C_a=C_sol_a.Get_Vector_Field(list_sol_b{i});
%     
%     dR(:, i) = (Vwc_a.*C_a-Vwc_b.*C_b)./(Vwc_b);
   dR(:, i) = (C_a-C_b);
end

R=R+dR;
 end