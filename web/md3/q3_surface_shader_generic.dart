part of tech3;

abstract class Q3_surface_shader_generic
{  
  rendering_context gl;
  int IN_VEC3_POSITION;
  int IN_VEC3_NORMAL;
  int IN_VEC2_ST;
  GLUniformLocation UN_MAT3_NORMALS;
  GLUniformLocation UN_MAT4_PROJECTION;
  GLUniformLocation UN_MAT4_MODELVIEW;
  GLUniformLocation UN_MAT4_MODELWORLD;
  GLUniformLocation UN_SAMP_TEXTURE;
  GLUniformLocation UN_VEC4_DEFAULT_COL;
  GLUniformLocation UN_VEC4_ES_LIGHT_1;
  GLUniformLocation UN_VEC4_ES_LIGHT_2;
  GLUniformLocation UN_VEC4_ES_LIGHT_3;
  GLUniformLocation UN_BOOL_MIRRORPASS;
  DwShader shader;
  
  void saveShaderLocations ();
  void delete();
  void setMat4_Projection (Matrix4 MAT4);
  void setMat4_ModelView (Matrix4 MAT4);
  void setMat4_ModelWorld (Matrix4 MAT4);
  void setMat3_Normals (Matrix3 MAT3);
  void activeTexture (int tex_loc);
  void setDefaultColor (Vector4 VEC4);
  void bind ();
  void unbind ();
  
  //void setMirrored (bool bool);
  //void setVec4_Light (int idx, Vector4 VEC4);
}