part of tech3;

abstract class rendering_context implements webgl_interface_2_0
{
  static bool dart;
  
  dynamic gl;
  
  factory rendering_context()
  {
    dart = window.navigator.userAgent.indexOf('(Dart)') != -1;
    
    if(dart)
    {
      print('[dart] supported');
    }
    else
    { 
      print('[dart] not supported.. Time for plan B.');
      
    }
    
    //return new rendering_context___js_proxy();      // NATIVE JAVASCRIPT proxy
    return new rendering_context_dartwebgl();       // dart_webgl library
  }
}

// WRAPPER types for WebGL API. these types work with the context factory model stated above
class NativeWrappingProxyType 
{ 
  dynamic underlying;
}

class GLActiveInfo extends NativeWrappingProxyType
{
  GLActiveInfo(){}
  /* just a wrapper for WebGLActiveInfo */
  String name;
  int size;
  int type;
  /* from spec:
    readonly attribute GLint size;
    readonly attribute GLenum type;
    readonly attribute DOMString name; */
}

class GLTexture extends NativeWrappingProxyType
{
  GLTexture(){}
  /* just a wrapper for WebGLTexture */
}

class GLProgram extends NativeWrappingProxyType
{
  GLProgram(){}
  /* just a wrapper for WebGLProgram */
}

class GLShader extends NativeWrappingProxyType
{
  GLShader(){}
  /* just a wrapper for WebGLShader */
}

class GLBuffer extends NativeWrappingProxyType
{
  GLBuffer(){}
  /* just a wrapper for WebGLBuffer */
}

class GLUniformLocation extends NativeWrappingProxyType
{
  GLUniformLocation(){}
  /* just a wrapper for WebGLUniformLocation */
}

class GLFramebuffer extends NativeWrappingProxyType
{
  GLFramebuffer(){}
  /* just a wrapper for WebGLFramebuffer */
}

class GLRenderbuffer extends NativeWrappingProxyType
{
  GLRenderbuffer(){}
  /* just a wrapper for WebGLRenderbuffer */
}

class GLShaderPrecisionFormat extends NativeWrappingProxyType
{
  GLShaderPrecisionFormat(){}
  /* just a wrapper for WebGLShaderPrecisionFormat */
  int rangeMin;
  int rangeMax;
  int precision;
  /* from spec:
    readonly attribute GLint rangeMin;
    readonly attribute GLint rangeMax;
    readonly attribute GLint precision; */
}

class GLVertexArrayObjectOES extends NativeWrappingProxyType
{
  GLVertexArrayObjectOES(){}
  /* just a wrapper for WebGLVertexArrayObjectOES */
  
  // http://www.khronos.org/registry/webgl/extensions/OES_vertex_array_object/
}

String symbol_name(Symbol symbol)
{
  String name;
  
  // DIRTY but it works
  
  name = symbol.toString();
  name = name.replaceAll(new RegExp(r'Symbol\("'), "")
             .replaceAll(new RegExp(r'"\)'), "");
  
  return name;
}

String getTypedDataArrayType(Object a)
{
  String t = null;
  
  if(a is Float32List)       t = 'Float32Array';
  if(a is Float64List)       t = 'Float64Array';
  if(a is Uint8ClampedList)  t = 'Uint8ClampedArray';
  if(a is Uint8List)         t = 'Uint8Array';
  if(a is Uint16List)        t = 'Uint16Array';
  if(a is Uint32List)        t = 'Uint32Array';
  if(a is Int8List)          t = 'Int8Array';
  if(a is Int16List)         t = 'Int16Array';
  if(a is Int32List)         t = 'Int32Array';
    
  //TODO: add more types
  
  return t;
}
dynamic wrapDartWebGLType(dynamic result)
{
  if(result != null)
  {
    // WRAP result to comply with API
    if(result is ActiveInfo)
    {
     GLActiveInfo a = new GLActiveInfo();
     a.name = result.name;
     a.size = result.size;
     a.type = result.type;
     a.underlying = result;
     return a;
    }
    if(result is Texture)
    {
      GLTexture t = new GLTexture();
      t.underlying = result;
      return t;
    }
    if(result is Shader)
    {
      GLShader t = new GLShader();
      t.underlying = result;
      return t;
    }
    if(result is Program)
    {
      GLProgram t = new GLProgram();
      t.underlying = result;
      return t;
    }
    if(result is Buffer)
    {
      GLBuffer t = new GLBuffer();
      t.underlying = result;
      return t;
    }
    if(result is UniformLocation)
    {
      GLUniformLocation t = new GLUniformLocation();
      t.underlying = result;
      return t;
    }
    if(result is Renderbuffer)
    {
      GLRenderbuffer t = new GLRenderbuffer();
      t.underlying = result;
      return t;
    }
    if(result is Framebuffer)
    {
      GLFramebuffer t = new GLFramebuffer();
      t.underlying = result;
      return t;
    }
  }
  return result;
}

