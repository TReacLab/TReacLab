% Abstra
%ct Class [Application of Dependency Inversion Principle]
%
%   No properties
%



classdef (Abstract) Time 
    properties
        initial_time   % Double class (float/int) stating the value of the initial time
        final_time     % Double class (float/int) stating the value of the final time
    end
    methods
        %constructor
        function this = Time(initial_time, final_time)
            this.initial_time = initial_time;
            this.final_time = final_time;
        end
        
        % getter
        % It returns the property 'final_time'
        function final_time = Get_Final_Time(this)
            final_time=this.final_time;
        end
        
        % getter
        % It returns the property 'initial_time'
        function initial_time = Get_Initial_Time(this)
            initial_time=this.initial_time;
        end

        
        % setter
        % It returns the property 'initial_time'
        function this = Set_Initial_Time(this, Initial_time)
            this.initial_time = Initial_time;
        end
        
        % setter
        % It returns the property 'initial_time'
        function this = Set_Final_Time(this, Final_time)
            this.final_time = Final_time;
        end
    end
    
    % Solve method for just one time step
end
