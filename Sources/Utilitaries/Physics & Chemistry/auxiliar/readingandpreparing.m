% The function reads a file and creates a cell class containing cells which
% contain the separated words of every meaningful line in a Phreeqc script format.

function Bprima=readingandpreparing (File)
    fid=fopen(File);
    tline = fgetl(fid);
    A={};
    i=1;
    while ischar(tline)
        A{i,1}=tline;
        tline = fgetl(fid);
        i=i+1;
    end
    
    for i=1:size(A,1)
    B{1,i}=obtainwords(A{i});
    end
    
    
    n=1;
    for i=1:size(B,2)
        if (size(B{1,i}, 2)~=0 && ~strcmp(B{i}{1,1},'#'))
            Bprima{1,n}=B{1,i};
            n=n+1;
        end
    end
    status = fclose('all');
    assert(status==0, 'Readingandpreparing function failed')
end