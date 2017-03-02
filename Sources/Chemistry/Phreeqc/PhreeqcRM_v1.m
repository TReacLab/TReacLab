% This class is based and works with PhreeqcRM, it is subject to new
% versions and changes.

% This version of class is defined as Serial, hence no Parallel
% optimization or work has been taken into account.

% This version does not take into account the UZsolids methods of
% PhreeqcRM, also the Rebalance (mixings)

% This version does not use multicomponent-diffusion, therefore it does not
% work with species, but with components

% It will assume that all the values of Time, or time step or related to
% time will have seconds as unit.

% Output message to the screen, log, and output file are not taken into
% account since, it is difficult already to asses its usefulnes.

classdef PhreeqcRM_v1 < Solve_Engine
    properties
        id_PhrRM_Inst           % Id	of the PhreeqcRM instance
        components              % Components
        headselout              % Head Selected Output
        varstatestruct          % Structure for variable states
        porSatRVstruct          % Porosity, representative volume, saturation
        othersstruct
        nxyz                    % number cells
        number_components
        number_columnsSelOut
    end
    methods
        function this = PhreeqcRM_v1 (Parameters, InitialData)
            % Parameter = { database, txt,nxyz,sunits, logoutstruct, PorSatRVstruct, varstatestruct ,Othersstruct}
            database = Parameters{1};
            PhreeqcFile = Parameters {2};
            nxyz = Parameters{3};
            unitsstruct = Parameters{4};
            logoutstruct = Parameters{5};
            PorSatRVstruct = Parameters{6};
            Varstatestruct = Parameters{7};
            Othersstruct = Parameters{8};
            this.nxyz = nxyz;
            %
            this.porSatRVstruct = PorSatRVstruct;
            this.varstatestruct = Varstatestruct;
            this.othersstruct = Othersstruct;
            % is the "PhreeqcRM" library loaded?
            if ~libisloaded('PhreeqcRMd')
                loadlibrary('PhreeqcRMd.dll','RM_interface_C.h')
            end
            %Create_RM
            nthreads = 1;                                                                               % This version is serial, hence nthreads = 1
            this.id_PhrRM_Inst = lib.PhreeqcRMd.RM_Create(nxyz,nthreads);   
            % Set Initial Parameters
            status = lib.PhreeqcRMd.RM_SetErrorHandlerMode(this.id_PhrRM_Inst, 0);                      % Sets Error Handle (So far not modification, maybe later)
            status = lib.PhreeqcRMd.RM_SetSelectedOutputOn(this.id_PhrRM_Inst, 1 );                     % Sets selectedout to 1, enables to retrieve data. 
            this.SetUnits(unitsstruct)                                                                  % Given a structure that contains the units, are created in the function SetUnits
            status = lib.PhreeqcRMd.RM_SetTime(this.id_PhrRM_Inst, 0 );                                 % Initial time 0
            status = lib.PhreeqcRMd.RM_SetTimeStep (this.id_PhrRM_Inst, 0 );                            % Initial time step 0
            this.Log_Output_Files(logoutstruct);                                                        % Files related to Phreeqc Calculations: Output, Log, and Dump files.
            this.SetVolumetricWaterContent(PorSatRVstruct, InitialData, nxyz);                          % Sets initial porosity, saturation and Representative Volume --> Volumetric water content
            this.SetVariableState(Varstatestruct, InitialData);                                         % Sets variable state, basically temperature and pressure
            this.SetOthers (Othersstruct, InitialData)                                                  % Other contains so far density, componentH2O, and which vol/dens use
            
            % load database
            [status, a]= lib.PhreeqcRMd.RM_LoadDatabase(this.id_PhrRM_Inst, database );   
            % Execute cell fils
            [status, cstring]= lib.PhreeqcRMd.RM_RunFile(this.id_PhrRM_Inst,1, 1, 1, PhreeqcFile );   % 1 true, 0 false
            [status] = lib.PhreeqcRMd.RM_RunCells(this.id_PhrRM_Inst);
            
            % Get List Components
            ncomp= lib.PhreeqcRMd.RM_FindComponents(this.id_PhrRM_Inst);
            components = cell(ncomp, 1);
            for i =0:ncomp-1
                [status, components{i+1}] = calllib('PhreeqcRMd', 'RM_GetComponent', this.id_PhrRM_Inst,i,char(ones(1,100)),100);
            end
            this.components = components;
            this.number_components = lib.PhreeqcRMd.RM_FindComponents(this.id_PhrRM_Inst);  
            % Get Header Selected Output
            ColSelOut=lib.PhreeqcRMd.RM_GetSelectedOutputColumnCount(this.id_PhrRM_Inst);
            head=cell(1,ColSelOut);
            for i = 0:ColSelOut-1
                [status, head{i+1}]= calllib('PhreeqcRMd','RM_GetSelectedOutputHeading', this.id_PhrRM_Inst, i, char(ones(1,100)), 100);
            end
            this.headselout = head;
            this.number_columnsSelOut = lib.PhreeqcRMd.RM_GetSelectedOutputColumnCount(this.id_PhrRM_Inst);
        end
        
        
        function out = Time_Stepping(this, parm)
            % par = {Time, dt, A_sol_mod, this.changesstruct };
            %  this.changesstruct = struct('Vec_Por',[],'Vec_Sat', [], 'Vec_Temp', [], 'Vec_Pressure', [], 'Vec_Density', []);
            % time initialization  
            status = lib.PhreeqcRMd.RM_SetTime(this.id_PhrRM_Inst, parm{1} );                                 
            status = lib.PhreeqcRMd.RM_SetTimeStep (this.id_PhrRM_Inst, parm{1} );
           [status, a]= lib.PhreeqcRMd.RM_SetConcentrations (this.id_PhrRM_Inst, parm{3});	
           % Set specials
           str = parm{4};            % Supose to be a structure with the vector for parameters that might change.
           
           if ~isempty(str.Vec_Por)
               [status, a]= lib.PhreeqcRMd.RM_SetPoosity(this.id_PhrRM_Inst, str.Vec_Por );
           end
           if ~isempty(str.Vec_Sat)
               [status, a]= lib.PhreeqcRMd.RM_SetSaturation(this.id_PhrRM_Inst, str.Vec_Sat );
           end
           if ~isempty(str.Vec_Temp)
               [status, a]= lib.PhreeqcRMd.RM_SetTemperature(this.id_PhrRM_Inst, str.Vec_Temp );
           end
           if ~isempty(str.Vec_Pressure)
               [status, a]= lib.PhreeqcRMd.RM_SetPressure(this.id_PhrRM_Inst, str.Vec_Pressure );
           end
           if ~isempty(str.Vec_Density)
               [status, a]= lib.PhreeqcRMd.RM_SetDensity(this.id_PhrRM_Inst, str.Vec_Density);
           end
           
           % Running
           [status] = lib.PhreeqcRMd.RM_RunCells(this.id_PhrRM_Inst);
           
           
           % Get_Arrays Comp
           Array_comp = zeros(this.nxyz, this.number_components);
           [status, Array_comp ] = lib.PhreeqcRMd.RM_GetConcentrations(this.id_PhrRM_Inst,Array_comp);
           
           
           % Get_Array SelectedOutput
           Array_Select0ut = zeros(this.nxyz, this.number_columnsSelOut);
           [status, Array_Select0ut]= lib.PhreeqcRMd.RM_GetSelectedOutput(this.id_PhrRM_Inst, Array_Select0ut); 
           
           % Get Volume, density, saturation
           Vec_Vol = zeros(this.nxyz, 1);
           Vec_Dens = zeros(this.nxyz, 1);
           Vec_Sat = zeros(this.nxyz, 1);
           
           [status, Vec_Sat ] = lib.PhreeqcRMd.RM_GetSaturation(this.id_PhrRM_Inst, Vec_Sat);
           [status, Vec_Vol ] = lib.PhreeqcRMd.RM_GetSolutionVolume(this.id_PhrRM_Inst, Vec_Vol);
           [status, Vec_Dens ] = lib.PhreeqcRMd.RM_GetSolutionVolume(this.id_PhrRM_Inst, Vec_Dens);
           
           %
           out = {Array_comp, Array_Select0ut, Vec_Sat, Vec_Vol, Vec_Dens};
        end
        
        % a structure with UnitSolution, UnitsExchange, ... as fields must
        % be given. The values of these filds are related to the type of
        % units that PhreeqcRM will take into account. To know which values
        % to use go to http://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqcrm/_r_m__interface___c_8h.html#aa7e29faf1269d8bebe916a12cdc0981b
        function SetUnits(this, unitsstrc)
            if ~isempty(unitsstrc.UnitsSolution)
                status = lib.PhreeqcRMd.RM_SetUnitsSolution(this.id_PhrRM_Inst, unitsstrc.UnitsSolution);
            end
            if ~isempty(unitsstrc.UnitsExchange)
                status = lib.PhreeqcRMd.RM_SetUnitsExchange(this.id_PhrRM_Inst, unitsstrc.UnitsExchange);
            end
            if ~isempty(unitsstrc.UnitsGasPhase)
                status = lib.PhreeqcRMd.RM_SetUnitsGasPhase(this.id_PhrRM_Inst, unitsstrc.UnitsGasPhase);
            end
            if ~isempty(unitsstrc.UnitsKinetics)
                status = lib.PhreeqcRMd.RM_SetUnitsKinetics(this.id_PhrRM_Inst, unitsstrc.UnitsKinetics);
            end
            if ~isempty(unitsstrc.UnitsPPassemblage)
                status = lib.PhreeqcRMd.RM_SetUnitsPPassemblage(this.id_PhrRM_Inst, unitsstrc.UnitsPPassemblage);
            end
            if ~isempty(unitsstrc.UnitsSSassemblage)
                status = lib.PhreeqcRMd.RM_SetUnitsSSassemblage(this.id_PhrRM_Inst, unitsstrc.UnitsSSassemblage);
            end
            if ~isempty(unitsstrc.UnitsSurface)
                status = lib.PhreeqcRMd.RM_SetUnitsSurface(this.id_PhrRM_Inst, unitsstrc.UnitsSurface);
            end
        end
        
        % Set the files to output, a struct must be given (logoustruct)
        % with the proper fields (OpenF, Prefix, ...).
        function Log_Output_Files(this, logoutstruct)
            if logoutstruct.OpenF == true
                status = lib.PhreeqcRMd.RM_OpenFiles(this.id_PhrRM_Inst);
                if isempty({logoutstruct.Prefix})
                    [IR_Result, string] = lib.PhreeqcRMd.RM_SetFilePrefix(this.id_PhrRM_Inst,'PhreeqcRM_Simulation');
                else
                    [IR_Result, string] = lib.PhreeqcRMd.RM_SetFilePrefix(this.id_PhrRM_Inst,logoutstruct.Prefix);
                end
                status = lib.PhreeqcRMd.RM_SetPrintChemistryOn(this.id_PhrRM_Inst,1,1,1);	
            end
            if logoutstruct.Dump == true
                if logoutstruct.DumpAppend == true
                    status = lib.PhreeqcRMd.RM_DumpModule(this.id_PhrRM_Inst,1,1);	
                else
                    status = lib.PhreeqcRMd.RM_DumpModule(this.id_PhrRM_Inst,1,0);
                end
            end
        end
        
        % Set the Initial Volumetric Water Content with the values of Por,
        % Sat, RV
        % PorSatRVsctruct.RVname, Porosityname, Saturationname are supossed
        % to be the names (char) of the element in the Data field. If
        % empty, a vector of ones is assigned.
        function SetVolumetricWaterContent(this, PorSatRVstruct, InitialData, nxyz)
            % Setting RV
            if isempty (PorSatRVstruct.RVname)
                [status, a]= lib.PhreeqcRMd.RM_SetRepresentativeVolume(this.id_PhrRM_Inst, ones(nxyz, 1) );
            else
                Vec_RV = InitialData.Get_Vector_Field (PorSatRVstruct.RVname);
                [status, a]= lib.PhreeqcRMd.RM_SetRepresentativeVolume(this.id_PhrRM_Inst, Vec_RV );
            end
            % Setting Porosity
            if isempty (PorSatRVstruct.Porosityname)
                [status, a]= lib.PhreeqcRMd.RM_SetPorosity(this.id_PhrRM_Inst, ones(nxyz, 1) );
            else
                Vec_Por = InitialData.Get_Vector_Field (PorSatRVstruct.Porosityname);
                [status, a]= lib.PhreeqcRMd.RM_SetPorosity(this.id_PhrRM_Inst, Vec_Por );
            end
            % Setting Sat
            if isempty (PorSatRVstruct.Saturationname)
                [status, a]= lib.PhreeqcRMd.RM_SetSaturation(this.id_PhrRM_Inst, ones(nxyz, 1) );
            else
                Vec_Sat = InitialData.Get_Vector_Field (PorSatRVstruct.Saturationname);
                [status, a]= lib.PhreeqcRMd.RM_SetSaturation(this.id_PhrRM_Inst, Vec_Sat );
            end
        end
        % Sets the variable Pressure and Temperature
        function SetVariableState(this, Varstatestruct ,InitialData)
            % Set Temperature
            if ~isempty(Varstatestruct.Temperaturename)
                Vec_T = InitialData.Get_Vector_Field (Varstatestruct.Temperaturename);
                [status, a]= lib.PhreeqcRMd.RM_SetTemperature(this.id_PhrRM_Inst, Vec_T ); 
            end
            % Set Pressure
            if ~isempty(Varstatestruct.Pressurename)
                Vec_P = InitialData.Get_Vector_Field (Varstatestruct.Pressurename);
                [status, a]= lib.PhreeqcRMd.RM_SetPressure(this.id_PhrRM_Inst, Vec_P ); 
            end
        end
        
        function SetOthers (this, Othersstruct, InitialData)
            % Use Density/Volume Phreeqc or Other
            if ~isempty(Othersstruct.UseSolDensVol)
                [status]= lib.PhreeqcRMd.RM_UseSolutionDensityVolume(this.id_PhrRM_Inst, Othersstruct.UseSolDensVol);
            end
            
            % Wheter H2O is a component or not
            if ~isempty(Othersstruct.H2OComponent)
                [status]= lib.PhreeqcRMd.RM_SetComponentH2O(this.id_PhrRM_Inst, Othersstruct.H2OComponent);
            end
            
            % Density
            if ~isempty(Othersstruct.Density)
                Vec_Den = InitialData.Get_Vector_Field (Other.Density);
                [status, a]= lib.PhreeqcRMd.RM_SetDensity(this.id_PhrRM_Inst, Vec_Den ); 
            end
        end
        
        % Get Component list
        function CompList = Get_ListComponents(this)
            CompList = this.components;
        end
        
        % Get SelectedOutputList
        function HeadSelOut = Get_ListSelectOutput (this)
            HeadSelOut = this.headselout;
        end
        
        % Get Variable Structure
        function VariableStateStruct = Get_VariableStateStruct(this)
            VariableStateStruct = this.varstatestruct;
        end
        
        % Get_Porosity_Saturation_RepresentativeVolume
        function PorSatRVstruct = Get_PorSatRVStruct(this)
            PorSatRVstruct = this.porSatRVstruct;
        end
        
        % Get_Porosity_Saturation_RepresentativeVolume
        function Others = Get_OthersStruct(this)
            Others = this.othersstruct;
        end
        
        function cells = Get_NumberCells (this)
            cells = this.nxyz;
        end
 
    end
end