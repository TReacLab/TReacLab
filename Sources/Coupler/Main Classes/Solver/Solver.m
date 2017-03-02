%
% Class is charge of solve the system of equations.
%
%

classdef Solver
    properties
        solve_engines     % Is a string of Solve Engines List
        problem     % Is a problem class
        solve_engines_list
    end
    
    methods
         
        %   Instantiate a Solver class. 
        %   The list of strings is a cell type (matlab) and contains the
        %   name of the solve engines that will be used to solve the
        %   concerning problem.

        function this = Solver (Problem, Solve_Engines_List)
            assert(isa(Problem, 'Problem'), '[Solver/Constructor] The problem class is not a problem')
            this.problem=Problem;
            this.solve_engines_list=Solve_Engines_List;
        end

        %   Solve the problem. 

        function results= Solve (this, CouplerMethod)
             % Since Phreeqc keeps information it is better to
             % reinizialite the solvers.
            this.solve_engines= this.problem.Instantiate_List_Of_Interface_and_Solve_Engines(this.solve_engines_list, CouplerMethod); 
            if nargin==1 || isempty(CouplerMethod)
                results = this.Sol_Direct();
            else
                results = this.Solve_According_Number_Solve_Engines (CouplerMethod, length(this.solve_engines));
            end
        end

 
        %   Solve the problem, regarding the length of the cell list. 

        function results = Solve_According_Number_Solve_Engines (this, CouplerMethod, N_SOLVE_ENGINES)
            if N_SOLVE_ENGINES==1
                results=Sol_Direct (this);
            elseif N_SOLVE_ENGINES==2
                coup = Coupling_Two_Solve_Engine(this.solve_engines{1}, this.solve_engines{2}, this.problem.Get_Initial_Field);
                results=coup.Loop(CouplerMethod, this.problem);
            elseif N_SOLVE_ENGINES==3
                coup=Coupling_Three_Solve_Engine(this.solve_engines{1}, this.solve_engines{2}, this.solve_engines{3}, this.problem.Get_Initial_Field);
                results=coup.Loop(CouplerMethod, this.problem);
            elseif N_SOLVE_ENGINES == 4
                coup=Coupling_Fourth_Solve_Engine (this.solve_engines{1}, this.solve_engines{2}, this.solve_engines{3}, this.solve_engines{4}, this.problem.Get_Initial_Field);
                results=coup.Loop(CouplerMethod, this.problem);
            end
        end
        
        function results =Sol_Direct (this)
                dic=Direct_Method (this.solve_engines{1}, this.problem.Get_Initial_Field);
                results=dic.Loop (this.problem);
        end
    end
end