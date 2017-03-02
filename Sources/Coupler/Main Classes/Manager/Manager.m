classdef Manager
    properties
        list_equations
        list_solve_engine
    end
    methods
        
        % List_Equations_SolveEngine has the following structure: {{Eq,Method}, ...., {Eq , Method}}
        % It is a cell of cells. Hereby cell means the matlab class.
        % The first position is reserved for Equation class and the second for a string determining the solve engine that will be used.
        
        function this = Manager (List_Equations_SolveEngine)
            this=this.Separate_Equation_SolveEngine(List_Equations_SolveEngine);
        end
        
        % Separates and checks that all the values belong to the
        % corresponding class.

        function this=Separate_Equation_SolveEngine(this, List_Equations_SolveEngine)
            d=length(List_Equations_SolveEngine);
            this.list_equations=cell(1,d);
            this.list_solve_engine=cell(1,d);
            for i=1:d
                equation=List_Equations_SolveEngine{i}{1};
                solve_engine_name=List_Equations_SolveEngine{i}{2};
                assert(isa(equation,'Equation'),'[Manager/Separate_Equation_SolveEngine] Not equation.\n')
                assert(isa(solve_engine_name,'char'),'[Manager/Separate_Equation_SolveEngine] Not string.\n')
                this.Assert_Consistency (equation,solve_engine_name);
                this.list_equations{i}=equation;
                this.list_solve_engine{i}=solve_engine_name;
            end
        end
        
        % Check that the equations can be solved by the given numerical
        % method.

        function Assert_Consistency(this, Equation, Solve_Engine_Name)
            string_class_name=class(Equation);
            if strcmpi(string_class_name,'Equation')
            else
                if strcmpi(Solve_Engine_Name, 'List_Phreeqc_Nodes_Models')
                    this.Assert_List_Phreeqc_Nodes_Models(string_class_name);
                elseif strcmpi(Solve_Engine_Name, 'Phreeqc_Process')
                    this.Assert_Phreeqc_Process(string_class_name);
                elseif strcmpi(Solve_Engine_Name, 'ODE_System_Solver45')
                    this.Assert_ODE_System_Solver45(string_class_name);
                elseif strcmpi(Solve_Engine_Name, 'Process_Identity')
                    this.Assert_Process_Identity(string_class_name);
                elseif strcmpi(Solve_Engine_Name, 'Phreeqc_Reactive_Transport_File')
                    this.Assert_Phreeqc_Reactive_Transport_File(string_class_name);
                elseif strcmpi(Solve_Engine_Name, 'Analytical')
                    this.Assert_Analytical(string_class_name);
                elseif strcmpi(Solve_Engine_Name, 'COMSOL_1D')
                elseif strcmpi(Solve_Engine_Name, 'COMSOL_1D_RichardsFlow')
                end
            end
        end
        
        % string_class_name=s
        
        function Assert_List_Phreeqc_Nodes_Models(this, S)
            b=strcmpi(S,'Equation_Phreeqc_Process');
            assert(b, '[Manager/Assert_List_Phreeqc_Nodes_Models] Solve engine not valid.\n');
        end
        
        % Solve_Engine_Name=s

        function Assert_Phreeqc_Process(this, S)
            b=strcmpi(S,'Equation_Phreeqc_Process');
            assert(b, '[Manager/Assert_Phreeqc_Process] Solve engine not valid.\n');
        end
        
        % Solve_Engine_Name=s

        function Assert_ODE_System_Solver45(this, S)
            b=strcmpi(S,'Equation_Bernoulli_Constant_Variables')|| strcmpi(S,'Equation_Homogeneous_Sys_Constant_Variables_ODE')|| strcmpi(S,'Equation_Simple_Cauchy');
            assert(b, '[Manager/Assert_ODE_System_Solver45] Solve engine not valid.\n');
        end

        % Solve_Engine_Name=s
        
        function Assert_Phreeqc_Reactive_Transport_File(this, S)
            b=strcmpi(S,'Equation_Phreeqc_Reactive_Transport');
            assert(b, '[Manager/Assert_Phreeqc_Reactive_Transport_File] Solve engine not valid.\n');
        end

        % Solve_Engine_Name=s
        
        function Assert_Analytical(this, S)
            b=strcmpi(S,'Equation_Simple_Cauchy') || strcmpi(S,'Equation_Lapidus_Ogata');
            assert(b, '[Manager/Assert_Analytical] Solve engine not valid.\n');
        end

        % Solve_Engine_Name=s
        
        function Assert_Process_Identity(this, S)
            b=strcmpi(S,'Equation_Identity');
            assert(b, '[Manager/Assert_Analytical] Solve engine not valid.\n');
        end
        
        % Accesor list_equations
        
        function list_equations = Get_List_Equations (this)
            list_equations=this.list_equations;
        end

        % Accesor list_equations
        
        function list_solve_engine = Get_List_Solve_Engine (this)
            list_solve_engine=this.list_solve_engine;
        end
    end
end