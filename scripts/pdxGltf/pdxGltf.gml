#macro TABSIZE 4
pdxGltfSpecificationVersion = "2.0.1";

function pdxModelFile() : pdxException() constructor {
    filename = "";
    filepath = "";
    filebase = "";
    
    static open = function(apath, afile, abase) {
        if(file_exists(apath + afile)) {
            self.filepath = apath;
            self.filename = afile;
            self.filebase = abase;
            return true;            
        }
        return false;
    }
}

function pdxGLTFBase(): pdxModelFile() constructor {
    self.json = undefined;
    self.loadTime = 0;
    self.readTime = 0;
    self.processTime = 0;
    self.buildTime = 0;
    self.errval = false;
    self.data = undefined;

    self.accessorData = undefined;
    self.bufferData = undefined;
    self.imagesData = undefined;
    self.materialData = undefined;

    self.vertexBuffer = array_create(0);
    self.primitiveList = array_create(0);
    
    self.tree = ["","",""];
    
    self.counts = {
        asset: 0,
        extensionsRequired: 0,
        extensionsUsed: 0,
        scenes: 0,
        nodes: 0,
        materials: 0,
        meshes: 0,
        textures: 0,
        accessors: 0,
        bufferViews: 0,
        samplers: 0,
        buffers: 0,
        animations: 0,
        skins: 0,
        cameras: 0,
        images: 0 
    }
    
    static getCount = function(object, element) {
        if(is_array(object[$ element])) {
            return array_length(object[$ element]);
        } else {
            return 0;
        }
    }
    
    static createCounts = function() {
        self.counts.asset =              self.getCount(self.data, "asset");
        self.counts.extensionsRequired = self.getCount(self.data, "extensionsRequired");
        self.counts.extensionsUsed =     self.getCount(self.data, "extensionsUsed");
        self.counts.scenes =             self.getCount(self.data, "scenes");
        self.counts.nodes =              self.getCount(self.data, "nodes");
        self.counts.materials =          self.getCount(self.data, "materials");
        self.counts.meshes =             self.getCount(self.data, "meshes");
        self.counts.textures =           self.getCount(self.data, "textures");
        self.counts.accessors =          self.getCount(self.data, "accessors");
        self.counts.bufferViews =        self.getCount(self.data, "bufferViews");
        self.counts.samplers =           self.getCount(self.data, "samplers");
        self.counts.buffers =            self.getCount(self.data, "buffers");
        self.counts.animations =         self.getCount(self.data, "animations");
        self.counts.skins =              self.getCount(self.data, "skins");
        self.counts.cameras =            self.getCount(self.data, "cameras");
        self.counts.images =             self.getCount(self.data, "images");
    }
    
    static addTreeKeyValue = function(key, object, treeNode) {
        var val = object[$ key];
        if(typeof(val) == "struct") {
            var keys = struct_get_names(val);
            var leaf = treeNode.addNode(key);
            for(var i=0, n=array_length(keys); i<n; i++) {
                self.addTreeKeyValue(keys[i], val, leaf);    
            }
            
        } else {
            treeNode.addItem(key, val);
        }
    }
    
    static addTreeMisc = function(object, treeNode) {
        if(self.keyExists(object, "extensions")) {
            self.addTreeKeyValue("extensions", object, treeNode);
            // treeNode.addItem("extensions", object.extensions);
        }
        if(self.keyExists(object, "extras")) {
            treeNode.addItem("extras", object.extras);
        }
        if(self.keyExists(object, "unhandled")) {
            treeNode.addItem("unhandled", object.unhandled);
        }
        
    }
    
    static gatherErrors = function() {
        self.errval = false;
        var text = "Assets\n\n";        
        var ec = 0;     
        if(self.data.asset.hasErrors()) {
            text += self.data.asset.error;
            ec++;
            self.errval = false;
        } else {
            text += "No errors\n";
        }
    
        text += "\nScenes (" + string(self.counts.scenes) + ")\n\n";   
        ec = 0;     
        for(var _i =0; _i < self.counts.scenes; _i++) {
            if(self.data.scenes[_i].hasErrors()) {
                text += self.data.scenes[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nNodes (" + string(self.counts.nodes) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.nodes; _i++) {
            if(self.data.nodes[_i].hasErrors()) {
                text += self.data.nodes[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nMaterials (" + string(self.counts.materials) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.materials; _i++) {
            if(self.data.materials[_i].hasErrors()) {
                text += self.data.materials[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nMeshes (" + string(self.counts.meshes) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.meshes; _i++) {
            if(self.data.meshes[_i].hasErrors()) {
                text += self.data.meshes[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nImages (" + string(self.counts.images) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.images; _i++) {
            if(self.data.images[_i].hasErrors()) {
                text += self.data.images[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nAccessors (" + string(self.counts.accessors) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.accessors; _i++) {
            if(self.data.accessors[_i].hasErrors()) {
                text += self.data.accessors[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nBufferViews (" + string(self.counts.bufferViews) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.bufferViews; _i++) {
            if(self.data.bufferViews[_i].hasErrors()) {
                text += self.data.bufferViews[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        return text;
    }
    
    static addTreeMesh = function(txt) {
        self.tree[0] += txt;
    }

    static free = function() {
    }
    
    static loadUriBuffer = function(uri) {
        var rval = -1;
        
        if(string_starts_with(uri, "data:")) {
            var temp = string_split(uri, ",", true, 1);
            if(array_length(temp) == 2) {
                rval = buffer_base64_decode(temp[1]);
            }
        } else {
            if(file_exists(self.filepath + uri)) {
                rval = buffer_create(0, buffer_grow, 1);
                if(buffer_exists(rval)) {
                    buffer_load_ext(rval, self.filepath + uri, 0);
                } else {
                    rval = -1;
                }
            } else {
                self.addError("File not found : " + uri);
            }
        }
        
        return rval;
    }
    
    static processAttributes = function(attributes, depth = 0) {
        if(self.keyExists(attributes, "POSITION")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "POSITION : " + string(attributes.POSITION) + "\n");
        }
        if(self.keyExists(attributes, "NORMAL")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "NORMAL   : " + string(attributes.NORMAL) + "\n");
        }
        if(self.keyExists(attributes, "TANGENT")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "TANGENT  : " + string(attributes.TANGENT) + "\n");
        }
        if(self.keyExists(attributes, "texcoord")) {
            var _al = array_length(attributes.texcoord);
            for(var _i=0; _i< _al; _i++) {
                self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "TEXCOORD_" + string(_i) + " : " + string(attributes.texcoord[_i]) + "\n");
            }
        }
        if(self.keyExists(attributes, "color")) {
            var _al = array_length(attributes.color);
            for(var _i=0; _i< _al; _i++) {
                self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "COLOR_" + string(_i) + " : " + string(attributes.color[_i]) + "\n");
            }
        }
        if(self.keyExists(attributes, "joints")) {
            var _al = array_length(attributes.joints);
            for(var _i=0; _i< _al; _i++) {
                self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "JOINTS_" + string(_i) + " : " + string(attributes.joints[_i]) + "\n");
            }
        }
        if(self.keyExists(attributes, "weights")) {
            var _al = array_length(attributes.weights);
            for(var _i=0; _i< _al; _i++) {
                self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "WEIGHTS_" + string(_i) + " : " + string(attributes.weights[_i]) + "\n");
            }
        }
        if(self.keyExists(attributes, "extensions")) {
            self.addTreeMesh(string_repeat(" ", (depth + 1) * TABSIZE) + "extensions : " + string(attributes.extensions) + "\n");
        }    
    }
    
    static processPrimitive = function(primitive, depth = 0) {
        if(self.keyExists(primitive, "attributes")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "Attributes" + "\n");
            self.processAttributes(primitive.attributes, depth + 1);
        }
        if(self.keyExists(primitive, "indices")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "indices  : " + string(primitive.indices) + "\n");
        }
        if(self.keyExists(primitive, "material")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "material : " + string(primitive.material) + "\n");
        }
        if(self.keyExists(primitive, "mode")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "mode     : " + string(primitive.mode) + "\n");
        }
        if(self.keyExists(primitive, "targets")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "targets  : " + string(primitive.targets) + "\n");
        }
        if(self.keyExists(primitive, "extensions")) {
            self.addTreeMesh(string_repeat(" ", (depth + 1) * TABSIZE) + "extensions : " + string(primitive.extensions) + "\n");
        }    
        array_push(self.primitiveList, primitive);
//        show_debug_message(json_stringify(primitive));
    }
    
    static processMesh = function(mesh, depth = 0) {
        if(self.keyExists(mesh, "name")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "Mesh : " + mesh.name + "\n");
        }
        
        if(self.keyExists(mesh, "primitives")) {
            var _al = array_length(mesh.primitives);
            for(var _i = 0; _i < _al; _i++) {
                self.processPrimitive(mesh.primitives[_i], depth + 1);
            }
        }
        
        if(self.keyExists(mesh, "weights")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "weights : " + string(mesh.weights) + "\n");
            self.addWarning("ToDo : Mesh weights not implemented yet");
        }
        if(self.keyExists(mesh, "extensions")) {
            self.addTreeMesh(string_repeat(" ", (depth + 1) * TABSIZE) + "extensions : " + string(mesh.extensions) + "\n");
        }    
        
        
    }
        
    static processNode = function(node, depth = 0) {
        if(self.keyExists(node, "name")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "Node : " + node.name + "\n");
        }
        
        if(self.keyExists(node, "mesh")) {
            if(node.mesh < self.counts.meshes) {
                self.processMesh(self.data.meshes[node.mesh], depth + 1);
            } else {
                self.addError("Bad mesh index (" + string(node.mesh) + ")");
            }
        }
        
        if(self.keyExists(node, "children")) {
            var _al = array_length(node.children);
            for(var _i = 0; _i < _al; _i++) {
                var child = node.children[_i];
                if(child < self.counts.nodes) {
                    self.processNode(self.data.nodes[child], depth + 1);
                } else {
                    self.addError("Bad node index (" + string(child) + ")");
                }
            }
        }
        
        if(self.keyExists(node, "camera")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "camera : " + string(node.camera) + "\n");
            self.addWarning("ToDo : Node camera not implemented yet");
        }
        
        if(self.keyExists(node, "skin")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "skin : " + string(node.skin) + "\n");
            self.addWarning("ToDo : Node skin not implemented yet");
        }
        
        if(self.keyExists(node, "matrix")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "matrix : " + string(node.matrix) + "\n");
            self.addWarning("ToDo : Node matrix not implemented yet");
        }
        
        if(self.keyExists(node, "rotation")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "rotation : " + string(node.rotation) + "\n");
            self.addWarning("ToDo : Node rotation not implemented yet : " +  + string(node.rotation));
        }
        
        if(self.keyExists(node, "scale")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "scale : " + string(node.scale) + "\n");
            self.addWarning("ToDo : Node scale not implemented yet");
        }
        
        if(self.keyExists(node, "translation")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "translation : " + string(node.translation) + "\n");
            self.addWarning("ToDo : Node translation not implemented yet");
        }
        
        if(self.keyExists(node, "weights")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "weights : " + string(node.weights) + "\n");
            self.addWarning("ToDo : Node weights not implemented yet");
        }
        
        if(self.keyExists(node, "extensions")) {
            self.addTreeMesh(string_repeat(" ", (depth + 1) * TABSIZE) + "extensions : " + string(node.extensions) + "\n");
        }    
        
    }    
    
    static processScene = function(scene, depth = 0) {
        if(self.keyExists(scene, "name")) {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "Scene : " + scene.name + "\n");
        } else {
            self.addTreeMesh(string_repeat(" ", depth * TABSIZE) + "Scene : <no name>\n");
        }

        if(self.keyExists(scene, "nodes")) {
            var _al = array_length(scene.nodes);
            for(var _i = 0; _i < _al; _i++) {
                var _node = scene.nodes[_i];
                if(_node < self.counts.nodes) {
                    self.processNode(self.data.nodes[_node], depth + 1);
                } else {
                    self.addError("Bad node index (" + string(_node) + ")");
                }
            }
        }
    }
    

    static createVariableType = function(type, count, componentType) {
        var value;
        switch(type) {
            case "SCALAR":
                value = new pdxGltfDataValueScalar(count, componentType);
                break;
            case "VEC2":
                value = new pdxGltfDataValueVector2(count, componentType);
                break;
            case "VEC3":
                value = new pdxGltfDataValueVector3(count, componentType);
                break;
            case "VEC4":
                value = new pdxGltfDataValueVector4(count, componentType);
                break;
            case "MAT2":
                value = new pdxGltfDataValueMatrix2(count, componentType);
                break;
            case "MAT3":
                value = new pdxGltfDataValueMatrix3(count, componentType);
                break;
            case "MAT4":
                value = new pdxGltfDataValueMatrix4(count, componentType);
                break;
            default:
                self.critical("Unknown accessor type");
                break;
        }                
        return value;
    }   
     
    static processAccessor = function(accessor, index) {
        var new_struct = self.createVariableType(accessor.type, accessor.count, accessor.componentType);
        if(self.keyExists(accessor, "bufferView")) {
            // If we have a bufferView read it in
            var view = self.data.bufferViews[accessor.bufferView];
            if(self.keyExists(view, "target")) {
                new_struct.target = view.target;
            }
            if(view.buffer < self.counts.bufferViews) {
                var buffer = self.bufferData[view.buffer];
                new_struct.read(buffer, view, accessor.byteOffset);
            } else {
                self.critical("Attempt to read out-of-bound bufferView");
            }

        } else {
            // With no bufferview initialise with zeros
            new_struct.init();
        }
  
        // Needs checking  
        if(self.keyExists(accessor, "sparse")) {
            new_struct.addSparse(accessor.sparse.count);

            new_struct.sparse.indices = self.createVariableType("SCALAR", accessor.sparse.count, accessor.sparse.indices.componentType);
            var sview1 = self.data.bufferViews[accessor.sparse.indices.bufferView];
            var buffer1 = self.bufferData[sview1.buffer];
            new_struct.sparse.indices.read(buffer1, sview1, accessor.byteOffset);

            new_struct.sparse.values = self.createVariableType(accessor.type, accessor.sparse.count, accessor.componentType);
            var sview2 = self.data.bufferViews[accessor.sparse.values.bufferView];
            var buffer2 = self.bufferData[sview2.buffer];
            new_struct.sparse.values.read(buffer2, sview2, accessor.byteOffset);
            
            // new_struct.applySparse();
            
        }
        
        self.accessorData[index] = new_struct;
    }

    static processAccessors = function(depth = 0) {
        var _al = array_length(self.data.accessors);
        if(is_undefined(self.accessorData)) {
            self.accessorData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processAccessor(self.data.accessors[_i], _i);
        }
    }
    
    static processMaterialTextureInfo = function(textureInfo, treeNode) {
        if(self.keyExists(textureInfo, "index")) {
            treeNode.addItem("index", textureInfo.index);
        }
        if(self.keyExists(textureInfo, "texCoord")) {
            treeNode.addItem("texCoord", textureInfo.texCoord);
        }
        self.addTreeMisc(textureInfo, treeNode);
    }

    static processMaterialOcclusionTexture = function(occlusionTexture, treeNode) {
        var leaf = treeNode.addNode("occlusionTexture");
        
        if(self.keyExists(occlusionTexture, "index")) {
            leaf.addItem("index", occlusionTexture.index);
        }
        if(self.keyExists(occlusionTexture, "texCoord")) {
            leaf.addItem("texCoord", occlusionTexture.texCoord);
        }
        if(self.keyExists(occlusionTexture, "strength")) {
            leaf.addItem("strength", occlusionTexture.strength);
        }
        self.addTreeMisc(occlusionTexture, treeNode);
    }
    
    static processMaterialNormalTexture = function(normalTexture, treeNode) {
        var leaf = treeNode.addNode("normalTexture");
        
        if(self.keyExists(normalTexture, "index")) {
            leaf.addItem("index", normalTexture.index);
        }
        if(self.keyExists(normalTexture, "texCoord")) {
            leaf.addItem("texCoord", normalTexture.texCoord);
        }
        if(self.keyExists(normalTexture, "scale")) {
            leaf.addItem("scale", normalTexture.scale);
        }
        self.addTreeMisc(normalTexture, treeNode);
    }

