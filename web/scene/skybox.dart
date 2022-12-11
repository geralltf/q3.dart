part of tech3;

enum skybox_type
{
  six_tex,
  one_tex
}

String skybox_env_url = q3bsp_base_folder + '/env/' + mapName + '/';

class skybox
{
  skybox_type type;
  cubemap map;
  GLTexture skymap;
  
  static GLBuffer skyboxBuffer = null;
  static GLBuffer skyboxIndexBuffer = null;
  static int skyboxIndexCount = 0;
  static Matrix4 skyboxMat;
  static shader_gl skyShader;
  static bool has_skyparams;
    
  static void loadSkyTexture(rendering_context gl, 
                             shader_gl shader, 
                             shader_p surface,
                             OnTextueLoad onTextureLoading,
                             OnTextueLoad onTextureLoadComplete)
  { 
    bool has_skyparams = shader.sky_env_map != null;
    
    
    
    if(has_skyparams)
    {
      // hard code in six or one texture mode for now
      
      String url = q3bsp_base_folder + '/' + shader.sky_env_map.params;
      String back_url = url + '_bk.jpg';
      String down_url = url + '_dn.jpg';
      String front_url = url + '_ft.jpg';
      String left_url = url + '_lf.jpg';
      String right_url = url + '_rt.jpg';
      String up_url = url + '_up.jpg';
      
//      cubemap_texture_six.load(back_url, 
//                               down_url, 
//                               front_url, 
//                               left_url, 
//                               right_url, 
//                               up_url, 
//                               gl, 
//      (GLTexture texture)
//      {
//        onTextureLoading(texture);
//      }, 
//      (GLTexture texture)
//      {
//        onTextureLoadComplete(texture);
//      });
      
      
      
      //TODO: support for single texture mode using something like this. need to find test map.
      
      cubemap_texture_one.load(back_url, gl, 
      (GLTexture texture)
      {
        onTextureLoading(texture);
      }, 
      (GLTexture texture)
      {
        onTextureLoadComplete(texture);
      });
      
      //cubemap_texture_one.load(q3bsp_base_folder + '/' + stage.map, gl, null, onTextureLoadComplete);
    }
    else
    {
      //UNTESTED condition
    }    
  }
  
  static skybox loadFromShader(rendering_context gl, shader_p surface, shader_gl shader)
  {
    skybox sky = new skybox();
    
    // determine type of skybox: number of textures to load
    
    sky.type = skybox_type.one_tex;
    
    
    //sky.map = new cubemap_texture_one();
    
    loadSkyTexture(gl, shader, surface, (GLTexture texture)
    {
      sky.skymap = texture;
    },
    (GLTexture texture) 
    {
      sky.skymap = texture;
      
      gl.generateMipmap(RenderingContext.TEXTURE_CUBE_MAP);
    });
    
    return sky;
  }
  
  skybox()
  {
    //skyboxBuffer = null;
    //skyboxIndexBuffer = null;
    //skyboxIndexCount = 0;
    skyboxMat = new Matrix4.identity();
    map = null;
  }
  
