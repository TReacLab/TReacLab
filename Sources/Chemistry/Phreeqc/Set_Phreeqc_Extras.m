function Options_P = Set_Phreeqc_Extras (varargin)
if (nargin == 0) && (nargout == 0)
  fprintf('        Dumpfile: [ boolean ]\n');
  fprintf('      DumpString: [ boolean ]\n');
  fprintf('       Errorfile: [ boolean ]\n');
  fprintf('           Lines: [ boolean ]\n'); 
  fprintf('       LogFileOn: [ boolean ]\n');
  fprintf('      OutputFile: [ boolean ]\n');
  fprintf('DropDumpFileTimeVector: [ vector of doubles related to time step ]\n');
  fprintf('DropOutputFileTimeVector: [ vector of doubles related to time step ]\n');
  fprintf('BackToLastStage: [ boolean ]\n');
  return;
end

Names = [
    'Dumpfile                '
    'DumpString              '
    'Errorfile               '
    'Lines                   '
    'LogFileOn               '
    'OutputFile              '  
    'DropDumpFileTimeVector  '
    'DropOutputFileTimeVector'
    'BackToLastStage         '
    ];
m = size(Names,1);
names = lower(Names);

% Combine all leading options structures o1, o2, ... in odeset(o1,o2,...).
Options_P = [];
for j = 1:m
  Options_P.(deblank(Names(j,:))) = [];
end
i = 1;
while i <= nargin
  arg = varargin{i};
  if ischar(arg)                         % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
      error(message('Phreeqc_Extra:NoPropNameOrStruct', i));
    end
    for j = 1:m
      if any(strcmp(fieldnames(arg),deblank(Names(j,:))))
        val = arg.(deblank(Names(j,:)));
      else
        val = [];
      end
      if ~isempty(val)
        Options_P.(deblank(Names(j,:))) = val;
      end
    end
  end
  i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  error(message('Phreeqc_Extra:ArgNameValueMismatch'));
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};
    
  if ~expectval
    if ~ischar(arg)
      error(message('Phreeqc_Extra:NoPropName', i));
    end
    
    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error(message('Phreeqc_Extra:InvalidPropName', arg));
    elseif length(j) > 1                % if more than one match
      % Check for any exact matches (in case any names are subsets of others)
      k = strmatch(lowArg,names,'exact');
      if length(k) == 1
        j = k;
      else
            matches = deblank(Names(j(1),:));
        for k = j(2:length(j))'
                matches = [matches ', ' deblank(Names(k,:))]; %#ok<AGROW>
        end
            error(message('Phreeqc_Extra:AmbiguousPropName',arg,matches));
      end
    end
    expectval = 1;                      % we expect a value next
    
  else
    Options_P.(deblank(Names(j,:))) = arg;
    expectval = 0;
      
  end
  i = i + 1;
end

if expectval
  error(message('Phreeqc_Extra:NoValueForProp', arg));
end
