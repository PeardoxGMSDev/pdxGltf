pdxLastImageIndex = 0;
pdxImageIndexDigits = 3;
pdxThrowNotReturn = false;
pdxGlobalGltfErrorFlag = false;
pdxGlobalGltfWarningFlag = false;

function exception_handler(except) {
    show_debug_message(except);
}

function init() {
}

function TextToFile(text, fname) {
    if(file_exists(fname)) {
        return;
    }
    var file = file_text_open_write(fname);
    file_text_write_string(file, text);
    file_text_close(file);    
}

function is_int(x) {
    return floor(x) == x;
}

function is_string_numeric(s) {
    if(typeof(s) != "string") {
        return false;
    }
    var _sl = string_length(s);
    for(var _i=1; _i <= _sl; _i++) {
        var _c = string_ord_at(s, _i);
        if((_c < 48) || (_c > 57)) {
            return false;
        }
    }
    
    return true;
}

function nextSequence(path, base, ext, digits = 3) {
    var _i = 0
    path = string_trim(path);
    base = string_trim(base);
    ext = string_trim(ext);
    while(string_ends_with(path, "/") || string_ends_with(path, "\\")) {
        path = string_copy(path, 1, string_length(path) - 1);
    }
    var seq_file;
    do {   
        _i++;
        var seq = string(_i);
        seq_file = path + "/" + base + string_repeat("0", digits - string_length(seq)) + seq + "." + ext;
    } until(!file_exists(seq_file));
    show_debug_message("Saving " + seq_file);

    return seq_file;
}

function pdxException() constructor {
    
    /// @description Check whether a struct has a key with "defined" value 
    /// @param {struct} object Structure to check
    /// @param {String} key Name of field to check exists and not is_undefined
    /// @return {Bool} Pass / Fail Boolean Value
    static keyExists = function(object, key) {
        if(struct_exists(object, key)) {
            if(is_undefined(object[$ key])) {
                return false;
            } else {
                return true;
            }
        }
        
        return false;
    }
    
    static addError = function(errmsg) {
        if(global.pdxThrowNotReturn) {
            throw(errmsg);                
        }        
        if(!struct_exists(self, "error")) {
            self.error = "";
            global.pdxGlobalGltfErrorFlag = true;
        }
        self.error += string(errmsg) + "\n";
    }
    
    static addWarning = function(errmsg) {
        if(!struct_exists(self, "warning")) {
            self.warning = "";
            global.pdxGlobalGltfWarningFlag = true;
        }
        self.warning += string(errmsg) + "\n";
    }
    
    static critical = function(errmsg) {
        var quit = show_question(errmsg + "\n\nTry to continue?");
        if(!quit) {
            game_end();
        }
    }
    
    static hasErrors = function() {
        if(struct_exists(self, "error")) {
            return true;
        }
       return false;
    }
    
    static hasWarnings = function() {
        if(struct_exists(self, "warning")) {
            return true;
        }
       return false;
    }
}

/// @desc Normalise a path
/// @param {string} path Path to normalize
/// @returns {string} Normalized path
function normalisePath(path) {
    var rpath = string_replace_all(path, "\\", "/");
    while(string_ends_with(rpath, "/")) {
        rpath = string_copy(rpath, 1, string_length(rpath) - 1);
    }
    
    return rpath + "/";
}

function getFileParts(filename, delim = "/") {
    var parts = {
        path: "",
        name: "",
        filebase: "",
        extension: ""
    };
        
    if(file_exists(filename)) {
        var _trailing_path_count = 0;
        if(string_ends_with(filename, "/") || string_ends_with(filename, "\\")) {
            _trailing_path_count = 1;
        }
        var _full_file_parts = string_split_ext(string_trim(filename), ["/","\\"], true);
        var _ffp_count = array_length(_full_file_parts);
        if(_ffp_count > 0) {
            for(var _i = 0; _i < (_ffp_count + _trailing_path_count - 1); _i++) {
                parts.path += _full_file_parts[_i] + delim;
            }
            if(_trailing_path_count == 0) {
                parts.name = string_trim(_full_file_parts[_ffp_count - 1]);    
            }
            if((os_type != os_windows) && (string_length(parts.path)>0)) {
                parts.path = delim + parts.path;
            }
            
            var _fname = string_trim(_full_file_parts[_ffp_count - 1]);
            var _file_parts = string_split(_fname, ".", true);
            var _fp_count = array_length(_file_parts);
            if(_fp_count > 1) {
                parts.extension = string_lower(_file_parts[_fp_count - 1]);
                var _ext_len = string_length(parts.extension);
                if(_ext_len > 0) {
                    parts.filebase = string_copy(_fname, 1, string_length(_fname) - _ext_len - 1);
                } else {
                    parts.filebase = _fname;
                }
            }
            
        }
    }
    
    return parts;
}

function openModel(filename) {
    var _rval = false;
    var _amodel = undefined;
    var _parts = getFileParts(filename);
        
    if(_parts.extension == "glb") {
        _amodel = new pdxGlb();
        if(_amodel.open(_parts.path, _parts.name, _parts.filebase)) {
            _rval = _amodel;
        } else {
            delete(_amodel);
        }
    } else if(_parts.extension == "gltf") {
        _amodel = new pdxGLTF();
        if(_amodel.open(_parts.path, _parts.name, _parts.filebase)) {
            _rval = _amodel;
        } else {
            delete(_amodel);
        }
    }
    
    return _rval;
}

function findModels(dir) {
    var files = false;
    var sdir = normalisePath(dir);

    if(directory_exists(sdir)) {
        var file_name = file_find_first(sdir + "*", fa_readonly | fa_archive | fa_none);
        while (file_name != "")
        {
            if(files == false) {
                files = array_create(0);
            }
            
            var ftype = getFileParts(sdir + file_name);
            if(array_contains(["glb", "gltf"],ftype.extension)) {
                array_push(files, file_name);
            }
            file_name = file_find_next();
        }
        
        file_find_close();        
    }
    
    return files;
}