  void bindSkyTexture(rendering_context gl, stage_gl stage,shader_prog_t program, time)
  {
    //map.render();
    
    if(type == skybox_type.one_tex)
    {
      if(skymap == null) { skymap = q3bsp.glshading.defaultTextureRed; }
      
      gl.activeTexture(RenderingContext.TEXTURE0);
      gl.uniform1i(program.uniform['texture'], 0);
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skymap);
    }
    else if(type == skybox_type.six_tex)
    {
      
    }
  }
  
  void bindSkySingleTexture(rendering_context gl, time)
  {
    //shader_gl shader =  q3bsp.shaders[skyShader.name];
    
    if(skymap == null) { skymap = q3bsp.glshading.defaultTextureRed; }
          
    gl.activeTexture(RenderingContext.TEXTURE0);
    //gl.uniform1i(program.uniform['texture'], 0);
    gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skymap);
  }
  
  void render(rendering_context gl, time)
  {
    //q3bsp.skybox_env.bindSkyTexture(gl, stage, program, time);
    
    // Loop through all shaders, drawing all surfaces associated with them
    if(q3bsp.surfaces.length > 0) {
      // If we have a skybox, render it first
      if(skyShader != null && skyboxIndexBuffer != null && skyboxBuffer != null) 
      {
          bindSkySingleTexture(gl,time);
        
          // SkyBox Buffers
          gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, skyboxIndexBuffer);
          gl.bindBuffer(RenderingContext.ARRAY_BUFFER, skyboxBuffer);
      
          // Render Skybox
          if(q3bsp.glshading.setShader(gl, skyShader)) 
          {
              for(var j = 0; j < skyShader.stages.length; ++j) 
              {
                 stage_gl stage = skyShader.stages[j];
                  
                  var shaderProgram = q3bsp.glshading.setShaderStage(gl, skyShader, stage, time);
                  if(shaderProgram == null) { continue; }
                  skybox.bindSkyAttribs(shaderProgram);
                  
                  // Draw Sky geometry
                  skybox.bindSkyMatrix(shaderProgram, leftViewMat, leftProjMat);
                  q3bsp.setViewport(leftViewport);
                  
                  gl.drawElements(RenderingContext.TRIANGLES, 
                                  skyboxIndexCount, 
                                  RenderingContext.UNSIGNED_SHORT, 
                                  0);
 
//                  if (rightViewMat != null) {
//                    skybox.bindSkyMatrix(shaderProgram, rightViewMat, rightProjMat);
//                    q3bsp.setViewport(rightViewport);
//                      
//                      gl.drawElements(RenderingContext.TRIANGLES, 
//                          skyboxIndexCount, 
//                              RenderingContext.UNSIGNED_SHORT, 
//                              0);
//                  }
              }
          }
      }
    }
  }
  
  static void bindSkyMatrix (shader_prog_t shader, Matrix4 modelViewMat, Matrix4 projectionMat) 
  {   
    skyboxMat = mat4Set(modelViewMat,skyboxMat); //mat4.set(modelViewMat, this.skyboxMat);
   
   // Clear out the translation components
    skyboxMat[12] = 0.0;
    skyboxMat[13] = 0.0;
    skyboxMat[14] = 0.0;
   
   // Set uniforms
   gl.uniformMatrix4fv(shader.uniform['modelViewMat'], false, storeMatrix4(skyboxMat));
   gl.uniformMatrix4fv(shader.uniform['projectionMat'], false, storeMatrix4(projectionMat));
  }
  
  static void bindSkyAttribs (shader_prog_t shader) 
  {
   // Setup vertex attributes
   gl.enableVertexAttribArray(shader.attrib['position']);
   gl.vertexAttribPointer(shader.attrib['position'], 
                          3, 
                          RenderingContext.FLOAT, 
                          false, 
                          q3bsp_sky_vertex_stride, 
                          0);
       
   if(shader.attrib['texCoord'] != null) 
   {
       gl.enableVertexAttribArray(shader.attrib['texCoord']);
       gl.vertexAttribPointer(shader.attrib['texCoord'], 
                              2, 
                              RenderingContext.FLOAT, 
                              false, 
                              q3bsp_sky_vertex_stride, 
                              3*4);
   }
  }
  
  static void buildSkyboxbuffers(rendering_context gl)
  {
    List lst_skyVerts = [
        -128.0, 128.0, 128.0, 0.0, 0.0,
        128.0, 128.0, 128.0, 1.0, 0.0,
        -128.0, -128.0, 128.0, 0.0, 1.0,
        128.0, -128.0, 128.0, 1.0, 1.0,
        
        -128.0, 128.0, 128.0, 0.0, 1.0,
        128.0, 128.0, 128.0, 1.0, 1.0,
        -128.0, 128.0, -128.0, 0.0, 0.0,
        128.0, 128.0, -128.0, 1.0, 0.0,
        
        -128.0, -128.0, 128.0, 0.0, 0.0,
        128.0, -128.0, 128.0, 1.0, 0.0,
        -128.0, -128.0, -128.0, 0.0, 1.0,
        128.0, -128.0, -128.0, 1.0, 1.0,
        
        128.0, 128.0, 128.0, 0.0, 0.0,
        128.0, -128.0, 128.0, 0.0, 1.0,
        128.0, 128.0, -128.0, 1.0, 0.0,
        128.0, -128.0, -128.0, 1.0, 1.0,
        
        -128.0, 128.0, 128.0, 1.0, 0.0,
        -128.0, -128.0, 128.0, 1.0, 1.0,
        -128.0, 128.0, -128.0, 0.0, 0.0,
        -128.0, -128.0, -128.0, 0.0, 1.0
    ];
    Float32List skyVerts = new Float32List(lst_skyVerts.length);
    skyVerts.setAll(0, lst_skyVerts);
    
    List lst_skyIndices = [
        0, 1, 2,
        1, 2, 3,
        
        4, 5, 6,
        5, 6, 7,
        
        8, 9, 10,
        9, 10, 11,
        
        12, 13, 14,
        13, 14, 15,
        
        16, 17, 18,
        17, 18, 19
    ];
    
    Uint16List skyIndices = new Uint16List(lst_skyIndices.length);
    skyIndices.setAll(0, lst_skyIndices);
    
    //Uint16List wgl_coordIndex=normalize_indicies_as_uint16(Int32List here);  // restricted to uint16 atm
    
    skyboxBuffer = gl.createBuffer();
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, skyboxBuffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, skyVerts, RenderingContext.STATIC_DRAW);
    
    skyboxIndexBuffer = gl.createBuffer();
    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, skyboxIndexBuffer);
    gl.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, skyIndices, RenderingContext.STATIC_DRAW);
    
    skyboxIndexCount = skyIndices.length;
  }
}

