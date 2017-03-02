% The function creates an Array_Field class from two .txt files
%
% The first txt contains the classification and list of elements.
% The classification and list look like(in the following order):
%                   1) list_solution_elements:  Ca Na Pb
%                   2) list_precipitation_dissolution_elements: Calcite 
%                   3) list_gaseous_elements: CO2
%                   4) list_ionexchange_elements:
%                   5) list_kineticreactants_elements: Quartz
%                   6) list_hydraulic_properties: porosity REV Saturation
%                   7) list_data_chem: NaX pH pe etc
%
% The third text contains the whole array if type heterogeneous or just
% the first row of the array and the number of rows if homogeneous.
% Heterogeneous and homogeneous mean, here, the number of values.
%
% if type_text2 is 'heterogeneous' it is an array directly, if it is
% 'homogeneous', we talk about the first row and a number that indicate the
% how many equal rows exist in order to create the main array.

function C = Create_Array_Field_Txt (txt1, txt2, type_text2)
List_Identifiers = Create_List_Identifier_Class_From_Text (txt1);
Array = Work_txt2 (txt2,  type_text2);
C = Array_Field(List_Identifiers, Array);
end

function Array = Work_txt2 (txt2, type_text2)

if strcmpi(type_text2, 'heterogeneous')
Array = dlmread(txt2);
elseif strcmpi(type_text2, 'homogeneous')
    fileID = fopen(txt2);
    tline = fgetl(fileID);
A={};
i=1;
while ischar(tline)
    A{i,1}=tline;
    tline = fgetl(fileID);
    i=i+1;
end
Vector = str2double(strsplit(A{1, 1},{' ' '\t' '\f' '\b'}));
Array = repmat( Vector,  str2num(A{2,1}), 1); 
fclose(fileID);
else
    error('[Create_Array_Field_Txt] ');
end
end
