%
% This class is temporal, and just works for search the Phreeqc/Comsol bug
% It does not work with activity but with concentrations. Assumption
% activity==concentration.
% K=[SoluteOne][Solutetwo]
% Mineral <--> SoluteOne+SoluteTwo
%
% Assume units of Mineral are mol, entry units of SoluteOne ant SoluteTwo
% are mol/kgw. 
% Assume there is 1 kgw
%

classdef SimpleBynaryChemistry_DissolutionPrecipitation
    properties
        name_solute_one
        name_solute_two
        name_mineral
        equilibrium_constant  % IAP
%         initial_amount_mineral
    end
    methods
        
        function this=SimpleBynaryChemistry_DissolutionPrecipitation(Equation)
            param=Equation.Get_Parameters();
            this.equilibrium_constant=param{1};
            this.name_solute_one=param{2};
            this.name_solute_two=param{3};
            this.name_mineral=param{4};
        end
        
        % Acessors
        function Str_NameSol1 = Get_Name_Solute_One(this)
            Str_NameSol1 = this.name_solute_one;
        end
        function Str_NameSol2 = Get_Name_Solute_Two(this)
            Str_NameSol2 = this.name_solute_two;
        end
        function Str_NameMin = Get_Name_Mineral(this)
            Str_NameMin = this.name_mineral;
        end
        
        function out=Time_Stepping (this, parm)
            old_value_Solute_One=parm{1};
            old_value_Solute_Two=parm{2};
            old_value_Mineral=parm{3};
            lng = parm{4};
            difference_constant=old_value_Solute_One-old_value_Solute_Two;
            
            new_value_Solute_One = zeros (lng, 1);
            new_value_Solute_Two = zeros (lng, 1);
            new_value_Mineral    = zeros (lng, 1);
            
            for i =1:lng
                % calculations
                new_value_Solute_One(i)=0.5*(difference_constant(i)+sqrt((difference_constant(i)^2)+4*this.equilibrium_constant));
                new_value_Solute_Two(i)=this.equilibrium_constant/new_value_Solute_One(i);
                %%
                difference_concentration_Solute_Two=new_value_Solute_Two(i)-old_value_Solute_Two(i);
                
                if  old_value_Mineral(i)==0 && difference_concentration_Solute_Two>0
                    new_value_Solute_One(i)=old_value_Solute_One(i);
                    new_value_Solute_Two(i)= old_value_Solute_Two(i);
                    new_value_Mineral(i)=0;
                elseif difference_concentration_Solute_Two>0 && old_value_Mineral(i)>0
                    
                    new_value_Mineral(i)=old_value_Mineral(i)-difference_concentration_Solute_Two;
                    if new_value_Mineral(i)>=0
                    else
                        new_value_Mineral(i)=0;
                        new_value_Solute_One(i)=old_value_Solute_One(i)+old_value_Mineral(i);
                        new_value_Solute_Two(i)=old_value_Solute_Two(i)+old_value_Mineral(i);
                    end
                elseif difference_concentration_Solute_Two<0 && new_value_Solute_One(i)>0 && new_value_Solute_Two(i)>0
                    new_value_Mineral(i)=old_value_Mineral(i)-difference_concentration_Solute_Two;
                elseif difference_concentration_Solute_Two<0 && (new_value_Solute_One(i)<0 || new_value_Solute_Two(i)<0)
                    if new_value_Solute_One(i)<0
                        new_value_Mineral(i)=old_value_Mineral(i)+old_value_Solute_One(i);
                        new_value_Solute_Two(i)= old_value_Solute_Two(i)+old_value_Solute_One(i);
                        new_value_Solute_One(i)=0;
                    else
                        new_value_Mineral(i)=old_value_Mineral(i)+old_value_Solute_Two(i);
                        new_value_Solute_One(i)= old_value_Solute_Two(i)+old_value_Solute_One(i);
                        new_value_Solute_Two(i)=0;
                    end
                elseif difference_concentration_Solute_Two==0
                    new_value_Mineral(i)=old_value_Mineral(i);
                end
                
            end
            
            out ={new_value_Solute_One, new_value_Solute_Two, new_value_Mineral};

        end
    end
end