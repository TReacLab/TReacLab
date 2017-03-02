% The given file (FileToRun) must be like a transport problem in Phreeqc. It must
% contain at least one iPhreeqc block.

% The function returns a result class where all the time step values saved
% in the time array and its corresponding Array_Field class.

function Results_Ref = PhreeqcTransport_Direct (Database, FileToRun, List_Identifiers_Class)

% iphreeqc class
iphreeqc=actxserver('IPhreeqcCOM.Object');
iphreeqc.LoadDatabase(Database);
iphreeqc.OutputFileOn = true;
% Not necesary
iphreeqc.ClearAccumulatedLines();
%
[timestep, finaltime, numbercells] = Get_TimeStepFinalTimeNumberCells (FileToRun);


% read file
frs = fileread(FileToRun);
% run file
iphreeqc.RunString(frs);

% 
A_Cell_Output = iphreeqc.GetSelectedOutputArray;
Vector_Time=(0:timestep:finaltime)';
d=length(Vector_Time);

Vector_Fields=Create_Vector_Field(A_Cell_Output , d, List_Identifiers_Class, numbercells);
% Results
Results_Ref = Results_1D (Vector_Fields, Vector_Time);

end

% The function returns the timestep, final time and number of cells from
% the given string (FileToRun). The strings correspond to the name of a
% txt. file which should have a Phreeqc (Transport) format.

function [timestep, finaltime, numbercells] = Get_TimeStepFinalTimeNumberCells (FileToRun)
A=readingandpreparing(FileToRun);
l=identifyingblocks(A);
for i=1:length(l)
    if strcmpi(A{l{i}{1}}{1}, 'TRANSPORT')
        for j=l{i}{1}:1:l{i}{2}
            if strcmpi(A{j}{1}, '-cells')
                numbercells=str2num(A{j}{2});
            elseif strcmpi(A{j}{1}, '-shifts')
                shifts=str2num(A{j}{2});
            elseif strcmpi(A{j}{1}, '-time_step')
                timestep=str2num(A{j}{2});
            end
        end
    end
end
finaltime = shifts*timestep;

assert (~isempty(timestep) || ~isempty(finaltime) || ~isempty(numbercells), '[PhreeqcTransport_Direct/Get_TimeStepFinalTimeNumberCells]');
end

% It returns a cell of Array_Field class for every time step of the
% simulation.

function Vector_Fields = Create_Vector_Field( CellOut, length_time,List_Identifiers_Class, N_cells)
Vector_Fields = cell( length_time, 1);
% cell with names
cell_list_id = List_Identifiers_Class.Get_List_Id;


% first row

first_row_output_reaction=CellOut(1, 1:end);
first_row_output_reaction=Remove_MOLKGW_String(first_row_output_reaction);
first_row_output_reaction=Remove_k(first_row_output_reaction);
first_row_output_reaction=Change_Mass_H20_For_Water(first_row_output_reaction);
first_row_output_reaction=Change_chargeEq_For_cb(first_row_output_reaction);
cellouttemp=cell(1);
% tempcell.
for i = 1:length(cell_list_id)
    [b, ind] = ismember (cell_list_id(i), first_row_output_reaction);
    if b && isempty(cellouttemp{1})
        cellouttemp = CellOut(:,ind);
    elseif b
        cellouttemp=[cellouttemp CellOut(:,ind)];
    else
        cell_dummy=num2cell(ones(size(cellouttemp,1),1));
        cell_dummy{1}=cell_list_id(i);
        cellouttemp=[cellouttemp cell_dummy];
    end
end
%deleteunimportant
cellouttemp=cellouttemp(end-(length_time*N_cells)+1:end, :);

for i=1:length_time
    Array=cell2mat(cellouttemp((1+(N_cells*(i-1))):(N_cells*i),:));
%     for j=1:length(ll)
%         if ll(j)==1
%             Array(1:end,j)=(Array(1:end,j).*Array(1:end,indexwater))./Array(1:end,indexsolvol);
%         end
%     end
    CC=Array_Field(List_Identifiers_Class, Array);
    CC=CC.InitializationRV_mol_litre_afterPhreeqcCalculation_Noporchange;
    Vector_Fields {i} = CC;
end


end