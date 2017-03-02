% The function run a iphreeqc Com server object given the string of the
% database and the string of a txt. The number of nodes (= n_rows) must be
% inputed as well as a List_Identifiers class and the matrix of
% array_hydraulic_properties, since the hydraulic properties elements are
% not withdrawn from Phreeqc. (liquid saturation is drawn from Phreeqc
% using solution volume divided by the porosity)

function C = Create_Array_Field_From_Phreeqc_File (database,txt, n_rows, List_Identifiers, array_hydraulic_properties)


% Ini iPhreeqc
iphreeqc=actxserver('IPhreeqcCOM.Object');

iphreeqc.OutputFileOn = true;
iphreeqc.LoadDatabase(database);
iphreeqc.RunFile(txt);

outputArray = iphreeqc.GetSelectedOutputArray();
l=List_Identifiers.Get_List_Id;

vector_out_T=Get_Ini_val_HOcb( l, outputArray);

% adding values to hydraulic properties
l_h=List_Identifiers.Get_List_Names ('HydraulicProperty');
d=length(l_h);
[~, c]=size(array_hydraulic_properties);
assert(c==d, '[Create_Array_Field_From_Phreeqc_File_vers2] The columns of hydraulic properties (hp) does not match the list of hp.');
for i=1:d
    [b, ind]=ismember(l_h{i}, l);
    if b==1
        vector_out_T(:, ind)=array_hydraulic_properties(:, i);
    else
        fprintf('[Create_Array_Field_From_Phreeqc_File_vers2] Hydraulic property not found in list!! \n');
    end
end

Array = repmat(vector_out_T, n_rows, 1);
C = Array_Field(List_Identifiers, Array);
% change of units
C=InitializationRV_mol_litre_afterPhreeqcCalculation_Noporchange(C);
end