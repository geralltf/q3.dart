part of tech3;


Symbol symGetError = new Symbol('getError');
Symbol symGetActiveAttrib = new Symbol('getActiveAttrib');
Symbol symTexImage2D = new Symbol('texImage2D');
Symbol symCreateTexture  = new Symbol('createTexture');
Symbol symBindTexture  = new Symbol('bindTexture');
Symbol symCreateShader  = new Symbol('createShader');
Symbol symShaderSource  = new Symbol('shaderSource');
Symbol symCompileShader = new Symbol('compileShader');
Symbol symGetShaderParameter = new Symbol('getShaderParameter');
Symbol symGetShaderInfoLog = new Symbol('getShaderInfoLog');
Symbol symDeleteShader = new Symbol('deleteShader');
Symbol symCreateProgram = new Symbol('createProgram');
Symbol symAttachShader = new Symbol('attachShader');
Symbol symLinkProgram = new Symbol('linkProgram');
Symbol symGetProgramParameter = new Symbol('getProgramParameter');
Symbol symDeleteProgram = new Symbol('deleteProgram');
Symbol symGetAttribLocation = new Symbol('getAttribLocation');
Symbol symGetActiveUniform = new Symbol('getActiveUniform');
Symbol symGetUniformLocation = new Symbol('getUniformLocation');

Symbol sym__interop_texImage2D_09 = new Symbol('texImage2D_09');
Symbol sym__interop_texImage2D_06 = new Symbol('texImage2D_06');

dynamic processWebGLPipe(Symbol method_symbol, List parameterlist, String method_name, rendering_context renderer)
{
  var gl = renderer.gl;
  var result = null;
  var p = parameterlist;
  

  ///////////////////////// TEXTURING /////////////////////////
  if(method_symbol == symTexImage2D)
  {
    if(parameterlist.length == 6)
    {
      result = pipe_texImage2D_06(gl, p[0], p[1], p[2], p[3], p[4], p[5]);
    }
    else if (parameterlist.length == 9)
    {
      result = pipe_texImage2D_09(gl, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]);
    }
  }
  
//  else if (method_symbol == symCreateTexture)
//  {
//    result = wrapFromJSObject(WebGLInterop.api_call(symCreateTexture, [ gl ]));
//  }
//  else if (method_symbol == symBindTexture)
//  {
//    result = WebGLInterop.api_call(symBindTexture, [ gl, p[0], p[1] ]);
//  }
//  ///////////////////////// SHADERS /////////////////////////
//  else if (method_symbol == symCreateProgram)
//  {
//    result = wrapFromJSObject(WebGLInterop.api_call(symCreateProgram, [ gl ]));
//  }
//  else if (method_symbol == symGetProgramParameter)
//  {
//    result = WebGLInterop.api_call(symGetProgramParameter, [ gl, p[0], p[1] ]);
//  }
//  else if (method_symbol == symAttachShader)
//  {
//    WebGLInterop.api_call(symAttachShader, [ gl, p[0], p[1] ]);
//  }
//  else if(method_symbol == symLinkProgram)
//  {
//    WebGLInterop.api_call(symLinkProgram, [ gl, p[0] ]);
//  }
//  else if (method_symbol == symCreateShader)
//  {
//    result = wrapFromJSObject(WebGLInterop.api_call(symCreateShader, [ gl, p[0] ]));
//  }
//  else if (method_symbol == symShaderSource)
//  {
//    WebGLInterop.api_call(symShaderSource, [ gl, p[0], p[1] ]);
//  }
//  else if (method_symbol == symCompileShader)
//  {
//    WebGLInterop.api_call(symCompileShader, [ gl, p[0] ]);
//  }
//  else if(method_symbol == symGetShaderParameter)
//  {
//    result = WebGLInterop.api_call(symGetShaderParameter, [ gl, p[0], p[1] ]);
//  }
//  else if(method_symbol == symGetShaderInfoLog)
//  {
//    result = WebGLInterop.api_call(symGetShaderInfoLog, [ gl, p[0] ]);
//  }
//  else if(method_symbol == symDeleteShader)
//  {
//    WebGLInterop.api_call(symDeleteShader, [ gl, p[0] ]);
//  }
//  else if(method_symbol == symDeleteProgram)
//  {
//    WebGLInterop.api_call(symDeleteProgram, [ gl, p[0] ]);
//  }
//  else if(method_symbol == symGetActiveAttrib)
//  {
//    result = wrapFromJSObject(WebGLInterop.api_call(symGetActiveAttrib, [ gl, p[0], p[1] ]));
//  }
//  else if(method_symbol == symGetAttribLocation)
//  {
//    result = WebGLInterop.api_call(symGetAttribLocation, [ gl, p[0], p[1] ]);
//  }
//  else if(method_symbol == symGetActiveUniform)
//  {
//    result = wrapFromJSObject(WebGLInterop.api_call(symGetActiveUniform, [ gl, p[0], p[1] ]));
//  }
//  else if(method_symbol == symGetUniformLocation)
//  {
//    result = WebGLInterop.api_call(symGetUniformLocation, [ gl, p[0], p[1] ]);
//  }
  /////////////////////// MISC //////////////////////////////
  else
  {
    try
    {
      result = wrapFromJSObject(WebGLInterop.api_call2(method_name, parameterlist));
      //result = WebGLInterop.gl_call(gl, method_name, parameterlist);
    }
    catch(ex) 
    {
      /* just ignore. Any issues javascript side are not our problem
       * We can however inspect the error state later on */
    }
  }
  
  return result;
}

// https://www.khronos.org/registry/webgl/specs/1.0/
dynamic pipe_texImage2D_09(gl, int target, int level, int internalformat, 
                   int width, int height, int border, 
                   int format, int type, [dynamic pixels])
{
  // pixels must be ArrayBufferView but is nullable
  dynamic result;
  List params = null;;
  
  if(pixels==null)
  {
    params = [  gl, target,  level, internalformat, width, 
                height, border, format, type, ' ', null  ];
  }
  else
  {
    if(pixels is ImageElement)
    {
      image_number++;
      String id = "tex_" + image_number.toString();
      pixels.id = id;
            
      params = [  gl, target,  level, internalformat,
                         width, height, border, 
                        format,   type, 'ImageElement', id  ];
      
      
    }
    else
    {
      JsArray arr = new JsArray.from(pixels);
      String dt = getTypedDataArrayType(pixels);
      
      params = [  gl, target,  level, internalformat,
                   width, height, border, 
                  format,   type, dt, arr  ];
    }
  }
  
  result = WebGLInterop.api_call(sym__interop_texImage2D_09, params);
  
  return result;
}

int image_number = 0;
dynamic pipe_texImage2D_06(gl, int target, int level, int internalformat, 
                           int format,  int type, [dynamic pixels]) 
{
  // pixels must be TexImageSource but is nullable
  dynamic result;
  List params = null;;
  
  if(pixels==null)
  {
    params = [  target,  level, internalformat,  format, type, ' '  ];
  }
  else
  {
    if(pixels is ImageElement)
    {
      image_number++;
      String id = "tex_" + image_number.toString();
      pixels.id = id;
      
      params = [  target,  level, internalformat,  format, type,  'ImageElement', id  ];
    }
    else 
    {
      JsArray arr = new JsArray.from(pixels);
      String dt = getTypedDataArrayType(pixels);
      
      params = [  target,  level, internalformat,  format, type,  dt, arr  ];
    }
  }
  
  result = WebGLInterop.api_call(sym__interop_texImage2D_06, params);
  
  return result;
  
}