part of tech3;

class MD3_Frame
{
  static var STR_NAME_MAX_LENGTH = 16;
  static bool logging = false;
  MD3_File md3_reader;
  int INDEX;
  int _start_pos;
  Float32List VEC3_MIN_BOUNDS;
  Float32List VEC3_MAX_BOUNDS;
  Float32List VEC3_LOCAL_ORIGIN;
  var F32_RADIUS;
  String STR_NAME;
  int _end_pos;
  List<double> bb_size;
  
  MD3_Frame (MD3_File md3_reader, int index)
  {
    this.md3_reader = md3_reader;
    this.INDEX = index;

    // TODO: update values for models exported from gmax
    this._start_pos         = md3_reader.byter.getPos();
    this.VEC3_MIN_BOUNDS    = md3_reader.byter.getFloat32Array(0, 3);
    this.VEC3_MAX_BOUNDS    = md3_reader.byter.getFloat32Array(0, 3);
    this.VEC3_LOCAL_ORIGIN  = md3_reader.byter.getFloat32Array(0, 3);
    this.F32_RADIUS         = md3_reader.byter.getFloat32Value(0);
    this.STR_NAME           = md3_reader.byter.getString(0, MD3_Frame.STR_NAME_MAX_LENGTH);
    this._end_pos           = md3_reader.byter.getPos();

    this.bb_size = [  this.VEC3_MAX_BOUNDS[0] -  this.VEC3_MIN_BOUNDS[0],
                      this.VEC3_MAX_BOUNDS[1] -  this.VEC3_MIN_BOUNDS[1],
                      this.VEC3_MAX_BOUNDS[2] -  this.VEC3_MIN_BOUNDS[2] ];
    if(MD3_Frame.logging)
      this.log();
  }
  
  log()
  {
    print("---------------------------- MD3_Frame[${this.INDEX}] ----------------------------");
    print("    file: "+this.md3_reader.filename);
    print("    _start_pos         = ${this._start_pos}"                       );
    print("     VEC3_MIN_BOUNDS   = ${vec3ToStr(this.VEC3_MIN_BOUNDS  , 3 )}" );
    print("     VEC3_MAX_BOUNDS   = ${vec3ToStr(this.VEC3_MAX_BOUNDS  , 3 )}" );
    print("     bb_size           = ${vec3ToStr(this.bb_size          , 3 )}" );
    print("     VEC3_LOCAL_ORIGIN = ${vec3ToStr(this.VEC3_LOCAL_ORIGIN, 3 )}" );
    print("     F32_RADIUS        = ${this.F32_RADIUS}"                       );
    print("     STR_NAME          = ${this.STR_NAME}"                         );
    print("    _end_pos           = ${this._end_pos}"                         );
    print("---------------------------/ MD3_Frame[${this.INDEX}] ----------------------------");
  }
}