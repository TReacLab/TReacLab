%Author: Etienne BRESCIANI
%Modified: JR de DREUZY (only directories that contain .m files)
%
%Add directories that contain Matlab files in Matlab path
% Write in directory_name the string where your TREACLAB folder is saved.
directory_name = pwd;
base_dir = [directory_name];
% List of all subdirectories
dir_list = genpath(base_dir);
SEP = filesep;
dir_list_key = regexp(dir_list, ';', 'split');

% Add those directories to the matlab path
fprintf('Added directories to the matlab path\n'); 
for i=1:length(dir_list_key)
    files_m = dir([dir_list_key{i} SEP '*.m']); 
    if(length(files_m)>0)
        addpath(dir_list_key{i});
        fprintf('%s\n', dir_list_key{i}); 
    end
end

savepath; 