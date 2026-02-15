#macro USE_DEFAULTS false

enum gltfVariableType {
    integer,
    float,
    vec3,
    vec4,
    object,
    array
}

enum gltfChunk {
    JSON = 0x4E4F534A,
    BIN  = 0x004E4942
}

enum gltfAccessorType {
    UNKNOWN = -1,
    SCALAR,
    VEC2,
    VEC3,
    VEC4,
    MAT2,
    MAT3,
    MAT4
}

enum gltfComponentType {
    UNKNOWN = -1,
    BYTE               = 5120,   //    signed byte     Signed, 2’s comp     8
    UNSIGNED_BYTE      = 5121,   //    unsigned byte   Unsigned             8
    SHORT              = 5122,   //    signed short    Signed, 2’s comp    16
    UNSIGNED_SHORT     = 5123,   //    unsigned short  Unsigned            16
    UNSIGNED_INT       = 5125,   //    unsigned int    Unsigned            32
    FLOAT              = 5126    //    float           Signed              32
}

enum gltfMeshPrimitiveMode {
    POINTS,
    LINES,
    LINE_LOOP,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    TRIANGLE_FAN
}

enum gltfBufferViewTarget {
    ARRAY_BUFFER = 34962,
    ELEMENT_ARRAY_BUFFER = 34963
}

function LeftFill(filler, value, digits) {
    var rval = string(value);
    var sl = string_length(rval);
    if(sl < digits) {
        rval = string_repeat(filler, digits - sl) + rval;
    }
    
    return rval;
}

function LeftFillZero(value, digits = 2) {
    return LeftFill("0", value, digits);
}

function LeftFillBlank(value, digits = 2) {
    return LeftFill(" ", value, digits);
}

function DrawModeToString(value) {
    var rval;
    switch(value) {
        case gltfMeshPrimitiveMode.POINTS:
            rval = "[SPOT]";
            break;
        case gltfMeshPrimitiveMode.LINES:
            rval = "[LINE]";
            break;
        case gltfMeshPrimitiveMode.LINE_LOOP:
            rval = "[LOOP]";
            break;
        case gltfMeshPrimitiveMode.LINE_STRIP:
            rval = "[LSPT]";
            break;
        case gltfMeshPrimitiveMode.TRIANGLES:
            rval = "[TRIS]";
            break;
        case gltfMeshPrimitiveMode.TRIANGLE_STRIP:
            rval = "[TSTP]";
            break;
        case gltfMeshPrimitiveMode.TRIANGLE_FAN:
            rval = "[TFAN]";
            break;
        default:
            rval = "[NONE]";
            break;
    }
    
    return rval;
}

function ComponentTypeToString(value) {
    switch(value) {
        case gltfComponentType.BYTE:
            return "S08";
        case gltfComponentType.FLOAT:
            return "F32";
        case gltfComponentType.SHORT:
            return "S16";
        case gltfComponentType.UNSIGNED_BYTE:
            return "U08";
        case gltfComponentType.UNSIGNED_INT:
            return "U32";
        case gltfComponentType.UNSIGNED_SHORT:
            return "U16";
    }    
    
    return false;
    
}

function AccessorTypeToString(value) {
    switch(value) {
        case gltfAccessorType.SCALAR:
            return "SCLR";
        case gltfAccessorType.VEC2:
            return "VEC2";
        case gltfAccessorType.VEC3:
            return "VEC3";
        case gltfAccessorType.VEC4:
            return "VEC4";
        case gltfAccessorType.MAT2:
            return "MAT2";
        case gltfAccessorType.MAT3:
            return "MAT3";
        case gltfAccessorType.MAT4:
            return "MAT4";
    }
    return "????";
}


function pdxGltfDataAbstractBase() : pdxException() constructor {
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
    self.unhandled                       = undefined;    // Any                             unhandled data
    static copyExtensions = function(object) {
        if(typeof(object) == "struct") {
            self.extensions = object;
            return true;
        }
        return false;
    }
    
    static copyExtras = function(value) {
        self.extras = value;
    }
    
    static copyUnhandled = function(name, value) {
        if(is_undefined(self.unhandled)) {
            self.unhandled = {};
        }
        self[$ "unhandled"][$ name] = value;
        self.addWarning("Unhandled " + typeof(value) + " value with key = " + string(name));
    }
    
    static copyObject = function(object) {
        if(typeof(object) == "struct") {
         struct_foreach(object, function(_name, _value) {
             self[$ _name] = _value;
             });
            return true;
        } else {
            return false;
        }
    }    
        
    static copyArray = function(target, array, type) {
        var _res = true;
        var _al = array_length(array);
        self[$ target] = array_create(_al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(array[_i]) == type) {
                self[$ target][_i] = array[_i];
            } else {
                self[$ target] = undefined;
                _res = false;
                self.addError("Array " + target + " index " + string(_i) + " value is not " + type);
                break;
            }
        }
        return _res;
    }
    
    static copyInteger = function(target, value) {
        var _res = true;
        if(typeof(value) == "number" && is_int(value)) {
            self[$ target] = value;
        } else {
            self[$ target] = undefined;
            _res = false;
            self.addError("Value " + target + " is not an integer");
        }
        return _res;
    }
    
    static copyFloat = function(target, value) {
        var _res = true;
        if(typeof(value) == "number") {
            self[$ target] = value;
        } else {
            self[$ target] = undefined;
            _res = false;
            self.addError("Value " + target + " is not a float");
        }
        return _res;
    }
    
    static copyMultiFloat = function(target, value, len) {
        var _res = true;
        if(typeof(value) != "array") {
            return false;
        }
        if(array_length(value) != len) {
            return false;
        }
        
        self[$ target] = array_create(len);
        
        for(var _i=0; _i < len; _i++) {
            if(typeof(value[_i]) == "number") {
                self[$ target][_i] = value[_i];
            } else {
                self[$ target] = undefined;
                _res = false;
                self.addError("Value " + target + " index " + string(_i) + " is not a float");
                break;
            }
        }
        return _res;
    }
    
    static copyString = function(target, value) {
        var _res = true;
        if(typeof(value) == "string") {
            self[$ target] = value;
        } else {
            self[$ target] = undefined;
            _res = false;
            self.addError("Value " + target + " is not a string");
        }
        return _res;
    }
    
    static copyIntegerArray = function(target, array) {
        var _res = true;
        var _al = array_length(array);
        self[$ target] = array_create(_al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(array[_i]) == "number" && is_int(array[_i])) {
                self[$ target][_i] = array[_i];
            } else {
                self[$ target] = undefined;
                _res = false;
                self.addError("Array " + target + " index " + string(_i) + " value is not an integer");
                break;
            }
        }
        return _res;
    }

}

