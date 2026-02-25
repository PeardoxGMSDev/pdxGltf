vbuf_show_debug = false;
vbuf_format_show_debug = false;
vbuf_color_show_debug = false;
vbuf_texcoord_show_debug = false;
triCount = 0;

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
        if(is_array(gltf.accessorData)) {
            var accessorDataCount = array_length(gltf.accessorData);
            var materialDataCount = array_length(gltf.materialData);

            var valid = true;
            var colorAssigned = false;
            
            vertex_format_begin();
            try {
            	if(primitive.attributes != undefined) { 
                    var attribs = primitive.attributes;   
                    
                    if(attribs.POSITION != undefined) {
                        if(attribs.POSITION >= accessorDataCount) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.POSITION].type != gltfAccessorType.VEC3) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.POSITION].elementType != gltfComponentType.FLOAT) {
                            valid = false;
                        } else {
                            vertex_format_add_position_3d();
                            if(global.vbuf_format_show_debug) {
                                show_debug_message("Added position_3d");
                            }
                        }
                    }
                    
                    if(attribs.NORMAL != undefined) {
                        if(attribs.NORMAL >= accessorDataCount) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.NORMAL].type != gltfAccessorType.VEC3) {
                            valid = false;
                        } else if(gltf.accessorData[attribs.NORMAL].elementType != gltfComponentType.FLOAT) {
                            valid = false;
                        } else {
                            vertex_format_add_normal();
                            if(global.vbuf_format_show_debug) {
                                show_debug_message("Added normal");
                            }
                        }
                    }
                    
                    if(is_array(attribs.texcoord)) {
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
                            if(global.vbuf_format_show_debug) {
                                show_debug_message("Added texcoord");
                            }
                        }
                    }
                    
                    if(is_array(attribs.color)) {
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
                            if(global.vbuf_format_show_debug) {
                                show_debug_message("Added color");
                            }
                        }
                    }
                    
                    // Todo: Add remaining attribs - TANGENT, joints, weights
                }
                
            	if(primitive.material != undefined) { 
                    if(primitive.material > materialDataCount) {
                        valid = false;
                    } else {
                        // For baseColor - primitive.material.getBaseColor()
                        vertex_format_add_colour();
                        if(global.vbuf_format_show_debug) {
                            show_debug_message("Added material color");
                        }
                    }
                }
            } finally {
                if(valid) {
                    fmt = vertex_format_end();
                    self.vertexFormat = fmt;
                } else {
                    self.critical("Attempted to create invalid vertex format")
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
        if(global.vbuf_show_debug) {
            show_debug_message("Index " + string(index));
        }
        var colorAssigned = false;
        
        if(primitive.attributes != undefined) { 
            var attribs = primitive.attributes;   
                    
            if(attribs.POSITION != undefined) {
                var pos = gltf.accessorData[attribs.POSITION].getValue(index);
                // Invert Y + Z to make gltf match Gamemaker
                vertex_position_3d(buf, pos.x, -pos.y, -pos.z);
                if(global.vbuf_show_debug) {
                    show_debug_message("Set position to " + string(pos));
                }
            }
            
            if(attribs.NORMAL != undefined) {
                var norm = gltf.accessorData[attribs.NORMAL].getValue(index);
                if(!is_undefined(norm)) {
                    vertex_normal(buf, norm.x, norm.y, norm.z);
                    if(global.vbuf_show_debug) {
                        show_debug_message("Set normal to " + string(norm));
                    }
                }
            }
            
            if(is_array(attribs.texcoord)) {
                var tex = gltf.accessorData[attribs.texcoord[0]].getValue(index);
                if(!is_undefined(tex)) {
                    vertex_texcoord(buf, tex.u, tex.v);
                    if(global.vbuf_show_debug || global.vbuf_texcoord_show_debug) {
//                        show_debug_message("Set texcoord to " + string(tex));
                    }
                }
            }
            
            if(is_array(attribs.color)) {
                // VEC3 versions WILL be converted to VEC4 (at least for now)
                var col = gltf.accessorData[attribs.color[0]].getValue(index);
                if(!is_undefined(col)) {
                    var rgb = undefined;
                    var alpha = undefined;
                    
                    switch(gltf.accessorData[attribs.color[0]].type) {
                        case gltfAccessorType.VEC4:
                            // rgb = make_colour_rgb(col.x, col.y, col.z);
                            rgb = make_colour_rgb(col.x * 255, col.y * 255, col.z * 255);
                            alpha = col.w * 255;
                            break;
                        case gltfAccessorType.VEC3:
                            //rgb = make_colour_rgb(col.x, col.y, col.z); 
                            rgb = make_colour_rgb(col.x * 255, col.y * 255, col.z * 255);
                            alpha = 255;
                            break;
                        default:
                            self.critical("primitive color failed");
                            break;
                    }
                    vertex_colour(buf, rgb, alpha);
                    if(global.vbuf_show_debug) || global.vbuf_color_show_debug {
                        show_debug_message("Set vertex color to " + string(rgb));
                    }
                    
                }
            }
            
            // Todo: Add remaining attribs - TANGENT, joints, weights
        }
        
        if(primitive.material != undefined) { 
            // For baseColor - primitive.material.getBaseColor()
            var col = gltf.materialData[primitive.material].getBaseColor();
            if(!is_undefined(col)) {
                var rgb = make_colour_rgb(col[0] * 255, col[1] * 255, col[2] * 255);
                var alpha = col[3] * 255;
                
                vertex_colour(buf, rgb, alpha);
                if(global.vbuf_show_debug) {
                    show_debug_message("Set color to " + string(rgb));
                }
            } else {
                self.critical("set material color failed");
            }
            var tex = gltf.materialData[primitive.material].getBaseColorTexture();
            if(!is_undefined(tex) && !is_undefined(tex.index)) {
                if(tex.index < array_length(gltf.textureData)) {
                    if(is_undefined(gltf.textureData[tex.index])) {
                        self.vertexImage = gridMagentaGreen64;
                    } else {
                        var img = gltf.textureData[tex.index].image;
                        if(!is_undefined(img) && !is_undefined(img.texturegroup_name) && !is_undefined(img.sprite_name)) {
                            var tex_array = texturegroup_get_sprites(img.texturegroup_name);
                            for (var i = 0; i < array_length(tex_array); ++i) {
                                if(sprite_get_name(tex_array[i]) == img.sprite_name) {
                                    self.vertexImage = tex_array[i];
                                }
                            }
                        }
                        
                    }
                    
                    
                }
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
        if(is_undefined(self.vertexFormat)) {
            self.critical("Vertex format not set");
        }
        vertex_begin(buf, self.vertexFormat);
        
        if(primitive.mode != undefined) { 
            if(primitive.mode != gltfMeshPrimitiveMode.TRIANGLES) {
                self.critical("Only primitive mode TRAINGLE is handled currently");
            }
        } else {
            self.critical("primitive has no mode");
        }
        if(primitive.indices != undefined) { 
            if(gltf.accessorData[primitive.indices].type == gltfAccessorType.SCALAR) {
                var indices = gltf.accessorData[primitive.indices].value;
                
                global.triCount += array_length(indices) / 3;
                
                    if(global.vbuf_format_show_debug) {
                        show_debug_message("Reading " + string(array_length(indices)) + " indices");
                    }
                
                for(var i =0, n = array_length(indices); i<n; i++) {
                    var idx = indices[i];
                    self.createVertexDataElement(gltf, primitive, idx, buf);
                }
            } else {
                self.critical("primitive.indices is not SCALAR")
            }
        }
        
        vertex_end(buf);
        // vertex_freeze(buf);
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
            if(!is_undefined(self.vertexImage)) {
                vertex_submit(self.vertexData, pr_trianglelist, sprite_get_texture(self.vertexImage, 0));
            } else {
                vertex_submit(self.vertexData, pr_trianglelist, -1);
            } 
        
        } 
    }
}

function pdxGltfVertexBufferSet(): pdxException() constructor {
    self.buffers = [];
    self.totalSize = 0;
    self.count = 0;
    self.buildTime = 0;
    
    static add = function(gltf, primitiveList) {
        var buildTimer = get_timer();
        for(var i=0, n = array_length(primitiveList); i<n; i++) {
            var vbuf = new pdxGltfVertexBuffer();
            if(vbuf.createVertex(gltf, primitiveList[i])) {
                self.count++;
                self.totalSize += vbuf.vertexSize;
                // show_debug_message(vertex_format_get_info(vbuf.vertexFormat));
                array_push(self.buffers, vbuf);
            } else {
                self.critical("Bad buffer");
            }
        }
        self.buildTime = get_timer() - buildTimer;
    }
    
    static submit = function() {
        for(var i=0; i<self.count; i++) {
            self.buffers[i].submit();
        }        
        
    }
    
    static freeze = function() {
        for(var i=0; i<self.count; i++) {
            vertex_freeze( self.buffers[i].vertexData);
        }        
        
    }
    
    static export = function(filename) {
        var b = buffer_create(self.totalSize, buffer_grow, 1);
        var p = 0;
        for(var i=0; i<self.count; i++) {
            var v = buffer_create_from_vertex_buffer(self.buffers[i].vertexData, buffer_grow, 1);
            var s = buffer_get_size(v);
            buffer_copy(v, 0, s, b, p);
            p += s;            
            buffer_delete(v);
        }        
        buffer_save(b, filename);
        buffer_delete(b);
        
    }
}

