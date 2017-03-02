
        %
        %   This method remove the "_" from the inputed string.
        %

        function s=stringmethod ( String)
            if strcmpi(String,'Strang_method_121')
                s='Strang method 121';
            elseif strcmpi(String,'Strang_method_212')
                s='Strang method 212';
            elseif strcmpi(String,'Sequential_12')
                s='Sequential 12';
            elseif strcmpi(String,'Sequential_21')
                s='Sequential 21';
            elseif  strcmpi(String,'Additive_method')
                s='Additive method';
            elseif  strcmpi(String,'Symmetrically_Weighted_method')
                s='Symmetrically Weighted method';
            elseif strcmpi( String, 'Sequential_1234')
                s='Sequential 1234';
            elseif strcmpi( String, 'AlternatingOS')
                s='AlternatingOS';
            elseif strcmpi( String, 'SIA_TC')
                s='SIA TC';
            elseif strcmpi( String, 'SIA_CC')
                s='SIA CC';
            elseif strcmpi (String, 'Direct')
                s='Direct';
            else
                fprintf('[Results/stringmethod] input is not an allowed method');
            end
        end