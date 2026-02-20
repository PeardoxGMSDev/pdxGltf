
if(texturegroup_exists("tex_world")) {
    var sprites = texturegroup_get_sprites("tex_world");
    var spr = sprites[0];
    var inf = sprite_get_info(spr);
    draw_sprite(spr,0, 0, 0);
//    amodel.error = "texture = " + string(texturegroup_get_status("tex_world"));
//    draw_sprite(new_sprite,0, 0, 0);
    
}

if(amodel && do_draw) {
    //rot += 1;
    gpu_set_zwriteenable(true);
    gpu_set_ztestenable(true);
    //shader_set(khr_unlit_vertex);
    
    var transform1, transform2, transform3;    
    
    if(ortho) {
        transform1 = matrix_build(lookat_x,lookat_y,0, 0, rot,0, 400,400,400);
    } else {
        transform1 = matrix_build(lookat_x,lookat_y,0, 0, rot,0, 248,248,248);
    }
    matrix_set(matrix_world, transform1);
    amodel.render();
 
    if(ortho) {
        transform2 = matrix_build(lookat_x - (lookat_x * (2 / 3)),lookat_y,0, 0, 0, rot, 400,400,400);
    } else {
        transform2 = matrix_build(lookat_x - (lookat_x * (2 / 3)),lookat_y,-100, 0, 0, rot, 240,240,240);
    }
    matrix_set(matrix_world, transform2);
    amodel.render();
    
    if(ortho) {
        transform3 = matrix_build(lookat_x + (lookat_x * (2 / 3)),lookat_y,0, 0, 0, rot, 400,400,400);
    } else {
        transform3 = matrix_build(lookat_x + (lookat_x * (2 / 3)),lookat_y, 100, 0, 0, rot, 240,240,240);
    }
    matrix_set(matrix_world, transform3);
    amodel.render();
    
    var identity = matrix_build_identity();
    matrix_set(matrix_world, identity);
    
    shader_reset();
    gpu_set_zwriteenable(false);
    gpu_set_ztestenable(false);
}

