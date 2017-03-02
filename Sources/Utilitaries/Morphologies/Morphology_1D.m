% This class must contain all the necesary information to define a 1D
% spatial domain.

classdef Morphology_1D < Morphology
    properties
        distance
        discretization_value
        mesh_field_map
    end
    methods
        
        %   Instantiate a Morphology_1D class. Length and dx must be given

        function this = Morphology_1D (Distance, Discretization_Value)
            this.distance=Distance;
            this.discretization_value= Discretization_Value;
            this.mesh_field_map=this.Create_Mesh_Field_Map();
        end

        %   Outputs a vector with the domain coordiantes
        %   (x1,x2,y1,y2,z1,z2). At it is 1D, It will be x=(x1, x2), being
        %   x1 the beginning of the column and x2 the end. 
        %
        %   Precondition= It is supossed that the units given are meters.

        function vector=Get_Edges_Domain (this)
            vector=[ 0, this.distance];
        end

        %   Outputs a double corresponding to the mesh step. (when it is
        %   supossed to be constant)
        %
        %   Precondition= It is supossed that the units given are meters.

        function discretization_vector=Get_Mesh_Discretization_Value (this)
            discretization_vector=this.discretization_value;
        end
        
        %   Outputs the saved 'distance' property
        
        function distance=Get_Distance (this)
            distance=this.distance;
        end

        %   Outputs a vector with the discretization points for a regular
        %   mesh. It means, a vector that goes from 0 until the last point
        %   with a value increment equal to the discretization value
        
        function vector_regular_discretization=Get_Vector_Regular_Discretization_Points (this)
            vector_regular_discretization=0:this.discretization_value:this.distance;
        end
        
        function vector_regular_discretization=Get_Vector_Regular_CenteredDiscretization_Points_WithEdges (this)
            vector_regular_discretization=this.discretization_value/2:this.discretization_value:(this.distance-(this.discretization_value/2));
            vector_regular_discretization=[0 vector_regular_discretization this.distance];
        end
        
        function vector_regular_discretization=Get_Vector_Regular_centeredDiscretization_Points (this)
            vector_regular_discretization=(this.discretization_value/2):this.discretization_value:(this.distance-(this.discretization_value/2));
        end
        
        % ======================================================================
        %
        % Fix Distance --> this=Fix_Distance (this, New_Distance)
        %
        %   inputs: 1) your Morphology_1D class.
        %           2) double
        %  
        %   output: 1) double.
        %   
        %   Fix a new given distance for the morphology.
        %
        % ======================================================================
        function this=Fix_Distance (this, New_Distance)
            this.distance=New_Distance;
        end
        
                
        % ======================================================================
        %
        % Fix dx --> this=Fix_Discretization_Value(this, New_Dx)
        %
        %   inputs: 1) your Morphology_1D class.
        %           2) double
        %  
        %   output: 1) double.
        %   
        %   Fix a new given discretization_value for the morphology.
        %
        % ======================================================================
        function this=Fix_Discretization_Value(this, New_Dx)
            this.discretization_value=New_Dx;
        end
        
        % ======================================================================
        %
        % Mesh_Field_Map --> mesh_field_map=Create_Mesh_Field_Map(this)
        %
        %   inputs: 1) vector (mesh points)
        %           2) vector
        %  
        %   output: 1) Map object
        %
        %   Creates a containers.Map class matlab. Linking numbers to
        %   different position of the mesh.
        %
        % ======================================================================
        function mesh_field_map=Create_Mesh_Field_Map(this)
            mesh_vector=this.Get_Vector_Regular_Discretization_Points;
            field_vector=1:1:length(mesh_vector);
            mesh_field_map=containers.Map (field_vector, mesh_vector);
        end
        
        % ======================================================================
        %
        % Fix Mesh_Field_Map --> mesh_field_map=Fix_Mesh_Field_Map(this, MeshFieldMap)
        %
        %   inputs: 1) containers.Map class matlab
        %  
        %   output: 1) Map object
        %
        %   Fix the property 'mesh_field_map' creating 
        %
        % ======================================================================
        function this=Fix_Mesh_Field_Map(this, MeshFieldMap)
            this.mesh_field_map=MeshFieldMap;
        end
        
    end
end