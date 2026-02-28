ortho = false;
upDir = new pdxVec3();

if(os_type == os_gxgames) {
    room_width = window_get_width();
    room_height = window_get_height();    
    surface_resize(application_surface, room_width, room_height);
} else {
    room_width = display_get_width();
    room_height = display_get_height();
    surface_resize(application_surface, room_width, room_height);
    window_enable_borderless_fullscreen(true);
    window_set_fullscreen(true);
}


virtual_width = room_width / virtual_scale;
virtual_height = room_height / virtual_scale;

pcam = false;
pcam = new pdxCamera();
if(is_instanceof(pcam, pdxCamera)) {
    pcam.init(1, virtual_width, virtual_height, CAMERA_TYPE.PERSPECTIVE, 0, 0, 60);
//    pcam.init(1, virtual_width, virtual_height);
    show_debug_message(json_stringify(pcam));
} else {
    
    if((virtual_width < room_width) && (room_height < virtual_height)) {
        lookat_x = (room_width div 2) + (virtual_width div 2);
        lookat_y = (room_height div 2) + (virtual_height div 2);
    } else {
        lookat_x = (virtual_width div 2);
        lookat_y = (virtual_height div 2);
    }
    
    var _current_cam = camera_get_active()
    if(_current_cam != -1) {
    //    camera_destroy(_current_cam);
    }
    cam = camera_create();
    // ysign = -1;
    viewmat = undefined;
    projmat = undefined;
    fieldOfView = 30;
    
    fieldOfView = clamp(fieldOfView, 0.01, 135);
    
    view_set_camera(view, cam);
    if(ortho) {
        cpos = ( -virtual_height / 2) ;
        cam_offset = 0;
        znear = 1;
        zfar = 32000;
        Roll = 0;
        Pitch = 0;
        upDir.x = dsin(Roll);
        upDir.y = dcos(Roll);
        viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                       lookat_x, lookat_y, 0,
                                       upDir.x,    upDir.y,   upDir.z);
    //    viewmat = matrix_build_lookat(lookat_x, lookat_y, -1000, lookat_x, lookat_y, 0, 0, 1, 0);
        projmat = matrix_build_projection_ortho(virtual_width, virtual_height, znear, zfar);
        
    } else {
        cpos = ( -virtual_height / 2) / dtan((fieldOfView) / 2);
        cam_offset = 0;
        znear = abs(cpos / 10);
        zfar = abs(cpos * 50);
        Roll = 180;
        Pitch = 0;
        upDir.x = dsin(Roll);
        upDir.y = dcos(Roll);
        viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                    lookat_x, lookat_y, 0,
                                    upDir.x,    upDir.y,   upDir.z);
        projmat = matrix_build_projection_perspective_fov(-fieldOfView, virtual_width / virtual_height, znear, zfar);
    }
    
    camera_set_view_mat(cam, viewmat);
    camera_set_proj_mat(cam, projmat);
    view_enabled = true;
    view_set_visible(view, true);
    view_set_wport(view, virtual_width);
    view_set_hport(view, virtual_height);
}