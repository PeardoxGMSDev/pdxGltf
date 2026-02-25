function pdxVec2(x = 0, y=0) constructor {
    self.x = x;
    self.y = y;    
}

function pdxVec3(x = 0, y=0, z=0) : pdxVec2(x = 0, y=0) constructor {
    self.z = z;
}

function pdxScreenRect() constructor {
    self.width = 0;
    self.height = 0;
    self.aspect = 0;
    
    static setSize = function(width, height) {
        if((width == 0) || (height == 0)) {
            return false;
        }
        self.width = width;
        self.height = height;
        self.aspect = self.width / self.height;
        
        return self;
    }
}

function pdxPhysicalScreenRect() : pdxScreenRect() constructor {
}

function pdxWindowScreenRect() : pdxScreenRect() constructor {
    self.isFullScreen = false;
    self.hasTitleBar = true;
}

function pdxVirtualScreenRect() : pdxScreenRect() constructor {
    self.scale = 1;
}

function pdxCamera() constructor {
    self.cameraId = undefined;
    self.position = new pdxVec3();
    self.direction = new pdxVec3();

}

function pdxViewConfig() constructor {
    self.isOrtho = false;
    self.isFullScreen = false;
    self.hasTitleBar = true;
    self.scale = 1;
    self.width = 640;
    self.height = 480;
}


function pdxViewPort() constructor {
    self.isOrtho = false;
    self.physical = new pdxPhysicalScreenRect();
    self.window = new pdxWindowScreenRect();
    self.virtual = new pdxVirtualScreenRect();
    self.viewPort = undefined;
    self.Camera = new pdxCamera();
    
    if(os_type == os_gxgames) {
        self.physical.setSize(window_get_width(), window_get_height());
    } else {
        self.physical.setSize(display_get_width(), display_get_height());
//        surface_resize(application_surface, room_width, room_height);
        window_enable_borderless_fullscreen(true);
//        window_set_fullscreen(true);
    }
    
    virtual_width = room_width / self.virtual.scale;
    virtual_height = room_height / self.virtual.scale;
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
    // ysign = -1;
    viewmat = undefined;
    projmat = undefined;
    fieldOfView = 30;
    
    fieldOfView = clamp(fieldOfView, 0.01, 135);
    
    //cpos = ysign * ( virtual_height / 2) / dtan((fieldOfView) / 2);
    // cpos += 100;
    
    view_set_camera(view, cam);
    if(ortho) {
        cpos = ( -virtual_height / 2) ;
        cam_offset = 0;
        znear = 1;
        zfar = 32000;
        viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                    lookat_x, lookat_y, 0,
                                        0,    1,   0);
    //    viewmat = matrix_build_lookat(lookat_x, lookat_y, -1000, lookat_x, lookat_y, 0, 0, 1, 0);
        projmat = matrix_build_projection_ortho(virtual_width, virtual_height, znear, zfar);
        
    } else {
            cpos = ( -virtual_height / 2) / dtan((fieldOfView) / 2);
            cam_offset = 0;
            znear = abs(cpos / 10);
            zfar = abs(cpos * 50);
            viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                           lookat_x, lookat_y, 0,
                                            0,    -1,   0);
            projmat = matrix_build_projection_perspective_fov(-fieldOfView, virtual_width / virtual_height, znear, zfar);
    }
    
    camera_set_view_mat(cam, viewmat);
    camera_set_proj_mat(cam, projmat);
    view_enabled = true;
    view_set_visible(view, true);
    view_set_wport(view, virtual_width);
    view_set_hport(view, virtual_height);
        
}