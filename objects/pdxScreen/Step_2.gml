
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
// Feather use all