function pdxGltfDataObject() : pdxGltfDataAbstractBase() constructor {
    self.extensionsUsed                  = undefined;    // string [1-*]                    Names of glTF extensions used in this asset.            No
    self.extensionsRequired              = undefined;    // string [1-*]                    Names of glTF extensions required to properly load      No
    self.accessors                       = undefined;    // accessor [1-*]                  An array of accessors.                                  No
    self.animations                      = undefined;    // animation [1-*]                 An array of keyframe animations.                        No
    self.asset                           = undefined;    // asset                           Metadata about the glTF asset.                          Yes
    self.buffers                         = undefined;    // buffer [1-*]                    An array of buffers.                                    No
    self.bufferViews                     = undefined;    // bufferView [1-*]                An array of bufferViews.                                No
    self.cameras                         = undefined;    // camera [1-*]                    An array of cameras.                                    No
    self.images                          = undefined;    // image [1-*]                     An array of images.                                     No
    self.materials                       = undefined;    // material [1-*]                  An array of materials.                                  No
    self.meshes                          = undefined;    // mesh [1-*]                      An array of meshes.                                     No
    self.nodes                           = undefined;    // node [1-*]                      An array of nodes.                                      No
    self.samplers                        = undefined;    // sampler [1-*]                   An array of samplers.                                   No
    self.scene                           = undefined;    // integer                         The index of the default scene.                         No
    self.scenes                          = undefined;    // scene [1-*]                     An array of scenes.                                     No
    self.skins                           = undefined;    // skin [1-*]                      An array of skins.                                      No
    self.textures                        = undefined;    // texture [1-*]                   An array of textures.                                   No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
    
    static init = function(object) {
        struct_foreach(object, function(_name, _value) {
            // show_debug_message("Type of " + string(_name) + " = " + typeof( _value) );
            var _val_type = typeof(_value);
            if(_name == "extras") {
                self.copyExtras(_value);
            } else {
                switch(_val_type) {
                    case "array":
                        var _al = array_length(_value);
                        switch(_name) {
                            case  "extensionsRequired":
                                if(!self.copyArray("extensionsRequired", _value, "string")) {
                                    self.addError("Bad Array for extensionsRequired");
                                }
                                break;
                            case "extensionsUsed":
                                if(!self.copyArray("extensionsUsed", _value, "string")) {
                                    self.addError("Bad Array for extensionsUsed");
                                }
                                break;
                            case "scenes":
                                self.scenes = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.scenes[_i] = new pdxGltfDataScene();
                                    self.scenes[_i].init(_value[_i]);
                                }
                                break;
                            case "nodes":
                                self.nodes = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.nodes[_i] = new pdxGltfDataNode();
                                    self.nodes[_i].init(_value[_i]);
                                }
                                break;
                            case "materials":
                                self.materials = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.materials[_i] = new pdxGltfDataMaterial();
                                    self.materials[_i].init(_value[_i]);
                                }
                                break;
                            case "meshes":
                                self.meshes = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.meshes[_i] = new pdxGltfDataMesh();
                                    self.meshes[_i].init(_value[_i]);
                                }
                                break;
                            case "textures":
                                self.textures = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.textures[_i] = new pdxGltfDataTexture();
                                    self.textures[_i].init(_value[_i]);
                                }
                                break;
                            case "images":
                                self.images = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.images[_i] = new pdxGltfDataImage();
                                    self.images[_i].init(_value[_i]);
                                }
                                break;
                            case "accessors":
                                self.accessors = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.accessors[_i] = new pdxGltfDataAccessor();
                                    self.accessors[_i].init(_value[_i]);
                                }
                                break;
                            case "bufferViews":
                                self.bufferViews = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.bufferViews[_i] = new pdxGltfDataBufferView();
                                    self.bufferViews[_i].init(_value[_i]);
                                }
                                break;
                            case "buffers":
                                self.buffers = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.buffers[_i] = new pdxGltfDataBuffer();
                                    self.buffers[_i].init(_value[_i]);
                                }
                                break;
                            case "samplers":
                                self.samplers = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.samplers[_i] = new pdxGltfDataSampler();
                                    self.samplers[_i].init(_value[_i]);
                                }
                                break;
                            case "skins":
                                self.skins = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.skins[_i] = new pdxGltfDataSkin();
                                    self.skins[_i].init(_value[_i]);
                                }
                                break;
                            case "animations":
                                self.animations = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.animations[_i] = new pdxGltfDataAnimation();
                                    self.animations[_i].init(_value[_i]);
                                }
                                break;
                            case "cameras":
                                self.cameras = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.cameras[_i] = new pdxGltfDataCamera();
                                    self.cameras[_i].init(_value[_i]);
                                }
                                break;
                            default:
                                self.addError("Unhandled " + _name);
                                self.copyUnhandled(_name, _value);
                                break;
                        }
                        break;
                    case "struct":
                        switch(_name) {
                            case "asset":
                                self.asset = new pdxGltfDataAsset();
                                self.asset.init(_value);
                                break;
                            case "extensions":
                                if(!self.copyExtensions(_value)) {
                                    self.addError("glTF extensions expected struct - got " + typeof(_value));
                                }
                                break;
                            default:
                                self.copyUnhandled(_name, _value);
                                break;
                        }
                        break;
                    case "number":
                        switch(_name) {
                            case "scene":
                                self.scene = _value;
                                break;
                            default:
                                self.copyUnhandled(_name, _value);
                                break;
                        }
                        break;
                    default:
                        if(_name == "extras") {
                            self.copyExtensions(_value);
                        } else {
                            self.copyUnhandled(_name, _value);
                        }
                        break;
                }
            }
        }
        
        
        );    
        
        if(is_undefined(self.asset)) {
            self.critical("Model is missing required asset element");
        }
    }
}

function pdxGltfDataAsset() : pdxGltfDataAbstractBase() constructor {
    self.copyright                       = undefined;    // string                          copyright for display to credit the content creator     No
    self.generator                       = undefined;    // string                          Tool that generated this glTF model                     No
    self.version                         = undefined;    // string                          The glTF version in the form of <major>.<minor>         Yes
    self.minVersion                      = undefined;    // string                          The minimum glTF version in the form of <major>.<minor> No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of scene is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "version") {
                if(!self.copyString("version", _value)) {
                    self.addError("asset element version is not a string");
                }
            } else if(_name == "copyright") {
                if(!self.copyString("copyright", _value)) {
                    self.addError("asset element copyright is not a string");
                }
            } else if(_name == "generator") {
                if(!self.copyString("generator", _value)) {
                    self.addError("asset element generator is not a string");
                }
            } else if(_name == "minVersion") {
                if(!self.copyString("minVersion", _value)) {
                    self.addError("asset element minVersion is not a string");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_undefined(self.version)) {
            self.critical("GLTF is missing REQUIRED version value in asset section");
        }
    }
}

