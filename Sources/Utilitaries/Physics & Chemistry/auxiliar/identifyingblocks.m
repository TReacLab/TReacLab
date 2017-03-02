% It gives the start lines and final lines of the datablock of Phreeqc that
% can be found in the cell A.
%
% A is a cell containing cell which contain strings.

function ranges=identifyingblocks(A)
    ranges={};
    t1=0;
    t2=0;
    counter=1;
    for i=1:size(A,2)
        if t2==0
            if (ItisBlock(A{i}{1,1}))
                t1=i;
                t2=i+1;
            end
        else
            if (ItisBlock(A{i}{1,1}))
                t2=i;
                ranges{1,counter}={t1, t2-1};
                counter=counter+1;
                t1=t2;
            end
        end
    end
    if (t1<=size(A,2))
        ranges{1,counter}={t1,size(A,2)};
    end
    
end

% The bolean is true if the given string match one type of the different of
% string of the different blocks that can be find in Phreeqc (Not all the
% blocks have been inputes although it is possible) 

function boolean=ItisBlock(string)
    boolean=false;
    if strcmpi(string,'TITLE') 
        boolean=true;
    elseif strcmpi(string,'SOLUTION') 
        boolean=true;
    elseif strcmpi(string,'END') 
        boolean=true;
    elseif strcmpi(string,'EQUILIBRIUM_PHASES') 
        boolean=true;
    elseif strcmpi(string,'EXCHANGE') 
        boolean=true;
    elseif strcmpi(string,'REACTION') 
        boolean=true;
    elseif strcmpi(string,'SELECTED_OUTPUT') 
        boolean=true;
    elseif strcmpi(string,'SAVE') 
        boolean=true;
    elseif strcmpi(string,'USE') 
        boolean=true;
    elseif strcmpi(string,'KINETICS') 
        boolean=true;
    elseif strcmpi(string,'RATES') 
        boolean=true;
    elseif strcmpi(string,'RUN_CELLS') 
        boolean=true;
    elseif strcmpi(string,'SOLUTION_SPREAD') 
        boolean=true;
    elseif strcmpi(string,'TRANSPORT') 
        boolean=true;
    elseif strcmpi(string,'#Apart')                            % Related to things that do vary like
        boolean=true;
    end
end