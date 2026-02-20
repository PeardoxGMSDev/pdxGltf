tfps += fps_real;
nfps++;

draw_set_valign(fa_top);
draw_set_colour(c_yellow);
draw_set_halign(fa_right);
if(amodel == false) {
    draw_text((virtual_width * virtual_scale) - 20,  20, "Model Not Found : " + model_file);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_text(20, 40, "Virtual : " + string(virtual_width) + " x "  + string(virtual_height));    
    exit;
    
}

amodel_data = amodel.data;

draw_text((virtual_width * virtual_scale) - 20,  20, "Tris = " + string(global.triCount) + ", Build : " + string_format(amodel.buildTime/1000000, 1, 6) + ", Process : " + 
    string_format(amodel.processTime/1000000, 1, 6) + ", Load : " + string_format(amodel.loadTime/1000000, 1, 6) + ", Read : " + string_format(amodel.readTime/1000000, 1, 6) + 
    ", FPS : " + string(fps) + ", RealFPS : " + string(tfps/nfps));

draw_set_colour(c_white);
draw_set_halign(fa_left);
//draw_text(20, 40, "LookAt : " + string(lookat_x) + " x "  + string(lookat_y));
draw_text(20, 40, "Model : " + string(amodel.filepath) + string(amodel.filename) + ", Virtual : " + string(virtual_width) + " x "  + string(virtual_height));
if(amodel) {
    switch(gui_mode) {
        case 0:
            draw_text(20,  80, "asset : "       + string(amodel_data.asset)             );
            draw_text(20, 100, "rexts : "       + string(array_length(amodel_data.extensionsRequired)) + " : " + string(amodel_data.extensionsRequired));
            draw_text(20, 120, "uexts : "       + string(array_length(amodel_data.extensionsUsed)    ) + " : " + string(amodel_data.extensionsUsed)    );
            draw_text(20, 140, "scene : "       + string(amodel_data.scene)             );
            draw_text(20, 160, "scenes : "      + string(array_length(amodel_data.scenes)            ) + " : " + string(amodel_data.scenes)            );
            if(array_length(amodel_data.nodes) > 4) {
                draw_text(20, 180, "nodes : "       + string(array_length(amodel_data.nodes)             ) + " : " + string(amodel_data.nodes[0]) + " [...]");
            } else {
                draw_text(20, 180, "nodes : "       + string(array_length(amodel_data.nodes)             ) + " : " + string(amodel_data.nodes)             );
            }
            draw_text(20, 200, "mat : "         + string(array_length(amodel_data.materials)         ) + " : " + string(amodel_data.materials)         );
            draw_text(20, 220, "mesh : "        + string(array_length(amodel_data.meshes)            ) + " : " + string(amodel_data.meshes)            );
            draw_text(20, 240, "tex : "         + string(array_length(amodel_data.textures)          ) + " : " + string(amodel_data.textures)          );
            draw_text(20, 260, "images : "      + string(array_length(amodel_data.images)            ) + " : " + string(amodel_data.images)            );
            if(array_length(amodel_data.accessors) > 4) {
                draw_text(20, 280, "accessors : "   + string(array_length(amodel_data.accessors)         )  + " : " + string(amodel_data.accessors[0]) + " [...]");
            } else {
                draw_text(20, 280, "accessors : "   + string(array_length(amodel_data.accessors)         ) + " : " + string(amodel_data.accessors)         );
            }
            if(array_length(amodel_data.bufferViews) > 4) {
                draw_text(20, 300, "bufferViews : " + string(array_length(amodel_data.bufferViews)       )  + " : " + string(amodel_data.bufferViews[0]) + " [...]");
            } else {
                draw_text(20, 300, "bufferViews : " + string(array_length(amodel_data.bufferViews)       ) + " : " + string(amodel_data.bufferViews)       );
            }
            draw_text(20, 320, "samplers : "    + string(array_length(amodel_data.samplers)          ) + " : " + string(amodel_data.samplers)          );
            draw_text(20, 340, "buffers : "     + string(array_length(amodel_data.buffers)           ) + " : " + string(amodel_data.buffers)           );
            if(array_length(amodel_data.animations) > 4) {
                draw_text(20, 360, "amins : "       + string(array_length(amodel_data.animations)        )  + " : " + string(amodel_data.animations[0]) + " [...]");
            } else {
                draw_text(20, 360, "amins : "       + string(array_length(amodel_data.animations)        ) + " : " + string(amodel_data.animations)        );
            }
            draw_text(20, 380, "skins : "       + string(array_length(amodel_data.skins)             ) + " : " + string(amodel_data.skins)             );
        
            if(amodel_data.hasErrors()) {
                draw_text(20, 420, "*** Errors *** : " + string(amodel_data.error));
            } else {
                draw_text(20, 420, "No Errors");
            }
            if(amodel_data.hasWarnings()) {
                draw_text(20, 440, "*** Warnings *** : " + string(amodel_data.warning));
            } else {
                draw_text(20, 440, "No Warnings");
            }
/*        
            if(is_array(self.files)) {
                draw_text(20, 460, "*** Files *** : " + string(self.files));
            } else {
                draw_text(20, 460, "No Files");
            }
*/            
            
            switch(show_detail) {
                case 0:
                    draw_text(20, 480, "Press F12 to show/hide Accessors")
                    break;
                case 1:
                    if(is_array(amodel.accessorData)) {
                        var _al = array_length(amodel.accessorData);
                        for(var _i=0; _i<_al; _i++) {
                          draw_text(20, 480 + (_i * 20), "accessorData[" + 
                                LeftFillBlank(_i) + 
                                "] " + 
                                amodel.accessorData[_i].prettyPrint()
                            );
                            if((80 + (_i * 20)) > (virtual_height - 720)) {
                                break;
                            }
                        }
                    } else {
                          draw_text(20, 480, "No Accessor Data") 
                    }
                    break;
                case 2: 
                    if(is_array(amodel.primitiveList)) {
                        var _al = array_length(amodel.primitiveList);
                        for(var _i=0; _i<_al; _i++) {
                          draw_text(20, 480 + (_i * 20), "primitiveList[" + 
                                string(_i) + 
                                "] " + 
                                amodel.primitiveList[_i].prettyPrint()
                            );
                            if((80 + (_i * 20)) > (virtual_height - 720)) {
                                break;
                            }
                        }
                    } else {
                          draw_text(20, 480, "No primitiveList Data") 
                    }
                    break;
                case 3:
                    if((amodel.vertexBufferSet != undefined) && (is_array(amodel.vertexBufferSet.buffers))) {
                        draw_text(20, 480, "Vertex Buffers (" + string(amodel.vertexBufferSet.count) + ") Size = " + string(amodel.vertexBufferSet.totalSize));
                        for(var i=0; i<amodel.vertexBufferSet.count; i++) {
                            draw_text(20, 500 + (i * 20), "Vertex Buffer #" + string(i) + " = " + string(amodel.vertexBufferSet.buffers[i].vertexSize));
                        }        
                    } else {
                        draw_text(20, 480, "No Accessor Vertex Buffer") 
                    }
                    break;
            }
            break;
        case 1:
            draw_text(20, 80, amodel.tree[0]);
            draw_text(800, 80, amodel.tree[1].prettyPrint());
            // draw_text(1600, 80, string(tv.prettyPrint()));

            break;
        case 2:
            if(model_errors != "") {
                draw_text(20, 80, model_errors);
            }
            if(amodel.hasErrors()) {
                draw_text(800, 40, "Error");
                draw_text(800, 80, amodel.error);
            }
            if(amodel.hasWarnings()) {
                draw_text(1600, 40, "Warning");
                draw_text(1600, 80, amodel.warning);
            }
            break;
    
    }

}

draw_text(20, display_get_gui_height() - 100, "fov = " + string_format(fieldOfView, 0, 9) + ", cpos = " + string(cpos) + ", znear = " + string(znear) + ", zfar = " + string(zfar));

draw_text(20, display_get_gui_height() - 80, "viewmat = " + string(viewmat));
draw_text(20, display_get_gui_height() - 60, "projmat = " + string(projmat));