function pdxGltfDataScene() : pdxGltfDataAbstractBase() constructor {
    self.nodes                           = undefined;    // integer [1-*]                   The indices of each root node.                          No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of scene is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("Scene name is not a string");
                }
            } else if(_name == "nodes") {
                if(typeof(_value) == "array") {
                    if(!self.copyIntegerArray("nodes", _value)) {
                        self.addError("Bad Array for nodes");
                    }
                } else {
                    self.addError("Node nodes is not an array");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });

    }
}

function pdxGltfDataNode() : pdxGltfDataAbstractBase() constructor {
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.children                        = undefined;    // integer [1-*]                   The indices of this node’s children.                    No, default: [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]
    self.mesh                            = undefined;    // integer                         The index of the mesh in this node.                     No
    self.camera                          = undefined;    // integer                         The index of the camera referenced by this node.        No
    self.skin                            = undefined;    // integer                         The index of the skin referenced by this node.          No
    self.matrix                          = undefined;    // number [16]                     A floating-point 4x4 transformation matrix              No
    self.rotation                        = undefined;    // number [4]                      The node’s unit quaternion rotation (x, y, z, w)        No, default: [0,0,0,1]
    self.scale                           = undefined;    // number [3]                      The node’s non-uniform scale along x, y, and z          No, default: [1,1,1]
    self.translation                     = undefined;    // number [3]                      The node’s translation along the x, y, and z axes.      No, default: [0,0,0]
    self.weights                         = undefined;    // number [1-*]                    The weights of the instantiated morph target.           No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(typeof(_value) == "string") {
                    self.name = _value;
                } else {
                    self.addError("Node name is not a string");
                }
            } else if(_name == "children") {
                if(typeof(_value) == "array") {
                    if(!self.copyIntegerArray("children", _value)) {
                        self.addError("Bad Array for children");
                    }
                } else {
                    self.addError("Node children is not an array");
                }
            } else if(_name == "skin") { 
                if(!self.copyInteger("skin", _value)) {
                    self.addError("node element skin is not an integer");
                }
            } else if(_name == "camera") { 
                if(!self.copyInteger("camera", _value)) {
                    self.addError("node element camera is not an integer");
                }
            } else if(_name == "mesh") { 
                if(!self.copyInteger("mesh", _value)) {
                    self.addError("node element mesh is not an integer");
                }
            
            } else if(_name == "scale") { 
                if(!self.copyMultiFloat("scale", _value, 3)) {
                    self.addError("Bad Array for node element scale");
                }
            } else if(_name == "translation") { 
                if(!self.copyMultiFloat("translation", _value, 3)) {
                    self.addError("Bad Array for node element translation");
                }
            } else if(_name == "rotation") { 
                if(!self.copyMultiFloat("rotation", _value, 4)) {
                    self.addError("Bad Array for node element rotation");
                }
            } else if(_name == "weights") { 
                if(!self.copyArray("weights", _value, "number")) {
                    self.addError("Bad Array for node element weights");
                }
            } else if(_name == "matrix") { 
                if(!self.copyMultiFloat("matrix", _value, 16)) {
                    self.addError("Bad Array for node element matrix");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            
        });
		
        if(USE_DEFAULTS) {
	        if(is_undefined(self.matrix)) {
	            self.matrix = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
	        }
	        if(is_undefined(self.rotation)) {
	            self.rotation = [0,0,0,1];
	        }
	        if(is_undefined(self.scale)) {
	            self.scale = [1,1,1];
	        }
	        if(is_undefined(self.translation)) {
	            self.translation = [0,0,0];
	        }
		}
        
    }
}
 
function pdxGltfDataMesh() : pdxGltfDataAbstractBase() constructor {
    self.primitives                      = undefined;    // mesh.primitive [1-*]            An array of primitives, each defining geometry.         Yes
    self.weights                         = undefined;    // number [1-*]                    Array of weights to be applied to the morph targets.    No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("Mesh name is not a string");
                }
            } else if(_name == "primitives") {
                if(typeof(_value) == "array") {
                    var _al = array_length(_value);
                    self.primitives = array_create(_al);
                    for(var _i = 0; _i<_al; _i++) {
                        self.primitives[_i] = new pdxGltfDataMeshPrimitive();
                        self.primitives[_i].init(_value[_i]);
                    }
                } else {
                    self.addError("Mesh primitives is not an array");
                }
            } else if(_name == "weights") { 
                if(typeof(_value) == "array") {
                    var _al = array_length(_value);
                } else {
                    self.addError("Mesh weights is not an array");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });

        // self.attributes is REQUIRED
        if(is_undefined(self.primitives)) {
            self.critical("Mesh has no primitives");
        }                
    }
}

function pdxGltfDataMeshPrimitive() : pdxGltfDataAbstractBase() constructor {
    self.attributes                      = undefined;    // object                          A plain JSON object,                                    Yes
    self.indices                         = undefined;    // integer                         The index of the accessor containing vertex indices.    No
    self.material                        = undefined;    // integer                         The index of the material to apply.                     No
    self.mode                            = undefined;    // integer                         The topology type of primitives to render.              No, default: 4
    self.targets                         = undefined;    // object [1-*]                    An array of morph targets.                              No
    
    static prettyPrint = function() {
        var txt = "";
        if(!is_undefined(self.mode)) {
            txt += DrawModeToString(self.mode); 
        } else {
            txt += "[----]"
        }
        if(!is_undefined(self.material)) {
           txt += "[MAT:" + LeftFillBlank(self.material) + "]";
        } else {
            txt += "[MAT:XX]";
        }
        if(!is_undefined(self.indices)) {
           txt += "[IND:" + LeftFillBlank(self.indices) + "]";
        } else {
            txt += "[IND:XX]";
        }
        if(!is_undefined(self.attributes)) {
            txt += ":ATTR: " + self.attributes.prettyPrint();
        } else {
            txt += ":ATTR: <NONE>";
        }
        
        return txt;
    }
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "attributes") {
                if(typeof(_value) == "struct") {
                    self.attributes = new pdxGltfDataMeshAttributes();
                    self.attributes.init(_value);
                } else {
                    self.addError("primitive element attributes is not a struct");
                }
            } else if(_name == "indices") {
                if(!self.copyInteger("indices", _value)) {
                    self.addError("primitive element indices is not an integer");
                }
            } else if(_name == "material") {
                if(!self.copyInteger("material", _value)) {
                    self.addError("primitive element material is not an integer");
                }
            } else if(_name == "mode") {
                if(!self.copyInteger("mode", _value)) {
                    self.addError("primitive element mode is not an integer");
                }
            } else if(_name == "targets") {
                if(typeof(_value) == "array") {
                    var _al = array_length(_value);
                    self.targets = array_create(_al);
                    for(var _i = 0; _i<_al; _i++) {
                        self.tagets[_i] = _value[_i];
                    }
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        // self.mode is optional with a default value of 4
        if(is_undefined(self.mode)) {
            self.mode = 4;
        }
        // self.attributes is REQUIRED
        if(is_undefined(self.attributes)) {
            self.critical("Mesh has no attributes");
        }
    }
}

