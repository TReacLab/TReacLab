% The function run a PhreeqcRMd library given the string of the
% database and the string of a txt or pqi. The number of cells must be
% inputed as well as a List_Identifiers class and the matrix of
% array_hydraulic_properties, since the hydraulic properties elements are
% not withdrawn from Phreeqc. (liquid saturation is drawn from Phreeqc
% using solution volume divided by the porosity)

function C = Create_Array_Field_From_PhreeqcRM_File (database,txt, nxyz, nthreads, b_transportwater,List_Identifiers, porosity, RV, saturation, b_Printoutput,unitsstrc)
% is the "PhreeqcRM" library loaded? 
if ~libisloaded('PhreeqcRMd')
    loadlibrary('PhreeqcRMd.dll','RM_interface_C.h')
end

id_PhreeqcRM_Instance = lib.PhreeqcRMd.RM_Create(nxyz,nthreads);
status = lib.PhreeqcRMd.RM_SetErrorHandlerMode	(id_PhreeqcRM_Instance, 1);

%% Set
% Temperature, pressure and density are set into the PhreeqFile
[IR_Result, a]= lib.PhreeqcRMd.RM_SetSaturation(id_PhreeqcRM_Instance, saturation );    
[IR_Result, a]= lib.PhreeqcRMd.RM_SetPorosity(id_PhreeqcRM_Instance, porosity );   
[IR_Result, a]= lib.PhreeqcRMd.RM_SetRepresentativeVolume(id_PhreeqcRM_Instance, RV );  
if b_transportwater == true
    IR_Result = lib.PhreeqcRMd.RM_SetComponentH2O(id_PhreeqcRM_Instance, 1); 
else
    IR_Result = lib.PhreeqcRMd.RM_SetComponentH2O(id_PhreeqcRM_Instance, 0);     
end
[IR_Result]= lib.PhreeqcRMd.RM_SetSelectedOutputOn(id_PhreeqcRM_Instance, 1 ); 

% Time, the function is inteded to get initial values. Therefore, Time is
% 0.
[IR_Result]= lib.PhreeqcRMd.RM_SetTime(id_PhreeqcRM_Instance, 0 ); 
[IR_Result]= lib.PhreeqcRMd.RM_SetTimeStep (id_PhreeqcRM_Instance, 0 ); 


% Set Units
%s = struct('UnitsSolution',{},'UnitsExchange',{},'UnitsGasPhase',{},'UnitsKinetics',{},'UnitsPPassemblage',{},'UnitsSSassemblage',{},'UnitsSurface',{});
if ~isempty(unitsstrc.UnitsSolution)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsSolution(id_PhreeqcRM_Instance, unitsstrc.UnitsSolution);
end
if ~isempty(unitsstrc.UnitsExchange)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsExchange(id_PhreeqcRM_Instance, unitsstrc.UnitsExchange);
end
if ~isempty(unitsstrc.UnitsGasPhase)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsGasPhase(id_PhreeqcRM_Instance, unitsstrc.UnitsGasPhase);
end
if ~isempty(unitsstrc.UnitsKinetics)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsKinetics(id_PhreeqcRM_Instance, unitsstrc.UnitsKinetics);
end
if ~isempty(unitsstrc.UnitsPPassemblage)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsPPassemblage(id_PhreeqcRM_Instance, unitsstrc.UnitsPPassemblage);
end
if ~isempty(unitsstrc.UnitsSSassemblage)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsSSassemblage(id_PhreeqcRM_Instance, unitsstrc.UnitsSSassemblage);
end
if ~isempty(unitsstrc.UnitsSurface)
    [IR_Result]= lib.PhreeqcRMd.RM_SetUnitsSurface(id_PhreeqcRM_Instance, unitsstrc.UnitsSurface);
end


% Printing_output

if b_Printoutput == true
    [IR_Result, string] =lib.PhreeqcRMd.RM_SetFilePrefix(id_PhreeqcRM_Instance,'IC');
    IR_Result = lib.PhreeqcRMd.RM_OpenFiles(id_PhreeqcRM_Instance);
    IR_Result = lib.PhreeqcRMd.RM_SetPrintChemistryMask(id_PhreeqcRM_Instance, 1);
    IR_Result = lib.PhreeqcRMd.RM_SetPrintChemistryOn(id_PhreeqcRM_Instance,1,1,1);	
end



% Set database
[IR_Result, a]= lib.PhreeqcRMd.RM_LoadDatabase(id_PhreeqcRM_Instance, database );    
% Run File
[IR_Result, cstring]= lib.PhreeqcRMd.RM_RunFile(id_PhreeqcRM_Instance,1, 1, 0, txt );   % 1 true, 0 false
[IR_Result] = lib.PhreeqcRMd.RM_RunCells(id_PhreeqcRM_Instance);


ncomp= lib.PhreeqcRMd.RM_FindComponents(id_PhreeqcRM_Instance );  
Array_Comp=zeros(nxyz, ncomp); % ncells, ncomponents

