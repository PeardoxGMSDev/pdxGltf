    if(texturegroup_exists("tex_world")) {
        var sprites = texturegroup_get_sprites("tex_world");
        var spr = sprites[0];
        
        var inf = sprite_get_info(spr);
        //show_debug_message(json_stringify(inf));
        draw_sprite(spr, 0, x, y);
        
    }
/*
    if(texturegroup_exists("tex-001")) {
        var sprites = texturegroup_get_sprites("tex-001");
        var spr = sprites[0];
        
        var inf = sprite_get_info(spr);
        draw_sprite(spr,0, 512, 0);
    }
*/