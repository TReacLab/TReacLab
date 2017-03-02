%   it sums up u_1 and u_2 and takes away c1, given as output the
%   result. It is the last step from additive method, where the
%   output of Process 1 and 2 are sump up and the intial input
%   concentrations is taken away.

function c_fin=Difference (U_1, U_2, C1)
if strcmpi(class(U_1),'Array_Field') && strcmpi(class(U_2),'Array_Field') && strcmpi(class(C1),'Array_Field')
    u_1_prima=U_1.Get_Array;
    u_2_prima=U_2.Get_Array;
    c1_prima=C1.Get_Array;
    Array=u_1_prima+u_2_prima-c1_prima;
    c_fin=Array_Field(C1.Get_List_Identifiers, Array);
else
    c_fin=U_1+U_2-C1;
end
end