% This class acts as an interface for saturated transport process, it makes
% some required data processing. 

classdef Process_Transport < Solve_Engine
    
    properties
        solve_engine  % The transport process that will be used, for instance TransportSolver_SNIA_Expl
        comsol_case   % look at the solve engine creator
    end
    
    methods
        
        % Constructor. 
        
        function this=Process_Transport (Solve_Engine, varargin)
            this.solve_engine=Solve_Engine;
            if length(varargin)== 0
                this.comsol_case=false;
            else
                this.comsol_case=true;
            end
        end
         
        %   Time_Stepping. It solves the transport equation one time step.

        function c2 = Time_Stepping (this, C1,Time,  varargin)
            C_transp=this.Preprocessing(C1);
            C_transp=this.solve_engine.Time_Stepping(C_transp, Time,  varargin);
            c2=this.Postprocessing (C_transp, C1);
        end

        % given an Array_Field the function returns a new Array_Field
        % containing only the elements within the solution. Moreover, The
        % total H and O becomes just the excess of O and H in the solution.
        % That means total H - 2* total H2O and total O - total H2O.
        
        function C_divide = Preprocessing (this, C1)
            % this matrix will dependend on the solve engine solved
            % therefore a new function will be writen.
            C=C1.Get_Desired_Array ('Solution');
            %
            C=C.SumDiff_Array ('H', 'H2O', '-');
            C=C.SumDiff_Array ('H', 'H2O', '-');
            C=C.SumDiff_Array ('O', 'H2O', '-');
            
            % This part maybe will be removed.
            if this.comsol_case ==false
                C2=C1.Get_Desired_Array ('HydraulicProperty');
                C_divide =C.Append_New_Element(C2);
            else
                C_divide =C;
            end
        end

        %   This method updates the values related to transport of the
        %   given initial concentration, with values taken from a
        %   Array_Field array which has undergone a transport process
        %   during either one time step or interval of time.

        function C_merge = Postprocessing (this, C_Transp, C_Transp_React)
            complet_list=C_Transp_React.Get_List_Identifiers;
            transp_ele=C_Transp.Get_List_Identifiers.Get_List_Id;
            array_temp=C_Transp_React.Get_Array;
            array_temp_transp=C_Transp.Get_Array;
            for i=1:size(transp_ele,2)
                [b,v]=ismember(transp_ele{1,i},complet_list.Get_List_Id);
                %                 if b==true && strcmpi ('pH',transp_ele{1,i})
                %                     arr=-log10(array_temp_transp(1:end,i));
                %                     array_temp(1:end,v)=array_temp_transp(1:end,i);
                if b==true
                    array_temp(1:end,v)=array_temp_transp(1:end,i);
                end
            end
            C_merge=Array_Field(complet_list, array_temp);
            C=C_merge.SumDiff_Array ('H', 'H2O', '+');
            C=C.SumDiff_Array ('H', 'H2O', '+');
            C_merge=C.SumDiff_Array ('O', 'H2O', '+');
        end

    end
end