function pdxGltfDataMeshAttributes() : pdxGltfDataAbstractBase() constructor {
    self.POSITION                        = undefined;
    self.NORMAL                          = undefined;
    self.TANGENT                         = undefined;
    self.texcoord                        = undefined;
    self.color                           = undefined;
    self.joints                          = undefined;
    self.weights                         = undefined;
    
    static prettyPrint = function() {
        var txt = "";
        
        if(!is_undefined(self.POSITION)) {
           txt += "[POS:" + LeftFillBlank(self.POSITION) + "]";
        } else {
            txt += "[POS:XX]";
        }
        if(!is_undefined(self.NORMAL)) {
           txt += "[NML:" + LeftFillBlank(self.NORMAL) + "]";
        } else {
            txt += "[NML:XX]";
        }
        if(is_array(self.texcoord)) {
            txt += "[";
            for(var _i=0, _n = array_length(self.texcoord); _i < _n; _i++) {
                if(_i > 0) {
                    txt += "|";
                }
                txt += "TEX" + string(_i) + ":" + LeftFillBlank(self.texcoord[_i]);
            }
            txt += "]";
        } else {
            txt += "[TEX:---]";
        }
        
        return txt;
    }
    
    // Some primitive entries are of the form <NAME>_<INDEX>
    // This will split out the index and convert into array format
    static setUnderscoreArrayValue = function(target, name, value) {
        var index = -1;

        var underscore_parts = string_split(string_trim(name), "_", true);
        if(array_length(underscore_parts) == 2) {
            if(is_string_numeric(underscore_parts[1])) {
                index = int64(underscore_parts[1]);
            }
        } else {
            return false;    
        }
        if(index < 0) {
            return false;    
        }
        // The order of creation may not be sequntial so when
        // defining array set any lower indicies to undefined
        // as this will allow trapping bad values easier
        if(is_undefined(self[$ target])) {
            self[$ target] = array_create((index + 1), undefined);
        }
        // Note that it is _possible_ that this may create
        // an array value of zero (bad + possibly wrong)
        // Workaround would be cumbersome and highly unlikely
        if(array_length(self[$ target]) < (index + 1)) {
            array_resize(self[$ target], index + 1);
        }
        
        if(is_int(value)) {
            self[$ target][index] = value;
            return true;
        }
        
        return false;        
    }
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "POSITION") {
                if(!self.copyInteger("POSITION", _value)) {
                    self.addError("attribute element POSITION is not an integer");
                }
            } else if(_name == "NORMAL") {
                if(!self.copyInteger("NORMAL", _value)) {
                    self.addError("attribute element NORMAL is not an integer");
                }
            } else if(_name == "TANGENT") {
                if(!self.copyInteger("TANGENT", _value)) {
                    self.addError("attribute element TANGENT is not an integer");
                }
            } else if(string_starts_with(_name, "COLOR_")) { 
                if(!self.setUnderscoreArrayValue("color",_name, _value)) {
                    self.addError("attribute element " + _name + " is not an integer");
                }
            } else if(string_starts_with(_name, "TEXCOORD_")) { 
                if(!self.setUnderscoreArrayValue("texcoord",_name, _value)) {
                    self.addError("attribute element " + _name + " is not an integer");
                }
            } else if(string_starts_with(_name, "JOINTS_")) {
                if(!self.setUnderscoreArrayValue("joints",_name, _value)) {
                    self.addError("attribute element " + _name + " is not an integer");
                }
            } else if(string_starts_with(_name, "WEIGHTS_")) {
                if(!self.setUnderscoreArrayValue("weights",_name, _value)) {
                    self.addError("attribute element " + _name + " is not an integer");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_array(self.texcoord)) {
            var _al = array_length(self.texcoord);
            for(var _i=0; _i<_al;_i++) {
                if(is_undefined(self.texcoord[_i])) {
                    self.critical("TEXCOORDs are not sequential")
                }
                if(self.texcoord[_i] == 0) {
                    self.addWarning("Suspicious TEXCOORDs value of zero")
                }
            }
        }
        if(is_array(self.joints)) {
            var _al = array_length(self.joints);
            for(var _i=0; _i<_al;_i++) {
                if(is_undefined(self.joints[_i])) {
                    self.critical("JOINTs are not sequential")
                }
                if(self.joints[_i] == 0) {
                    self.addWarning("Suspicious JOINTs value of zero")
                }
            }
        }
        if(is_array(self.weights)) {
            var _al = array_length(self.weights);
            for(var _i=0; _i<_al;_i++) {
                if(is_undefined(self.weights[_i])) {
                    self.critical("WEIGHTs are not sequential")
                }
                if(self.weights[_i] == 0) {
                    self.addWarning("Suspicious WEIGHTs value of zero")
                }
            }
        }
    
    }
}

