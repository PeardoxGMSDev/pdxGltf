
if(amodel && do_draw) {
        //rot += 1;

    gpu_set_zwriteenable(true);
    gpu_set_ztestenable(true);
    // draw_clear(c_black);
    // shader_set(khr_unlit_vertex);
    
    var transform1, transform2, transform3;    
    
    transform1 = matrix_build(lookat_x,lookat_y,0, -rotX, -rotY, -rotZ, 248,248,248);
    //transform1 = matrix_build(lookat_x,lookat_y,0, -70, 45, 0, 0.5, 0.5, 0.5 );
    matrix_set(matrix_world, transform1);
    amodel.render();
/* 
    if(ortho) {
        transform2 = matrix_build(lookat_x - (lookat_x * (2 / 3)),lookat_y,0, 0, 0, rot, 240,240,240);
    } else {
        transform2 = matrix_build(lookat_x - (lookat_x * (2 / 3)),lookat_y,0, 0, 0, rot, 240,240,240);
    }
    matrix_set(matrix_world, transform2);
    amodel.render();
*/    

    var identity = matrix_build_identity();
    matrix_set(matrix_world, identity);
    
    shader_reset();
    gpu_set_zwriteenable(false);
    gpu_set_ztestenable(false);
}

