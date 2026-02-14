/// @description Aa Abstract Vertex Buffer
function pdxVertexBuffer() : pdxException() constructor {
    self.vertexData = undefined;
    self.vertexFormat = undefined;
    self.vertexImage = undefined;
    self.vertexPrimitiveMode = undefined;
    

}

/// @description A GLTF Vertex Buffer
function pdxGltfVertexBuffer(): pdxVertexBuffer() constructor {
    /// @description Create the Vertex Format for a Primitive
    /// @param {Struct.pdxGLTFBase} gltf A GLTF structure
    /// @param {Struct.pdxGltfDataMeshPrimitive} primitive A primative structure
    /// @return {Bool} Success / Fail Boolean Value
    static createVertexFormat = function(gltf, primitive) {
        var fmt = undefined;
        if(is_undefined(gltf)) {
            return false;
        }
        if(is_undefined(primitive)) {
            return false;
        }
        if(self.keyExists(gltf, "accessorData")) {
            var accessorDataCount = array_length(gltf.accessorData);
    
            var valid = true;
            vertex_format_begin();
            try {
            	if(self.keyExists(primitive, "attributes")) { 
                    var attribs = primitive.attributes;   
                    
                    if(self.keyExists(attribs, "POSITION")) {
                        if(attribs.POSITION >= accessorDataCount) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.POSITION].type != gltfAccessorType.VEC3) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.POSITION].elementType != gltfComponentType.FLOAT) {
                            valid = false;
                        } else {
                            vertex_format_add_position_3d();
                        }
                    }
                    
                    if(self.keyExists(attribs, "NORMAL")) {
                        if(attribs.NORMAL >= accessorDataCount) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.NORMAL].type != gltfAccessorType.VEC3) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.NORMAL].elementType != gltfComponentType.FLOAT) {
                            valid = false;
                        } else {
                            vertex_format_add_normal();
                        }
                    }
                    
                    if(self.keyExists(attribs, "texcoord")) {
                        if(array_length(attribs.texcoord) > 1) {
                            self.critical("Something is using TEXCOORD_1 (or above) - not handled yet");
                            valid = false;
                        }
                        if(attribs.texcoord[0] >= accessorDataCount) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.texcoord[0]].type != gltfAccessorType.VEC2) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.texcoord[0]].elementType != gltfComponentType.FLOAT) {
                            valid = false;
                        } else {
                            vertex_format_add_texcoord();
                        }
                    }
                    
                    
                    
                }
            } finally {
                if(valid) {
                    fmt = vertex_format_end();
                    self.vertexFormat = fmt;
                } else {
                    self.addError("Attempted to create invalid vertex format")
                }
            }
        }
        if(is_undefined(fmt)) {
            return false;
        } else {
            return true;
        }
    }
}