function pdxGltfDataMaterial() : pdxGltfDataAbstractBase() constructor {
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.pbrMetallicRoughness            = undefined;    // material.pbrMetallicRoughness   PBR metallic-roughness material model                   No
    self.normalTexture                   = undefined;    // material.normalTextureInfo      The tangent space normal texture.                       No                          
    self.occlusionTexture                = undefined;    // material.occlusionTextureInfo   The occlusion texture.                                  No                          
    self.emissiveTexture                 = undefined;    // textureInfo                     The emissive texture.                                   No                         
    self.emissiveFactor                  = undefined;    // number [3]                      The factors for the emissive color of the material.     No, default: [0,0,0]       
    self.alphaMode                       = undefined;    // string                          The alpha rendering mode of the material.               No, default: "OPAQUE"
    self.alphaCutoff                     = undefined;    // number                          The alpha cutoff value of the material.                 No, default: 0.5
    self.doubleSided                     = undefined;    // boolean                         Specifies whether the material is double sided.         No
    
    static getBaseColor = function() {
        var col = undefined;
        
        if(!is_undefined(self.pbrMetallicRoughness)) {
            col = self.pbrMetallicRoughness.baseColorFactor;
        }
        
        return col;
    }

    static getBaseTexture = function() {
        var tex = undefined;
        
        if(!is_undefined(self.pbrMetallicRoughness)) {
            tex = self.pbrMetallicRoughness.baseColorTexture;
        }
        
        return tex;
    }

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("material element name is not a string");
                }
            } else if(_name == "pbrMetallicRoughness") {
                if(typeof(_value)=="struct") {
                    self.pbrMetallicRoughness = new pdxGltfDataMaterialPbrMetallicRoughness();
                    self.pbrMetallicRoughness.init(_value);
                } else {
                    self.addError("material element pbrMetallicRoughness is not a struct");
                }
            } else if(_name == "normalTexture") {
                if(typeof(_value)=="struct") {
                    self.normalTexture = new pdxGltfDataMaterialNormalTextureInfo();
                    self.normalTexture.init(_value);
                } else {
                    self.addError("material element normalTexture is not a struct");
                }
            } else if(_name == "occlusionTexture") {
                if(typeof(_value)=="struct") {
                    self.occlusionTexture = new pdxGltfDataMaterialOcclusionTextureInfo();
                    self.occlusionTexture.init(_value);
                } else {
                    self.addError("material element occlusionTexture is not a struct");
                }
            } else if(_name == "emissiveTexture") {
                if(typeof(_value)=="struct") {
                    self.emissiveTexture = new pdxGltfDataTextureInfo();
                    self.emissiveTexture.init(_value);
                } else {
                    self.addError("material element emissiveTexture is not a struct");
                }
            } else if(_name == "emissiveFactor") {
                if(!self.copyMultiFloat("emissiveFactor", _value, 3)) {
                    self.addError("material element emissiveFactor is not a float(3)");
                }
            } else if(_name == "alphaMode") {
                if(!self.copyString("alphaMode", _value)) {
                    self.addError("material element alphaMode is not a string");
                }
            } else if(_name == "alphaCutoff") {
                if(!self.copyFloat("alphaCutoff", _value)) {
                    self.addError("material element alphaCutoff is not a float");
                }
            } else if(_name == "doubleSided") {
                if(typeof(_value) == "bool") {
                    self.doubleSided = _value;
                } else {
                    self.addError("material element doubleSided is not a bool");
                }            
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            } else {
                self.copyUnhandled(_name, _value);
            }
        });
        
        if(is_undefined(self.alphaMode)) {
            self.alphaMode = "OPAQUE";
        }
        if(is_undefined(self.alphaCutoff)) {
            self.alphaCutoff = 0.5;
        }
        if(is_undefined(self.emissiveFactor)) {
            self.emissiveFactor = [0, 0, 0];
        }    
    }
    

}

function pdxGltfDataMaterialPbrMetallicRoughness() : pdxGltfDataAbstractBase() constructor {
    self.baseColorFactor                 = undefined;    // number [4]                      The factors for the base color of the material.         No, default: [1,1,1,1]
    self.baseColorTexture                = undefined;    // textureInfo                     The base color texture.                                 No
    self.metallicFactor                  = undefined;    // number                          The factor for the metalness of the material.           No, default: 1
    self.roughnessFactor                 = undefined;    // number                          The factor for the roughness of the material.           No, default: 1
    self.metallicRoughnessTexture        = undefined;    // textureInfo                     The metallic-roughness texture.                         No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "baseColorFactor") {
                if(!self.copyMultiFloat("baseColorFactor", _value, 4)) {
                    self.addError("material element baseColorFactor is not a float(4)");
                }
            } else if(_name == "metallicFactor") {
                if(!self.copyFloat("metallicFactor", _value)) {
                    self.addError("material element metallicFactor is not a float");
                }
            } else if(_name == "roughnessFactor") {
                if(!self.copyFloat("roughnessFactor", _value)) {
                    self.addError("material element roughnessFactor is not a float");
                }
            } else if(_name == "baseColorTexture") {
                if(typeof(_value)=="struct") {
                    self.baseColorTexture = new pdxGltfDataTextureInfo();
                    self.baseColorTexture.init(_value);
                } else {
                    self.addError("material element baseColorTexture is not a struct");
                }
            } else if(_name == "metallicRoughnessTexture") {
                if(typeof(_value)=="struct") {
                    self.metallicRoughnessTexture = new pdxGltfDataTextureInfo();
                    self.metallicRoughnessTexture.init(_value);
                } else {
                    self.addError("material element metallicRoughnessTexture is not a struct");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_undefined(self.metallicFactor)) {
            self.metallicFactor = 1;
        }
        if(is_undefined(self.roughnessFactor)) {
            self.roughnessFactor = 1;
        }
        if(is_undefined(self.baseColorFactor)) {
            self.baseColorFactor = [1, 1, 1, 1];
        }    
    }
    
}

function pdxGltfDataMaterialNormalTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD attribute           No, default: 0
    self.scale                           = undefined;    // number                          The scalar parameter applied to each normalTex vector   No, default: 1
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of TewxtureInfo is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "index") {
                if(!self.copyInteger("index", _value)) {
                    self.addError("material element index is not an integer");
                }
            } else if(_name == "texCoord") {
                if(!self.copyInteger("texCoord", _value)) {
                    self.addError("material element texCoord is not an integer");
                }
            } else if(_name == "scale") {
                if(!self.copyFloat("scale", _value)) {
                    self.addError("material element scale is not a float");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_undefined(self.texCoord)) {
            self.texCoord = 0;
        }

        if(is_undefined(self.scale)) {
            self.scale = 1;
        }
        if(is_undefined(self.index)) {
            self.critical("TextureInfo index not set");
        }
    
    }
    
}

function pdxGltfDataMaterialOcclusionTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    self.strength                        = undefined;    // number                          A scalar multiplier for the amount of occlusion.        No, default: 1
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of TewxtureInfo is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "index") {
                if(!self.copyInteger("index", _value)) {
                    self.addError("material element index is not an integer");
                }
            } else if(_name == "texCoord") {
                if(!self.copyInteger("texCoord", _value)) {
                    self.addError("material element texCoord is not an integer");
                }
            } else if(_name == "strength") {
                if(!self.copyFloat("strength", _value)) {
                    self.addError("material element strength is not a float");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_undefined(self.texCoord)) {
            self.texCoord = 0;
        }
        if(is_undefined(self.strength)) {
            self.strength = 1;
        }
        if(is_undefined(self.index)) {
            self.critical("TextureInfo index not set");
        }
    
    }
    
}

function pdxGltfDataTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of TewxtureInfo is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "index") {
                if(!self.copyInteger("index", _value)) {
                    self.addError("material element index is not an integer");
                }
            } else if(_name == "texCoord") {
                if(!self.copyInteger("texCoord", _value)) {
                    self.addError("material element texCoord is not an integer");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_undefined(self.texCoord)) {
            self.texCoord = 0;
        }
        if(is_undefined(self.index)) {
            self.critical("TextureInfo index not set");
        }
    
    }
    
}

function pdxGltfDataSampler() : pdxGltfDataAbstractBase() constructor {
    self.magFilter                       = undefined;    // integer                         Magnification filter.                                   No
    self.minFilter                       = undefined;    // integer                         Minification filter.                                    No
    self.wrapS                           = undefined;    // integer                         S (U) wrapping mode.                                    No, default: 10497
    self.wrapT                           = undefined;    // integer                         T (V) wrapping mode.                                    No, default: 10497
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("sampler name is not a string");
                }
            } else if(_name == "magFilter") { 
                if(!self.copyInteger("magFilter", _value)) {
                    self.addError("sampler element magFilter is not an integer");
                }
            } else if(_name == "minFilter") { 
                if(!self.copyInteger("minFilter", _value)) {
                    self.addError("sampler element minFilter is not an integer");
                }
            } else if(_name == "wrapS") { 
                if(!self.copyInteger("wrapS", _value)) {
                    self.addError("sampler element wrapS is not an integer");
                }
            } else if(_name == "wrapT") { 
                if(!self.copyInteger("wrapT", _value)) {
                    self.addError("sampler element wrapT is not an integer");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        
        if(is_undefined(self.wrapS)) {
            self.wrapS = 10497;
        }
        if(is_undefined(self.wrapT)) {
            self.wrapT = 10497;
        }
        
    }     
}

function pdxGltfDataAccessor() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the bufferView.                            No
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0
    self.componentType                   = undefined;    // integer                         The datatype of the accessor’s components.              Yes
    self.normalized                      = undefined;    // boolean                         Integer values are normalized before usage.             No, default: false
    self.count                           = undefined;    // integer                         The number of elements referenced by this accessor.     Yes
    self.type                            = undefined;    // string                          Specifies the accessor’s type                           Yes
    self.max                             = undefined;    // number [1-16]                   Maximum value of each component in this accessor.       No
    self.min                             = undefined;    // number [1-16]                   Minimum value of each component in this accessor.       No
    self.sparse                          = undefined;    // accessor.sparse                 Sparse storage of elements that deviate.                No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("accessor name is not a string");
                }
            } else if(_name == "type") {
                if(!self.copyString("type", _value)) {
                    self.addError("accessor type is not a string");
                }
            } else if(_name == "normalized") {
                if(typeof(_value) == "bool") {
                    self.normalized = _value;
                } else {
                    self.addError("accessor normalized is not a bool");
                }
            } else if(_name == "bufferView") { 
                if(!self.copyInteger("bufferView", _value)) {
                    self.addError("accessor element bufferView is not an integer");
                }
            } else if(_name == "byteOffset") { 
                if(!self.copyInteger("byteOffset", _value)) {
                    self.addError("accessor element byteOffset is not an integer");
                }
            } else if(_name == "componentType") { 
                if(!self.copyInteger("componentType", _value)) {
                    self.addError("accessor element componentType is not an integer");
                }
            } else if(_name == "count") { 
                if(!self.copyInteger("count", _value)) {
                    self.addError("accessor element count is not an integer");
                }
            } else if(_name == "min") { 
                if(!self.copyArray("min", _value, "number")) {
                    self.addError("Bad Array for accessor element min");
                }
            } else if(_name == "max") { 
                if(!self.copyArray("max", _value, "number")) {
                    self.addError("Bad Array for accessor element max");
                }
            } else if(_name == "sparse") { 
                self.sparse = new pdxGltfDataAccessorSparse();
                self.sparse.init(_value);
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        
        if(is_undefined(self.normalized)) {
            self.normalized = false;
        }
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.componentType)) {
            self.critical("accessor componentType not set");
        }
        if(is_undefined(self.type)) {
            self.critical("accessor type not set");
        }
        if(is_undefined(self.count)) {
            self.critical("accessor count not set");
        }
        
    } 
}


function pdxGltfDataBuffer() : pdxGltfDataAbstractBase() constructor {
    self.uri                             = undefined;    // string                          The URI (or IRI) of the buffer.                         No
    self.byteLength                      = undefined;    // integer                         The length of the buffer in bytes.                      Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
//    self.data                            = undefined;    // binary (internal)               Read on build stage                                     No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "byteLength") {
                if(!self.copyInteger("byteLength", _value)) {
                    self.addError("buffer element byteLength is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("buffer element name is not a string");
                }
            } else if(_name == "uri") {
                if(!self.copyString("uri", _value)) {
                    self.addError("buffer element uri is not a string");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });

        if(is_undefined(self.byteLength)) {
            self.critical("buffer byteLength not set");
        }
    }

}

function pdxGltfDataBufferView() : pdxGltfDataAbstractBase() constructor {
    self.buffer                          = undefined;    // integer                         The index of the buffer.                                Yes
    self.byteOffset                      = undefined;    // integer                         The offset into the buffer in bytes.                    No, default: 0
    self.byteLength                      = undefined;    // integer                         The length of the bufferView in bytes.                  Yes
    self.byteStride                      = undefined;    // integer                         The stride, in bytes.                                   No
    self.target                          = undefined;    // integer                         The hint representing the intended GPU buffer type      No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "buffer") {
                if(!self.copyInteger("buffer", _value)) {
                    self.addError("bufferView element buffer is not an integer");
                }
            } else if(_name == "byteOffset") {
                if(!self.copyInteger("byteOffset", _value)) {
                    self.addError("bufferView element byteOffset is not an integer");
                }
            } else if(_name == "byteLength") {
                if(!self.copyInteger("byteLength", _value)) {
                    self.addError("bufferView element byteLength is not an integer");
                }
            } else if(_name == "byteStride") {
                if(!self.copyInteger("byteStride", _value)) {
                    self.addError("bufferView element byteStride is not an integer");
                }
            } else if(_name == "target") {
                if(!self.copyInteger("target", _value)) {
                    self.addError("bufferView element target is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("bufferView element name is not a string");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.buffer)) {
            self.critical("buffer buffer not set");
        }
        if(is_undefined(self.byteLength)) {
            self.critical("buffer byteLength not set");
        }
    }
}

