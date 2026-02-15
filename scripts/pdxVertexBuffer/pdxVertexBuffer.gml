/// @description Aa Abstract Vertex Buffer
function pdxVertexBuffer() : pdxException() constructor {
    self.vertexData = undefined;
    self.vertexFormat = undefined;
    self.vertexImage = undefined;
    self.vertexPrimitiveMode = undefined;
    self.vertexSize = undefined;
    

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
            var materialDataCount = array_length(gltf.materialData);

            var valid = true;
            var colorAssigned = false;
            
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
                            show_debug_message("Added position_3d");
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
                            show_debug_message("Added normal");
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
                            show_debug_message("Added texcoord");
                        }
                    }
                    
                    if(self.keyExists(attribs, "color")) {
                        if(array_length(attribs.color) > 1) {
                            self.critical("Something is using COLOR_1 (or above) - not handled yet");
                            valid = false;
                        }
                        if(attribs.color[0] >= accessorDataCount) {
                            valid = false;
                        } else if((gltf.accessorData[attribs.color[0]].type != gltfAccessorType.VEC4) && (gltf.accessorData[attribs.color[0]].type != gltfAccessorType.VEC3)) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.color[0]].elementType != gltfComponentType.FLOAT) {
                            valid = false;
                        } else {
                            // VEC3 versions WILL be converted to VEC4 (at least for now)
                            vertex_format_add_colour();
                            show_debug_message("Added color");
                        }
                    }
                    
                    // Todo: Add remaining attribs - TANGENT, joints, weights
                }
                
            	if(self.keyExists(primitive, "material")) { 
                    if(primitive.material > materialDataCount) {
                        valid = false;
                    } else {
                        // For baseColor - primitive.material.getBaseColor()
                        vertex_format_add_colour();
                        show_debug_message("Added material color");
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

    /// @description Create the Vertex Format for a Primitive
    /// @param {Struct.pdxGLTFBase} gltf A GLTF structure
    /// @param {Struct.pdxGltfDataMeshPrimitive} primitive A primative structure
    /// @return {Bool} Success / Fail Boolean Value
    static createVertexDataElement = function(gltf, primitive, index, buf) {
        show_debug_message("Index " + string(index));
        var colorAssigned = false;
        
        if(self.keyExists(primitive, "attributes")) { 
            var attribs = primitive.attributes;   
                    
            if(self.keyExists(attribs, "POSITION")) {
                var pos = gltf.accessorData[attribs.POSITION].getValue(index);
                vertex_position_3d(buf, pos.x, pos.y, pos.z);
                show_debug_message("Set position to " + string(pos));
            }
            
            if(self.keyExists(attribs, "NORMAL")) {
                var norm = gltf.accessorData[attribs.NORMAL].getValue(index);
                if(!is_undefined(norm)) {
                    vertex_normal(buf, norm.x, norm.y, norm.z);
                } else {
                    
                }
            }
            
            if(self.keyExists(attribs, "texcoord")) {
                var tex = gltf.accessorData[attribs.texcoord[0]].getValue(index);
                if(!is_undefined(tex)) {
                    vertex_texcoord(buf, tex.u, tex.v);
                } else {
                    
                }
            }
            
            if(self.keyExists(attribs, "color")) {
                // VEC3 versions WILL be converted to VEC4 (at least for now)
                var col = gltf.accessorData[attribs.color[0]].getValue(index);
                if(!is_undefined(col)) {
                    var rgb = undefined;
                    var alpha = undefined;
                    
                    switch(gltf.accessorData[attribs.color[0]].type) {
                        case gltfAccessorType.VEC4:
                            rgb = make_colour_rgb(col.x, col.y, col.z);
                            alpha = col.w;
                            break;
                        case gltfAccessorType.VEC3:
                            rgb = make_colour_rgb(col.x, col.y, col.z);
                            alpha = 1;
                            break;
                        default:
                            self.critical("primitive color failed");
                            break;
                    }
                    vertex_colour(buf, rgb, alpha);
                } else {
                    
                }
            }
            
            // Todo: Add remaining attribs - TANGENT, joints, weights
        }
        
        if(self.keyExists(primitive, "material")) { 
            // For baseColor - primitive.material.getBaseColor()
            var col = gltf.materialData[primitive.material].getBaseColor();
            if(!is_undefined(col)) {
                var rgb = make_colour_rgb(col[0] * 255, col[1] * 255, col[2] * 255);
                var alpha = col[3];
                
                vertex_colour(buf, rgb, alpha);
                show_debug_message("Set color to " + string(rgb));
            } else {
                self.critical("material color failed");
            }
        }
    }

    /// @description Create the Vertex Format for a Primitive
    /// @param {Struct.pdxGLTFBase} gltf A GLTF structure
    /// @param {Struct.pdxGltfDataMeshPrimitive} primitive A primative structure
    /// @return {Bool} Success / Fail Boolean Value
    static createVertexData = function(gltf, primitive) {
        if(is_undefined(gltf)) {
            return false;
        }
        if(is_undefined(primitive)) {
            return false;
        }
        
        var buf = vertex_create_buffer();
        vertex_begin(buf, self.vertexFormat);
        
        if(self.keyExists(primitive, "mode")) { 
            if(primitive.mode != gltfMeshPrimitiveMode.TRIANGLES) {
                self.critical("Only primitive mode TRAINGLE is handled currently");
            }
        } else {
            self.critical("primitive has no mode");
        }
        if(self.keyExists(primitive, "indices")) { 
            if(gltf.accessorData[primitive.indices].type == gltfAccessorType.SCALAR) {
                var indices = gltf.accessorData[primitive.indices].value;
                for(var i =0, n = array_length(indices); i<n; i++) {
                    var idx = indices[i];
                    self.createVertexDataElement(gltf, primitive, idx, buf);
                }
            } else {
                self.critical("primitive.indices is not SCALAR")
            }
        }
        
        vertex_end(buf);
        self.vertexSize = vertex_get_buffer_size(buf);
        self.vertexData = buf;
    }

    
    static createVertex = function(gltf, primitive) {
        if(self.createVertexFormat(gltf, primitive)) {
            self.createVertexData(gltf, primitive);
            return true;
            
        }
        return false;
    }
    
    static submit = function() {
        if(!is_undefined(self.vertexData)) {
            vertex_submit(self.vertexData, pr_trianglelist, -1);
        }
       
    }
}


