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
var _fn = "Models/textured_1k_cube/glTF-Binary/textured_1k_cube.glb";
//_fn = "Models/Skeleton_Mage/Animations/Rig_Medium_MovementBasic.glb";
//_fn = "Models/Skeleton_Mage/Skeleton_Mage.glb";
//_fn = "Models/Skeleton_Mage/Skeleton_Staff.gltf";
//_fn = "Models/uvcube/glTF/uvcube.gltf";

//_fn = "Models/deck/glTF-Binary/deck.glb";
//_fn = "Models/TVRemote/glTF-Binary/TVRemote.glb";
//_fn = "NonFree/Gamepad/glTF-Binary/Gamepad.glb";
//_fn = "NonFree/d6.glb";


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