function pdxGltfDataCamera() : pdxGltfDataAbstractBase() constructor {
    self.orthographic                    = undefined;    // camera.orthographic             An orthographic camera                                  No
    self.perspective                     = undefined;    // camera.perspective              A perspective camera                                    No
    self.type                            = undefined;    // string                          camera uses a perspective or orthographic projection.   Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of camera is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("camera element name is not a string");
                }
            } else if(_name == "type") {
                if(!self.copyString("type", _value)) {
                    self.addError("camera element type is not a string");
                }
            } else if(_name == "orthographic") { 
                if(typeof(_value) == "struct") {
                    self.orthographic = new pdxGltfDataCameraOrthographic();
                    self.orthographic.init(_value);
                } else {
                    self.addError("accessor.sparse element indices is not a struct");
                }
            } else if(_name == "perspective") { 
                if(typeof(_value) == "struct") {
                    self.perspective = new pdxGltfDataCameraPerspective();
                    self.perspective.init(_value);
                } else {
                    self.addError("accessor.sparse element indices is not a struct");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        if(is_undefined(self.type)) {
            self.critical("camera type not set");
        }
    }
}

function pdxGltfDataCameraOrthographic() : pdxGltfDataAbstractBase() constructor {
    self.xmag                            = undefined;    // number                          The horizontal magnification of the view. > 0           Yes
    self.ymag                            = undefined;    // number                          The vertical magnification of the view. > 0             Yes
    self.zfar                            = undefined;    // number                          The distance to the far clipping plane. > 0 > znear.    Yes
    self.znear                           = undefined;    // number                          The floating-point distance to the near clipping plane. Yes
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of camera is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "xmag") {
                if(!self.copyFloat("xmag", _value)) {
                    self.addError("orthographic camera element xmag is not a float");
                }
            } else if(_name == "ymag") {
                if(!self.copyFloat("ymag", _value)) {
                    self.addError("orthographic camera element ymag is not a float");
                }
            } else if(_name == "zfar") {
                if(!self.copyFloat("zfar", _value)) {
                    self.addError("orthographic camera element zfar is not a float");
                }
            } else if(_name == "znear") {
                if(!self.copyFloat("znear", _value)) {
                    self.addError("orthographic camera element znear is not a float");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        if(is_undefined(self.xmag)) {
            self.critical("camera xmag not set");
        }
        if(is_undefined(self.ymag)) {
            self.critical("camera ymag not set");
        }
        if(is_undefined(self.znear)) {
            self.critical("camera znear not set");
        }
        if(is_undefined(self.zfar)) {
            self.critical("camera zfar not set");
        }
    }
    
}

function pdxGltfDataCameraPerspective() : pdxGltfDataAbstractBase() constructor {
    self.aspectRatio                     = undefined;    // number                          The aspect ratio of the field of view.                  No
    self.yfov                            = undefined;    // number                          The vertical field of view in radians. < π.             Yes
    self.zfar                            = undefined;    // number                          The floating-point distance to the far clipping plane.  No
    self.znear                           = undefined;    // number                          The floating-point distance to the near clipping plane. Yes

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of camera is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "aspectRatio") {
                if(!self.copyFloat("aspectRatio", _value)) {
                    self.addError("perspective camera element aspectRatio is not a float");
                }
            } else if(_name == "yfov") {
                if(!self.copyFloat("yfov", _value)) {
                    self.addError("perspective camera element yfov is not a float");
                }
            } else if(_name == "zfar") {
                if(!self.copyFloat("zfar", _value)) {
                    self.addError("perspective camera element zfar is not a float");
                }
            } else if(_name == "znear") {
                if(!self.copyFloat("znear", _value)) {
                    self.addError("perspective camera element znear is not a float");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
        if(is_undefined(self.fov)) {
            self.critical("camera fov not set");
        }
        if(is_undefined(self.zfar)) {
            self.critical("camera zfar not set");
        }
    }

}

function pdxGltfDataImage() : pdxGltfDataAbstractBase() constructor {
    self.uri                             = undefined;    // string                          The URI (or IRI) of the image.                          No
    self.mimeType                        = undefined;    // string                          The image’s media type.                                 No
    self.bufferView                      = undefined;    // integer                         The index of the bufferView that contains the image     No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
//    self.data                            = undefined;    // binary (internal)               Read on build stage                                     No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of image is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "bufferView") {
                if(!self.copyInteger("bufferView", _value)) {
                    self.addError("image element bufferView is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("image element name is not a string");
                }
            } else if(_name == "uri") {
                if(!self.copyString("uri", _value)) {
                    self.addError("image element uri is not a string");
                }
            } else if(_name == "mimeType") {
                if(!self.copyString("mimeType", _value)) {
                    self.addError("image element mimeType is not a string");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
        });
    }
}


function pdxGltfDataTexture() : pdxGltfDataAbstractBase() constructor {
    self.sampler                         = undefined;    // integer                         The index of the sampler used by this texture           No
    self.source                          = undefined;    // integer                         The index of the image used by this texture             No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("texture name is not a string");
                }
            } else if(_name == "sampler") { 
                if(!self.copyInteger("sampler", _value)) {
                    self.addError("texture element sampler is not an integer");
                }
            } else if(_name == "source") { 
                if(!self.copyInteger("source", _value)) {
                    self.addError("texture element source is not an integer");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        
    }
}

function pdxGltfDataAccessorSparse() : pdxGltfDataAbstractBase() constructor {
    self.count                           = undefined;    // integer                         Number of deviating accessor vals in the sparse array   Yes
    self.indices                         = undefined;    // accessor.sparse.indices         An object pointing to a buffer view of indices          Yes
    self.values                          = undefined;    // accessor.sparse.values          An object pointing to a buffer view of values           Yes
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "count") {
                if(!self.copyInteger("count", _value)) {
                    self.addError("accessor.sparse element count is not an integer");
                }
            } else if(_name == "indices") { 
                if(typeof(_value) == "struct") {
                    self.indices = new pdxGltfDataAccessorSparseIndices();
                    self.indices.init(_value);
                } else {
                    self.addError("accessor.sparse element indices is not a struct");
                }
            } else if(_name == "values") { 
                if(typeof(_value) == "struct") {
                    self.values = new pdxGltfDataAccessorSparseValues();
                    self.values.init(_value);
                } else {
                    self.addError("accessor.values element indices is not a struct");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        
        if(is_undefined(self.count)) {
            self.critical("sparse count not set");
        }
        if(is_undefined(self.indices)) {
            self.critical("sparse indicies not set");
        }
        if(is_undefined(self.values)) {
            self.critical("sparse values not set");
        }
    }        
    

}

