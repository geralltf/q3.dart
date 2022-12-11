part of tech3;

/**
 * Pipes rendering API calls to the dart_webgl library
 */
class rendering_context_dartwebgl implements rendering_context
{  
  bool tracing = false;
  bool errorLogging = false;
  bool paramListLogging = false;
  bool stackTracing = false;
  InstanceMirror mirror;
  RenderingContext gl;
  
  int get drawingBufferWidth => this.gl.drawingBufferWidth;
  int get drawingBufferHeight => this.gl.drawingBufferHeight;
  
  rendering_context_dartwebgl()
  {
    CanvasElement canvas = query('#viewport');
    gl = canvas.getContext3d();
    mirror = reflect(gl);
  }
  
  dynamic noSuchMethod(Invocation invocation) 
  {
    Symbol method_symbol = invocation.memberName;
    
    if(method_symbol == symGetError)
    {
      return reflect(this).invoke(symGetError, []);
    }
    
    String method_name = '';
    
    if(tracing == true)
    {
      method_name = MirrorSystem.getName(method_symbol);
      
      String args = getArgs(invocation);
    
      if(paramListLogging)
      {
        print('[webgl] piped to dart_webgl -> ${method_name}(${args})');
      }
      else
      {
        print('[webgl] piped to dart_webgl -> ${method_name}(...)');
      }
    }
      
    // UNWRAP any webgl objects used into dart_webgl library objects
    dynamic result = mirror.invoke(method_symbol, 
          unwrapDartPositionalArguments(invocation.positionalArguments), 
          unwrapDartNamedArguments(invocation.namedArguments))
          .reflectee;
    
    dynamic wrapped = wrapDartWebGLType(result);
    
    if(wrapped != null)
    {
      return wrapped;
    }
    
    if(errorLogging == true)
    {
      handleContextErrors(this, stackTracing, method_name, gl.getError);
    }
    
    return result;
  }
}