abstract class cubemap
{
  //render();
  
}

class cubemap_texture_six extends cubemap
{
  static load(String back_url, 
      String down_url,
      String front_url,
      String left_url,
      String right_url,
      String up_url,
      rendering_context gl, 
      OnTextueLoad onloading, 
      OnTextueLoad onloadComplete)
  {
    GLTexture skybox = gl.createTexture();
    //gl.enable(RenderingContext.TEXTURE_CUBE_MAP);
    gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
    
    gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
    gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.LINEAR);
    gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
    gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE);
    //gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_WRAP_R, RenderingContext.CLAMP_TO_EDGE);


//     
//    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, RGB, xneg->w, xneg->h, 0, RGB, GL_UNSIGNED_BYTE, xneg->pixels); 
//    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, RGB, ypos->w, ypos->h, 0, RGB, GL_UNSIGNED_BYTE, ypos->pixels); 
//    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, RGB, yneg->w, yneg->h, 0, RGB, GL_UNSIGNED_BYTE, yneg->pixels); 
//    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, RGB, zpos->w, zpos->h, 0, RGB, GL_UNSIGNED_BYTE, zpos->pixels); 
//    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, RGB, zneg->w, zneg->h, 0, RGB, GL_UNSIGNED_BYTE, zneg->pixels); 

    // http://www.rioki.org/2013/03/07/glsl-skybox.html
    
    int num_loaded = 0;
    onloading(skybox);
    
    //ASYNC loading of skybox right here
    fetch_texture(back_url, (t){}, (t,image){
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
//      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
//                    0, 
//                    RenderingContext.RGB, 
//                    xpos->w, 
//                    xpos->h, 
//                    0, 
//                    RenderingContext.RGB, 
//                    RenderingContext.UNSIGNED_BYTE, 
//                    image
//      );
      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_Z, 
                    0, 
                    RenderingContext.RGBA, 
                    RenderingContext.RGBA, // could be RGB
                    RenderingContext.UNSIGNED_BYTE, image);
      num_loaded++;
      if(num_loaded == 6) onloadComplete(skybox);
    });
    fetch_texture(down_url, (t){}, (t,image){
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
//      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
//                    0, 
//                    RenderingContext.RGB, 
//                    xpos->w, 
//                    xpos->h, 
//                    0, 
//                    RenderingContext.RGB, 
//                    RenderingContext.UNSIGNED_BYTE, 
//                    image
//      );
      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
                    0, 
                    RenderingContext.RGBA, 
                    RenderingContext.RGBA, // could be RGB
                    RenderingContext.UNSIGNED_BYTE, image);
      num_loaded++;
            if(num_loaded == 6) onloadComplete(skybox);
    });
    fetch_texture(front_url, (t){}, (t,image){
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
//      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
//                    0, 
//                    RenderingContext.RGB, 
//                    xpos->w, 
//                    xpos->h, 
//                    0, 
//                    RenderingContext.RGB, 
//                    RenderingContext.UNSIGNED_BYTE, 
//                    image
//      );
      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_X, 
                    0, 
                    RenderingContext.RGBA, 
                    RenderingContext.RGBA, // could be RGB
                    RenderingContext.UNSIGNED_BYTE, image);
      num_loaded++;
            if(num_loaded == 6) onloadComplete(skybox);
    } );
    fetch_texture(left_url, (t){}, (t,image){
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
//      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
//                    0, 
//                    RenderingContext.RGB, 
//                    xpos->w, 
//                    xpos->h, 
//                    0, 
//                    RenderingContext.RGB, 
//                    RenderingContext.UNSIGNED_BYTE, 
//                    image
//      );
      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_Y, 
                    0, 
                    RenderingContext.RGBA, 
                    RenderingContext.RGBA, // could be RGB
                    RenderingContext.UNSIGNED_BYTE, image);
      num_loaded++;
            if(num_loaded == 6) onloadComplete(skybox);
    });
    fetch_texture(right_url, (t){}, (t,image){
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
//      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
//                    0, 
//                    RenderingContext.RGB, 
//                    xpos->w, 
//                    xpos->h, 
//                    0, 
//                    RenderingContext.RGB, 
//                    RenderingContext.UNSIGNED_BYTE, 
//                    image
//      );
      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_Y, 
                    0, 
                    RenderingContext.RGBA, 
                    RenderingContext.RGBA, // could be RGB
                    RenderingContext.UNSIGNED_BYTE, image);
      num_loaded++;
            if(num_loaded == 6) onloadComplete(skybox);
    });
    fetch_texture(up_url, (t){}, (t,image){
      gl.bindTexture(RenderingContext.TEXTURE_CUBE_MAP, skybox);
//      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X, 
//                    0, 
//                    RenderingContext.RGB, 
//                    xpos->w, 
//                    xpos->h, 
//                    0, 
//                    RenderingContext.RGB, 
//                    RenderingContext.UNSIGNED_BYTE, 
//                    image
//      );
      gl.texImage2D(RenderingContext.TEXTURE_CUBE_MAP_POSITIVE_Z, 
                    0, 
                    RenderingContext.RGBA, 
                    RenderingContext.RGBA, // could be RGB
                    RenderingContext.UNSIGNED_BYTE, image);
      num_loaded++;
            if(num_loaded == 6) onloadComplete(skybox);
    });
  }

  
}

