classdef Interface_PhreeqcRM_v1 < Interface 
    properties
        ListComponentsRM
        ListSelectedOutputRM
        variablestatestruct
        porSatRVstruct
        othersstruct
        changesstruct
        prev_data
        nxyz
    end
    methods
        
        % Constructor
        function this = Interface_PhreeqcRM_v1 (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
            this.ListComponentsRM = this.solve_engine.Get_ListComponents();
            this.ListSelectedOutputRM = this.solve_engine.Get_ListSelectOutput ();
            this.variablestatestruct = this.solve_engine.Get_VariableStateStruct ();
            this.porSatRVstruct = this.solve_engine.Get_PorSatRVStruct;
            this.othersstruct = this.solve_engine.Get_OthersStruct;
            this.nxyz =  this.solve_engine.Get_NumberCells;
            % for changes
            Changes_struct = struct('Vec_Por',[],'Vec_Sat', [], 'Vec_Temp', [], 'Vec_Pressure', [], 'Vec_Density', []);
            this.changesstruct = Changes_struct;
        end
        
        
        function Data = Time_Stepping (this, Data, Time, varargin) 
            parm = Coupler2SolveEngine (this, Data, Time);
            out  = this.solve_engine.Time_Stepping(parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm= Coupler2SolveEngine (this, Data, Time)
            this.prev_data = Data;
            % time
            Time=Time.Get_Time_Interval;
            dt = Time/20;
            
            % Concentrations
            A_Sol_Class=Data.Get_Desired_Array('Solution');
            li = Data.Get_List_Identifiers;
            A_Sol = A_Sol_Class.Get_Array;
            A_sol_mod = A_Sol;
            Lsol= li.Get_List_Names ('Solution');
            for i = 1: length(this.ListComponentsRM)
                b_ind=strcmpi(this.ListComponentsRM{i}, Lsol);
                integerIndex = find(b_ind);
                if ~isempty(integerIndex)
                    A_sol_mod(:, i) = A_Sol(:, integerIndex);
                else
                    error('You muest include %s in the List Identifiers', string)
                end
            end
            
            % Saturation and Porosity
            if this.porSatRVstruct.Pchange == true
                Vec_Por = InitialData.Get_Vector_Field (this.varstatestruct.Porosityname);
                this.changesstruct.Vec_Por = Vec_Por;
            end
            if this.porSatRVstruct.Schange == true
                Vec_Sat = InitialData.Get_Vector_Field (this.varstatestruct.Saturationname);
                this.changesstruct.Vec_Sat = Vec_Sat;
            end
            
            % Temperature and Pressure
            if this.variablestatestruct.Tchange == true
                Vec_Temp = InitialData.Get_Vector_Field (this.varstatestruct.Temperaturename);
                this.changesstruct.Vec_Temp = Vec_Temp;
            end
            if this.variablestatestruct.Pchange == true
                Vec_Pressure = InitialData.Get_Vector_Field (this.varstatestruct.Pressurename);
                this.changesstruct.Vec_Pressure = Vec_Pressure;
            end
            
            % density
            if this.othersstruct.Dchange == true
                Vec_Density = InitialData.Get_Vector_Field (this.varstatestruct.Density);
                this.changesstruct.Vec_Density = Vec_Density;
            end
            
            parm = {Time, dt, A_sol_mod, this.changesstruct };
        end
        
        function Data = SolveEngine2Coupler (this, out)
            % out = {Array_comp, Array_Select0ut, Vec_Sat, Vec_Vol, Vec_Dens};
            Array_Comp = out{1};
            Array_Select0ut = out{2};
            Vec_Sat = out{3};
            Vec_Vol = out{4};
            Vec_Dens = out{5};
            
            %
            List_Identifiers = this.prev_data.Get_List_Identifiers;
            Li = List_Identifiers.Get_List_Id;
            % Create empty Array to assgin values of simulation
            Array = zeros(this.nxyz, length(Li));
            
            % Add components to the Array
            for i = 1:length(this.ListComponentsRM)
                b_ind=strcmpi(this.ListComponentsRM{i},Li);
                integerIndex = find(b_ind);
                if ~isempty(integerIndex)
                    Array(:, integerIndex) = Array_Comp(:,i);
                else
                    fprintf('[Create_Array_Field_From_PhreeqcRM_File] Phreeqc gives you the component %s which you have not defined in your ListIdentifier class.\n',this.ListComponentsRM{i});
                end
            end
            
            % Now that the components have been introduced into the Array the other elements must also be added
            % remove components from the list identifiers 
            % this.ListSelectedOutputRM
            for i = 1:length(this.ListSelectedOutputRM)
                b_ind=strcmpi(this.ListSelectedOutputRM{i}, this.ListComponentsRM);
                integerIndex = find(b_ind);
                if isempty(integerIndex)
                    b_ind=strcmpi(this.ListSelectedOutputRM{i},Li);
                    integerIndex = find(b_ind);
                    if ~isempty(integerIndex)
                        Array(:, integerIndex) = Array_Select0ut(:,i);
                    end
                end
            end
            
            % It will assume that Saturation, Volume and Density have the
            % following name in the main Data given: liquid_saturation,
            % volumetricwatercontent and dens;
            Array = PropertyChanged(this, 'dens', Li,Vec_Dens,Array);
            Array = PropertyChanged(this, 'liquid_saturation', Li,Vec_Sat,Array);
            Array = PropertyChanged(this, 'volumetricwatercontent', Li,Vec_Vol,Array);
            Array = PropertyChanged(this, 'RV', Li,Vec_Sat,Array);
            Array = PropertyChanged(this, 'porosity', Li,Vec_Vol,Array);

            
            Data = Array_Field(List_Identifiers, Array);
        end
        
        function Array = PropertyChanged(this, string, list,Vec,Array)
            b_ind=strcmpi(string,list);
            integerIndex = find(b_ind);
            if ~isempty(integerIndex)
                if ~all( Array(:, integerIndex) == Vec)
                    Array(:, integerIndex) = Vec;
                end
            else
                fprintf('[Interface_PhreeqcRM_v1] %s not found', string);
            end
        end
        
    end
end