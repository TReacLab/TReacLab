%
% Checks the convergence of the solutes in the SIA_TC approach
%

function b =  Convergence_Reached (c_after, c_before, varargin)
b=true;

Li_b = c_before.Get_List_Identifiers;
Li_a = c_after.Get_List_Identifiers;

list_sol_b = Li_b.Get_List_Names ('Solution');
list_sol_a = Li_a.Get_List_Names ('Solution');
d=length(list_sol_a);

assert(isempty( setxor(list_sol_b, list_sol_a)));

% The convergence is assumed with solute concentrations, if you want to
% uses mols you will need to multiply the concentration per the volumetric
% water content.

% Vwc_b=c_before.Get_Vector_Field('volumetricwatercontent');
% Vwc_a=c_after.Get_Vector_Field('volumetricwatercontent');

opt = varargin{1};

[conv_value_aq, conv_value_mi] = Convergence_Values (opt);

for i=1:d
    C_b=c_before.Get_Vector_Field(list_sol_b{i});
    C_a=c_after.Get_Vector_Field(list_sol_a{i});
    
    % dif_rel = abs(((C_a.*Vwc_a)-(C_b.*Vwc_b)./(C_a.*Vwc_a));
    dif_rel = abs((C_a-C_b)./C_a);
    dif_rel(isnan(dif_rel))=0;
    if any(dif_rel>conv_value_aq)
        b=false;
        break
    end
  
end

% If you desire to take into account the convergence of the precipitated
% and dissolved minerals in equilibrium, use the following lines:

% list_pred_b = Li_b.Get_List_Names ('PrecipitationDissolution');
% list_pred_a = Li_a.Get_List_Names ('PrecipitationDissolution');
% d=length(list_pred_a);
% 
% for i=1:d
%     C_b=c_before.Get_Vector_Field(list_pred_b{i});
%     C_a=c_after.Get_Vector_Field(list_pred_a{i});
%     
%     dif_rel = abs((C_a-C_b)./C_a);
%     dif_rel(isnan(dif_rel))=0;
%     if any(dif_rel>conv_value_mi)
%         b=false;
%         break
%     end
%     
% end


end


% this function relies in a struct matlab class that uses son predetermine
% names in order to set the criterion value for the convergence.
function [conv_value_aq, conv_value_mi] = Convergence_Values (opt)

a = opt.SIA_Convergence_Criteria;
b = opt.SIA_Conv_Criteria_Aqueous;
c = opt.SIA_Conv_Criteria_Mineral;

if ~isempty (b)
    conv_value_aq = b;
elseif ~isempty (a)
    conv_value_aq = a;
else
    conv_value_aq = 1e-8;
end


if ~isempty (c)
    conv_value_mi = c;
elseif ~isempty (a)
    conv_value_mi = a;
else
    conv_value_mi = 1e-8;
end
end