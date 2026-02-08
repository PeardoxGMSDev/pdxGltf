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
// amodel = new pdxGLB();
//amodel = new pdxGLTF();
var _fn = "glb/textured_1k_cube.glb";
/*
_fn = "glb/basic_cube.glb";
_fn = "glb/cube_pyramid.glb";
_fn = "glb/squirrel.glb";
_fn = "glb/world.glb";
_fn = "glb/ShadedCubeOffsetX30.glb";
_fn = "glb/CubeRotateTranslate.glb";
_fn = "glb/watchtower.glb";
_fn = "glb/Skeleton_Warrior.glb";
_fn = "glb/Skeleton_Warrior_Free.glb";
_fn = "glb/ShadedCube.glb";
_fn = "gltf/basic_cube.gltf";
_fn = "glb\\door-rotate-square-a.glb";
_fn = "glb/assetforge-door.glb";
_fn = "gltf/Rotator.gltf";
_fn = "glb/rotate.glb";
_fn = "glb/dice.glb";
_fn = "glb/ancient_desert_arena.glb";
_fn = "glb/d6.glb";
_fn = "glb/d20.glb";
_fn = "gltf/chess_set_1k.gltf";
_fn = "glb/chubbycat.glb";
_fn = "glb/uvcube.glb";
_fn = "gltf/uvcube-unlit.gltf"; 
_fn = "glb/boy_ani.glb";
_fn = "glb/boy.glb";
_fn = "glb/stonelake.glb";
_fn = "glb/island.glb";
_fn = "glb/CarConcept.glb";
*/
_fn = "gltf/chess_set_1k.gltf";

// _fn = "glb/basic_cube.glb";
// _fn = "glb/ShadedCube.glb";
// _fn = "gltf/ShadedCube.gltf";
// _fn = "glb/d20.glb";
// _fn = "glb/rotate.glb"
// _fn = "gltf/Rotator.gltf";
// _fn = "glb/uvcube.glb";
 _fn = "gltf/uvcube-unlit.gltf";
// _fn = "glb/CarConcept.glb";
wd = working_directory;


//_fn = "FlightHelmet\\glTF-Binary\\FlightHelmet.glb";
// _fn = "SimpleSparseAccessor/glTF/SimpleSparseAccessor.gltf";
// wd = "C:\\git\\glTF-Sample-Assets\\Models\\";

model_file = wd + _fn;
amodel = openModel(model_file);

//amodel = openModel(working_directory + _fn);
if(amodel) {
    amodel.read();
    amodel.build();
    
    model_errors = amodel.gatherErrors();
    if(amodel.errval) {
        gui_mode = 2;
    }

}

files = findModels(wd + "glb");

tv = new pdxWidgetTreeView("Root");
tv.addItem("Item 1", "data1");
var _node2 = tv.addNode("Node 1");
tv.addItem("Item 2", "data2");
_node2.addItem("Item 3", "data3");
_node2.addItem("Item 4", "data4");
_node2.addItem("Item 5", "data5");

var _test_image = wd + "gltf/imgtest/Mercator_projection_Square";

//_test_image += ".gif";
//_test_image += ".png";
_test_image += ".jpg";
// _test_image += ".qoi";
var _imtest = false;
if(file_exists(_test_image) && _imtest) {
    var _tp = new pdxImage();
    _tp.load_frome_file(_test_image, "tex_world");
}

