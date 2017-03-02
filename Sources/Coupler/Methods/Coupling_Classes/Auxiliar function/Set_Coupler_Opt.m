function Options_P = Set_Coupler_Opt (varargin)
if (nargin == 0) && (nargout == 0)
  fprintf('           Max_n_fixPoint: [ double ]\n');
  fprintf('      Max_n_ReductionTime: [ double ]\n');
  fprintf(' SIA_Convergence_Criteria: [ boolean ]\n');
  fprintf('SIA_Conv_Criteria_Aqueous: [ boolean ]\n'); 
  fprintf('SIA_Conv_Criteria_Mineral: [ boolean ]\n');
  return;
end

Names = [
    'Max_n_fixPoint             '
    'Max_n_ReductionTime        '
    'SIA_Convergence_Criteria   '
    'SIA_Conv_Criteria_Aqueous  '
    'SIA_Conv_Criteria_Mineral  '
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
      error(message('Coupler_Opt:NoPropNameOrStruct', i));
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
  error(message('Coupler_Opt:ArgNameValueMismatch'));
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};
    
  if ~expectval
    if ~ischar(arg)
      error(message('Coupler_Opt:NoPropName', i));
    end
    
    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error(message('Coupler_Opt:InvalidPropName', arg));
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
            error(message('Coupler_Opt:AmbiguousPropName',arg,matches));
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
  error(message('Coupler_Opt:NoValueForProp', arg));
end
