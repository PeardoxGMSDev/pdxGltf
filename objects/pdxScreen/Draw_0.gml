
if(texturegroup_exists("tex_world")) {
    sprites = texturegroup_get_sprites("tex_world");
    draw_sprite(sprites[0],0, 0, 0);
//    amodel.error = "texture = " + string(texturegroup_get_status("tex_world"));
//    draw_sprite(new_sprite,0, 0, 0);
    
}

if(amodel) {
    gpu_set_zwriteenable(true);
    gpu_set_ztestenable(true);
    var transform = matrix_build(0,0,0, 270,0,0, 48,48,48);
    matrix_set(matrix_world, transform);
    amodel.render();
    var identity = matrix_build_identity();
    matrix_set(matrix_world, identity);
    gpu_set_zwriteenable(false);
    gpu_set_ztestenable(false);
}

/*
var _num = (current_time / 1000 * 12) mod (vertex_get_number(vb) + 1);
vertex_submit_ext(vb, pr_linestrip, -1, 0, _num);
*/