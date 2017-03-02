% Get the words of a phrase removing the space and sorting it in a cell
% class of matlab as a char class.

function s=obtainwords(String)
    r=strsplit(String,{' ' '\t' '\f' '\b'});
    s={};
    temp='';
    counter=1;
    for i=1:size(r,2)
        if (EmptyString(r{i}))
            temp=Stringwithoutspace(r{i});
            s{counter}=temp;
            counter=counter+1;
        end
    end
end

% Get a String, if the String is empty returns a true if not a false
% boolean.

function bool=EmptyString(String)
   bool=false;
   for i=1:size(String,2)
       if (~strcmp(String(i),' '))
           bool=true;
       end
   end
end

% Remove spaces of a string.

function st=Stringwithoutspace(String)
    st='';
    for i=1:size(String,2)
        if ~strcmp(String(i),'')
            st=strcat(st,String(i));
        end
    end
end