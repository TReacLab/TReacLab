% The function create a List_identifiers with all the properties of the
% class fill. 
% Setting the user free of the tedious time consuming tasks of adding all
% the list in the code.
% The text should look as:
%
% list_solution_elements: cb H O H2O C Ca
% list_precipitation_dissolution_elements: Calcite Portlandite
% list_gaseous_elements: CO2(g)
% list_ionexchange_elements:
% list_kineticreactants_elements:
% list_hydraulic_properties: porosity liquid_saturation RV volumetricwatercontent
% list_data_chem: dens vol_sol pe pH water Alk(eq/kgw) C(-4) C(4) H(0) O(0) d_Calcite d_Portlandite d_CO2(g)
%
%

function Li = Create_List_Identifier_Class_From_Text (textstring)
fid=fopen(textstring);
tline = fgetl(fid);
A={};
List_Id={};
i=1;
while ischar(tline)
    A{i,1}=tline;
    tline = fgetl(fid);
    i=i+1;
end
d=length(A);
for i=1:d
    r=strsplit(A{i},{' ' '\t' '\f' '\b'});
    List_Id=[List_Id r{2:end}];
    r=r(~cellfun('isempty',r));
    if strcmpi(r{1}, 'list_solution_elements:')
        assert(i==1, '[Create_List_Identifier_Class_From_Text]')
        d_s=length(r)-1;
    elseif strcmpi(r{1}, 'list_precipitation_dissolution_elements:') 
        assert(i==2, '[Create_List_Identifier_Class_From_Text]')
        d_p=length(r)-1;
    elseif strcmpi(r{1}, 'list_gaseous_elements:')
        assert(i==3, '[Create_List_Identifier_Class_From_Text]')
        d_g=length(r)-1;
    elseif strcmpi(r{1}, 'list_ionexchange_elements:')
        assert(i==4, '[Create_List_Identifier_Class_From_Text]')
        d_i=length(r)-1;
    elseif strcmpi(r{1}, 'list_kineticreactants_elements:')
        assert(i==5, '[Create_List_Identifier_Class_From_Text]')
        d_k=length(r)-1;
    elseif strcmpi(r{1}, 'list_hydraulic_properties:')
        assert(i==6, '[Create_List_Identifier_Class_From_Text]')
        d_h=length(r)-1;
    elseif strcmpi(r{1}, 'list_data_chem:')
        assert(i==7, '[Create_List_Identifier_Class_From_Text]')
        d_d=length(r)-1;
    end
end

status = fclose('all');
assert(status==0, 'Readingandpreparing function failed')
%
l_s_e = [ones(1, d_s) zeros(1, d_p) zeros(1, d_g) zeros(1, d_i) zeros(1, d_k) zeros(1, d_h) zeros(1, d_d)];
l_p_d_e = [zeros(1, d_s) ones(1, d_p) zeros(1, d_g) zeros(1, d_i) zeros(1, d_k) zeros(1, d_h) zeros(1, d_d)];
l_g_e = [zeros(1, d_s) zeros(1, d_p) ones(1, d_g) zeros(1, d_i) zeros(1, d_k) zeros(1, d_h) zeros(1, d_d)];
l_i_e = [zeros(1, d_s) zeros(1, d_p) zeros(1, d_g) ones(1, d_i) zeros(1, d_k) zeros(1, d_h) zeros(1, d_d)];
l_k_e = [zeros(1, d_s) zeros(1, d_p) zeros(1, d_g) zeros(1, d_i) ones(1, d_k) zeros(1, d_h) zeros(1, d_d)];
l_h_p = [zeros(1, d_s) zeros(1, d_p) zeros(1, d_g) zeros(1, d_i) zeros(1, d_k) ones(1, d_h) zeros(1, d_d)];
l_d = [zeros(1, d_s) zeros(1, d_p) zeros(1, d_g) zeros(1, d_i) zeros(1, d_k) zeros(1, d_h) ones(1, d_d)];
%
Li=List_Identifiers (List_Id);
Li=Li.Add_List(l_s_e, 'Solution');
Li=Li.Add_List(l_p_d_e, 'PrecipitationDissolution');
Li=Li.Add_List(l_g_e, 'Gas');
Li=Li.Add_List(l_i_e, 'Ion_Exchange');
Li=Li.Add_List(l_k_e, 'Kinetics');
Li=Li.Add_List(l_h_p, 'HydraulicProperty');
Li=Li.Add_List(l_d, 'Data_Chem');
end