virtual_scale = 1;
virtual_width = 0;
virtual_height = 0;
lookat_x = 0;
lookat_y = 0;
cam = 0;
view = 0;
sprites = undefined;
tfps = 0;
nfps = 0;
gui_mode = 0;
show_detail = 0;
rot = 0;
do_draw = true;


// display_set_timing_method(tm_systemtiming);

// 
// show_debug_overlay(true);

// amodel = new pdxGLB();
//amodel = new pdxGLTF();
var _fn = "Models/textured_1k_cube/glTF-Binary/textured_1k_cube.glb";
//_fn = "Models/Skeleton_Mage/Animations/Rig_Medium_MovementBasic.glb";
//_fn = "Models/Skeleton_Mage/Skeleton_Mage.glb";
//_fn = "Models/Skeleton_Mage/Skeleton_Staff.gltf";

//_fn = "Models/deck/glTF-Binary/deck.glb";
//_fn = "Models/TVRemote/glTF-Binary/TVRemote.glb";
//_fn = "NonFree/d6.glb";
//_fn = "NonFree/dice.glb";
//_fn = "NonFree/squirrel.glb";

//_fn = "Models/watchtower/glTF-Binary/watchtower.glb";
//_fn = "Models/door-rotate-square-a/glTF-Binary/door-rotate-square-a.glb";
_fn = "Models/uvcube/glTF-Binary/uvcube.glb";
_fn = "Models/uvcube/glTF/uvcube.gltf";
_fn = "NonFree/d12.glb";
_fn = "NonFree/d20.glb";
_fn = "NonFree/d6.glb";
_fn = "Models/uvcube/glTF-Binary/uvcube.glb";
// _fn = "Models/uvcube/glTF/uvcube.gltf";
// _fn = "NonFree/dice/d6.gltf";
// _fn = "Models/ShadedCube/glTF/ShadedCube.gltf";

//_fn = "NonFree/d20.glb";
//_fn = "NonFree/dice.glb";
//_fn = "gltf-samples/Models/CarConcept/glTF/CarConcept.gltf";
// _fn = "Models/Skeleton_Mage/Skeleton_Mage.glb"; 
// _fn = "NonFree/Gamepad/glTF-Binary/Gamepad.glb";
// _fn = "gltf-samples/Models/BoxVertexColors/glTF/BoxVertexColors.gltf";
// _fn = "Models/Dispatcher/glTF-Binary/Dispatcher.glb";


wd = working_directory;
// wd = "c:/src/pdxGltf/datafiles/";

//_fn = "FlightHelmet\\glTF-Binary\\FlightHelmet.glb";
// _fn = "SimpleSparseAccessor/glTF/SimpleSparseAccessor.gltf"; 
// wd = "C:\\git\\glTF-Sample-Assets\\Models\\";

model_file = wd + _fn;
amodel = openModel(model_file);
// amodel.critical("Quit?")

//amodel = openModel(working_directory + _fn);
if(amodel) {
    amodel.read();
    amodel.process();
    amodel.build();
    
    model_errors = amodel.gatherErrors();
    if(amodel.errval) {
        gui_mode = 2;
    }

}

// files = findModels(wd + "glb");

instance_create_depth(1,1,0,testImage);

var _fp_root = layer_get_flexpanel_node("UILayer_1");
flexpanel_calculate_layout(_fp_root, 2560, 1440, flexpanel_direction.LTR);
// show_debug_message(_fp_root);