dynamic wrapFromJSObject(JsObject j)
{
  
  if(j != null)
  {
    String type = j.toString();

    if(type=="[object WebGLTexture]")
    {
      GLTexture tex = new GLTexture();
      tex.underlying = j;
      return tex;
    }
    if(type=="[object WebGLShader]")
    {
      GLShader s = new GLShader();
      s.underlying = j;
      return s;
    }
    if(type=="[object WebGLBuffer]")
    {
      GLBuffer s = new GLBuffer();
      s.underlying = j;
      return s;
    }
    if(type=="[object WebGLActiveInfo]")
    {
      GLActiveInfo s = new GLActiveInfo();
      s.underlying = j;
      s.name = j['name'];
      s.size = j['size'];
      s.type = j['type'];
      return s;
    }
    if(type=="[object WebGLProgram]")
    {
      GLProgram s = new GLProgram();
      s.underlying = j;
      return s;
    }
    if(type=="[object WebGLUniformLocation]")
    {
      GLUniformLocation s = new GLUniformLocation();
      s.underlying = j;
      return s;
    }
    if(type=="[object WebGLFramebuffer]")
    {
      GLFramebuffer s = new GLFramebuffer();
      s.underlying = j;
      return s;
    }
    if(type=="[object WebGLRenderbuffer]")
    {
      GLRenderbuffer s = new GLRenderbuffer();
      s.underlying = j;
      return s;
    }
    if(type=="[object WebGLShaderPrecisionFormat]")
    {
      GLShaderPrecisionFormat s = new GLShaderPrecisionFormat();
      s.underlying = j;
      s.precision = j['precision'];
      s.rangeMax = j['rangeMax'];
      s.rangeMin = j['rangeMin'];      
      return s;
    }
  }
  return j;
}

dynamic unwrapDartParam(dynamic p, Symbol method_symbol, String method_name)
{
  return toUnderlyingType(p);
}

List unwrapDartParams(List args, Symbol method_symbol, String method_name)
{
  List lst = new List();
  
  args.forEach((dynamic arg)
  {
    lst.add(unwrapDartParam(arg, method_symbol, method_name));
  });
  
  return lst;
}

List getArgsList(Invocation invocation)
{
  List args = new List();
  
  invocation.positionalArguments.forEach((arg)
  {
    args.add(WebGLInterop.marshalToNative(arg));
  });
  invocation.namedArguments.forEach((name, value)
  {
    args.add(WebGLInterop.marshalToNative(value));
  });
  
  return args;
}

dynamic toUnderlyingType(dynamic r)
{
  if(r != null)
  {
    // UNWRAP result to comply with API
    
    if(r is NativeWrappingProxyType)
    {
      return r.underlying;
    }
  }
  return r;
}

List<dynamic> unwrapDartPositionalArguments(List<dynamic> args)
{
  List<dynamic> lst = new List<dynamic>();
  
  args.forEach((dynamic arg)
  {
    lst.add(toUnderlyingType(arg));
  });
  
  return lst;
}

