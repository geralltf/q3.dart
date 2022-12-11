part of tech3;

/* Copyright (c) Gerallt G. Franke based off RedneringContext code by the Dart Authors
 * 
 * Based to comply with the dart_webgl RenderingContext webgl interface  
 * automatically takes vector_math types and converts them to a standard WebGL TypedData type.
 * 
 * USAGE: You may utilise constants in dart:web_gl RenderingContext, 
 *        but these constants will be replaced with enums like OpenTK.
 */
// ~~~~ WebGL interface based somewhat off the auto-generated dart:web_gl library.
abstract class webgl_interface_2_0 
{
  
  int get drawingBufferHeight;
  int get drawingBufferWidth;
  
  /* This is the base API 1:1 compatible with the dart:web_gl RenderingContext 
   * and not to be modified unless RenderingContext changes */
  void activeTexture(int texture);
  void attachShader(GLProgram program, GLShader shader);
  void bindAttribLocation(GLProgram program, int index, String name);
  void bindBuffer(int target, GLBuffer buffer);
  void bindFramebuffer(int target, GLFramebuffer framebuffer);
  void bindRenderbuffer(int target, GLRenderbuffer renderbuffer);
  void bindTexture(int target, GLTexture texture);
  void blendColor(num red, num green, num blue, num alpha);
  void blendEquation(int mode);
  void blendEquationSeparate(int modeRGB, int modeAlpha);
  void blendFunc(int sfactor, int dfactor);
  void blendFuncSeparate(int srcRGB, int dstRGB, int srcAlpha, int dstAlpha);
  void bufferByteData(int target, dynamic data, int usage);
  void bufferData(int target, data_OR_size, int usage);
  void bufferDataTyped(int target, dynamic data, int usage);
  void bufferSubByteData(int target, int offset, ByteBuffer data);
  void bufferSubData(int target, int offset, data);
  void bufferSubDataTyped(int target, int offset, dynamic data);
  int checkFramebufferStatus(int target);
  void clear(int mask);
  void clearColor(num red, num green, num blue, num alpha);
  void clearDepth(num depth);
  void clearStencil(int s);
  void colorMask(bool red, bool green, bool blue, bool alpha);
  void compileShader(GLShader shader);
  void compressedTexImage2D(int target, int level, int internalformat, int width, int height, int border, dynamic data);
  void compressedTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, dynamic data);
  void copyTexImage2D(int target, int level, int internalformat, int x, int y, int width, int height, int border);
  void copyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height);
  GLBuffer createBuffer();
  GLFramebuffer createFramebuffer();
  GLProgram createProgram();
  GLRenderbuffer createRenderbuffer();
  GLShader createShader(int type);
  GLTexture createTexture();
  void cullFace(int mode);
  void deleteBuffer(GLBuffer buffer);
  void deleteFramebuffer(GLFramebuffer framebuffer);
  void deleteProgram(GLProgram program);
  void deleteRenderbuffer(GLRenderbuffer renderbuffer);
  void deleteShader(GLShader shader);
  void deleteTexture(GLTexture texture);
  void depthFunc(int func);
  void depthMask(bool flag);
  void depthRange(num zNear, num zFar);
  void detachShader(GLProgram program, GLShader shader);
  void disable(int cap);
  void disableVertexAttribArray(int index);
  void drawArrays(int mode, int first, int count);
  void drawElements(int mode, int count, int type, int offset);
  void enable(int cap);
  void enableVertexAttribArray(int index);
  void finish();
  void flush();
  void framebufferRenderbuffer(int target, int attachment, int renderbuffertarget, GLRenderbuffer renderbuffer);
  void framebufferTexture2D(int target, int attachment, int textarget, GLTexture texture, int level);
  void frontFace(int mode);
  void generateMipmap(int target);
  GLActiveInfo getActiveAttrib(GLProgram program, int index);
  GLActiveInfo getActiveUniform(GLProgram program, int index);
  List<GLShader> getAttachedShaders(GLProgram program);
  int getAttribLocation(GLProgram program, String name);
  dynamic getBufferParameter(int target, int pname);
  ContextAttributes getContextAttributes();
  int getError();
  dynamic getExtension(String name);
  dynamic getFramebufferAttachmentParameter(int target, int attachment, int pname);
  dynamic getParameter(int pname);
  String getProgramInfoLog(GLProgram program);
  dynamic getProgramParameter(GLProgram program, int pname);
  dynamic getRenderbufferParameter(int target, int pname);
  String getShaderInfoLog(GLShader shader);
  dynamic getShaderParameter(GLShader shader, int pname);
  GLShaderPrecisionFormat getShaderPrecisionFormat(int shadertype, int precisiontype);
  String getShaderSource(GLShader shader);
  List<String> getSupportedExtensions();
  dynamic getTexParameter(int target, int pname);
  dynamic getUniform(GLProgram program, GLUniformLocation location);
  GLUniformLocation getUniformLocation(GLProgram program, String name);
  dynamic getVertexAttrib(int index, int pname);
  int getVertexAttribOffset(int index, int pname);
  void hint(int target, int mode);
  bool isBuffer(GLBuffer buffer);
  bool isContextLost();
  bool isEnabled(int cap);
  bool isFramebuffer(GLFramebuffer framebuffer);
  bool isProgram(GLProgram program);
  bool isRenderbuffer(GLRenderbuffer renderbuffer);
  bool isShader(GLShader shader);
  bool isTexture(GLTexture texture);
  void lineWidth(num width);
  void linkProgram(GLProgram program);
  void pixelStorei(int pname, int param);
  void polygonOffset(num factor, num units);
  void readPixels(int x, int y, int width, int height, int format, int type, TypedData pixels);
  void renderbufferStorage(int target, int internalformat, int width, int height);
  void sampleCoverage(num value, bool invert);
  void scissor(int x, int y, int width, int height);
  void shaderSource(GLShader shader, String string);
  void stencilFunc(int func, int ref, int mask);
  void stencilFuncSeparate(int face, int func, int ref, int mask);
  void stencilMask(int mask);
  void stencilMaskSeparate(int face, int mask);
  void stencilOp(int fail, int zfail, int zpass);
  void stencilOpSeparate(int face, int fail, int zfail, int zpass);
  void texImage2D(int target, int level, int internalformat, int format_OR_width, int height_OR_type, border_OR_canvas_OR_image_OR_pixels_OR_video, [int format, int type, dynamic pixels]);
  void texImage2DCanvas(int target, int level, int internalformat, int format, int type, dynamic canvas);
  void texImage2DImage(int target, int level, int internalformat, int format, int type, dynamic image);
  void texImage2DImageData(int target, int level, int internalformat, int format, int type, dynamic pixels);
  void texImage2DVideo(int target, int level, int internalformat, int format, int type, dynamic video);
  void texParameterf(int target, int pname, num param);
  void texParameteri(int target, int pname, int param);
  void texSubImage2D(int target, int level, int xoffset, int yoffset, int format_OR_width, int height_OR_type, canvas_OR_format_OR_image_OR_pixels_OR_video, [int type, dynamic pixels]);
  void texSubImage2DCanvas(int target, int level, int xoffset, int yoffset, int format, int type, dynamic canvas);
  void texSubImage2DImage(int target, int level, int xoffset, int yoffset, int format, int type, dynamic image);
  void texSubImage2DImageData(int target, int level, int xoffset, int yoffset, int format, int type, dynamic pixels);
  void texSubImage2DVideo(int target, int level, int xoffset, int yoffset, int format, int type, dynamic video);
  void uniform1f(GLUniformLocation location, num x);
  void uniform1fv(GLUniformLocation location, Float32List v);
  void uniform1i(GLUniformLocation location, int x);
  void uniform1iv(GLUniformLocation location, Int32List v);
  void uniform2f(GLUniformLocation location, num x, num y);
  void uniform2fv(GLUniformLocation location, Float32List v);
  void uniform2i(GLUniformLocation location, int x, int y);
  void uniform2iv(GLUniformLocation location, Int32List v);
  void uniform3f(GLUniformLocation location, num x, num y, num z);
  void uniform3fv(GLUniformLocation location, Float32List v);
  void uniform3i(GLUniformLocation location, int x, int y, int z);
  void uniform3iv(GLUniformLocation location, Int32List v);
  void uniform4f(GLUniformLocation location, num x, num y, num z, num w);
  void uniform4fv(GLUniformLocation location, Float32List v);
  void uniform4i(GLUniformLocation location, int x, int y, int z, int w);
  void uniform4iv(GLUniformLocation location, Int32List v);
  void uniformMatrix2fv(GLUniformLocation location, bool transpose, Float32List array);
  void uniformMatrix3fv(GLUniformLocation location, bool transpose, Float32List array);
  void uniformMatrix4fv(GLUniformLocation location, bool transpose, Float32List array);
  void useProgram(GLProgram program);
  void validateProgram(GLProgram program);
  void vertexAttrib1f(int indx, num x);
  void vertexAttrib1fv(int indx, Float32List values);
  void vertexAttrib2f(int indx, num x, num y);
  void vertexAttrib2fv(int indx, Float32List values);
  void vertexAttrib3f(int indx, num x, num y, num z);
  void vertexAttrib3fv(int indx, Float32List values);
  void vertexAttrib4f(int indx, num x, num y, num z, num w);
  void vertexAttrib4fv(int indx, Float32List values);
  void vertexAttribPointer(int indx, int size, int type, bool normalized, int stride, int offset);
  void viewport(int x, int y, int width, int height);
  void texImage2DUntyped(int targetTexture, int levelOfDetail, int internalFormat, int format, int type, data);
  void texImage2DTyped(int targetTexture, int levelOfDetail, int internalFormat, int width, int height, int border, int format, int type, dynamic data);
  void texSubImage2DUntyped(int targetTexture, int levelOfDetail, int xOffset, int yOffset, int format, int type, data);
  void texSubImage2DTyped(int targetTexture, int levelOfDetail, int xOffset, int yOffset, int width, int height, int format, int type, dynamic data);
}