function pdxGltfDataAccessorSparseIndices() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the buffer view with sparse indices        Yes
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0
    self.componentType                   = undefined;    // integer                         The indices data type.                                  Yes

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "bufferView") {
                if(!self.copyInteger("bufferView", _value)) {
                    self.addError("accessor.sparse.indicies element bufferView is not an integer");
                }
            } else if(_name == "byteOffset") {
                if(!self.copyInteger("bufferView", _value)) {
                    self.addError("accessor.sparse.indicies element byteOffset is not an integer");
                }
            } else if(_name == "componentType") {
                if(!self.copyInteger("componentType", _value)) {
                    self.addError("accessor.sparse.indicies element componentType is not an integer");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.bufferView)) {
            self.critical("sparse.indices bufferView not set");
        }
        if(is_undefined(self.componentType)) {
            self.critical("sparse.indices componentType not set");
        }
    }
}

function pdxGltfDataAccessorSparseValues() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the buffer view with sparse indices        Yes
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "bufferView") {
                if(!self.copyInteger("bufferView", _value)) {
                    self.addError("accessor.sparse.values element bufferView is not an integer");
                }
            } else if(_name == "byteOffset") {
                if(!self.copyInteger("bufferView", _value)) {
                    self.addError("accessor.sparse.values element byteOffset is not an integer");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.bufferView)) {
            self.critical("sparse.values bufferView not set");
        }
    }
}


function pdxGltfDataSkin() : pdxGltfDataAbstractBase() constructor {
    self.inverseBindMatrices             = undefined;    // integer                         accessor with 4x4 inverse-bind matrices.                No
    self.skeleton                        = undefined;    // integer                         The index of the node used as a skeleton root.          No
    self.joints                          = undefined;    // integer [1-*]                   Indices of skeleton nodes, used as joints in this skin. Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "inverseBindMatrices") {
                if(!self.copyInteger("inverseBindMatrices", _value)) {
                    self.addError("skin.values element inverseBindMatrices is not an integer");
                }
            } else if(_name == "skeleton") {
                if(!self.copyInteger("skeleton", _value)) {
                    self.addError("skin.values element skeleton is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("texture name is not a string");
                }
            } else if(_name == "joints") {
                if(typeof(_value) == "array") {
                    if(!self.copyIntegerArray("joints", _value)) {
                        self.addError("Bad Array for joints");
                    }
                } else {
                    self.addError("skin.joints is not an array");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        if(is_undefined(self.joints)) {
            self.critical("skin.joints not set");
        }
    }
}

function pdxGltfDataAnimation() : pdxGltfDataAbstractBase() constructor {
    self.channels                        = undefined;    // animation.channel [1-*]         An array of animation channels                          Yes
    self.samplers                        = undefined;    // animation.sampler [1-*]         An array of animation samplers                          Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copyString("name", _value)) {
                    self.addError("animation name is not a string");
                }
            } else if(_name == "samplers") { 
                if(is_array(_value)) {
                    var _al = array_length(_value);
                    self.samplers = array_create(_al);
                    for(var _i=0; _i< _al; _i++) {
                        if(typeof(_value[_i]) == "struct") {
                            self.samplers[_i] = new pdxGltfDataAnimationSampler();
                            self.samplers[_i].init(_value[_i]);
                        } else {
                            self.addError("animation.sampler element is not a struct");
                        }
                    }
                } else {
                    self.addError("animation.samplers element is not an array");
                }
            } else if(_name == "channels") { 
                if(is_array(_value)) {
                    var _al = array_length(_value);
                    self.channels = array_create(_al);
                    for(var _i=0; _i< _al; _i++) {
                        if(typeof(_value[_i]) == "struct") {
                            self.channels[_i] = new pdxGltfDataAnimationChannel();
                            self.channels[_i].init(_value[_i]);
                        } else {
                            self.addError("animation.channel element is not a struct");
                        }
                    }
                } else {
                    self.addError("animation.channels element is not an array");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        if(is_undefined(self.channels)) {
            self.critical("animation.channels not set");
        }
        if(is_undefined(self.samplers)) {
            self.critical("animation.samplers not set");
        }
    }
}

function pdxGltfDataAnimationSampler() : pdxGltfDataAbstractBase() constructor {
    self.input                           = undefined;    // integer                         The index of an accessor keyframe timestamps.           Yes
    self.interpolation                   = undefined;    // string                          Interpolation algorithm.                                No, default: "LINEAR"
    self.output                          = undefined;    // integer                         The index of an accessor, containing keyframe output    Yes

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "input") {
                if(!self.copyInteger("input", _value)) {
                    self.addError("animation.sampler.input is not an integer");
                }
            } else if(_name == "output") {
                if(!self.copyInteger("output", _value)) {
                    self.addError("animation.sampler.output is not an integer");
                }
            } else if(_name == "interpolation") {
                if(!self.copyString("interpolation", _value)) {
                    self.addError("animation.sampler.interpolation is not a string");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        if(is_undefined(self.interpolation)) {
            self.interpolation = "LINEAR";
        }
        if(is_undefined(self.input)) {
            self.critical("animation.sampler.input not set");
        }
        if(is_undefined(self.output)) {
            self.critical("animation.sampler.output not set");
        }
    }
}


function pdxGltfDataAnimationChannel() : pdxGltfDataAbstractBase() constructor {
    self.sampler                         = undefined;    // integer                         The index of a sampler in this animation                Yes
    self.target                          = undefined;    // animation.channel.target        The descriptor of the animated property.                Yes

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "sampler") {
                if(!self.copyInteger("sampler", _value)) {
                    self.addError("animation.sampler is not an integer");
                }
            } else if(_name == "target") {
                if(typeof(_value) == "struct") {
                    self.target = new pdxGltfDataAnimationTarget();
                    self.target.init(_value);
                } else {
                    self.addError("animation.channel.target is not a struct");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        if(is_undefined(self.sampler)) {
            self.critical("animation.channel.sampler not set");
        }
        if(is_undefined(self.target)) {
            self.critical("animation.channel.target not set");
        }
    }
}

function pdxGltfDataAnimationTarget() : pdxGltfDataAbstractBase() constructor {
    self.node                            = undefined;    // integer                         The index of the node to animate                        No
    self.path                            = undefined;    // string                          The name of the node’s TRS property to animate...       Yes

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "node") {
                if(!self.copyInteger("node", _value)) {
                    self.addError("animation.target.node is not an integer");
                }
            } else if(_name == "path") {
                if(!self.copyString("path", _value)) {
                    self.addError("animation.target.path is not a string");
                }
            } else if(_name == "extensions") {
                self.copyExtensions(_value);
            } else if(_name == "extras") {
                self.copyExtras(_value);
            }
            
            } );
        if(is_undefined(self.path )) {
            self.critical("animation.target.path not set");
        }
    }
}