Map<Symbol,dynamic> unwrapDartNamedArguments(Map<Symbol,dynamic> args)
{
  Map<Symbol,dynamic> m = new Map<Symbol,dynamic>();
  
  args.forEach((Symbol s, dynamic arg)
  {
    m[s] = toUnderlyingType(arg);
  });
  
  return m;
}

void handleContextErrors(rendering_context gl, bool stackTracing, String method_name, int glGetErrorCodeFunct())
{
  int error = glGetErrorCodeFunct();
  Map<int,String> errors = new Map();
  
  
  // webgl can report multiple errors for a single call. so loop until the gl doesnt return anymore error codes 
  while(error != RenderingContext.NO_ERROR)
  {        
    String errorMessage = '';
    switch (error) 
    {
      case RenderingContext.INVALID_ENUM:
        errorMessage = 'An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.';
        break;
      case RenderingContext.INVALID_VALUE:
        errorMessage = 'A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.';
        break;
      case RenderingContext.INVALID_OPERATION:
        errorMessage = 'The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.';
        break;
      case RenderingContext.INVALID_FRAMEBUFFER_OPERATION:
        errorMessage = 'The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.';
        break;
      case RenderingContext.OUT_OF_MEMORY:
        errorMessage = 'There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.';
        break;
      default:
        errorMessage = 'An unknown error occurred';
        break;
    }
    
    errors[error] = errorMessage;  
    
    error = glGetErrorCodeFunct();
  }
  
  if(errors.length > 0 )
  {
    dynamic call_stack;
    if(stackTracing)
    {
      call_stack = new Error().stackTrace;
      
      if(call_stack==null)
      {
        try 
        {
          throw new Error();
        } 
        catch(exception, stackTrace) 
        {
          call_stack = stackTrace;
        }
      }
    }
    
    print('[webgl] there was an error with the previous call {$method_name} please see the following list:');
    errors.forEach((code, message)
    {
      print('[webgl] -----> Err code: {$code} Additional message: {$message}');
    });    
    if(stackTracing)
    {
      print("here's a dandy stack trace");
      print('{$call_stack}');
    }
  }
}

class WebGLInterop
{
  static dynamic api_call2(String funct, List args)
  {
    JsObject interop = context['jsinterop'];
    dynamic result = interop.callMethod(funct, args);
    return result;
  }
  static dynamic api_call(Symbol api_symb, List args)
  {
    String funct = symbol_name(api_symb);
    JsObject interop = context['jsinterop'];
    dynamic result = interop.callMethod(funct, args);
    return result;
  }
  static dynamic gl_call(dynamic gl, String funct, List args)
  {
    JsObject interop = context['jsinterop'];
    if(args == null) args = new List();
    JsArray arr = new JsArray.from(args);
    dynamic result = interop.callMethod('gl_call',[gl,funct, arr]);
    if(result==null) return null;
    result = wrapFromJSObject(result);
    return result;
  }
  static dynamic marshalToNative(dynamic instance)
  {
    return instance;
//    if(instance is List<int>)
//    {
//      // must be a native type of ArrayBufferView
//      
//      // this shit is driving me crazy. dart typed data should compile into javascript webgl compatible types!
//      // but no.
//      
//      Int32List lst = new Int32List(instance.length);
//      lst.setAll(0, instance);
//      //return lst;
//      
//      JsArray<int> arr = new JsArray<int>.from(instance);
//      
//      
//      
//      return instantiateArray('Int32Array', instance.length, arr );
//      
//    }
//    else if(instance is List<double>)
//    {
//      var a = 1;
//    }
//    else if (instance is Float32List)
//    {
//      var a = 1;
//    }
//    return instance;
  }
  // Instantiates the specified native type using js interop
  static dynamic instantiateArray(String nativeType, num length, dynamic values)
  {
    dynamic instance;
    
    JsObject interop = context['jsinterop'];
    
    instance = interop.callMethod('instantiateArray',[nativeType,length, length * Int32List.BYTES_PER_ELEMENT , values]);
    
    
    
    return instance;
  }
  
}