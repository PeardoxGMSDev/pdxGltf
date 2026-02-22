    if(texturegroup_exists("tex_world")) {
        var sprites = texturegroup_get_sprites("tex_world");
        var spr = sprites[0];
        
        var inf = sprite_get_info(spr);
        //show_debug_message(json_stringify(inf));
        draw_sprite(spr,x, y, 0);
    //    amodel.error = "texture = " + string(texturegroup_get_status("tex_world"));
    //    draw_sprite(new_sprite,0, 0, 0);
        
    }