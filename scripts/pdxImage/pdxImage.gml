function pdxImageDimensions(width = 0, height = 0) constructor {
    self.width = width;
    self.height = height;
}

function pdxImage() : pdxException() constructor {
    self.buffer = undefined;
    self.texturegroup_name = undefined;
    self.sprite_name = undefined;
    self.sprite_size = new pdxImageDimensions(1024, 1024);
    
    static free = function() {
        if(buffer_exists(self.texturegroup_name)) {
            texturegroup_unload(self.texturegroup_name);
        }
        if(buffer_exists(self.buffer)) {
            buffer_delete(self.buffer);
            self.buffers = undefined;
        }
    }
    
    static load_frome_file = function(filename, texturegoup) {
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, filename, 0);        
        self.load_from_buffer(_buffer, 0, buffer_get_size(_buffer), texturegoup);
    }
    
    static load_from_buffer = function(inbuf, buffer_offset, buffer_length, texturegoup) {
        // Before we do anything check the buffer is a buffer and it has spave for the image to read
        if(!buffer_exists(inbuf)) {
            self.addError("Buffer does not exist");
            return false;    
        }
        if( buffer_get_size(inbuf) < (buffer_offset + buffer_length) ) {
            self.addError("Buffer is too small");
            return false;
        }
        global.pdxLastImageIndex++;
        var seq = string(global.pdxLastImageIndex);
        self.sprite_name = "img-" + string_repeat("0", global.pdxImageIndexDigits - string_length(seq)) + seq;
        
        self.buffer = buffer_create(buffer_length, buffer_fixed, 1);
        if(self.buffer == -1) {
            self.addError("Unknown Buffer error");
            return false;
        }
        
        buffer_copy(inbuf, buffer_offset, buffer_length, self.buffer, 0);
        var _sprite_data = { sprites : {}};
        _sprite_data.sprites[$ self.sprite_name] = { width : self.sprite_size.width, height : self.sprite_size.height, frames : [  { x : 0, y : 0 } ] };
        self.texturegroup_name = texturegoup;
        texturegroup_add(self.texturegroup_name, self.buffer, _sprite_data);
        texturegroup_load(self.texturegroup_name);
        
        return true;
    }

}

