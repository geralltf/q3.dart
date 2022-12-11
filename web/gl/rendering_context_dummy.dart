part of tech3;

class rendering_context_dummy_proxy implements rendering_context
{
  InstanceMirror mirror; 
  JsObject gl;
  
  Map<String,Type> apiFunctionsWithResultTypes = 
  {
    "createBuffer": Buffer,
    "createFramebuffer": Framebuffer,
    "createProgram": Program,
    "createRenderbuffer": Renderbuffer,
    "createShader": Shader,
    "createTexture": Texture,
    "getActiveAttrib": null,
    "getActiveUniform": null,
    "getBufferParameter": null,
    "getContextAttributes": null,
    "getAttachedShaders": null,
    "getFramebufferAttachmentParameter": null,
    "getParameter": null,
    "getProgramParameter": null,
    "getProgramInfoLog": null,
    "getRenderbufferParameter": null,
    "getShaderParameter": null,
    "getShaderInfoLog": null,
    "getShaderSource": null,
    "getTexParameter": null,
    "getUniform": null,
    "getUniformLocation": null,
    "getVertexAttrib": null,
    "isBuffer": bool,
    "isEnabled": bool,
    "isFramebuffer": bool,
    "isProgram": bool,
    "isRenderbuffer": bool,
    "isShader": bool,
    "isTexture": bool
  };
  
  rendering_context_nativewebgl_proxy()
  {
    mirror = reflect(this);
    JsObject interop = context['jsinterop'];
    this.gl = interop.callMethod('getContext3D', [canvas]);
  }
  
  noSuchMethod(Invocation invocation) 
  {
    Symbol method_symbol = invocation.memberName;
    String method_name = MirrorSystem.getName(method_symbol);
    String args = getArgs(invocation);
    
    print('[webgl] ${method_name}(${args}) piped to js');
    
    // return dummy data ?
    
    return null;
    
    //Type type = apiFunctionsWithResultTypes[method_name];
    
    
    
    //return result;
  }
}