if(keyboard_check(vk_escape)) {
    game_end();
}

if(keyboard_check_pressed(vk_space)) {
    gui_mode++;
    if(gui_mode > 2) {
        gui_mode = 0;
    }
    
    tfps = 0;
    nfps = 0;
}

if(keyboard_check_pressed(vk_f12)) {
    show_detail++;
    if(show_detail > 3) {
        show_detail = 0;
    }
    
}
