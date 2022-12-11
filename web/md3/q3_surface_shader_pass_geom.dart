part of tech3;

class Q3_surface_shader_pass_geom extends Q3_surface_shader_generic
{  
  Q3_surface_shader_pass_geom(rendering_context gl)
  {
    this.gl = gl;

    shader = new DwShader(gl, "", q3bsp_base_folder + "/models/SHADERS/md3_shader_pass_geom_vert.glsl", 
                                  q3bsp_base_folder + "/models/SHADERS/md3_shader_pass_geom_frag.glsl");
    shader.onload =()
    {
      saveShaderLocations();
    };
    shader.load(null);
  }

  void saveShaderLocations ()
  {
    gl.useProgram(this.shader.HANDLE_program);
    {
      this.IN_VEC3_POSITION    = gl.getAttribLocation (this.shader.HANDLE_program,  "IN_VEC3_POSITION"   );
      this.IN_VEC3_NORMAL      = gl.getAttribLocation  (this.shader.HANDLE_program, "IN_VEC3_NORMAL"     );
      this.IN_VEC2_ST          = gl.getAttribLocation (this.shader.HANDLE_program,  "IN_VEC2_ST"         );

      this.UN_MAT3_NORMALS     = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_MAT3_NORMALS"    );
      this.UN_MAT4_PROJECTION  = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_MAT4_PROJECTION" );
      this.UN_MAT4_MODELVIEW   = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_MAT4_MODELVIEW"  );
      this.UN_MAT4_MODELWORLD  = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_MAT4_MODELWORLD"  );

      this.UN_SAMP_TEXTURE     = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_SAMP_TEXTURE"    );
      this.UN_VEC4_DEFAULT_COL = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_VEC4_DEFAULT_COL");
    }
    gl.useProgram(null);
  }

  void delete ()
  {
    this.shader.delete();
    this.shader = null;
  }
  void setMat4_Projection (Matrix4 MAT4)
  {
    this.gl.uniformMatrix4fv( this.UN_MAT4_PROJECTION, false, MAT4.storage);
  }

  void setMat4_ModelView (Matrix4 MAT4)
  {
    this.gl.uniformMatrix4fv( this.UN_MAT4_MODELVIEW, false, MAT4.storage);
  }
  void setMat4_ModelWorld (Matrix4 MAT4)
  {
    this.gl.uniformMatrix4fv( this.UN_MAT4_MODELWORLD, false, MAT4.storage);
  }

  void setMat3_Normals (Matrix3 MAT3)
  {
    this.gl.uniformMatrix3fv( this.UN_MAT3_NORMALS, false, MAT3.storage);
  }

  void activeTexture (int tex_loc)
  {
    this.gl.uniform1i(this.UN_SAMP_TEXTURE, tex_loc);
  }
  void setDefaultColor (Vector4 VEC4)
  {
    this.gl.uniform4fv( this.UN_VEC4_DEFAULT_COL, VEC4.storage);
  }

  void bind ()
  {
    this.gl.useProgram(this.shader.HANDLE_program);
  }

  void unbind ()
  {
    this.gl.useProgram(null);
  } 
}