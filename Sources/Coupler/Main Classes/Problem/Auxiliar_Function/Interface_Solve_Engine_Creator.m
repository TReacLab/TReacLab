% This function instantiates the solve engines, using the list given in the
% Problem class. Here is the place to add new solve engines strings if new
% solvers wants to be used. (Remember: The new solvers should have an
% equation class or can use the generic one as well as we coherent with the
% manager class)

function solve_engine = Interface_Solve_Engine_Creator (Morphology, Equation, Initial_Concentration, Solve_Engine_Name, CouplerMethod)

% Symmetrically Weighted OS is an special case, therefore it must be
% treated differently. Since some of the solver can store information that
% should not be mixed up during process approach calls.

if strcmpi(CouplerMethod,'Symmetrically_Weighted_method')
    solve_engine=cell(1,2);
    solve_engine{1} =Solve_Engine_Creator_Cont (Morphology, Equation, Initial_Concentration, Solve_Engine_Name, 2036);
    solve_engine{2} =Solve_Engine_Creator_Cont (Morphology, Equation, Initial_Concentration, Solve_Engine_Name, 2037);
else
    solve_engine =Solve_Engine_Creator_Cont (Morphology, Equation, Initial_Concentration, Solve_Engine_Name);
end

end

% Some of these solvers should be removed, the decision must be stated.

function  solve_engine = Solve_Engine_Creator_Cont (Morphology, Equation, Initial_Concentration, Solve_Engine_Name, varargin)
if strcmpi(Solve_Engine_Name, 'COMSOL_1D')
    if ~isempty(varargin)
        solve_engine = Interface_COMSOL_1D( COMSOL_1D( Morphology, Equation, Initial_Concentration, varargin{1}) ); 
    else
        solve_engine = Interface_COMSOL_1D( COMSOL_1D( Morphology, Equation, Initial_Concentration));
    end
elseif strcmpi(Solve_Engine_Name, 'SimpleBynaryChemistry_DissolutionPrecipitation')
    solve_engine = Interface_SimpleBynaryChemistry_DissolutionPrecipitation( SimpleBynaryChemistry_DissolutionPrecipitation( Equation) );   
elseif strcmpi (Solve_Engine_Name, 'TransportSNIA_PDEPEmod')
    solve_engine=Interface_TransportSNIA_PDEPEmod(TransportSNIA_PDEPEmod (Morphology, Equation, Initial_Concentration));      
elseif strcmpi (Solve_Engine_Name, 'LinearTransportFD_1D_ConstantVelDiffMesh')
    solve_engine=Interface_LinearTransportFD_1D_ConstantVelDiffMesh (LinearTransportFD_1D_ConstantVelDiffMesh (Morphology, Equation, Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'LinearTransportFD_1D_ConstantVelDiffMesh_modLunnbench')
    solve_engine=Interface_LinearTransportFD_1D_ConstantVelDiffMesh_modLunnbench (LinearTransportFD_1D_ConstantVelDiffMesh_modLunnbench (Morphology, Equation, Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'LinearTransportFD_1D_ConstantVelDiffMesh_v2')
    solve_engine=Interface_LinearTransportFD_1D_ConstantVelDiffMesh (LinearTransportFD_1D_ConstantVelDiffMesh_v2 (Morphology, Equation, Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA')
    solve_engine = Interface_Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA(Saturated_Conservative_Transport_PDEPEMATLAB_1D_SIA( Morphology, Equation, Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'LinearTransportFD_1D_ConstantVelDiffMeshImpl')
    solve_engine=Interface_LinearTransportFD_1D_ConstantVelDiffMeshImpl (LinearTransportFD_1D_ConstantVelDiffMeshImpl (Morphology, Equation, Initial_Concentration)); 
elseif strcmpi (Solve_Engine_Name, 'FVT_1D_Solver')
    solve_engine=Interface_FVT_1D_Solver (FVT_1D_Solver (Morphology, Equation, Initial_Concentration)); 
elseif strcmpi (Solve_Engine_Name, 'Phreeqc_Batch_Seq_v3')  %development
    solve_engine=Interface_Phreeqc_Batch_Seq_v3(Phreeqc_Batch_Seq_v3 (Equation.Get_Parameters), Initial_Concentration); 
elseif strcmpi (Solve_Engine_Name, 'Phreeqc_Batch_Seq_v2')  
    solve_engine=Interface_Phreeqc_Batch_Seq_v2(Phreeqc_Batch_Seq_v2 (Equation.Get_Parameters), Initial_Concentration); 
elseif strcmpi (Solve_Engine_Name, 'Phreeqc_Batch_Seq')
    solve_engine=Interface_Phreeqc_Batch_Seq(Phreeqc_Batch_Seq (Equation.Get_Parameters), Initial_Concentration);
elseif strcmpi (Solve_Engine_Name, 'PhreeqcRM_v1')
    solve_engine=Interface_PhreeqcRM_v1(PhreeqcRM_v1(Equation.Get_Parameters,Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'SimpleR_FirstOrder_Decay')
    solve_engine=Interface_SimpleR_FirstOrder_Decay (SimpleR_FirstOrder_Decay(Equation, Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'Lunn_Bench_Chemistry')
    solve_engine=Interface_Lunn_Bench_Chemistry (Lunn_Bench_Chemistry(Equation, Initial_Concentration));
elseif strcmpi (Solve_Engine_Name, 'Process_Identity')
    solve_engine=Interface_Identity (Process_Identity());
elseif strcmpi (Solve_Engine_Name, 'Saturated_Conservative_Transport_PDEPEMATLAB_1D')    
    solve_engine=Saturated_Conservative_Transport_PDEPEMATLAB_1D(Morphology, Equation, Initial_Concentration);
else
    fprintf ('[Problem/Process] The given process_name does not exist.\n');
end
end

% ======================================================================
%
% Creates Analytical Solve Engines --> Solve_Engine=Create_Analytical(Equation)
%
% ======================================================================
function solve_engine=Create_Analytical(Morphology, Equation)
if isa (Equation, 'Equation_Simple_Cauchy')
    solve_engine=AnalyticalSolution_Of_Simp_Cauchy_Function (Equation) ;
elseif isa ( Equation,'Equation_Lapidus_Ogata')
    if length(Equation.Get_Parameters) == 1
        solve_engine = Process_Transport ( Analytical_Transport_1D_Column_ConstantProfile(Morphology, Equation ) );
    else
        solve_engine = Process_Selected_Transport ( Analytical_Transport_1D_Column_ConstantProfile(Morphology, Equation ), Equation.Get_Parameters{2} );
    end
end
end

%
% list_models={{Preecq_Process, [i1, i2]}, {Preeqc_Process2, [i3, i4]}}
%
function list_models=Create_List_Phreeqc_Models (Equation_Vector)
    d=length(Equation_Vector);
    list_models=cell(1,d);
    for i=1:d
        list_models{i}={Phreeqc_Process(Equation_Vector(i).Get_Parameters{1}) Equation_Vector(i).Get_Parameters{2:end}};
    end
end
