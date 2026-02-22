var _test_image = working_directory + "imgtest/xyzcube";

//_test_image += ".gif";
_test_image += ".png";
// _test_image += ".jpg";
// _test_image += ".qoi";
var _imtest = true;
if(file_exists(_test_image)) {
    var _tp = new pdxImage();
    _tp.load_frome_file(_test_image, "tex_world");
}