/*
    self.baseColorFactor                 = undefined;    // number [4]                      The factors for the base color of the material.         No, default: [1,1,1,1]
    self.baseColorTexture                = undefined;    // textureInfo                     The base color texture.                                 No
    self.metallicFactor                  = undefined;    // number                          The factor for the metalness of the material.           No, default: 1
    self.roughnessFactor                 = undefined;    // number                          The factor for the roughness of the material.           No, default: 1
    self.metallicRoughnessTexture        = undefined;    // textureInfo                     The metallic-roughness texture.                         No
*/        
    static processMaterialPbrMetallicRoughness = function(pbrMetallicRoughness, treeNode) {
        var leaf = treeNode.addNode("pbrMetallicRoughness");
        
        if(self.keyExists(pbrMetallicRoughness, "baseColorFactor")) {
            leaf.addItem("baseColorFactor", pbrMetallicRoughness.baseColorFactor);
        }
        if(self.keyExists(pbrMetallicRoughness, "metallicFactor")) {
            leaf.addItem("metallicFactor", pbrMetallicRoughness.metallicFactor);
        }
        if(self.keyExists(pbrMetallicRoughness, "roughnessFactor")) {
            leaf.addItem("roughnessFactor", pbrMetallicRoughness.roughnessFactor);
        }
        if(self.keyExists(pbrMetallicRoughness, "baseColorTexture")) {
            var baseNode = leaf.addNode("baseColorTexture");
            self.processMaterialTextureInfo(pbrMetallicRoughness.baseColorTexture, baseNode);
        }
        if(self.keyExists(pbrMetallicRoughness, "metallicRoughnessTexture")) {
            var metalNode = leaf.addNode("metallicRoughnessTexture");
            self.processMaterialTextureInfo(pbrMetallicRoughness.metallicRoughnessTexture, metalNode);
        }
        self.addTreeMisc(pbrMetallicRoughness, treeNode);
    }
    
    
