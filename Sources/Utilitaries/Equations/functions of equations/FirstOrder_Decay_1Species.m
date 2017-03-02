% first order decay one species
%
%   y1'=-a*y1
%
function dy=FirstOrder_Decay_1Species (T, Y, A)
dy=-1.*A.*Y;
end