class cubemap_texture_one extends cubemap
{
  //Texture skybox;
  
  static load(String url, rendering_context gl, OnTextueLoad onloading, OnTextueLoad onloadComplete)
  {
    fetch_texture(url,(skybox)
    {
      onloading(skybox);
    }, 
    (skybox, image)
    {
      bool isPowerOf2 = false;
      
      gl.enable(RenderingContext.TEXTURE_CUBE_MAP);
      gl.bindTexture(RenderingContext.TEXTURE_2D, skybox);
      
      //gl.texImage2D(types[i], 0, GL_RGB, pImage->columns(), pImage->rows(), 0, RenderingContext.RGBA,
      //     RenderingContext.UNSIGNED_BYTE, blob.data());
      gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, RenderingContext.RGBA, 
          RenderingContext.UNSIGNED_BYTE, image);
      
      gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
      gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_MIN_FILTER, isPowerOf2 ? RenderingContext.LINEAR : RenderingContext.LINEAR_MIPMAP_LINEAR);
      gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
      gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE);
      //gl.texParameteri(RenderingContext.TEXTURE_CUBE_MAP, RenderingContext.TEXTURE_WRAP_R, RenderingContext.CLAMP_TO_EDGE);
      if(isPowerOf2) gl.generateMipmap(RenderingContext.TEXTURE_2D);
      onloadComplete(skybox);
    });
  }
}