[IR_Result, Array_Comp ] = lib.PhreeqcRMd.RM_GetConcentrations(id_PhreeqcRM_Instance,Array_Comp);

List_Component = cell(1,ncomp);
for i = 0: ncomp-1
[status, List_Component{i+1}] = calllib('PhreeqcRMd', 'RM_GetComponent',id_PhreeqcRM_Instance,i,char(ones(1,100)),100);
end

ColSelOut=lib.PhreeqcRMd.RM_GetSelectedOutputColumnCount(id_PhreeqcRM_Instance);
Array_Select_Outp = zeros(nxyz, ColSelOut);

[IR_Result, Array_Select_Outp]= lib.PhreeqcRMd.RM_GetSelectedOutput(id_PhreeqcRM_Instance, Array_Select_Outp); 

HeadSelOut=cell(1,ColSelOut);

for i = 0:ColSelOut-1
        [IR_Result, HeadSelOut{i+1}]= calllib('PhreeqcRMd','RM_GetSelectedOutputHeading',id_PhreeqcRM_Instance, i, char(ones(1,100)), 100);  
end

% Saturation and Water Volume
Vec_Sat = zeros(nxyz, 1);
[IR_Result, Vec_Sat ] = lib.PhreeqcRMd.RM_GetSaturation(id_PhreeqcRM_Instance, Vec_Sat);
Vec_volume = zeros(nxyz, 1); 
[IR_Result, Vec_volume ] = lib.PhreeqcRMd.RM_GetSolutionVolume(id_PhreeqcRM_Instance, Vec_volume);

% Printing_output
if b_Printoutput == true
    [IR_Result] = lib.PhreeqcRMd.RM_CloseFiles(id_PhreeqcRM_Instance); 
end

Li = List_Identifiers.Get_List_Id;

Array = Create_Array(Li,List_Component,Array_Comp,HeadSelOut, Array_Select_Outp, nxyz, porosity, RV, Vec_volume, Vec_Sat);

C = Array_Field(List_Identifiers, Array);





end



% creating Array for the Data class
function Array = Create_Array(List_Identifiers, List_Component,Array_Comp,HeadSelOut, Array_Select_Outp, nxyz, porosity, RV, Vec_volume, Vec_Sat)

% Check that ArrayComp and Array_Select_Output have the same size and
% is equal to the number of cells
[r_c, c_c] = size(Array_Comp);
[r_so, c_so] = size(Array_Select_Outp);
assert(r_c == r_so & nxyz == r_c,'[Create_Array_Field_From_PhreeqcRM_File] Mismatch between the number of cells, the select output array and the array of components');

% Create empty Array to assgin values of simulation
Array = zeros(nxyz, length(List_Identifiers));

% Add components to the Array
for i = 1:length(List_Component)
    b_ind=strcmpi(List_Component{i},List_Identifiers);
    integerIndex = find(b_ind);
    if ~isempty(integerIndex)
        Array(:, integerIndex) = Array_Comp(:,i);
    else
        error('[Create_Array_Field_From_PhreeqcRM_File] Phreeqc gives you the component %s which you have not defined in your ListIdentifier class',List_Component{i});
    end
end

% Now that the components have been introduced into the Array the other elements must also be added
% remove components from the list identifiers

for i = 1:length(HeadSelOut)
    b_ind=strcmpi(HeadSelOut{i},List_Component);
    integerIndex = find(b_ind);
    if isempty(integerIndex)
        b_ind=strcmpi(HeadSelOut{i},List_Identifiers);
        integerIndex = find(b_ind);
        if ~isempty(integerIndex)
            Array(:, integerIndex) = Array_Select_Outp(:,i);
        else
%             strp = strcat('[Create_Array_Field_From_PhreeqcRM_File] Phreeqc gives you: ',HeadSelOut{i},' which you have not defined in your ListIdentifier class.\n Would you like to stop the running and added it in your List Identifiers or continue? \n [Enter:1 for continue or any other number to stop]');
%             x = input(strp);
%             if x~=1
%                 error();
%             end
        end
    end
end

% Finally saturation, porosity, representative element volume and water volume must be assigned

% porosity 

Array = Array_Assign(Array, 'porosity', porosity, List_Identifiers);
% RV
Array = Array_Assign(Array, 'RV', RV, List_Identifiers);
%liquid_saturation 
Array = Array_Assign(Array, 'liquid_saturation', Vec_Sat, List_Identifiers);
%volumetricwatercontent
Array = Array_Assign(Array, 'volumetricwatercontent', Vec_volume, List_Identifiers);



end



function Array = Array_Assign(Array, string, vec, List_Identifiers)
b_ind=strcmpi(string, List_Identifiers);
integerIndex = find(b_ind);
if ~isempty(integerIndex)
    Array(:, integerIndex) = vec;
else
    error('You muest include %s in the List Identifiers', string)
end
end