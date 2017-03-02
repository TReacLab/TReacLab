% development
% cell {database, txt}
%
% Solve_Engine is an abstract class, it contains just Time_Stepping as abstract method
% Furthermore, Solve_Engine inherits the class handle from Matlab (for more info about handle look mathworks of Matlab)
%

classdef Phreeqc_Batch_Seq_v3 < Solve_Engine
    properties
        iphreeqc                    % Iphreec COM object
        number_cells   
        iphreeqc_extras
        timevectorDump
        timevectorOutputFile
%         Previous_ArrayC
    end
    methods
%         function this = Phreeqc_Batch_Seq_v2 (cell, InitialArray)
        function this = Phreeqc_Batch_Seq_v3 (cell)
            this.iphreeqc=actxserver('IPhreeqcCOM.Object');
            this.iphreeqc.LoadDatabase(cell{1});  
            this.iphreeqc.OutputFileOn = true;
            this.number_cells=cell{3};
            this.iphreeqc_extras= cell{4};
            [this.timevectorDump, this.timevectorOutputFile]=this.Phreeqc_Batch_Seq_ExtrasPhreeqc_Instantiation();
            this.iphreeqc.RunFile( cell{2});
            this.Phreeqc_Batch_Seq_ExtrasPhreeqc_Instantiation2();
            %             this.Previous_ArrayC=InitialArray;
        end
        %         function C2=Time_Stepping (this, C, Time, varargin)
        function b_t=Time_Stepping (this, parm)
            
            [rows_chem] = parm{1};
            dt= parm{2};
            final_time= parm{3};
            cell_for_RUNCELLS = parm{4};
            ListSol = parm{5};
            ListSolid = parm{6};
            A_Sol = parm{7};
            B_Solid = parm{8};
            index_h2o = parm{9};
            index_o = parm{10};
            index_h = parm{11};
            index_cb = parm{12};
            
            cancel_dump_file=false;
            cancel_output_file=false;
            % OUTPUT OR DUMPFILE ON
            if any(final_time==this.timevectorDump)
                this.SetOn_Output_Dump_File(final_time);
                cancel_dump_file=true;
            end
            if any(final_time==this.timevectorOutputFile)
                this.SetOn_Output_File(final_time);
                cancel_output_file=true;
            end
            
            modify_string = this.Create_Modify_String ( ListSol, ListSolid, A_Sol, B_Solid,index_h2o, index_o, index_h, index_cb, dt, rows_chem, cell_for_RUNCELLS);
            this.iphreeqc.RunString(modify_string);
            
            % OUTPUT OR DUMPFILE OFF
            if cancel_dump_file==true
                this.SetOFF_Output_File();
            end
            
            if cancel_output_file==true
                this.SetOFF_Output_File();
            end
            %%%
            
            b_t = this.iphreeqc.GetSelectedOutputArray();

        end
        
        function Array_Sol = Get_Solute_Array( this, ListSol, C1)
            d=length(ListSol);
            Array_Sol=zeros(length(C1.Get_Rows),d);
            for i=1:d
                Array_Sol(1:end,i)=C1.Get_Vector_Field (ListSol{i});
            end
        end

        
        function String_mod=Create_Modify_String (this, ListSol, ListSolid, A_Sol_NoNeg, B_Solid, index_h2o, index_o, index_h, index_cb, dt, rows_chem, cell_for_RUNCELLS)
            d=length(rows_chem);
            String_mod='';
            
            % modify solution
            for i=1:d
                s=this.Create_Modify_String_Cell_Sol(rows_chem(i), ListSol, A_Sol_NoNeg(rows_chem(i),:), index_h2o, index_o, index_h, index_cb);
                String_mod=sprintf([String_mod,'\n',s]);
            end
            % modify solid
            for i=1:d
                so=this.Create_Modify_String_Cell_Solid(rows_chem(i), ListSolid, B_Solid(rows_chem(i),:));
                String_mod=sprintf([String_mod,'\n',so]);
            end
