part of tech3;

class rendering_context___js_proxy implements rendering_context
{
  InstanceMirror mirror; 
  JsObject gl;
  bool tracing = false;
  bool errorLogging = false;
  bool paramListLogging = false;
  bool stackTracing = false;
  
  //TODO: implement these:
  int get drawingBufferWidth => this.gl['drawingBufferWidth'];
  int get drawingBufferHeight => this.gl['drawingBufferHeight'];
  
  rendering_context___js_proxy()
  {
    mirror = reflect(this);
    JsObject interop = context['jsinterop'];
    this.gl = interop.callMethod('getContext3D', []);
  }
  
  dynamic noSuchMethod(Invocation invocation) // API call
  {
    Symbol method_symbol = invocation.memberName;
    String method_name = '';
    
    if(tracing)
    {
      method_name = MirrorSystem.getName(method_symbol);
      String args = getArgs(invocation);
    
      if(paramListLogging)
      {
        print('[webgl] ${method_name}(${args}) piped to js');
      }
      else
      {
        print('[webgl] ${method_name}(..) piped to js');
      }
    }
    
    List parameterlist = unwrapDartParams(getArgsList(invocation),method_symbol, method_name);
    
    var result = processWebGLPipe(method_symbol, parameterlist, method_name, this);
    
    if(errorLogging)
    {
      handleContextErrors(this, stackTracing, method_name, ()
      {
        int errorCode; 
        errorCode = gl.callMethod(symbol_name(symGetError),[]);
        return errorCode;
      });
    }

    return result;
  }
}