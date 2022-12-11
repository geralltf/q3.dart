part of tech3;

class MD3_SurfaceFrame
{
  static bool logging = false;
  
  static int MD3_XYZ_SCALE       = 64;
  static double MD3_XYZ_SCALE_inv   = 1/MD3_SurfaceFrame.MD3_XYZ_SCALE;
  static double TWO_PI              = PI*2;
  static double TWO_PI_div_0xFF     = MD3_SurfaceFrame.TWO_PI/0xFF;
  static double TWO_PI_div_0xFF_inv = 1/MD3_SurfaceFrame.TWO_PI_div_0xFF_inv;
  
  MD3_File md3_reader;
  MD3_Surface parent_surface;
  int INDEX;
  int num_vertices;
  int _start_pos;
  Int16List xyz_normals;
  int _end_pos;
  List<double> bb_minXYZ;
  List<double> bb_maxXYZ;
  List<double> bb_size;
  Float32List vertexbuffer_xyzn;
  
  MD3_SurfaceFrame(MD3_File md3_reader, MD3_Surface parent_surface, int index)
  {

    this.md3_reader = md3_reader;
    this.parent_surface = parent_surface;
    this.INDEX = index;
    
    this.num_vertices =  this.parent_surface.S32_NUM_VERTS;

    this._start_pos         = md3_reader.byter.getPos();
    this.xyz_normals        = md3_reader.byter.getInt16Array(0, this.num_vertices*4);
    this._end_pos           = md3_reader.byter.getPos();

    // bounding box
    
    double max = MAX_FINITE;
    double min = MIN_POSITIVE;

    this.bb_minXYZ = [max, max, max];
    this.bb_maxXYZ = [min, min, min];
    this.bb_size   = [0.0, 0.0, 0.0];

    // generate final vertice-buffer, used for vbo
    this.vertexbuffer_xyzn = new Float32List(this.num_vertices * 6); // (v1x, x1y, v1z), (n1x, n1y, n1z), (v2x, x2y, ...

    this.generateVertexBuffer();
    this.generateBoundingBox();

    if( MD3_SurfaceFrame.logging )
      this.log();

  }
  
  log()
  {
    print("---------------------------- MD3_SurfaceFrame[${this.INDEX}] ----------------------------");
    print("    file: ${this.md3_reader.filename}"                          );
    print("    _start_pos         = ${this._start_pos}"                    );
    print("    _end_pos           = ${this._end_pos}"                      );
    print("---------------------------/ MD3_SurfaceFrame[${this.INDEX}] ----------------------------");
  }
  
  void generateVertexBuffer()
  {
    for(var i = 0; i < this.num_vertices; i++)
    {

      ////// get data from  this.xyz_normals;
      var idx_src = i*4;
      int x = this.xyz_normals[idx_src+0];
      int y = this.xyz_normals[idx_src+1];
      int z = this.xyz_normals[idx_src+2];
      int n = this.xyz_normals[idx_src+3];

      ////// apply new values to this.vertexbuffer_xyzn
      var idx_dst = i*6;
      // new vertex xyz
      double x_new = x*MD3_SurfaceFrame.MD3_XYZ_SCALE_inv;
      double y_new = y*MD3_SurfaceFrame.MD3_XYZ_SCALE_inv;
      double z_new = z*MD3_SurfaceFrame.MD3_XYZ_SCALE_inv;

      this.vertexbuffer_xyzn[idx_dst+0] = x_new;
      this.vertexbuffer_xyzn[idx_dst+1] = y_new;
      this.vertexbuffer_xyzn[idx_dst+2] = z_new;

      // new vertex normal
      double lat = ((n >> 8) & 0xFF) * MD3_SurfaceFrame.TWO_PI_div_0xFF;
      double lng = ((n >> 0 )& 0xFF) * MD3_SurfaceFrame.TWO_PI_div_0xFF;

      double nx_new = (cos ( lat ) * sin ( lng ));
      double ny_new = (sin ( lat ) * sin ( lng ));
      double nz_new = (cos ( lng ));
      this.vertexbuffer_xyzn[idx_dst+3] = nx_new;
      this.vertexbuffer_xyzn[idx_dst+4] = ny_new;
      this.vertexbuffer_xyzn[idx_dst+5] = nz_new;
    }
  }
  
  void generateBoundingBox ()
  {
    for(int i = 0; i < this.num_vertices; i++)
    {
      int idx = i*6;
      
      double x = this.vertexbuffer_xyzn[idx+0];
      double y = this.vertexbuffer_xyzn[idx+1];
      double z = this.vertexbuffer_xyzn[idx+2];

      if( this.bb_minXYZ[0] > x) this.bb_minXYZ[0] = x;
      if( this.bb_minXYZ[1] > y) this.bb_minXYZ[1] = y;
      if( this.bb_minXYZ[2] > z) this.bb_minXYZ[2] = z;

      if( this.bb_maxXYZ[0] < x) this.bb_maxXYZ[0] = x;
      if( this.bb_maxXYZ[1] < y) this.bb_maxXYZ[1] = y;
      if( this.bb_maxXYZ[2] < z) this.bb_maxXYZ[2] = z;
    }

    this.bb_size[0] = this.bb_maxXYZ[0] - this.bb_minXYZ[0];
    this.bb_size[1] = this.bb_maxXYZ[1] - this.bb_minXYZ[1];
    this.bb_size[2] = this.bb_maxXYZ[2] - this.bb_minXYZ[2];
  }
}