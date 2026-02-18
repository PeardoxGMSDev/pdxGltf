
if(texturegroup_exists("tex_world")) {
    sprites = texturegroup_get_sprites("tex_world");
    draw_sprite(sprites[0],0, 0, 0);
//    amodel.error = "texture = " + string(texturegroup_get_status("tex_world"));
//    draw_sprite(new_sprite,0, 0, 0);
    
}

if(amodel && do_draw) {
    rot += 1;
    gpu_set_zwriteenable(true);
    gpu_set_ztestenable(true);
    //shader_set(khr_unlit_vertex);
    
    var transform1 = matrix_build(0,0,0, 0, rot,0, 48,48,48);
    matrix_set(matrix_world, transform1);
    amodel.render();
 
    var transform2 = matrix_build(115,-10,-10, 0, 0, rot, 48,48,48);
    matrix_set(matrix_world, transform2);
    amodel.render();
    
    var transform3 = matrix_build(-240, 20, 10, rot, 0, 0, 48,48,48);
    matrix_set(matrix_world, transform3);
    amodel.render();
    
    var identity = matrix_build_identity();
    matrix_set(matrix_world, identity);
    
    shader_reset();
    gpu_set_zwriteenable(false);
    gpu_set_ztestenable(false);
}

