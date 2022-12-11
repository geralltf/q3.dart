part of tech3;

class MD3_Header
{
  static const int MAX_QPATH        = 64;
  static const int MAX_IDENT        = 4;
  static const int MD3_MAX_FRAMES   = 1024;
  static const int MD3_MAX_TAGS     = 16;
  static const int MD3_MAX_SURFACES = 32;
  
  static bool logging = false;
  
  MD3_File md3_reader;
  int _start_pos;
  String IDENT;
  int VERSION;
  String NAME;
  int S32_FLAGS;
  int S32_NUM_FRAMES;
  int S32_NUM_TAGS;
  int S32_NUM_SURFACES;
  int S32_NUM_SKINS;
  int S32_OFS_FRAMES;
  int S32_OFS_TAGS;
  int S32_OFS_SURFACES;
  int S32_OFS_EOF;
  int _end_pos;
  
  
  MD3_Header(MD3_File md3_reader)
  {
    this.md3_reader = md3_reader;
 
    //Byter bin = new Byter(md3_reader.byter.bytes);
    this._start_pos        = md3_reader.byter.getPos();
    this.IDENT             = md3_reader.byter.getString    (0, MD3_Header.MAX_IDENT);
    this.VERSION           = md3_reader.byter.getInt32Value(0);
    this.NAME              = md3_reader.byter.getString    (0, MD3_Header.MAX_QPATH);
    this.S32_FLAGS         = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_FRAMES    = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_TAGS      = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_SURFACES  = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_SKINS     = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_FRAMES    = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_TAGS      = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_SURFACES  = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_EOF       = md3_reader.byter.getInt32Value(0);
    this._end_pos          = md3_reader.byter.getPos();

    if( MD3_Header.logging )
      this.log();

    if( this.S32_NUM_FRAMES   < 1 || this.S32_NUM_FRAMES   > MD3_Header.MD3_MAX_FRAMES)  
    {
      print ("(!CORRPUT MD3!) S32_NUM_FRAMES = ${this.S32_NUM_FRAMES} ... min/max = 1/"
        +MD3_Header.MD3_MAX_FRAMES.toString());
    }
    if( this.S32_NUM_TAGS     < 0 || this.S32_NUM_TAGS     > MD3_Header.MD3_MAX_TAGS)    
    {
      print ("(!CORRPUT MD3!) S32_NUM_TAGS = ${this.S32_NUM_TAGS} ... min/max = 0/"
        +MD3_Header.MD3_MAX_TAGS.toString());
    }
    if( this.S32_NUM_SURFACES < 0 || this.S32_NUM_SURFACES > MD3_Header.MD3_MAX_SURFACES)
    {
      print ("(!CORRPUT MD3!) S32_NUM_SURFACES = ${this.S32_NUM_SURFACES} ... min/max = 0/"
        +MD3_Header.MD3_MAX_SURFACES.toString());
    }

    if(this.S32_OFS_EOF != md3_reader.byter.totalSize())
    {
      //throw ("(!CORRPUT MD3!) FILE_SIZE incorrect: expected '"+this.S32_OFS_EOF.toString() +" bytes', but got '"+bin.length.toString() +" bytes'");
      print ("(!CORRPUT MD3!) FILE_SIZE incorrect: expected '${this.S32_OFS_EOF} bytes', but got '"
      +md3_reader.byter.total_size.toString() +" bytes'");
    }
    
    //if( this.S32_OFS_EOF != byter.totalSize())
      //throw ("(!CORRPUT MD3!) FILE_SIZE incorrect: expected '"+this.S32_OFS_EOF +" bytes', but got '"+byter.totalSize()+" bytes'");
  }
  
  log()
  {
    print("---------------------------- MD3_Header ----------------------------");
    print("    file: ${this.md3_reader.filename}");
    print("    _start_pos         = ${this._start_pos}"      );
    print("     IDENT             = ${this.IDENT}"           );
    print("     VERSION           = ${this.VERSION}");
    print("     NAME              = ${this.NAME}"            );
    print("     S32_FLAGS         = ${this.S32_FLAGS}"       );
    print("     S32_NUM_FRAMES    = ${this.S32_NUM_FRAMES}"  );
    print("     S32_NUM_TAGS      = ${this.S32_NUM_TAGS}"    );
    print("     S32_NUM_SURFACES  = ${this.S32_NUM_SURFACES}");
    print("     S32_NUM_SKINS     = ${this.S32_NUM_SKINS}"   );
    print("     S32_OFS_FRAMES    = ${this.S32_OFS_FRAMES}"  );
    print("     S32_OFS_TAGS      = ${this.S32_OFS_TAGS}"    );
    print("     S32_OFS_SURFACES  = ${this.S32_OFS_SURFACES}");
    print("     S32_OFS_EOF       = ${this.S32_OFS_EOF}"     );
    print("    _end_pos           = ${this._end_pos}"        );
    print("---------------------------/ MD3_Header ----------------------------");
  }
}