/*
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.pbrMetallicRoughness            = undefined;    // material.pbrMetallicRoughness   PBR metallic-roughness material model                   No
    self.normalTexture                   = undefined;    // material.normalTextureInfo      The tangent space normal texture.                       No                          
    self.occlusionTexture                = undefined;    // material.occlusionTextureInfo   The occlusion texture.                                  No                          
    self.emissiveTexture                 = undefined;    // textureInfo                     The emissive texture.                                   No                         
    self.emissiveFactor                  = undefined;    // number [3]                      The factors for the emissive color of the material.     No, default: [0,0,0]       
    self.alphaMode                       = undefined;    // string                          The alpha rendering mode of the material.               No, default: "OPAQUE"
    self.alphaCutoff                     = undefined;    // number                          The alpha cutoff value of the material.                 No, default: 0.5
    self.doubleSided                     = undefined;    // boolean                         Specifies whether the material is double sided.         No
*/
    static processMaterial = function(material, index, treeNode) {
        var leaf = treeNode.addNode("Material (" + string(index) + ")");

        if(self.keyExists(material, "name")) {
            leaf.addItem("name", material.name);
        } else {
            leaf.addItem("name", "<UNNAMED>");
        }
        
        if(self.keyExists(material, "pbrMetallicRoughness")) {
            self.processMaterialPbrMetallicRoughness(material.pbrMetallicRoughness, leaf);
        }
        
        if(self.keyExists(material, "normalTexture")) {
            self.processMaterialNormalTexture(material.normalTexture, leaf);
        }
        
        if(self.keyExists(material, "occlusionTexture")) {
            self.processMaterialOcclusionTexture(material.occlusionTexture, leaf);
        }
        
        if(self.keyExists(material, "emissiveTexture")) {
            var emleaf = leaf.addNode("emissiveTexture");
            self.processMaterialTextureInfo(material.emissiveTexture, emleaf);
        }
        self.addTreeMisc(material, treeNode);
        
        // Todo : Deepcopy
        self.materialData[index] = material;

    }
        
    static processMaterials = function(treeNode) {
        var _al = array_length(self.data.materials);
        if(is_undefined(self.materialData)) {
            self.materialData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processMaterial(self.data.materials[_i], _i, treeNode);
        }
    }
    
    
    static processImage = function(image, index) {
        var temp;
        if(self.keyExists(image, "uri")) {
            // If the image has a uri then we can read it from the file specified
            temp = self.loadUriBuffer(image.uri);
            if(buffer_exists(temp)) {
                self.imagesData[index] = temp;
            }
        } else {
            // Otherwise the image is in  BufferView
            self.addWarning("*** Using buffered image ***");
            /*
            if(struct_exists(self, "binbuffer")) {
                if(!is_undefined(self.binbuffer)) {
                    // Re-assign the buffer reference
                    self.bufferdata[index] = self.binbuffer;
                    // This buffer has been transferred to buffers[_i] so remore the reference
                    // This will a;lso signify to the caller that the binary buffer from the 
                    // GLB has been re-assigned to a buffer
                    self.binbuffer = undefined;
                } else {
                    self.critical("GLB binary buffer already used")
                }
            }
             */
        }
    }
    

    static processImages = function(depth = 0) {
        var _al = array_length(self.data.images);
        if(is_undefined(self.imagesData)) {
            self.imagesData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processImage(self.data.images[_i], _i);
        }
    }
    /*
    static processBufferView = function(view) {
        
    }

    static processBufferViews = function(depth = 0) {
        var _al = array_length(self.data.bufferViews);
        for(var _i = 0; _i < _al; _i++) {
            self.processBufferView(self.data.bufferViews[_i]);
        }
    }
    */
    static processBuffer = function(buffer, index) {
        if(self.keyExists(buffer, "uri")) {
            // If the buffer has a uri then we can read it from the file specified
            var temp = self.loadUriBuffer(buffer.uri);
            if(buffer_exists(temp)) {
                self.bufferData[index] = temp;
            }
        } else {
            // Otherwise it SHOULD have been embedded in the glb so re-assign that one
            if(struct_exists(self, "binbuffer")) {
                if(!is_undefined(self.binbuffer)) {
                    // Re-assign the buffer reference
                    self.bufferData[index] = self.binbuffer;
                    // This buffer has been transferred to buffers[_i] so remore the reference
                    // This will a;lso signify to the caller that the binary buffer from the 
                    // GLB has been re-assigned to a buffer
                    self.binbuffer = undefined;
                } else {
                    self.critical("GLB binary buffer already used")
                }
            }
        }
    }
    
    static processBuffers = function(depth = 0) {
        var _al = array_length(self.data.buffers);
        if(is_undefined(self.bufferData)) {
            self.bufferData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processBuffer(self.data.buffers[_i], _i);
        }
        if(struct_exists(self, "binbuffer")) {
            // binbuffer only exists for GLB. Check that if it existed it has been consumed
            if(!is_undefined(self.binbuffer)) {
                self.addError("GLB buffer not used");
            }
         }
    }
    
    static process = function() {
        self.processTime = get_timer();
        self.tree = ["","",""];
        self.tree[1] = new pdxWidgetTreeView("Materials");
        // Clear primitiveList
        if(array_length(self.primitiveList)>0) {
            array_delete(self.primitiveList, 0, array_length(self.primitiveList));
        }
        
        // First create counts of all the main arrays
        self.createCounts();
        
        // Next we run some sanity checks        
        if(is_int(self.data.scene)) {
            if(self.counts.scenes == 0) {
                return false;
            }
            if(self.counts.nodes == 0) {
                return false;
            }
        }     
        
        // Fill the buffers from declared sources
        if(self.counts.buffers > 0) {
            self.processBuffers();
        }
        
        // Fill the buffers from declared sources
        if(self.counts.images > 0) {
            self.processImages();
        }
        
        // Now read/decode all bufferViews + buffers
        if(self.counts.accessors > 0) {
            self.processAccessors();
        }
         
        // Materials
        if(self.counts.materials > 0) {
            self.processMaterials(self.tree[1]);
        }
        // Finally build scene(s)       
        if(self.data.scene < self.counts.scenes) {
            var _scene = self.data.scenes[self.data.scene];
            self.processScene(_scene);
        }
        
        // show_debug_message(json_stringify( self.primitiveList ));
        
        self.processTime = get_timer() - self.processTime;
        return true;
    }

    static build = function() {
        self.buildTime = get_timer();
        // Clear vertexBuffer
        if(array_length(self.vertexBuffer)>0) {
            array_delete(self.vertexBuffer, 0, array_length(self.vertexBuffer));
        }
        
        // show_debug_message("Build_time = " + string(get_timer() - self.buildTime));
        for(var i=0, n = array_length(self.primitiveList); i<n; i++) {
//        for(var i= array_length(self.primitiveList)-1; i>=0; i--) {
            var vbuf = new pdxGltfVertexBuffer();
            if(vbuf.createVertex(self, self.primitiveList[i])) {
                array_push(self.vertexBuffer, vbuf);
               // show_debug_message("Build_timen [" + string(self.accessorData[self.primitiveList[i]].) + "] = " + string(get_timer() - self.buildTime));
            } else {
                self.critical("Bad buffer");
            }
        }
        self.buildTime = get_timer() - self.buildTime;
    }
    
    static render = function() {
        for(var i=0, n=array_length(self.vertexBuffer); i<n; i++) {
            self.vertexBuffer[i].submit();
        }        
    }
}

