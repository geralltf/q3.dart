part of tech3;

class MD3_Surface
{
  static const int MAX_QPATH         = 64;
  static const int MD3_MAX_SHADERS   = 256; 
  static const int MD3_MAX_VERTS     = 4096; 
  static const int MD3_MAX_TRIANGLES = 8192; 
  
  static bool logging = false;
  
  MD3_File md3_reader;
  int INDEX;
  int _start_pos;
  String STR_IDENT;
  String STR_NAME;
  int S32_FLAGS;
  int S32_NUM_FRAMES;
  int S32_NUM_SHADERS;
  int S32_NUM_VERTS;
  int S32_NUM_TRIANGLES;
  int S32_OFS_TRIANGLES;
  int S32_OFS_SHADERS;
  int S32_OFS_ST;
  int S32_OFS_XYZNORMAL;
  int S32_OFS_END;
  int _end_pos;
  int pos_shaders;
  int pos_triangles;
  int pos_texcoords;
  int pos_xyznormals;
  
  List<MD3_Shader> shaders;
  Int32List S32_3_INDICES;
  Uint16List Uint16_3_INDICES;
  Float32List S32_2_ST;
  
  List<MD3_SurfaceFrame> surface_frames;
  
  MD3_Surface(MD3_File md3_reader, int index)
  {

    this.md3_reader = md3_reader;
    this.INDEX = index;

    this._start_pos         = md3_reader.byter.getPos();
    this.STR_IDENT          = md3_reader.byter.getString(0,4);
    this.STR_NAME           = md3_reader.byter.getString(0, MD3_Surface.MAX_QPATH);
    this.S32_FLAGS          = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_FRAMES     = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_SHADERS    = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_VERTS      = md3_reader.byter.getInt32Value(0);
    this.S32_NUM_TRIANGLES  = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_TRIANGLES  = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_SHADERS    = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_ST         = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_XYZNORMAL  = md3_reader.byter.getInt32Value(0);
    this.S32_OFS_END        = md3_reader.byter.getInt32Value(0);
    this._end_pos           = md3_reader.byter.getPos();


    if( MD3_Surface.logging )
      this.log();

    if(this.S32_NUM_FRAMES !=   this.md3_reader.header.S32_NUM_FRAMES )
    {
      print("(!CORRPUT MD3!) number of frames incorrect = "+  this.S32_NUM_FRAMES.toString());
    }
    if(this.S32_NUM_SHADERS   < 0 || this.S32_NUM_SHADERS   > MD3_Surface.MD3_MAX_SHADERS)
    {
      print("(!CORRPUT MD3!) S32_NUM_SHADERS = ${this.S32_NUM_SHADERS}"     
          +" ... min/max = 0/" + MD3_Surface.MD3_MAX_SHADERS.toString());
    }
    if(this.S32_NUM_VERTS < 0 || this.S32_NUM_VERTS > MD3_Surface.MD3_MAX_VERTS) 
    {
      print("(!CORRPUT MD3!) S32_NUM_VERTS = ${this.S32_NUM_VERTS}"        
          +" ... min/max = 0/" + MD3_Surface.MD3_MAX_VERTS.toString());
    }
    if( this.S32_NUM_TRIANGLES < 0 || this.S32_NUM_TRIANGLES > MD3_Surface.MD3_MAX_TRIANGLES )  
    {
      print("(!CORRPUT MD3!) S32_NUM_TRIANGLES = ${this.S32_NUM_TRIANGLES}" 
          + " ... min/max = 0/" + MD3_Surface.MD3_MAX_TRIANGLES.toString());
    }

    this.pos_shaders    = this._start_pos + this.S32_OFS_SHADERS;
    this.pos_triangles  = this._start_pos + this.S32_OFS_TRIANGLES;
    this.pos_texcoords  = this._start_pos + this.S32_OFS_ST;
    this.pos_xyznormals = this._start_pos + this.S32_OFS_XYZNORMAL;


    // get Shaders for current surface
    md3_reader.byter.setPos(this.pos_shaders);
    this.shaders = new List(this.S32_NUM_SHADERS);
    for(int i = 0; i < this.S32_NUM_SHADERS; i++)
    {
      this.shaders[i] = new MD3_Shader(this.md3_reader, this, i);
    }


    // get Triangle Indices for current surface
    md3_reader.byter.setPos(this.pos_triangles);
    int num_indices = this.S32_NUM_TRIANGLES*3;

    this.S32_3_INDICES  = md3_reader.byter.getInt32Array(0, num_indices);

    this.Uint16_3_INDICES = new Uint16List(num_indices);
//  console.log("this.Uint16_3_INDICES = "+this.Uint16_3_INDICES.length);
    for(int i = 0; i < num_indices; i++)
    {
      this.Uint16_3_INDICES[i] = this.S32_3_INDICES[i];
    }

    // get texcoords for current surface
    md3_reader.byter.setPos(this.pos_texcoords);
    this.S32_2_ST     = md3_reader.byter.getFloat32Array(0, this.S32_NUM_VERTS*2);


    // get Vertices (XYZ, NORMAL) for each frame of current surface
    md3_reader.byter.setPos(this.pos_xyznormals);
    this.surface_frames = new List(this.S32_NUM_FRAMES);
    for(int i = 0; i < this.S32_NUM_FRAMES; i++)
    {
      this.surface_frames[i] = new MD3_SurfaceFrame(this.md3_reader, this, i);
    }

    if( (this.S32_OFS_END+this._start_pos) != md3_reader.byter.getPos())
    {
      print ("(!CORRPUT MD3!): surface size (number of bytes) incorrect");
    }
  }
  
  log ()
  {
    print("---------------------------- MD3_Surface[${this.INDEX}] ----------------------------");
    print("    file: "+this.md3_reader.filename);
    print("    _start_pos         = ${_start_pos}"        );
    print("     STR_IDENT         = ${STR_IDENT}"        );
    print("     STR_NAME          = ${STR_NAME}"         );
    print("     S32_FLAGS         = ${S32_FLAGS}"        );
    print("     S32_NUM_FRAMES    = ${S32_NUM_FRAMES}"   );
    print("     S32_NUM_SHADERS   = ${S32_NUM_SHADERS}"  );
    print("     S32_NUM_VERTS     = ${S32_NUM_VERTS}"    );
    print("     S32_NUM_TRIANGLES = ${S32_NUM_TRIANGLES}");
    print("     S32_OFS_TRIANGLES = ${S32_OFS_TRIANGLES}");
    print("     S32_OFS_SHADERS   = ${S32_OFS_SHADERS}"  );
    print("     S32_OFS_ST        = ${S32_OFS_ST}"       );
    print("     S32_OFS_XYZNORMAL = ${S32_OFS_XYZNORMAL}");
    print("     S32_OFS_END       = ${S32_OFS_END}"      );
    print("    _end_pos           = ${_end_pos}"          );
    print("---------------------------/ MD3_Surface[${this.INDEX}] ----------------------------");
  }
}