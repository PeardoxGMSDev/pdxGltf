enum imageFile {
    UNKNOWN,
    PNG,
    JPG
}

enum imageColourType {
    UNKNOWN = -1,
    GREYSCALE = 0,
    RGB = 2,
    PALETTE = 3,
    GREYSCALE_ALPHA = 4,
    RGBA = 6,
    CMYK = 9 // Just for JPEG
}

imgMagic = [
    [0],                                                // UNKNOWN - Dummy value
    [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a],   // PNG - https://www.w3.org/TR/REC-png-961001#R.PNG-file-signature
    [0xFF, 0xD8]                                        // JPG - https://en.wikipedia.org/wiki/List_of_file_signatures
    ];

function byteSwap32(value) {
    return ((value & 0xFF000000) >> 24) |
           ((value & 0x00FF0000) >>  8) |
           ((value & 0x0000FF00) <<  8) |
           ((value & 0x000000FF) << 24);
    
}

function byteSwap16(value) {
    return ((value & 0xFF00) >> 8) |
           ((value & 0x00FF) << 8);
    
}

function validateMagic(buffer, buffer_offset, magic) {
    var rval = false;
    
    for(var i=0, n = array_length(magic); i < n; i++) {
        if(buffer_peek(buffer, i + buffer_offset, buffer_u8) == magic[i]) {
            rval = true;
        } else {
            rval = false;
            break;
        }
    }
    
    return rval;
}

function pdxImageDimensions(width = 0, height = 0) : pdxException() constructor {
    self.width = width;
    self.height = height;
    self.colourDepth = 0;
    self.colourType = imageColourType.UNKNOWN;
    
    static isEmpty = function() {
        if((self.width <= 0) || (self.height <= 0)) {
            return true;
        }
        return false;
    }
}

function pdxImageDimensionsPNG(width = 0, height = 0): pdxImageDimensions(width, height) constructor {
    static readChunk = function(buffer, pos) {
        return { chkLen: byteSwap32(buffer_peek(buffer, pos, buffer_u32)), chkTyp: buffer_peek(buffer, pos + 4, buffer_u32) };
    }
    
    static extractImageInfo = function(buffer, buffer_offset, buffer_length, preValidated = false) {
        if(!preValidated && !validateMagic(buffer, buffer_offset, global.imgMagic[imageFile.PNG])) {
            return;
        }
        
        var len = buffer_length;
        var pos = buffer_offset + 8; // Start directly after magic
        // There are 12 required bytes of header so make sure we've got enough buffer left
        while((pos + 12) < len) {
            var chk = self.readChunk(buffer, pos);
            if(chk.chkTyp = 0x52444849) { // IHDR
                // Found header, read data values
                // First check we have buffer to read it
                if((pos + 12 + chk.chkLen) < len) {
                    self.width = byteSwap32(buffer_peek(buffer, pos + 8, buffer_u32));
                    self.height = byteSwap32(buffer_peek(buffer, pos + 12, buffer_u32));
                    self.colourDepth = buffer_peek(buffer, pos + 16, buffer_u8);
                    self.colourType = buffer_peek(buffer, pos + 17, buffer_u8);
                } else {
                    self.addError("Buffer overrun reading image header");
                }
                // Finally skip the resat of the file
                break;
            } else if(chk.chkTyp == 0x444E4549) { // IEND
                // We should never get here. If we do skip anything left and exit;
                self.addError("Buffer overrun reading image header");
                break;
            }
            // A chunk is <chkLen> + len + typ + crc long so chkLen + 12 (len + typ + crc are u32, crc is after the data
            pos += chk.chKLen + 12; 
        }
    }
}

