part of tech3;


class MD3_Tag
{
  static int MAX_QPATH = 64;
  static bool logging = false;
  
  MD3_File md3_reader;
  MD3_TagFrame parent_tag_frame;
  int INDEX;
  int _start_pos;
  String STR_NAME;
  Float32List VEC3_ORIGIN;
  Float32List VEC3_X_AXIS;
  Float32List VEC3_Y_AXIS;
  Float32List VEC3_Z_AXIS;
  int _end_pos;
  Matrix4 matrix;
  Matrix4 matrix_inv;
  Matrix4 matrix_trans;
  
  MD3_Tag(MD3_File md3_reader, MD3_TagFrame parent_tag_frame, int index)
  {

    this.md3_reader = md3_reader;
    this.parent_tag_frame = parent_tag_frame;
    this.INDEX = index;

    this._start_pos         = md3_reader.byter.getPos();
    this.STR_NAME           = md3_reader.byter.getString(0,MD3_Tag.MAX_QPATH);
    this.VEC3_ORIGIN        = md3_reader.byter.getFloat32Array(0, 3);
    this.VEC3_X_AXIS        = md3_reader.byter.getFloat32Array(0, 3);
    this.VEC3_Y_AXIS        = md3_reader.byter.getFloat32Array(0, 3);
    this.VEC3_Z_AXIS        = md3_reader.byter.getFloat32Array(0, 3);
    this._end_pos           = md3_reader.byter.getPos();

    // create matrix from tag axis and origin
    this.matrix = new Matrix4.identity(); // this.matrix = DwMat4.identity_new();
    
    mat4setAxisXYZ_ref(this.matrix, this.VEC3_X_AXIS, this.VEC3_Y_AXIS, this.VEC3_Z_AXIS);
    mat4SetTranslation(this.matrix, this.VEC3_ORIGIN);

    // create inverted matrix (could be the transposed too )
    this.matrix_inv   = mat4Inverse_new(this.matrix);
    // create transposed matrix (faster to generate)
    this.matrix_trans = mat4Transpose_new(this.matrix);
    //TODO if transposed is ok, use it,....

//  print("-----mat inverse -----");
//  print(DwMat4.toStr(this.matrix_inv));
//  print("-----mat transpose -----");
//  print(DwMat4.toStr(this.matrix_trans));

    if( MD3_Tag.logging )
      this.log();
  }
  
  log ()
  {
    print("---------------------------- MD3_Tag[${this.INDEX}] ----------------------------");
    print("    file: "+this.md3_reader.filename);
    print("    _start_pos         = ${this._start_pos} "                );
    print("     STR_NAME          = ${this.STR_NAME}"                  );
    print("     VEC3_ORIGIN       = "+vec3ToStr(this.VEC3_ORIGIN, 3) );
    print("     VEC3_ORIGIN       = "+vec3ToStr(this.VEC3_ORIGIN, 3) );
    print("     VEC3_X_AXIS       = "+vec3ToStr(this.VEC3_X_AXIS, 3) );
    print("     VEC3_Y_AXIS       = "+vec3ToStr(this.VEC3_Y_AXIS, 3) );
    print("     VEC3_Z_AXIS       = "+vec3ToStr(this.VEC3_Z_AXIS, 3) );
    print("    _end_pos           = ${this._end_pos}"                  );
    print("---------------------------/ MD3_Tag[${this.INDEX}] ----------------------------");
  }
  


  
  getMatrix (){
    return this.matrix;
  }
  getMatrixInv ()
  {
    return this.matrix_inv;
//  return this.matrix_trans;
  }
}