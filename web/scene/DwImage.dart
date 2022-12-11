part of tech3;


class DwImage
{
  rendering_context gl;
  var path;
  var filename;
  var image;
  var LOADED;
  var HANDLE_TEX;
  var filesuffix;
  
  var ID;
  var col_map_type;
  var image_type;
  var col_map_start;
  var col_map_len;
  var col_map_depth;
  var x_pos;
  var y_pos;
  var width;
  var height;
  var pixel_depth;
  var pixel_attr;
  var pixel_count;
  var pixels;
  
  DwImage(rendering_context gl, String path, String filename)
  {
    this.gl = gl;
    this.path = path;
    this.filename = filename;

    this.image = null;
    this.LOADED = false;

    this.HANDLE_TEX = null;
    var _this = this;
    
    int fnidx = -1;
    
    if(filename!=null && filename != '')
    {
      fnidx= filename.lastIndexOf(".");
    }
    
    
    if(fnidx == -1)
    {
      // DIRTY
      this.filesuffix = filename + '.tga';
    }
    else
    {
      this.filesuffix = filename.substring(fnidx);
    }
        
    

    // handle TGAs separately
    if( this.filesuffix == ".tga"){
//    print("image type: TGA");
      DwImage_TGA tga = new DwImage_TGA(path, filename);
      tga.onload = (){

//    http://www.khronos.org/registry/webgl/specs/latest/#TEXIMAGE2D
        if( tga.pixel_depth == 32 ){
          _this.createTextureFromTGA (RenderingContext.RGBA, tga.width, tga.height, RenderingContext.RGBA, tga.pixels);
          _this.image = tga;

        } else if( tga.pixel_depth == 24 ){
          _this.createTextureFromTGA (RenderingContext.RGB, tga.width, tga.height, RenderingContext.RGB, tga.pixels);
          _this.image = tga;
        }
      };
      tga.load(null,true);
//  http://www.khronos.org/registry/webgl/specs/latest/#TEXIMAGE2D
//    if( tga.pixel_depth == 32 ){
//      this.createTextureFromTGA (this, this.gl.RGBA, tga.width, tga.height, this.gl.RGBA, tga.pixels);
//      this.image = tga;
  //
//    } else if( tga.pixel_depth == 24 ){
//      this.createTextureFromTGA (this, this.gl.RGB, tga.width, tga.height, this.gl.RGB, tga.pixels);
//      this.image = tga;
//    }
    }
    else
    if (
          this.filesuffix == ".jpg"
      ||  this.filesuffix == ".jpeg"
      ||  this.filesuffix == ".png"
      ||  this.filesuffix == ".bmp"
      ||  this.filesuffix == ".gif")
    {
      try{
        ImageElement tmp_image = new ImageElement();
        tmp_image.src = path+filename;
        tmp_image.onLoad.listen((e){
          createTexture(tmp_image);
          image = tmp_image;
        });
        tmp_image.onError.listen((e) {
          print("ERROR while loading Image: "+path+filename);
        });
      } catch (exception){
        print(exception);
      }
    }
    else
    {
      print("(DwImage) filename, filetype not suported: "+this.filesuffix);
    }
  }

  delete (image){
    this.gl.deleteTexture(this.HANDLE_TEX );
    this.HANDLE_TEX = null;
  }



  createTextureFromTGA (gl_internalformat, width, height,gl_format, pixels)
  {
//  print("loading tga: "+_this.path +", "+_this.filename);
    HANDLE_TEX = gl.createTexture();
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, HANDLE_TEX);
    gl.pixelStorei   ( RenderingContext.UNPACK_FLIP_Y_WEBGL, 1); // true
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.LINEAR_MIPMAP_NEAREST);
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.MIRRORED_REPEAT ) ;
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.MIRRORED_REPEAT ) ;
    gl.texImage2D    ( RenderingContext.TEXTURE_2D, 0, gl_internalformat, width, height, 0, gl_format, RenderingContext.UNSIGNED_BYTE, pixels);
    //      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);

    gl.generateMipmap( RenderingContext.TEXTURE_2D);
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, null);
    LOADED = true;
  }
  createTexture (image)
  {
    HANDLE_TEX = gl.createTexture();
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, HANDLE_TEX);
//  gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true); //TODO: check
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.LINEAR_MIPMAP_NEAREST);
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.MIRRORED_REPEAT ) ;
    gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.MIRRORED_REPEAT ) ;
    gl.texImage2D    ( RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, image);
    gl.generateMipmap( RenderingContext.TEXTURE_2D);
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, null);
    LOADED = true;
  }
}