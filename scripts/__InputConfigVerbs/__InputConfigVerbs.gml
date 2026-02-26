function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        //Add your own verbs here!
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ACCEPT,
        QUIT,
        ACTION,
        SPECIAL,
        PAUSE,
        MAP,
        IN,
        OUT,
        ROLL_LEFT,
        ROLL_RIGHT,
        PITCH_UP,
        PITCH_DOWN,
        RESET,
        AZIMUTH_LEFT,
        AZIMUTH_RIGHT
    }
    
    enum INPUT_CLUSTER
    {
        //Add your own clusters here!
        //Clusters are used for two-dimensional checkers (InputDirection() etc.)
        NAVIGATION,
    }
    
    InputDefineVerb(INPUT_VERB.IN,      "in",           [vk_pageup,   "Q"], [-gp_axisrh]);
    InputDefineVerb(INPUT_VERB.OUT,     "out",          [vk_pagedown, "E"], [ gp_axisrh]);
    InputDefineVerb(INPUT_VERB.ROLL_LEFT,  "rollLeft",  [vk_home],          [ gp_shoulderl]);
    InputDefineVerb(INPUT_VERB.ROLL_RIGHT, "rollRight", [vk_end],           [ gp_shoulderr]);
    InputDefineVerb(INPUT_VERB.AZIMUTH_LEFT,  "azimuthUp",    [vk_insert],        [ gp_padl]);
    InputDefineVerb(INPUT_VERB.AZIMUTH_RIGHT, "azimuthDown", [vk_delete],        [ gp_padr]);
    InputDefineVerb(INPUT_VERB.PITCH_UP,  "pitchUp",    [vk_insert],        [ gp_padu]);
    InputDefineVerb(INPUT_VERB.PITCH_DOWN, "pitchDown", [vk_delete],        [ gp_padd]);
    InputDefineVerb(INPUT_VERB.UP,      "up",           [vk_up,       "W"], [-gp_axislv]);
    InputDefineVerb(INPUT_VERB.DOWN,    "down",         [vk_down,     "S"], [ gp_axislv]);
    InputDefineVerb(INPUT_VERB.LEFT,    "left",         [vk_left,     "A"], [-gp_axislh]);
    InputDefineVerb(INPUT_VERB.RIGHT,   "right",        [vk_right,    "D"], [ gp_axislh]);
    InputDefineVerb(INPUT_VERB.ACTION,  "action",        vk_f12,              gp_face4);
    InputDefineVerb(INPUT_VERB.SPECIAL, "special",       vk_f11,              gp_face3);
    

    InputDefineVerb(INPUT_VERB.ACCEPT, "accept", vk_space, gp_face1);
    InputDefineVerb(INPUT_VERB.RESET, "reset", vk_f5, gp_start);
    InputDefineVerb(INPUT_VERB.QUIT, "quit", vk_escape, gp_select);

    
    
    //Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
}
