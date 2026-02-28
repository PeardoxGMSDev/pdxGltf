if(is_instanceof(pcam, pdxCamera)) {
    pcam.update();
    if(InputPressed(INPUT_VERB.QUIT)) {
        game_end();
    }
} else {

    // Feather use none
    if(InputPressed(INPUT_VERB.SPECIAL)) {
        do_draw = !do_draw;
        layer_set_visible("Tiles_1",do_draw);
        tfps = 0;
        nfps = 0;
    }
    
    if(InputPressed(INPUT_VERB.ACTION)) {
        show_detail++;
        if(show_detail > 3) {
            show_detail = 0;
        }
        
    }
    
    if(InputPressed(INPUT_VERB.ACCEPT)) {
        gui_mode++;
        if(gui_mode > 2) {
            gui_mode = 0;
        }
        
        tfps = 0;
        nfps = 0;    
    }
    
    if(InputPressed(INPUT_VERB.QUIT)) {
        game_end();
    }
    
    if(InputCheck(INPUT_VERB.UP)) {
        rotX++;
    }
        
    if(InputCheck(INPUT_VERB.DOWN)) {
        rotX--;
    }
    
    if(InputCheck(INPUT_VERB.LEFT)) {
        rotY--;
    }
        
    if(InputCheck(INPUT_VERB.RIGHT)) {
        rotY++;
    }
    
    if(InputCheck(INPUT_VERB.IN)) {
        rotZ--;
    }
        
    if(InputCheck(INPUT_VERB.OUT)) {
        rotZ++;
    }
    
    if(InputCheck(INPUT_VERB.RESET)) {
        rotX = 0;
        rotY = 0;
        rotZ = 0;
        Pitch = 0;
        if(ortho) {
            Roll = 0;
        } else {
            Roll = 180;
        }
        upDir.x = dsin(Roll);
        upDir.y = dcos(Roll);
        upDir.z = 0;
        viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                    lookat_x, lookat_y, 0,
                                    upDir.x,    upDir.y,   upDir.z);
        camera_set_view_mat(cam, viewmat);
    }
    
    if(InputCheck(INPUT_VERB.ROLL_LEFT)) {
        Roll++;
        if(Roll >= 360) {
            Roll -= 360;
        }
        upDir.x = dsin(Roll);
        upDir.y = dcos(Roll);
        upDir.z = 0;
        viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                    lookat_x, lookat_y, 0,
                                    upDir.x,    upDir.y,   upDir.z);
        camera_set_view_mat(cam, viewmat);
    }
    
    if(InputCheck(INPUT_VERB.ROLL_RIGHT)) {
        Roll--;
        if(Roll < 0) {
            Roll += 360;
        }
        upDir.x = dsin(Roll);
        upDir.y = dcos(Roll);
        upDir.z = 0;
        viewmat = matrix_build_lookat( lookat_x, lookat_y, cpos + cam_offset, 
                                    lookat_x, lookat_y, 0,
                                    upDir.x,    upDir.y,   upDir.z);
        camera_set_view_mat(cam, viewmat);
    }
    
    
    
    // Feather use all
    
}
