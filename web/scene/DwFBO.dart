part of tech3;

//  http://www.khronos.org/webgl/wiki_1_15/index.php/WebGL_and_OpenGL_Differences

class DwFBO
{
  rendering_context gl;
  
  GLTexture HANDLE_tex;
  GLRenderbuffer HANDLE_rb_depth;
  GLRenderbuffer HANDLE_rb_stencil;
  GLFramebuffer HANDLE_FBO;
  
  var width;
  var height;
  int datatype;
  
  DwFBO(rendering_context gl, int width, int height, int datatype)
  {
    this.gl = gl;
    this.width = width;
    this.height = height;
    this.datatype = datatype == null ? RenderingContext.UNSIGNED_BYTE : datatype;


    // TEXTURE
    this.HANDLE_tex = gl.createTexture();
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, this.HANDLE_tex);
    {
//    gl.pixelStorei   ( gl.UNPACK_FLIP_Y_WEBGL, true);
//    gl.pixelStorei   ( gl.UNPACK_ALIGNMENT, 1);
      gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.NEAREST);
      gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.NEAREST);
      gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE ) ;
      gl.texParameteri ( RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE ) ;
      gl.texImage2D    ( RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, width, height, 0, RenderingContext.RGBA, this.datatype, null);
    //      gl.generateMipmap( gl.TEXTURE_2D);
    }
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, null);


    // RENDERBUFFER / DEPTH
    this.HANDLE_rb_depth = gl.createRenderbuffer();
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, this.HANDLE_rb_depth);
    gl.renderbufferStorage(RenderingContext.RENDERBUFFER, RenderingContext.DEPTH_COMPONENT16, width, height);
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, null);

    // RENDERBUFFER / STENCI
    this.HANDLE_rb_stencil = gl.createRenderbuffer();
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, this.HANDLE_rb_stencil);
    gl.renderbufferStorage(RenderingContext.RENDERBUFFER, RenderingContext.DEPTH_STENCIL, width, height);
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, null);


    // FBO
    this.HANDLE_FBO = gl.createFramebuffer();
    gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, this.HANDLE_FBO);
    {
      gl.framebufferTexture2D   (RenderingContext.FRAMEBUFFER, RenderingContext.COLOR_ATTACHMENT0, RenderingContext.TEXTURE_2D,   this.HANDLE_tex, 0);
      //gl.framebufferRenderbuffer(RenderingContext.FRAMEBUFFER, RenderingContext.DEPTH_ATTACHMENT,  RenderingContext.RENDERBUFFER, this.HANDLE_rb_depth);
      gl.framebufferRenderbuffer(RenderingContext.FRAMEBUFFER, RenderingContext.DEPTH_STENCIL_ATTACHMENT,  RenderingContext.RENDERBUFFER, this.HANDLE_rb_stencil);

      WEBGL_FBO_CHECK(gl, this.HANDLE_FBO);
    }
  }
  
  WEBGL_FBO_CHECK (rendering_context gl, GLFramebuffer handle_fbo)
  {
    if (!gl.isFramebuffer(handle_fbo)) 
    {
      print("Invalid framebuffer");
    }
    
    int status = gl.checkFramebufferStatus(RenderingContext.FRAMEBUFFER);
    
    switch (status) {
      case RenderingContext.FRAMEBUFFER_COMPLETE:
        break;
      case RenderingContext.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
        print("Incomplete framebuffer: FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
        break;
      case RenderingContext.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
        print("Incomplete framebuffer: FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT");
        break;
      case RenderingContext.FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
        print("Incomplete framebuffer: FRAMEBUFFER_INCOMPLETE_DIMENSIONS");
        break;
      case RenderingContext.FRAMEBUFFER_UNSUPPORTED:
        print("Incomplete framebuffer: FRAMEBUFFER_UNSUPPORTED");
        break;
      default:
        print("Incomplete framebuffer: ${status}");
    }
  }
  
  void resize (width, height)
  {
    this.width = width;
    this.height = height;
    
    // TEXTURE 2D
    gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, this.HANDLE_FBO);

    gl.bindTexture   ( RenderingContext.TEXTURE_2D, this.HANDLE_tex);
    gl.texImage2D    ( RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, this.width, this.height, 0, RenderingContext.RGBA, this.datatype, null);
    gl.bindTexture   ( RenderingContext.TEXTURE_2D, null);

    // RENDERBUFFER / DEPTH
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, this.HANDLE_rb_depth);
    gl.renderbufferStorage(RenderingContext.RENDERBUFFER, RenderingContext.DEPTH_COMPONENT16, this.width, this.height);
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, null);

    // RENDERBUFFER / STENCI
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, this.HANDLE_rb_stencil);
    gl.renderbufferStorage(RenderingContext.RENDERBUFFER, RenderingContext.DEPTH_STENCIL, this.width, this.height);
    gl.bindRenderbuffer   (RenderingContext.RENDERBUFFER, null);

    gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, null);
  }

  void delete (width, height)
  {
    gl.deleteTexture(this.HANDLE_tex);
    gl.deleteRenderbuffer(this.HANDLE_rb_stencil);
    gl.deleteFramebuffer(this.HANDLE_FBO);
    this.HANDLE_FBO        = null;
    this.HANDLE_rb_stencil = null;
    this.HANDLE_tex        = null;
    this.gl = null;
    this.width = 0;
    this.height = 0;
    this.datatype = 0;
  }

  getTexture()
  {
    return this.HANDLE_tex;
  }

  getWidth()
  {
    return this.width;
  }
  getHeight()
  {
    return this.height;
  }
  void bind()
  {
    this.gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, this.HANDLE_FBO);
  }
  void unbind()
  {
    this.gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, null);
  }
  
}