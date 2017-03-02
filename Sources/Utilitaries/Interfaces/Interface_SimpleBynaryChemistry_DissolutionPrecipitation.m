classdef Interface_SimpleBynaryChemistry_DissolutionPrecipitation < Interface 
    properties
        data
    end
    methods
        function this = Interface_SimpleBynaryChemistry_DissolutionPrecipitation (Solve_Engine ,varargin)
            this = this@Interface(Solve_Engine ,varargin); 
        end
        
        function Data = Time_Stepping (this, Data, Time, varargin)  
            parm = Coupler2SolveEngine(this, Data, Time, varargin);
            out  = this.solve_engine.Time_Stepping (parm);
            Data = SolveEngine2Coupler (this, out);
        end
        
        function parm = Coupler2SolveEngine (this, Data, Time, varargin)
            name_solute_one = this.solve_engine.Get_Name_Solute_One;
            name_solute_two = this.solve_engine.Get_Name_Solute_Two;
            name_mineral    = this.solve_engine.Get_Name_Mineral;
            
            old_value_Solute_One=Data.Get_Vector_Field (name_solute_one);
            old_value_Solute_Two=Data.Get_Vector_Field (name_solute_two);
            old_value_Mineral=Data.Get_Vector_Field (name_mineral);
            
            this.data = Data;
            
            lng = length(old_value_Solute_One);
            
            parm = {old_value_Solute_One, old_value_Solute_Two, old_value_Mineral, lng};
        end
        
        function Data = SolveEngine2Coupler (this, out)
            new_value_Solute_One = out{1};
            new_value_Solute_Two = out{2};
            new_value_Mineral    = out{3};
            
            name_solute_one = this.solve_engine.Get_Name_Solute_One;
            name_solute_two = this.solve_engine.Get_Name_Solute_Two;
            name_mineral    = this.solve_engine.Get_Name_Mineral;
            
            Data=this.data.Update_Array_Element ( new_value_Solute_One, name_solute_one);
            Data=Data.Update_Array_Element ( new_value_Solute_Two, name_solute_two);
            Data=Data.Update_Array_Element ( new_value_Mineral, name_mineral);

        end
    end
end

