part of tech3;

class DwShaderElement
{
  rendering_context gl;
  GLShader HANDLE;
  var total_file_path;
  var shader_type;
  var onload;
  var onerror;
  
  DwShaderElement(rendering_context gl, path, filename, shader_type)
  {
    this.gl = gl;
    this.HANDLE = null;
    this.total_file_path = path + filename;
    this.shader_type = shader_type;

    this.onload = (){};
    this.onerror = ()
    {
      print("ERROR while loading SHADER-file: "+total_file_path);
    };
  }

  static DwShaderElement FromSource(rendering_context gl, String source, shader_type)
  {
    DwShaderElement s = new DwShaderElement(gl, null, null, shader_type);
    
    s.HANDLE = gl.createShader(shader_type);
    gl.shaderSource(s.HANDLE, source);
    
    if (!gl.getShaderParameter(s.HANDLE, RenderingContext.COMPILE_STATUS)) 
    {
      print("ERROR on compiling shader: "+ source +"\n"+gl.getShaderInfoLog(s.HANDLE));
    }
    else 
    {
      s.onload();
    }
    
    return s;
  }
  
  //  //https://developer.mozilla.org/en/XMLHttpRequest
  load (obj, async){
    
    HttpRequest.request(this.total_file_path, responseType: 'text').then((HttpRequest request)
    {
      HANDLE = gl.createShader(shader_type);
      gl.shaderSource(HANDLE, request.responseText);
      gl.compileShader(HANDLE);
      if (!gl.getShaderParameter(HANDLE, RenderingContext.COMPILE_STATUS)) {
    //      alert("ERROR ON COMPILING SHADER");
    //      _this.onerror();
        print("ERROR on compiling shader: "+total_file_path+"\n"+gl.getShaderInfoLog(HANDLE));
      }else {
        onload();
      }
    });
    
//    var XHR = new HttpRequest();
//    XHR.open("GET", this.total_file_path, async: true ); //true=asynchronous
//    XHR.responseType = "text";
//    
//    XHR.onLoad.listen((e){
//      
//
//    });
//    
//    
//    try{
//      XHR.send(obj); // usually null
//    } catch (exception){
//    //    console.log(exception);
//      print("ERROR while loading SHADER-file: "+this.total_file_path);
//      onerror();
//    }
  }
  
  delete()
  {
    this.gl.deleteShader(this.HANDLE);
    this.HANDLE = null;
  }
}

class DwShader
{
  rendering_context gl;
  var path;
  var shader_name_vert;
  var shader_name_frag;
  var HANDLE_program;
  var HANDLE_vert;
  var HANDLE_frag;
  
  var HANDLE;
  var onload;
  
  //http://www.opengl.org/wiki/OpenGL_Shading_Language#Building_shaders
  DwShader(rendering_context gl, path, shader_name_vert, shader_name_frag)
  {
    this.gl = gl;
    this.path = path;
    this.shader_name_vert = shader_name_vert;
    this.shader_name_frag = shader_name_frag;
    
    this.HANDLE_program = null;
    this.HANDLE_vert = null;
    this.HANDLE_frag = null;
    
    this.onload = (){};
  }
  
  static DwShader FromSource(rendering_context gl, String vertex_src, String fragment_src)
  {
    DwShader s = new DwShader(gl, null, null, null);
    
    var shader_vert = DwShaderElement.FromSource(gl, vertex_src, RenderingContext.VERTEX_SHADER);
    var shader_frag = DwShaderElement.FromSource(gl, fragment_src, RenderingContext.FRAGMENT_SHADER);
    
    s.createShaderProgram(shader_vert, shader_frag);
    
    return s;
  }
  
  load (obj)
  {
    var shader_vert = new DwShaderElement(gl,path, shader_name_vert, RenderingContext.VERTEX_SHADER);
    var shader_frag = new DwShaderElement(gl,path, shader_name_frag, RenderingContext.FRAGMENT_SHADER);
    
    // fragment shader is loaded after vertex shader
    shader_frag.onload = (){
      createShaderProgram(shader_vert, shader_frag);
      onload(); // defined by caller!!!
    };
      
    // vertex shader is loaded at first, ... on load the fragmentshader is getting loaded
    shader_vert.onload = (){
      shader_frag.load(obj, true);
    };
    
    // now, init the loading process (asynchronous)
    shader_vert.load(obj, true);
  }
  
  delete ()
  {
    this.gl.deleteShader (this.HANDLE_vert);
    this.gl.deleteShader (this.HANDLE_frag);
    this.gl.deleteProgram(this.HANDLE_program);
    this.HANDLE_vert = null;
    this.HANDLE_frag = null;
    this.HANDLE_program = null;
  }
  
  createShaderProgram (vert, frag)
  {
    this.HANDLE_vert = vert.HANDLE;
    this.HANDLE_frag = frag.HANDLE;
    this.HANDLE_program = this.gl.createProgram();
    this.gl.attachShader(this.HANDLE_program, vert.HANDLE);
    this.gl.attachShader(this.HANDLE_program, frag.HANDLE);
    this.gl.validateProgram(this.HANDLE_program);
    this.gl.linkProgram (this.HANDLE_program);
    
    if (!this.gl.getProgramParameter(this.HANDLE_program, RenderingContext.LINK_STATUS)) 
    {
      print("Could not initialise shaders");
      print(this.gl.getProgramInfoLog(this.HANDLE_program));
    }
  } 
}