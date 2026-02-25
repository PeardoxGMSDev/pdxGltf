function pdxGltfSparseData(count) : pdxException() constructor {
    self.count                           = count;
    self.indices                         = undefined;
    self.values                          = undefined;

}

function pdxGltfDataValue(valueCount, elementType = gltfComponentType.UNKNOWN) : pdxException() constructor {
    self.value = undefined;
    self.elementLength = 0;
    self.valueLength = 0;
    self.readSize = undefined;
    self.type = gltfAccessorType.UNKNOWN;
    self.elementType = gltfComponentType.UNKNOWN;
    self.sparse = undefined;
    self.target = undefined;
    
    switch(elementType) {
        case gltfComponentType.BYTE:
            self.readSize = buffer_sizeof(buffer_s8);
            self.elementType = elementType;
            self.elementLength = valueCount;
            break;
        case gltfComponentType.FLOAT:
            self.readSize = buffer_sizeof(buffer_f32);
            self.elementType = elementType;
            self.elementLength = valueCount;
            break;
        case gltfComponentType.SHORT:
            self.readSize = buffer_sizeof(buffer_s16);
            self.elementType = elementType;
            self.elementLength = valueCount;
            break;
        case gltfComponentType.UNSIGNED_BYTE:
            self.readSize = buffer_sizeof(buffer_u8);
            self.elementType = elementType;
            self.elementLength = valueCount;
            break;
        case gltfComponentType.UNSIGNED_INT:
            self.readSize = buffer_sizeof(buffer_u32);
            self.elementType = elementType;
            self.elementLength = valueCount;
            break;
        case gltfComponentType.UNSIGNED_SHORT:
            self.readSize = buffer_sizeof(buffer_u16);
            self.elementType = elementType;
            self.elementLength = valueCount;
            break;
        default:
            self.critical("Tying to set value to wrong type");
        return true;
    }      
    
    static check_buffer = function(buffer, view, localOffset) {
        if(!buffer_exists(buffer)) {
            return false;
        }
        if(view.byteLength < (self.readSize * self.elementLength * self.valueLength)) {
            return false;
        }
        if(buffer_get_size(buffer) < (view.byteOffset + localOffset + (self.readSize * self.elementLength * self.valueLength))) {
            return false;
        }
        
        return true;
    }

    static read = function(buffer, view, localOffset = 0) {
        switch(self.elementType) {
            case gltfComponentType.BYTE:
                if(!self.check_buffer(buffer, view, localOffset)) {
                    self.critical("Buffer Overread for buffer");
                }
                buffer_seek(buffer, buffer_seek_start, view.byteOffset + localOffset);
                for(var elm=0; elm<self.elementLength; elm++) {
                    for(var val=0; val<self.valueLength; val++) {
                        self.value[(elm * self.valueLength) + val] = buffer_read(buffer, buffer_s8);
                    }
                }
                break;
            case gltfComponentType.FLOAT:
                if(!self.check_buffer(buffer, view, localOffset)) {
                    self.critical("Buffer Overread for buffer");
                }
                buffer_seek(buffer, buffer_seek_start, view.byteOffset + localOffset);
                for(var elm=0; elm<self.elementLength; elm++) {
                    for(var val=0; val<self.valueLength; val++) {
                        self.value[(elm * self.valueLength) + val] = buffer_read(buffer, buffer_f32);
                    }
                }
                break;
            case gltfComponentType.SHORT:
                if(!self.check_buffer(buffer, view, localOffset)) {
                    self.critical("Buffer Overread for buffer");
                }
                buffer_seek(buffer, buffer_seek_start, view.byteOffset + localOffset);
                for(var elm=0; elm<self.elementLength; elm++) {
                    for(var val=0; val<self.valueLength; val++) {
                        self.value[(elm * self.valueLength) + val] = buffer_read(buffer, buffer_s16);
                    }
                }
                break;
            case gltfComponentType.UNSIGNED_BYTE:
                if(!self.check_buffer(buffer, view, localOffset)) {
                    self.critical("Buffer Overread for buffer");
                }
                buffer_seek(buffer, buffer_seek_start, view.byteOffset + localOffset);
                for(var elm=0; elm<self.elementLength; elm++) {
                    for(var val=0; val<self.valueLength; val++) {
                        self.value[(elm * self.valueLength) + val] = buffer_read(buffer, buffer_u8);
                    }
                }
                break;
            case gltfComponentType.UNSIGNED_INT:
                if(!self.check_buffer(buffer, view, localOffset)) {
                    self.critical("Buffer Overread for buffer");
                }
                buffer_seek(buffer, buffer_seek_start, view.byteOffset + localOffset);
                for(var elm=0; elm<self.elementLength; elm++) {
                    for(var val=0; val<self.valueLength; val++) {
                        self.value[(elm * self.valueLength) + val] = buffer_read(buffer, buffer_u32);
                    }
                }
                break;
            case gltfComponentType.UNSIGNED_SHORT:
                if(!self.check_buffer(buffer, view, localOffset)) {
                    self.critical("Buffer Overread for buffer");
                }
                buffer_seek(buffer, buffer_seek_start, view.byteOffset + localOffset);
                for(var elm=0; elm<self.elementLength; elm++) {
                    for(var val=0; val<self.valueLength; val++) {
                        self.value[(elm * self.valueLength) + val] = buffer_read(buffer, buffer_u16);
                    }
                }
                break;
            default:
                self.critical("Unknown ComponentType");
                break;
        }            
    }

    static set = function(value) {
        if(is_array(value) && (array_length(value) == self.valueLength)) {
            for(var elm=0; elm<self.elementLength; elm++) {
                for(var val=0; val<self.valueLength; val++) {
                    self.value[(elm * self.valueLength) + val] = value[val];
                }
            }
        } else {
            self.critical("Attempting to set bad value for a pdxGltfDataValue");
        }
    }

    static init = function() {
        for(var elm=0; elm<self.elementLength; elm++) {
            for(var val=0; val<self.valueLength; val++) {
                self.value[(elm * self.valueLength) + val] = 0;
            }
        }
    }
    
    static addSparse = function(count) {
        self.sparse = new pdxGltfSparseData(count);
    }
    
    static applySparse = function() {
        if(is_undefined(self.sparse)) {
            self.critical("Trying to apply sparse to a non-sparse accessor");
        }
        for(var _i=0; _i < self.sparse.count; _i++) {
            var elm = self.sparse.indices.value[_i];
            for(var val=0; val<self.valueLength; val++) {
                self.value[(elm * self.valueLength) + val] = self.sparse.values.value[(_i * self.valueLength) + val]; 
            }
        }
    }
    
    static prettyPrint = function() {
        var t = "[NON]"
        if(!is_undefined(self.target)) {
            if(self.target == gltfBufferViewTarget.ARRAY_BUFFER) {
                t = "[ARR]";
            } else if(self.target == gltfBufferViewTarget.ELEMENT_ARRAY_BUFFER) {
                t = "[ELM]";
            } else {
                t = "[UNK]";
            }
        }
        t += "[" + AccessorTypeToString(self.type) + ":" + ComponentTypeToString(self.elementType) + ":" + string(self.elementLength) + "] : ";
        if(self.elementLength < 10) {
            for(var _i=0; _i<self.elementLength; _i++) {
                if(_i > 0) {
                    t += ",";
                }
                t += string(self.getValue(_i));
            }
        } else {
            for(var _i=0; _i<10; _i++) {
                if(_i > 0) {
                    t += ",";
                }
                t += string(self.getValue(_i));
            }
            t += "...";
        }
            
        return t;
    }
}

