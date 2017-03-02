% This function represent the following. An homogeneous linear system of
% ordinary differentical equations. The coefficients are supossed to be
% constant.
% Mathematical representation looks:
%   dc/dt = Matrix* c
%
% So c is the vector of unknowns, dc/dt is the temporal variation and
% matrix are the coefficients.


function dcdt = ODE_linearhomogeneous_constantcoeff (t,c, matrix)
dcdt = matrix*c;
end