function pdxImageDimensionsJPG(width = 0, height = 0): pdxImageDimensions(width, height) constructor {
    static find_next_marker = function(buffer, pos, buffer_length) {
        var cpos = pos;
        while(cpos < buffer_length - 1) {
            if(buffer_peek(buffer, cpos, buffer_u8)  == 0xFF) {
                var byte = buffer_peek(buffer, cpos+1, buffer_u8);
                // Skip over filler FF....00
                if(byte == 0xFF) {
                    cpos+=2;
                    while((cpos < buffer_length - 1) && (buffer_peek(buffer, cpos, buffer_u8)  == 0xFF)) {
                        cpos++;
                    }
                    if(buffer_peek(buffer, cpos, buffer_u8)  == 0x00) {
                        cpos++;
                        continue;
                    }
                }
                break; 
                
            }
            cpos++;
        }
        
        if(cpos >= buffer_length) {
            cpos = 0;
        }
        
        return cpos;
        
    }
    
    static extractImageInfo = function(buffer, buffer_offset, buffer_length, preValidated = false) {
        if(!preValidated && !validateMagic(buffer, buffer_offset, global.imgMagic[imageFile.JPG])) {
            return;
        }
        
        var len = buffer_length;
        var pos = buffer_offset + 2; // Start directly after magic
        // There are 12 required bytes of header so make sure we've got enough buffer left
        while((pos < len)) {
            pos = self.find_next_marker(buffer, pos, buffer_length);
            var mark = buffer_peek(buffer, pos, buffer_u16);
            var hex = intToHex(mark);
            switch(mark) {
                case 0xDAFF:
                    break;
                case 0xD9FF:
                    break;
                case 0xC0FF: 
                case 0xC1FF: 
                case 0xC2FF: 
                case 0xC3FF: 
                case 0xC5FF: 
                case 0xC6FF: 
                case 0xC7FF: 
                case 0xC9FF: 
                case 0xCAFF: 
                case 0xCBFF:
                case 0xCDFF:
                case 0xCEFF:
                case 0xCFFF:
                    var data = buffer_peek(buffer, pos + 2, buffer_u16);
                    var data_length = byteSwap16(data);
                    if(data_length<8) {
                        return;
                    }
                    var bits = buffer_peek(buffer, pos + 4, buffer_u8);
                    var height = byteSwap16(buffer_peek(buffer, pos + 5, buffer_u16));
                    var width = byteSwap16(buffer_peek(buffer, pos + 7, buffer_u16));
                    var comps = buffer_peek(buffer, pos + 9, buffer_u8);
                    
                    self.width = width;
                    self.height = height;
                    self.colourDepth = bits;
                    switch(comps) {
                        case 1:
                            self.colourType = imageColourType.GREYSCALE;
                            break;
                        case 3:
                            self.colourType = imageColourType.RGB;
                            break;
                        case 4:
                            self.colourType = imageColourType.CMYK;
                            break;
                        default:
                            self.colourType = imageColourType.UNKNOWN;
                            break;
                    }
                                    
                    // show_debug_message("StartOfFrame");
                    return; 
                case 0xC4FF: 
                case 0xC8FF: 
                case 0xCCFF:
                    break;
                default:
                    break;
                }
            
                pos += 2;
            }
        
    } 
}