%             String_mod=sprintf([String_mod, 'RUN_CELLS \n']);
%             s=sprintf('-cells \t 2-%d \n', this.number_cells);
            s_r = this.Create_Modify_String_RunCells (cell_for_RUNCELLS);
            String_mod=sprintf([String_mod, s_r]);
            s2=sprintf('-time_step \t %f \n', dt);
            String_mod=sprintf([String_mod, s2]);
        end
        
        function s = Create_Modify_String_RunCells (this, cell_for_RUNCELLS)
            s = 'RUN_CELLS \n';
            d = numel(cell_for_RUNCELLS);
            for i = 1:d
                if i == 1
                    if numel (cell_for_RUNCELLS{i}) == 1
                        sp=sprintf('-cells \t %d \n', cell_for_RUNCELLS{i});
                    elseif numel (cell_for_RUNCELLS{i}) == 2
                        sp=sprintf('-cells \t %d-%d \n', cell_for_RUNCELLS{i}(1), cell_for_RUNCELLS{i}(2));
                    else
                        error('[Phreeqc_Batch_Seq\Create_Modify_String_RunCells] Doom');
                    end
                    s = sprintf([s, sp]);
                else
                    if numel (cell_for_RUNCELLS{i}) == 1
                        sp=sprintf(' \t %d \n', cell_for_RUNCELLS{i});
                    elseif numel (cell_for_RUNCELLS{i}) == 2
                        sp=sprintf(' \t %d-%d \n', cell_for_RUNCELLS{i}(1), cell_for_RUNCELLS{i}(2));
                    else
                        error('[Phreeqc_Batch_Seq\Create_Modify_String_RunCells] Doom');
                    end
                    s = sprintf([s, sp]);
                end
            end
        end 
        
        function  s=Create_Modify_String_Cell_Sol(this, i, ListSol, A_vec, index_h2o, index_o, index_h, index_cb)
            %
