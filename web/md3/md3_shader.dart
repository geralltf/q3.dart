part of tech3;

class MD3_Shader
{
  static const MAX_QPATH = 64;
  static bool logging = false;
  MD3_File md3_reader;
  MD3_Surface parent_surface;
  int INDEX;
  int _start_pos;
  String STR_NAME;
  int S32_SHADER_INDEX;
  int _end_pos;
  
  
  MD3_Shader(MD3_File md3_reader, MD3_Surface parent_surface, int index)
  {

    this.md3_reader = md3_reader;
    this.parent_surface = parent_surface;
    this.INDEX = index;
    
    this._start_pos         = md3_reader.byter.getPos();
    this.STR_NAME           = md3_reader.byter.getString(0, MD3_Shader.MAX_QPATH);
    this.S32_SHADER_INDEX   = md3_reader.byter.getInt32Value(0);
    this._end_pos           = md3_reader.byter.getPos();


    if( MD3_Shader.logging )
      this.log();
  }
  
  log()
  {
    print("---------------------------- MD3_Shader[${this.INDEX}] ----------------------------");
    print("    file: "+this.md3_reader.filename             );
    print("    _start_pos         = ${this._start_pos}"       );
    print("     STR_NAME          = ${this.STR_NAME}"         );
    print("     S32_SHADER_INDEX  = ${this.S32_SHADER_INDEX}" );
    print("    _end_pos           = ${this._end_pos}"         );
    print("---------------------------/ MD3_Shader[${this.INDEX}] ----------------------------");
  }
}