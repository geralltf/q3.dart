part of tech3;

class DOF_shader
{
  rendering_context gl;
  DwShader shader;
  
  int IN_VEC3_POSITION;
  int IN_VEC2_ST;
  GLUniformLocation UN_MAT4_PROJECTION;
  GLUniformLocation UN_SAMP2D_RENDERING;
  GLUniformLocation UN_SAMP2D_NORMAL_Z;
  GLUniformLocation UN_FLOAT_CAM_FAR;
  GLUniformLocation UN_FLOAT_CAM_NEAR;
  GLUniformLocation UN_FLOAT_DOF_DISTANCE;
  GLUniformLocation UN_FLOAT_DOF_STRENGTH;
  GLUniformLocation UN_VEC2_VIEWPORT_SIZE;
  
  DOF_shader(rendering_context gl)
  {
    this.gl = gl;
    this.shader = new DwShader(gl, "", q3bsp_base_folder + "/models/SHADERS/SH_DOF_vert.glsl", 
                                       q3bsp_base_folder + "/models/SHADERS/SH_DOF_frag.glsl");
    
    this.shader.onload = ()
    {
      this.saveShaderLocations();
    };
    
    this.shader.load(null);
  }
  
  saveShaderLocations()
  {
    gl.useProgram(this.shader.HANDLE_program);
    {
      this.IN_VEC3_POSITION    = gl.getAttribLocation (this.shader.HANDLE_program,  "IN_VEC3_POSITION"    );
      this.IN_VEC2_ST          = gl.getAttribLocation (this.shader.HANDLE_program,  "IN_VEC2_ST"          );
      this.UN_MAT4_PROJECTION  = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_MAT4_PROJECTION"  );

      this.UN_SAMP2D_RENDERING = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_SAMP2D_RENDERING" );
      this.UN_SAMP2D_NORMAL_Z  = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_SAMP2D_NORMAL_Z"  );

      this.UN_FLOAT_CAM_FAR      = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_FLOAT_CAM_FAR" );
      this.UN_FLOAT_CAM_NEAR     = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_FLOAT_CAM_NEAR" );
      this.UN_FLOAT_DOF_DISTANCE = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_FLOAT_DOF_DISTANCE" );
      this.UN_FLOAT_DOF_STRENGTH = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_FLOAT_DOF_STRENGTH" );
      this.UN_VEC2_VIEWPORT_SIZE = gl.getUniformLocation(this.shader.HANDLE_program,  "UN_VEC2_VIEWPORT_SIZE" );

    }
    gl.useProgram(null);
    //  console.log("attribute location: IN_VEC3_POSITION          = "+this.IN_VEC3_POSITION);
    //  console.log("attribute location: IN_VEC2_ST                = "+this.IN_VEC2_ST);
    //  console.log("uniform   location: UN_MAT4_PROJECTION        = "+this.UN_MAT4_PROJECTION);
      //
    //  console.log("uniform   location: UN_SAMP2D_RENDERING       = "+this.UN_SAMP2D_RENDERING);
    //  console.log("uniform   location: UN_SAMP2D_NORMAL_Z        = "+this.UN_SAMP2D_NORMAL_Z);
      //
    //  console.log("uniform   location: UN_FLOAT_CAM_FAR          = "+this.UN_FLOAT_CAM_FAR     );
    //  console.log("uniform   location: UN_FLOAT_CAM_NEAR         = "+this.UN_FLOAT_CAM_NEAR    );
    //  console.log("uniform   location: UN_FLOAT_DOF_DISTANCE     = "+this.UN_FLOAT_DOF_DISTANCE);
    //  console.log("uniform   location: UN_FLOAT_DOF_STRENGTH     = "+this.UN_FLOAT_DOF_STRENGTH);
    //  console.log("uniform   location: UN_VEC2_VIEWPORT_SIZE     = "+this.UN_VEC2_VIEWPORT_SIZE);
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

  void activeTexture (GLUniformLocation handle, int tex_loc)
  {
    this.gl.uniform1i(handle, tex_loc);
  }
  void setCamNearFar (num NEAR, num FAR)
  {
    this.gl.uniform1f( this.UN_FLOAT_CAM_NEAR, NEAR);
    this.gl.uniform1f( this.UN_FLOAT_CAM_FAR, FAR);
  }
  void setDOF (num DOF_DIS, num STRENGTH)
  {
    this.gl.uniform1f( this.UN_FLOAT_DOF_DISTANCE, DOF_DIS);
    this.gl.uniform1f( this.UN_FLOAT_DOF_STRENGTH, STRENGTH);
  }
  void setViewportSize (double WIDTH, double HEIGHT)
  {
    Float32List lst = new Float32List(2);
    lst.setAll(0, [WIDTH, HEIGHT]);
    
    this.gl.uniform2fv( this.UN_VEC2_VIEWPORT_SIZE, lst);
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