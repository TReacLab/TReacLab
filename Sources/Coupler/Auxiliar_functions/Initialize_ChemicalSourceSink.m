function R = Initialize_ChemicalSourceSink(String, varargin)
if strcmpi(String, '1D')
    a = varargin{1};
    R = zeros(a(1), a(2));
elseif strcmpi(String, '2D')
elseif strcmpi(String, '3D')
end
end