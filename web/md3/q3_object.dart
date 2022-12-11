part of tech3;

class Q3_Object
{
  rendering_context gl;
  String path;
  String md3_filename;
  String skin_filename;
  Q3_TexturePool texturepool;
  int frame_IDX_max;
  int frame_IDX_cur;
  List<MD3_Surface> surfaces;
  int surfaces_count;
  List surface_vbo_list;
  List<DwImage> texture_list;
  MD3_File MD3_FILE;
  Q3_SkinFile SKIN_FILE;
  var onload;
  
  Q3_Object(rendering_context gl, String path, String md3_filename, String skin_filename, Q3_TexturePool texturepool)
  {
    this.gl            = gl;
    this.path          = path;
    this.md3_filename  = md3_filename;
    this.skin_filename = skin_filename;
    this.texturepool   = texturepool;

    this.frame_IDX_max = 0;
    this.frame_IDX_cur = 0;

    this.surfaces       = null;
    this.surfaces_count = 0;

    this.surface_vbo_list = [];
    this.texture_list     = [];

    this.MD3_FILE  = null;
    this.SKIN_FILE = null;

    this.onload = (){};


    this.MD3_FILE = new MD3_File( path, md3_filename);
    
    this.MD3_FILE.onload = ()
    {

      frame_IDX_max = MD3_FILE.header.S32_NUM_FRAMES - 1;
      frame_IDX_cur = 0;

      // build vbo's for surfaces
      surfaces       = MD3_FILE.surfaces;
      surfaces_count = MD3_FILE.surfaces.length;

      surface_vbo_list = new List(surfaces_count);
      for(var i = 0; i < surfaces_count; i++)
      {
        surface_vbo_list[i] = new Q3_surface_VBO(gl, MD3_FILE, i);
      }

      // build texture array, ... init with null's
      texture_list = new List(surfaces_count);
      for(var i = 0; i < surfaces_count; i++)
      {
        texture_list[i] = null;
      }

      SKIN_FILE = new Q3_SkinFile(path, skin_filename); // returns null, on fail
      SKIN_FILE.onload = (){
        //try{
          applyTexturesFromSkinfile(SKIN_FILE);
//      this.SKIN_FILE.log();
        //} catch ( exception ){
          //print( exception );
        //}
      };

      //try
      //{
        SKIN_FILE.load(null, true);
      //}
      //catch(exception)
      //{
        //print(exception);
      //}
      onload(); //TODO: check if textures are needed for further processing
    };
//  this.MD3_FILE.load(null, true);
  }


  load ()
  {
    this.MD3_FILE.load(null, true);
  }

  void applyTexturesFromSkinfile (Q3_SkinFile skinfile)
  {
    for(int i = 0; i < this.surfaces_count; i++){
      String surface_name = this.surfaces[i].STR_NAME;
      int idx = skinfile.getSurfaceNameIDX(surface_name);
      if( idx >= 0 )
      {
        String img_name = skinfile.image_names[idx];
        //String img_path = skinfile.image_paths[idx];
        DwImage tex = null;
        if( this.texturepool != null)
        {
//        //TODO edit path, or assume path is in same dir as md3 and skinfile
          tex = this.texturepool.getTexture( this.path, img_name);
        } 
        else 
        {
          tex = new DwImage(this.gl, this.path, img_name);
        }
        this.texture_list[i] = tex;
      } 
      else 
      {
        print("(Q3_Object) no texture for current surface in skinfile listed!!");
      }
    }
  }


  int setCurrentFrameIDX (int frame_IDX)
  {
    this.frame_IDX_cur = frame_IDX;
    if( frame_IDX > this.frame_IDX_max ) this.frame_IDX_cur = this.frame_IDX_max;
    if( frame_IDX < 0                  ) this.frame_IDX_cur = 0;
    return this.frame_IDX_cur;
  }


  MD3_Tag getTagByName (String tag_name, int frame_idx)
  {
    if( !this.MD3_FILE.LOADED ){
      return null;
    }
    frame_idx = frame_idx != null ? frame_idx : this.frame_IDX_cur;
    List<MD3_Tag> tags = this.MD3_FILE.tag_frames[frame_idx].tags;
    for(  var i = 0; i < tags.length; i++){
      if(  tags[i].STR_NAME == tag_name)
        return tags[i];
    }
    return null;
  }



  List<String> getNamesOfSurfaces ()
  {
    var count = this.getNumberOfSurfaces();
    List<String> names = new List(count);
    for(var i = 0; i < count; i++){
      names[i] = this.surfaces[i].STR_NAME;
    }
    return names;
  }
  
  List<String> getNamesOfTags ()
  {
    if( !this.MD3_FILE.LOADED ){
      return null;
    }
    var count = this.getNumberOfTags();
    List<String> names = new List(count);
    for(var i = 0; i < count; i++){
      names[i] = this.MD3_FILE.tag_frames[0].tags[i].STR_NAME;
    }
    return names;
  }


  int getNumberOfFrames ()
  {
    if( !(this.MD3_FILE.frames != null && this.MD3_FILE.frames.length > 0) )
      return 0;
    
    return this.MD3_FILE.frames.length;
  }
  
  int getNumberOfTags ()
  {
    if( !(this.MD3_FILE.tag_frames != null && this.MD3_FILE.tag_frames.length > 0))
      return 0;
    
    return this.MD3_FILE.tag_frames[0].tags.length;
  }
  
  int getNumberOfSurfaces ()
  {
    if(!(this.surfaces != null || this.surfaces.length > 0))
      return 0;
    
    return this.surfaces.length;
  }


  void delete ()
  {
    for(var i = 0; i < this.surfaces_count; i++)
    {
      var surface_vbo = this.surface_vbo_list[i];
      //var tex         = this.texture_list[i];
      surface_vbo.delete();
    }
    
    this.path          = null;
    this.md3_filename  = null;
    this.skin_filename = null;
//  this.texturepool   = null;

    this.frame_IDX_max = 0;
    this.frame_IDX_cur = 0;

    this.surfaces       = null;
    this.surfaces_count = 0;

    this.surface_vbo_list = [];
    this.texture_list     = [];

    this.MD3_FILE  = null;
    this.SKIN_FILE = null;
  }



  void draw (Q3_surface_shader_generic shader, int frame_IDX)
  {
    if( frame_IDX != null )
      this.setCurrentFrameIDX(frame_IDX);

    for(var i = 0; i < this.surfaces_count; i++)
    {
      var surface_vbo = this.surface_vbo_list[i];
      DwImage tex         = this.texture_list[i];
      this.gl.bindTexture(RenderingContext.TEXTURE_2D, null);
      
      if( tex != null)
      {
        this.gl.bindTexture(RenderingContext.TEXTURE_2D, tex.HANDLE_TEX);
        this.gl.activeTexture(RenderingContext.TEXTURE0);
        shader.activeTexture(0);
//      shader.setDefaultColor([0, 0, 0, 0]);
      } 
      else 
      {
        shader.setDefaultColor(new Vector4(0.45, 0.45, 0.45, 1.00));
      }
      if( surface_vbo != null)
      {
        surface_vbo.beginDraw(shader, this.frame_IDX_cur);
        surface_vbo.draw();
      }

    }
    this.gl.bindTexture(RenderingContext.TEXTURE_2D, null);
  }
}