%             A_vec(A_vec<1e-16)=0;
            %
            s1=sprintf('SOLUTION_MODIFY %s \n',num2str(i));
            s2=sprintf('-total_h \t %s \n',num2str(A_vec(index_h), 16));
            s3=sprintf('-total_o \t %s \n',num2str(A_vec(index_o), 16));
            s4=sprintf('-cb \t %s \n',num2str(A_vec(index_cb), 16));
            s5='-totals \n';
            ss=sprintf([s1, s2, s3, s4, s5]);
            %remove
            A=sort([index_h2o, index_o, index_h, index_cb]);
            A_vec(A(4))=[];
            ListSol(A(4))=[];
            A_vec(A(3))=[];
            ListSol(A(3))=[];
            A_vec(A(2))=[];
            ListSol(A(2))=[];
            A_vec(A(1))=[];
            ListSol(A(1))=[];
            % cont
            for j=1:length(ListSol)
                s=sprintf(' \t %s \t %s     \t  \n',ListSol{j},num2str(A_vec(j), 16));
                ss=sprintf([ss, s]);
            end
            s=ss;
        end
        
        function  s=Create_Modify_String_Cell_Solid(this, i, ListSolid, B_vec_solid)
            if length(ListSolid)>0
            s1=sprintf('EQUILIBRIUM_PHASES_MODIFY %s \n',num2str(i));
            s=s1;
            for  j=1:length(ListSolid)
                s1=sprintf('-component \t %s \n', ListSolid{j});
                s2=sprintf('\t -moles \t %s \n', num2str(B_vec_solid(j), 16));
                s=sprintf([s, s1, s2]);
            end
            else
                s='';
            end
        end
        
        function Array=Add_Neg(this, ListSol, Li, Array_t, A_Sol_Neg)
            list_complete=Li.Get_List_Id;
            for i=1:length(ListSol)
                [b, j]=ismember(ListSol{i}, list_complete);
                if b==1
                    Array_t(:,j)=Array_t(:,j)+ A_Sol_Neg(:,i);
                else
                    fprintf('[Phreeqc_Batch_Seq\Add_Neg] Doom');
                end
            end
            Array=Array_t;
        end
        
        
        function [timevectorDump, timevectorOutputFile]= Phreeqc_Batch_Seq_ExtrasPhreeqc_Instantiation(this)
            if ~isempty(this.iphreeqc_extras.Dumpfile)
                v = this.iphreeqc_extras.Dumpfile;
                this.iphreeqc.DumpFileOn = v;
            end
            if ~isempty(this.iphreeqc_extras.DumpString)
                v = this.iphreeqc_extras.DumpString;
                this.iphreeqc.DumpStringOn = v;
            end
            if ~isempty(this.iphreeqc_extras.Errorfile)
                v = this.iphreeqc_extras.Errorfile;
                this.iphreeqc.ErrorFileOn = v;
            end
            if ~isempty(this.iphreeqc_extras.Lines)
                v = this.iphreeqc_extras.Lines;
                if v==true
                    this.iphreeqc.Lines
                end
            end
            if ~isempty(this.iphreeqc_extras.LogFileOn)
                v = this.iphreeqc_extras.LogFileOn;
                this.iphreeqc.LogFileOn = v;
            end
            if ~isempty(this.iphreeqc_extras.OutputFile)
                v = this.iphreeqc_extras.OutputFile;
                this.iphreeqc.OutputFileOn = v;
            end
            if ~isempty(this.iphreeqc_extras.DropDumpFileTimeVector)
                v = this.iphreeqc_extras.DropDumpFileTimeVector;
                timevectorDump=v;
                if v(1)==0
                    s='DumpFile_T_Initial.out';
                    this.iphreeqc.DumpFileName=s;
                    this.iphreeqc.DumpFileOn = true;
                end
            else
                timevectorDump=0;
            if ~isempty(this.iphreeqc_extras.DropOutputFileTimeVector)
                v = this.iphreeqc_extras.DropOutputFileTimeVector;
                timevectorOutputFile=v;
                if v(1)==0
                    s='OutputFile_T_Initial.out';
                    this.iphreeqc.OutputFileOn=s;
                    this.iphreeqc.OutputFileOn = true;
                end
            else
                timevectorOutputFile=0;
            end
            end
        end
        function Phreeqc_Batch_Seq_ExtrasPhreeqc_Instantiation2(this)
            if strcmpi(this.iphreeqc.OutputFileOn, 'OutputFile_T_Initial.out')
                if isfield(this.iphreeqc_extras,'Dumpfile')
                    v = this.iphreeqc_extras.Dumpfile;
                    if v==true
                        s= strcat('dump.', num2str(this.iphreeqc.Id),'.out');
                        this.iphreeqc.DumpFileName = s;
                    else
                        this.iphreeqc.DumpFileOn = false;
                    end
                else
                    s= strcat('dump.', num2str(this.iphreeqc.Id),'.out');
                    this.iphreeqc.DumpFileName = s;
                    this.iphreeqc.DumpFileOn = false;
                end
            end
            if strcmpi(this.iphreeqc.OutputFileOn, 'OutputFile_T_Initial.out')
                if isfield(this.iphreeqc_extras,'OutputFile')
                    v = this.iphreeqc_extras.OutputFilee;
                    if v==true
                        s= strcat('phreeqc.', num2str(this.iphreeqc.Id),'.out');
                        this.iphreeqc.OutputFileName = s;
                    else
                        this.iphreeqc.OutputFileOn = false;
                    end
                else
                    s= strcat('phreeqc.', num2str(this.iphreeqc.Id),'.out');
                    this.iphreeqc.OutputFileName = s;
                    this.iphreeqc.OutputFileOn = false;
                end
            end
        end
        
        function SetOn_Dump_File(this, final_time)
            s=strcat('DumpFile_T_',num2str(final_time),'.out');
            this.iphreeqc.DumpFileName=s;
            this.iphreeqc.DumpFileOn = true;
        end
        
        function SetOn_Output_File(this, final_time)
            s=strcat('OutputFile_T_',num2str(final_time),'.out');
            this.iphreeqc.OutputFileOn=s;
            this.iphreeqc.OutputFileOn = true;
        end
        
        function SetOFF_Dump_File(this)
            if isfield(this.iphreeqc_extras,'Dumpfile')
                v = this.iphreeqc_extras.Dumpfile;
                if v==true
                    s= strcat('dump.', num2str(this.iphreeqc.Id),'.out');
                    this.iphreeqc.DumpFileName = s;
                else
                    this.iphreeqc.DumpFileOn = false;
                end
            else
                s= strcat('dump.', num2str(this.iphreeqc.Id),'.out');
                this.iphreeqc.DumpFileName = s;
                this.iphreeqc.DumpFileOn = false;
            end
        end

        function SetOFF_Output_File(this)
                if isfield(this.iphreeqc_extras,'OutputFile')
                    v = this.iphreeqc_extras.OutputFilee;
                    if v==true
                        s= strcat('phreeqc.', num2str(this.iphreeqc.Id),'.out');
                        this.iphreeqc.OutputFileName = s;
                    else
                        this.iphreeqc.OutputFileOn = false;
                    end
                else
                    s= strcat('phreeqc.', num2str(this.iphreeqc.Id),'.out');
                    this.iphreeqc.OutputFileName = s;
                    this.iphreeqc.OutputFileOn = false;
                end
            
        end
        
    end
end