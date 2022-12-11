part of tech3;

class Q3_SkinFile
{
  static bool logging = false;
  String path;
  String filename;
  String total_file_path;
  bool LOADED;
  List<String> tag_names;
  List<String> surface_names;
  List<String> image_names;
  List<String> image_paths;
  var content;
  var onload;
  var onerror;
  var loadingtime;
  
  Q3_SkinFile( path, filename)
  {

    if( path == null || filename == null)
    {
      print("(SkinFile) invalid path or filename");
    }

    this.path = path;
    this.filename = filename;
    this.total_file_path = this.path+this.filename;

    this.LOADED = false;

    // final arrays
    this.tag_names      = [];
    this.surface_names  = [];
    this.image_names    = [];
    this.image_paths    = [];

    this.content = null;

    this.onload = (){};
    this.onerror = ()
    {
      print("ERROR while loading SKIN-file: "+this.total_file_path);
    };



//  var timer = new Date().getTime();
//  try{
//    this.content = Q3_SkinFile.loadFileContent(this.total_file_path);
//  } catch (exception){
//    console.log(exception);
//    throw exception;
//  }
  //
//  try{
//    this.extractFileContent(this.content);
//  } catch (exception){
//    console.log(exception);
//    this.log();
//    throw exception;
//  }
//  this.loadingtime = new Date().getTime()-timer;


    this.LOADED = true;
    this.loadingtime = 0;
//  this.log();
  }
  
  load(obj, bool async)
  {
    var _this = this;

    HttpRequest.request(this.total_file_path, responseType: 'text').then((HttpRequest request){
      int timer = new DateTime.now().millisecondsSinceEpoch;
      //try{
        _this.extractFileContent(request.responseText);
        _this.LOADED = true;
        _this.loadingtime = new DateTime.now().millisecondsSinceEpoch-timer;
        _this.onload();
//      } catch (exception){
//        print(exception);
//        _this.log();
//        throw exception;
//      }
    });
    
    
//
//    try{
//      XHR.send(obj); //usually null
//    } catch (exception){
////    console.log(exception);
//      _this.onerror();
//    }
  }
  
  
  extractFileContent (String content) 
  {
    var lines = content.split("\n");
    var expecting_image = false;
    for( var i = 0; i < lines.length; i++ )
    {
      var ln = lines[i];
      ln = ln.trim();
//    console.log(ln);
      var ln_tokens = ln.split(",");

      for( var j = 0; j < ln_tokens.length; j++)
      {
        String token = ln_tokens[j].trim();

        if( token.length == 0 || token.substring(0,2) == "//")
        {
          continue;
        }
        // add tag to list
        if( !expecting_image && token.substring(0,4) ==  "tag_")
        {
          if( this.tag_names.indexOf(token) < 0){
            this.tag_names.add(token);
          }
        // add surface-name to list
        } 
        else if( !expecting_image )
        {
          this.surface_names.add(token);
          expecting_image = true;
        // add surface-image to list
        } 
        else if( expecting_image )
        {
          this.image_paths.add(token);
          var idx = token.lastIndexOf("/");
          var image_name = token.substring(token.lastIndexOf("/")+1);
          this.image_names.add(image_name);
          expecting_image = false;
        } 
        else {
          print("--------------------------------problem------------------------------");
        }
      }
    }
    if (this.surface_names.length != this.image_paths.length )
    {
      print ("(!CORRPUT SKIN-File!) number of surfaces != number of images");
    }
  }
  
  loadFileContent (String path)
  {    
    var xhr = new HttpRequest();
    xhr.open("GET", path, async: false);

    try{
      xhr.send(null);
    } catch(e){
      throw ("(SkinFile.loadFileContent) invalid file: "+path);
    }

    if (xhr.readyState == 4) {
      if (xhr.status == 0) { // TODO: 200
        return xhr.responseText;
      }
      throw( "(SkinFile.loadFileContent) xhr.status !== 200 ");
    }
    throw( "(SkinFile.loadFileContent) xhr.readyState !== 4 ");
  }
  
  String getImageNameBySurfaceName(String surface_name)
  {
    var img_idx = this.getSurfaceNameIDX(surface_name);
    if( img_idx == -1)
      return null;
    return this.image_names[img_idx];
  }
  
  String getImagePathBySurfaceName (String surface_name)
  {
    var img_idx = this.getSurfaceNameIDX(surface_name);
    if( img_idx == -1)
      return null;
    return this.image_paths[img_idx];
  }

  int getSurfaceNameIDX (String surface_name)
  {
    return this.surface_names.indexOf(surface_name);
  }

  log()
  {
    print("--------------------- Skin_File -------------------------");
    print("(path) "+this.total_file_path);
    for(var i = 0; i < this.tag_names.length; i++ )
    {
      print("(tag) "+this.tag_names[i]);
    }
    for(var i = 0; i < this.surface_names.length; i++)
    {
      String surf  = this.surface_names[i];
      String image = this.image_paths[i];
      String image_name = this.image_names[i];
      print("(surf) "+surf+", (image)"+image +", ("+image_name+")");
    }
    print("(...loading time ... "+this.loadingtime+" ms ");
    print("---------------------/ Skin_File -------------------------");
  }
}