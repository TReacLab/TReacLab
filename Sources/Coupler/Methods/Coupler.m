% Coupling methods choice: switch to some coupler method(s)


classdef Coupler < handle
    properties
    end
    methods (Abstract)
    end
    methods (Static)
        function L = AlternatingOS ()
            L={'AlternatingOS'};
        end
        function L = Sequential_12 ()
            L={'Sequential_12'};
        end
        function L = Sequential_21 ()
            L={'Sequential_21'};
        end
        function L = Sequential_1234 ()
            L={'Sequential_1234'};
        end
        function L = Sequential ()
            L= {'Sequential_12', 'Sequential_21'};
        end
        function L = Additive ()
            L={'Additive_method'};
        end
        function L = Strang_121 ()
            L={'Strang_method_121'};
        end
        function L = Strang_212 ()
            L={'Strang_method_212'};
        end
        function L = Strang ()
            L={'Strang_method_121', 'Strang_method_212'};
        end
        function L = Symetrically ()
            L={'Symmetrically_Weighted_method'};
        end
        function L = Partial_First_Order_Methods_1 ()
            L={'Sequential_12', 'Additive_method'};
        end
        function L = Partial_First_Order_Methods_2()
            L={'Sequential_21', 'Additive_method'};
        end
        function L = All_First_Order_Methods ()
            L={'Sequential_12', 'Sequential_12', 'Additive_method'};
        end
        function L = Partial_Second_Order_Methods_1 ()
            L={'Strang_method_121', 'Symmetrically_Weighted_method'};
        end
        function L = Partial_Second_Order_Methods_2 ()
            L={'Strang_method_212', 'Symmetrically_Weighted_method'};
        end
        function L = All_Second_Order_Methods ()
            L={'Strang_method_121', 'Strang_method_212', 'Symmetrically_Weighted_method'};
        end
        function L = Partial_Methods_1 ()
            L={'Sequential_12', 'Additive_method', 'Strang_method_121',  'Symmetrically_Weighted_method'};
        end
        function L = Partial_Methods_2 ()
            L={'Sequential_21', 'Additive_method', 'Strang_method_212',  'Symmetrically_Weighted_method'};
        end
        function L = All_Methods ()
            L={'Sequential_12', 'Sequential_21', 'Additive_method', 'Strang_method_121', 'Strang_method_212', 'Symmetrically_Weighted_method'};
        end
    end
end