function pdxGltfDataValueScalar(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 1;
    self.type = gltfAccessorType.SCALAR;
    self.value = array_create(valueCount * self.valueLength);
    
    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return self.value[_idx];
    }
}

function pdxGltfDataValueVector2(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 2;
    self.type = gltfAccessorType.VEC2;
    self.value = array_create(valueCount * self.valueLength);

    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return { u: self.value[_idx], v: self.value[_idx+1] };
    }
}

function pdxGltfDataValueVector3(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 3;
    self.type = gltfAccessorType.VEC3;
    self.value = array_create(valueCount * self.valueLength);

    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return { x: self.value[_idx], y: self.value[_idx+1], z: self.value[_idx+2] };
    }
}

function pdxGltfDataValueVector4(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 4;
    self.type = gltfAccessorType.VEC4;
    self.value = array_create(valueCount * self.valueLength);
    
    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return { x: self.value[_idx], y: self.value[_idx+1], z: self.value[_idx+2], w: self.value[_idx+3] };
    }
        
}

function pdxGltfDataValueMatrix2(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 2;
    self.type = gltfAccessorType.MAT2;
    self.value = array_create(valueCount * self.valueLength);
    
    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return [ self.value[_idx], self.value[_idx+1] ];
    }
}

function pdxGltfDataValueMatrix3(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 3;
    self.type = gltfAccessorType.MAT3;
    self.value = array_create(valueCount * self.valueLength);
    
    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return [ self.value[_idx], self.value[_idx+1], self.value[_idx+2] ];
    }
}

function pdxGltfDataValueMatrix4(valueCount, elementType): pdxGltfDataValue(valueCount, elementType) constructor {
    self.valueLength = 4;
    self.type = gltfAccessorType.MAT4;
    self.value = array_create(valueCount * self.valueLength);
    
    static getValue = function(index) {
        var _idx =  index * self.valueLength;
        return [ self.value[_idx], self.value[_idx+1], self.value[_idx+2], self.value[_idx+3] ];
    }
}

