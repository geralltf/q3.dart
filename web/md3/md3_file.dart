part of tech3;

class MD3_File
{
  static bool logging = true;
  bool LOADED = false;
  var onload;
  String total_file_path;
  String filename;
  String path;
  var onerror;
  MD3_Header header;
  //binary_stream byter;
  Byter byter;
  List<MD3_Frame> frames;
  List<MD3_TagFrame> tag_frames;
  var loading_time;
  List<MD3_Surface> surfaces;
  
  MD3_File(String path, String filename )
  {
    this.path = path == null ? '' : path;
    this.filename = filename;
    this.total_file_path = this.path + this.filename;
    
    if( this.filename == null)
    {
      throw new Exception("(MD3_File) invalid filename, can't load MD3-File: " + this.total_file_path);
    }

    this.LOADED = false;
    this.onload = (){};
    this.onerror = ()
    {
      print("ERROR while loading MD3-file: "+this.total_file_path);
    };
  }
  
  void load(obj, bool async)
  {
//    try
//    {
      HttpRequest.request(this.total_file_path, responseType: 'arraybuffer').then((HttpRequest request){
        this.loadFileContent(request.response);
        this.LOADED = true;
        this.onload();
      });
      
//    } 
//    catch (exception)
//    {
//      this.onerror();
//    }
  }
  
  void loadFileContent(ByteBuffer arraybuffer)
  {
    int time_start = new DateTime.now().millisecondsSinceEpoch;

    // initialize byte viewer
    this.byter = new Byter(arraybuffer);
    //this.byter = new binary_stream(arraybuffer);
    
    // check for errors before loading
//    if( !this.byter.isValid() ) {
//      throw ("  bytebuffer INVALID, ... stop READING MD3-FILE ...");
//    }

    /* get Header */
    this.header = new MD3_Header(this);

    /* get Frames */
    this.byter.setPos(this.header.S32_OFS_FRAMES);
    this.frames = new List( this.header.S32_NUM_FRAMES );
    for(int i = 0; i < this.frames.length; i++)
    {
      this.frames[i] = new MD3_Frame(this, i);
    }
    /* get Tag frames */
    this.byter.setPos(this.header.S32_OFS_TAGS);
    this.tag_frames = new List(this.header.S32_NUM_FRAMES);
    for(var i = 0; i < this.tag_frames.length; i++)
    {
      this.tag_frames[i] = new MD3_TagFrame(this, i);
    }

    /* get Surfaces */
    this.byter.setPos(this.header.S32_OFS_SURFACES);
    this.surfaces = new List(this.header.S32_NUM_SURFACES);
    for(var i = 0; i < this.surfaces.length; i++)
    {
      this.surfaces[i] = new MD3_Surface(this, i);
    }


    int time_end = new DateTime.now().millisecondsSinceEpoch;

    /* check for error */
    if( this.header.S32_OFS_EOF !=  this.byter.getPos() )
    {
      print(">> WARNING: not at OFS_EOF${( this.header.S32_OFS_EOF - this.byter.getPos())}");
      print(">> WARNING: file may be corrupt");
      print ("(!CORRPUT MD3!)");
    } 
    else 
    {
      int size = (this.byter.totalSize() ~/ 1000.0);
      this.loading_time = time_end - time_start;
      
      if( MD3_File.logging )
      {
        print(">>> loaded MD3-File (${this.loading_time} ms, ${size} Kb): \"${this.filename}\"");
      }
    }
  }
}