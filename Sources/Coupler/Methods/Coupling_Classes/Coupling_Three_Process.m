
% This class is in charge of applying different Operator Splitting methods
% with three process


classdef Coupling_Three_Process
    properties
        process_1            % A Process class.
        process_2            % A Process class.
        process_3            % A Process class.
        results              % A Results class.
    end
    methods
        
        %   Instantiate a Coupling_Three_Process class. 

        function this=Coupling_Three_Process(Process1, Process2, Process3, Ini_Concentration)
                    this.process_1=Process1;
                    this.process_2=Process2;
                    this.process_3=Process3;
                    if (strcmpi(class(Ini_Concentration),'Array_Field'))
                        this.results=Results_1D({},[]);
                    else
                        this.results=Results_0D({},[]);
                    end
        end
    end
end