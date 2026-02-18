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
if((virtual_width < room_width) && (room_height < virtual_height)) {
    lookat_x = (room_width div 2) + (virtual_width div 2);
    lookat_y = (room_height div 2) + (virtual_height div 2);
} else {
    lookat_x = (virtual_width div 2);
    lookat_y = (virtual_height div 2);
}

var _current_cam = camera_get_active()
if(_current_cam != -1) {
    camera_destroy(_current_cam);
}
cam = camera_create();
view_set_camera(view, cam);
var _viewmat = matrix_build_lookat(lookat_x, lookat_y, -1000, lookat_x, lookat_y, 0, 0, -1, 0);
//  _viewmat = matrix_build_lookat(lookat_x, lookat_y, -1000, 0, lookat_x, lookat_y, 1, 0, 0);
//    _viewmat = matrix_build_lookat(lookat_x, -1000, lookat_y, lookat_x, 0, lookat_y, 0, 0, 1);
var _viewmatp = matrix_build_lookat(250,   -100, 250, 
                                      0,   0,   0, 
                                      0,  1,   0);
var _projmat = matrix_build_projection_ortho(virtual_width, virtual_height, -32000.0, 64000.0);
// _projmat = matrix_build_projection_perspective(virtual_width, virtual_height, virtual_width, virtual_width * 2);
var _projmatp = matrix_build_projection_perspective_fov(30, room_width / room_height, 1, 32000);
camera_set_view_mat(cam, _viewmatp);
camera_set_proj_mat(cam, _projmatp);
view_enabled = true;
view_set_visible(view, true);
view_set_wport(view, virtual_width);
view_set_hport(view, virtual_height);