function pdxGLTF(): pdxGLTFBase() constructor {
    static read = function() {
        self.loadTime = get_timer();
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, self.filepath + self.filename, 0);
        var _bsize = buffer_get_size(_buffer);
        self.readTime = get_timer() - self.loadTime;
        if(_bsize > 0) {
            var _json_txt = buffer_read(_buffer, buffer_string);
            self.json = json_parse(_json_txt);
        }
        buffer_delete(_buffer);
        
        if(!is_undefined(self.json)) {
            self.data = new pdxGltfDataObject();
            self.data.init(self.json);
            self.loadTime = get_timer() - self.loadTime;
            
            return true;
        }
    }
    
    return false;
} 

function pdxGlb(): pdxGLTFBase() constructor {
    self.bufcount = 0;
    self.binbuffer = undefined;
    
    static read = function() {
        self.loadTime = get_timer();
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, self.filepath + self.filename, 0);
        var _bsize = buffer_get_size(_buffer);
        self.readTime = get_timer() - self.loadTime;
        if(_bsize > 12) {
            var _magic = buffer_read(_buffer, buffer_u32);
            var _version = buffer_read(_buffer, buffer_u32); 
            var _length = buffer_read(_buffer, buffer_u32);
            if(_magic <> 0x46546C67) {
                self.addError("glTF magic wrong");
                return false;
            }
            if(_version <> 2) {
                self.addError("glTF version wrong");
                return false;
            }
            if(_length <> _bsize) {
                self.addError("glTF length wrong");
                return false;
            }
            
            while((buffer_tell(_buffer) + 8) < _bsize) {
                var _chunk_length = buffer_read(_buffer, buffer_u32);
                var _chunk_type = buffer_read(_buffer, buffer_u32);
                if((buffer_tell(_buffer) + _chunk_length) > _bsize) {
                    self.addError("glTF buffer read overflow");
                    return false;
                }
                switch(_chunk_type) {
                    case gltfChunk.JSON:
                        var _tempbuf1 = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, _tempbuf1, 0);
                        var _json_txt = buffer_read(_tempbuf1, buffer_string);
                        self.json = json_parse(_json_txt);
                        var _outfile = self.filepath + self.filebase + ".json";
                        if(!file_exists(_outfile)) {
                            buffer_save_ext(_tempbuf1, _outfile, 0, _chunk_length);
                        }
                        
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        buffer_delete(_tempbuf1);
                        
                        break;
                    case gltfChunk.BIN:
                        if(!is_undefined(self.binbuffer)) {
                            self.critical("GLB has multiple buffer entries");
                        }
                        self.binbuffer = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, self.binbuffer, 0);
                        // Do stuff with tempobuf2
                        /*
                        if(self.filename == "world.glb") {
                            var _al = array_length(self.images);
                            array_resize(self.images, _al + 1)
                            self.images[_al] = new pdxImage();
                            self.images[_al].load_from_buffer(self.binbuffers[0], 69248, 1337486, "tex_world");
                        }
                        */
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        break;
                    default:
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        self.critical("Unhandled Binary Chunk");
                        break;
                }
            }
            
        }
        
        buffer_delete(_buffer);
        
        if(!is_undefined(self.json)) {
            self.data = new pdxGltfDataObject();
            self.data.init(self.json);
            self.loadTime = get_timer() - self.loadTime;
            
            return true;
        }
        
        return false;

    }
    
}

