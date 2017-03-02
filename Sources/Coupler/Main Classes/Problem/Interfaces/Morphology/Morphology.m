
%
% Abstract class, it represents the spatial domain.
%

classdef (Abstract)Morphology 
    properties     
    end
    methods (Abstract)
        vector=Get_Edges_Domain (this)
        discretization_vector=Get_Mesh_Discretization_Value (this)
    end
end