function pdxImage() : pdxException() constructor {
    self.buffer = undefined;
    self.texturegroup_name = undefined;
    self.sprite_name = undefined;
    self.imageType = imageFile.UNKNOWN;
    self.sprite_size = undefined;

    
    static getImageType = function(buffer, buffer_offset) {
        // Default to imageFile.UNKNOWN;
        var rval = imageFile.UNKNOWN;
        
        // Loop over magic numbers but skip UNKNOWN
        for(var i=1, n = array_length(global.imgMagic); i < n; i++) {
            // Check the magic for each supported value
            var magicok = validateMagic(buffer, buffer_offset, global.imgMagic[i]);
            // If the magic number validates...
            if(magicok) {
                rval = i; // This will now be imageFile.<ImageType>;
                break;
            }
        }
        
        return rval;
    }
    
    static free = function() {
        if(buffer_exists(self.texturegroup_name)) {
            texturegroup_unload(self.texturegroup_name);
        }
        if(buffer_exists(self.buffer)) {
            buffer_delete(self.buffer);
            self.buffers = undefined;
        }
    }
    
    static getFreeImage = function() {
        global.pdxLastImageIndex++;
        var seq = string(global.pdxLastImageIndex);
        return "img-" + string_repeat("0", global.pdxImageIndexDigits - string_length(seq)) + seq;
    }
    
    static getFreeTexturePage = function() {
        global.pdxLastTexturePageIndex++;
        var seq = string(global.pdxLastTexturePageIndex);
        return "tex-" + string_repeat("0", global.pdxTexturePageIndexDigits - string_length(seq)) + seq;
    }
    
    static load_frome_file = function(filename, texturegroup = "") {
        if(texturegroup == "") {
            self.texturegroup_name = self.getFreeTexturePage();
        } else {
            self.texturegroup_name = texturegroup;
        }
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, filename, 0);        
        return self.copy_from_buffer(_buffer, 0, buffer_get_size(_buffer));
    }
    
    static load_from_buffer = function(inbuf, buffer_offset, buffer_length, texturegroup = "") {
        if(texturegroup == "") {
            self.texturegroup_name = self.getFreeTexturePage();
        } else {
            self.texturegroup_name = texturegroup;
        }
        return self.copy_from_buffer(inbuf, buffer_offset, buffer_length);
    }
    
    
    static copy_from_buffer = function(inbuf, buffer_offset, buffer_length) {
        // Before we do anything check the buffer is a buffer and it has spave for the image to read
        if(!buffer_exists(inbuf)) {
            self.addError("Buffer does not exist");
            return false;    
        }
        if( buffer_get_size(inbuf) < (buffer_offset + buffer_length) ) {
            self.addError("Buffer is too small");
            return false;
        }
        
        self.imageType = self.getImageType(inbuf, buffer_offset);
        if(self.imageType == imageFile.UNKNOWN ) {
            self.addError("Unsupported Image Format");
            return false;
        }
        
        switch(self.imageType) {
            case imageFile.UNKNOWN:
                // Unknown will be replaced with checkerboard sprite
                self.sprite_size = new pdxImageDimensions(64, 64);
                break;
            case imageFile.PNG:
                self.sprite_size = new pdxImageDimensionsPNG();
                self.sprite_size.extractImageInfo(inbuf, buffer_offset, buffer_length, true);
                break;
            case imageFile.JPG:
                self.sprite_size = new pdxImageDimensionsJPG();
                self.sprite_size.extractImageInfo(inbuf, buffer_offset, buffer_length, true);
                break;
            default:
                self.sprite_size = new pdxImageDimensions(0, 0);
                break;
        }
        
        if(self.sprite_size.isEmpty()) {
            return false;
        }
                
        self.sprite_name = getFreeImage();
        
        self.buffer = buffer_create(buffer_length, buffer_fixed, 1);
        if(self.buffer == -1) {
            self.addError("Unknown Buffer error");
            return false;
        }
        
        buffer_copy(inbuf, buffer_offset, buffer_length, self.buffer, 0);
        var _sprite_data = { sprites : {}};
//        _sprite_data.sprites[$ self.sprite_name] = { width : self.sprite_size.width, height : self.sprite_size.height, frames : [  { x : 0, y : 0, x_offset: self.sprite_size.width / 2, y_offset: self.sprite_size.height / 2 } ] };
        _sprite_data.sprites[$ self.sprite_name] = { width : self.sprite_size.width, height : self.sprite_size.height, frames : [  { x : 0, y : 0, x_offset: 0, y_offset: 0 } ] };
        texturegroup_add(self.texturegroup_name, self.buffer, _sprite_data);
        texturegroup_load(self.texturegroup_name);
        
        show_debug_message("========> Added sprite " + self.sprite_name + " in tex group " + self.texturegroup_name);
        
        return true;
    }

}

function pdxGltfTextureData() : pdxException() constructor {
    self.texture = undefined;
    self.image   = undefined;

}