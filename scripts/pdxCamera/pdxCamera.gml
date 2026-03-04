enum CAMERA_TYPE {
    ORTHOGRAPHIC,
    PERSPECTIVE
}

function pdxVec2(x = 0, y=0) constructor {
    self.x = x;
    self.y = y;    
}

function pdxVec3(x = 0, y=0, z=0) : pdxVec2(x, y) constructor {
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

function pdxCameraPos(x=0, y=0, z=0) : pdxVec3(x, y, z) constructor {
    
}

function pdxFocalPlane() : pdxScreenRect() constructor {
    self.left = 0;
    self.top = 0;
    self.depth = 0;
    
    static setOrigin = function(left, top) {
        self.left = left;
        self.top = top;
    }
    
    static getHalfHeight = function() {
        return self.height / 2;
    }
    
    static getHalfWidth = function() {
        return self.width / 2;
    }
    
    static getHeight = function() {
        return self.height;
    }
    
    static getWidth = function() {
        return self.width;
    }
    
    static getFocalPoint = function() {
        return new pdxVec3( self.left + (self.width / 2), self.top + (self.height / 2), self.depth );
    }    
}

function pdxCamera() constructor {
    self.cameraId = undefined;
    self.viewId = undefined;
    self.cameraType = CAMERA_TYPE.PERSPECTIVE;
    self.changed = false;
    self.fieldOfView = 60;
    self.cameraPos = new pdxCameraPos();
    self.offset = new pdxVec3();
    self.focalPlane = new pdxFocalPlane();
    self.focalLength = 0;
    self.upDir = new pdxVec3();
    self.znear = 1;
    self.zfar = 32000;
    self.viewmat = undefined;
    self.projmat = undefined;
    self.roll = 0;
    self.inclination = 90;
    self.azimuth = 90;
    
    static incAzimuth = function(value = 1) {
        self.azimuth += value;
        while(self.azimuth >= 360) {
            self.azimuth -= 360;
        }
        self.changed = true;
    }

    static decAzimuth = function(value = 1) {
        self.azimuth -= value;
        while(self.azimuth < 0) {
            self.azimuth += 360;
        }
        self.changed = true;
    }

    static incRoll = function(value = 1) {
        self.roll += value;
        while(self.roll >= 360) {
            self.roll -= 360;
        }
        self.changed = true;
    }

    static decRoll = function(value = 1) {
        self.roll -= value;
        while(self.roll < 0) {
            self.roll += 360;
        }
        self.changed = true;
    }

    static incInclination = function(value = 1) {
        self.inclination += value;
        if(self.inclination >= 180) {
            self.inclination = 179.99999;
        }
        self.changed = true;
    }

    static decInclination = function(value = 1) {
        self.inclination -= value;
        if(self.inclination <= 0) {
            self.inclination = 0.00001;
        }
        self.changed = true;
    }

    static init = function(viewId, width, height, cameraType = CAMERA_TYPE.ORTHOGRAPHIC, originX = 0, originY = 0, fieldOfView = 60) {
        if((cameraType != CAMERA_TYPE.PERSPECTIVE) && (cameraType != CAMERA_TYPE.ORTHOGRAPHIC)) {
            return false;
        }
        if((fieldOfView <= 0) || (fieldOfView >= 135)) {
            return false;
        }
        if((width <= 0) || (height <= 0)) {
            return false;
        }
        if((viewId < 0) || (viewId > 7)) {
            return false;
        }
        
        self.viewId = viewId;
        self.focalPlane.setOrigin(originX, originY);
        self.focalPlane.setSize(width, height);
        self.cameraId = camera_create();
        self.cameraType = cameraType;
        self.fieldOfView = fieldOfView;
        self.offset.x = self.focalPlane.getHalfWidth();
        self.offset.y = self.focalPlane.getHalfHeight();
        
        self.reset();
                
        view_set_camera(self.viewId, self.cameraId);
        self.changed = true;
        self.update();
        camera_set_proj_mat(self.cameraId, self.projmat);
        view_enabled = true;
        view_set_visible(self.viewId, true);
        view_set_wport(self.viewId, self.focalPlane.width);
        view_set_hport(self.viewId, self.focalPlane.height);
        view_set_xport(self.viewId, self.focalPlane.left);
        view_set_yport(self.viewId, self.focalPlane.top);
        
        return self;
        
    }

    static update = function() {
        if(self.changed) {
            // Update everything
            
            self.cameraPos.x = self.focalLength * dcos(self.azimuth);
            
            self.cameraPos.y = -self.focalLength * dcos(self.inclination);
            self.cameraPos.z = self.focalLength * dsin(self.azimuth);
        //    self.cameraPos.z += 100;
        }
        self.upDir.x = dsin(self.roll);
        self.upDir.y = dcos(self.roll);

        var lookAt = self.focalPlane.getFocalPoint(); 
        self.viewmat = matrix_build_lookat( self.cameraPos.x + self.offset.x, self.cameraPos.y + self.offset.y, self.cameraPos.z + self.offset.z, 
                                            lookAt.x, lookAt.y, lookAt.z,
                                            self.upDir.x, self.upDir.y, self.upDir.z);
        camera_set_view_mat(self.cameraId, self.viewmat);
        self.changed = false;
    }
    
    static reset = function() {
        self.inclination = 90;
        self.azimuth = 90;
        
        switch(self.cameraType) {
            case CAMERA_TYPE.ORTHOGRAPHIC: 
                self.roll = 0;
            break;
            case CAMERA_TYPE.PERSPECTIVE:
                self.roll = 180;
            break;
        }
        self.setCameraType();
        self.changed = true;
    }
    
    static switchLens = function() {
        if(self.cameraType == CAMERA_TYPE.ORTHOGRAPHIC) {
                self.cameraType = CAMERA_TYPE.PERSPECTIVE;
        } else { 
                self.cameraType = CAMERA_TYPE.ORTHOGRAPHIC;
        }
        //self.incRoll(180);
        self.setCameraType();
        self.changed = true;
        
    }
    
    static setCameraType = function() {
        switch(self.cameraType) {
            case CAMERA_TYPE.ORTHOGRAPHIC: 
                self.focalLength = -self.focalPlane.height;
                self.cameraPos.z = self.focalLength;
                self.znear = 1;
                self.zfar = 32000;
                self.projmat = matrix_build_projection_ortho(self.focalPlane.width, self.focalPlane.height, self.znear, self.zfar);
            break;
            case CAMERA_TYPE.PERSPECTIVE:
                self.focalLength = -self.focalPlane.getHalfHeight() / dtan((fieldOfView) / 2);
                self.cameraPos.z = self.focalLength;
                self.znear = abs(self.cameraPos.z / 10);
                self.zfar = abs(self.cameraPos.z * 50);
                
                self.projmat = matrix_build_projection_perspective_fov(-fieldOfView, self.focalPlane.aspect, znear, zfar);
            break;
        }        
    }
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