part of tech3;

/*
 * q3glshader.js - Transforms a parsed Q3 shader definition into a set of WebGL compatible states
 */

class q3glshader
{
  GLTexture white;
  shader_gl defaultShader;
  GLTexture defaultTexture, defaultTextureRed;
  Matrix4 texMat;
  shader_prog_t defaultProgram;
  shader_prog_t modelProgram;
  bool shader_source_tracing = false;
  
  q3glshader()
  {
    white = null;
    defaultShader = null;
    defaultTexture = null;
    texMat = new Matrix4.identity(); // mat4.create()
    defaultProgram = null;
  }
  
  init (rendering_context gl) 
  {
      white = createSolidTexture(gl, [255, 255, 255, 255]);
      //white = createSolidTexture(gl, [0,0,0,255]);
      
      defaultProgram = compileShaderProgram(gl, q3bsp_default_vertex, q3bsp_default_fragment);
      modelProgram = compileShaderProgram(gl, q3bsp_default_vertex, q3bsp_model_fragment); 

      
      // Load default texture
      fetch_texture(q3bsp_no_shader_default_texture_url, (GLTexture defau)
      {
        defaultTexture = defau;
      }, 
      (GLTexture defau, image)
      {
        bool isPowerOf2 = false;
        
        gl.bindTexture(RenderingContext.TEXTURE_2D, defau);
        gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, image);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, isPowerOf2 ? RenderingContext.LINEAR_MIPMAP_NEAREST : RenderingContext.LINEAR );
        if(isPowerOf2) gl.generateMipmap(RenderingContext.TEXTURE_2D);
      });
      fetch_texture(q3bsp_no_shader_default_texture_url2, (GLTexture defau)
      {
        defaultTextureRed = defau;
      }, 
      (GLTexture defau, image)
      {
        bool isPowerOf2 = false;
        
        gl.bindTexture(RenderingContext.TEXTURE_2D, defau);
        gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, image);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, isPowerOf2 ? RenderingContext.LINEAR_MIPMAP_NEAREST : RenderingContext.LINEAR );
        if(isPowerOf2) gl.generateMipmap(RenderingContext.TEXTURE_2D);
      });
      // Load default stage
      defaultShader = buildDefault(gl,null);
  }
  
  //
  // Shader building
  //
  shader_gl build (rendering_context gl, shader_t shader, shader_p surface) 
  {
    if(shader==null) return null;
    
      shader_gl glShader = new shader_gl();
      glShader.cull =  translateCull(gl, shader.cull);
      glShader.sort= shader.sort;
      glShader.sky = shader.sky;
      glShader.blend= shader.blend;
      glShader.name= shader.name;
      glShader.sky_env_map= shader.sky_env_map;
      glShader.stages= [];
      
      for(var j = 0; j < shader.stages.length; ++j) 
      {
          stage_t t = shader.stages[j];
          stage_gl s = new stage_gl();
          
          s.animFrame = t.animFrame;
          s.animFreq = t.animFreq;
          s.animMaps=t.animMaps;
          s.animTexture=t.animTexture;
          s.blendDest=t.blendDest;
          s.blendSrc=t.blendSrc;
          s.texture = null;
          s.blendSrc = translateBlend(gl, t.blendSrc);
          s.blendDest = translateBlend(gl, t.blendDest);
          s.depthFunc = translateDepthFunc(gl, t.depthFunc);
          s.map = t.map;
          s.tcMods = t.tcMods;

          s.depthWrite = t.depthWrite;
          s.isLightmap = t.isLightmap;
          s.shaderSrc = t.shaderSrc;
          s.clamp = t.clamp;
          s.tcGen = t.tcGen;
          s.rgbGen  = t.rgbGen;
          s.rgbWaveform  = t.rgbWaveform;
          s.alphaGen  = t.alphaGen;
          s.alphaFunc  = t.alphaFunc;
          s.alphaWaveform  = t.alphaWaveform;
          s.hasBlendFunc  = t.hasBlendFunc;
          s.depthWriteOverride  = t.depthWriteOverride;
          s.blend  = t.blend;
          s.opaque  = t.opaque;
          
          glShader.stages.add(s);
      }
      
      return glShader;
  }
  
  shader_gl buildDefault (rendering_context gl, shader_p surface) 
  {
      stage_gl diffuseStage = new stage_gl();
      diffuseStage.map = (surface != null ? surface.shaderName + '.jpg' : null);
      diffuseStage.isLightmap = false;
      diffuseStage.blendSrc = RenderingContext.ONE;
      diffuseStage.blendDest = RenderingContext.ZERO;
      diffuseStage.depthFunc = RenderingContext.LEQUAL;
      diffuseStage.depthWrite = true;
      
      shader_gl glShader = new shader_gl();
      glShader.cull = RenderingContext.FRONT;
      glShader.blend = false;
      glShader.sort = 3;
      glShader.stages = [ diffuseStage ];
      glShader.sky = false;
      
      if(surface != null) 
      {
          loadTexture(gl, glShader, surface, diffuseStage);
      } 
      else 
      {
          diffuseStage.texture = defaultTexture;
      }
      
      return glShader;
  }
  
  int translateDepthFunc (rendering_context gl, String depth) 
  {
      if(depth == null) { return RenderingContext.LEQUAL; }
      switch(depth.toLowerCase()) {
          case 'gequal': return RenderingContext.GEQUAL;
          case 'lequal': return RenderingContext.LEQUAL;
          case 'equal': return RenderingContext.EQUAL;
          case 'greater': return RenderingContext.GREATER;
          case 'less': return RenderingContext.LESS;
          default: return RenderingContext.LEQUAL;
      }
  }
  
  int translateCull (rendering_context gl, String cull) {
      if(cull == null) { return RenderingContext.FRONT; }
      switch(cull.toLowerCase()) {
          case 'disable':
          case 'none': return null;
          case 'front': return RenderingContext.BACK;
          case 'back':
          default: return RenderingContext.FRONT;
      }
  }
  
  int translateBlend (rendering_context gl, String blend) {
      if(blend == null) { return RenderingContext.ONE; }
      switch(blend.toUpperCase()) {
          case 'GL_ONE': return RenderingContext.ONE;
          case 'GL_ZERO': return RenderingContext.ZERO;
          case 'GL_DST_COLOR': return RenderingContext.DST_COLOR;
          case 'GL_ONE_MINUS_DST_COLOR': return RenderingContext.ONE_MINUS_DST_COLOR;
          case 'GL_SRC_ALPHA ': return RenderingContext.SRC_ALPHA;
          case 'GL_ONE_MINUS_SRC_ALPHA': return RenderingContext.ONE_MINUS_SRC_ALPHA;
          case 'GL_SRC_COLOR': return RenderingContext.SRC_COLOR;
          case 'GL_ONE_MINUS_SRC_COLOR': return RenderingContext.ONE_MINUS_SRC_COLOR;
          default: return RenderingContext.ONE;
      }
  }
  
  //
  // Texture loading
  //

  void loadShaderMaps (rendering_context gl, shader_p surface, shader_gl shader) 
  {    
    if(shader.sky == true)
    {
        q3bsp.skybox_env = skybox.loadFromShader(gl, surface, shader);
    }    
    for(var i = 0; i < shader.stages.length; ++i) 
    {
        stage_gl stage = shader.stages[i];
        if(stage.map != null)
        {
          loadTexture(gl, shader, surface, stage);  
        }
        if(stage.shaderSrc != null && stage.program == null) 
        {
            fetch_update("Compiling " + shader.name);
            stage.program = compileShaderProgram(gl, stage.shaderSrc.vertex.source_code, 
                                                     stage.shaderSrc.fragment.source_code);
        }
    }
  }

  void loadTexture (rendering_context gl, shader_gl shader, shader_p surface, stage_gl stage) 
  {
    if(shader.name=='textures/atcs/skybox_s')
            {
              var aaa =1;
            }
      if(stage.map == null) {
          stage.texture = white;
          return;
      } 
      else if(stage.map == '\$lightmap') {
          stage.texture = (surface.geomType != 3 ? q3bsp.lightmap : white);
          return;
      } 
      else if(stage.map == '\$whiteimage') {
          stage.texture = white;
          return;
      }
      
      stage.texture = defaultTexture;
      
      if(stage.map == 'anim') {
          stage.animTexture = [];
          for(int i = 0; i < stage.animMaps.length; ++i) 
          {
              var animLoad = (int i) 
              {
                  if(i > stage.animTexture.length-1)
                  {
                    stage.animTexture.add(defaultTexture);
                  }
                  String url = q3bsp_base_folder + '/' + stage.animMaps[i];
                  loadTextureUrl(gl, stage, url, (GLTexture texture) 
                  {
                    stage.animTexture.insert(i, texture);
                  });
              };
              animLoad(i);
          }
          stage.animFrame = 0;
      } 
      else 
      {
        
        
        //if(shader.sky == false)
        //{
          String url = q3bsp_base_folder + '/' + stage.map;
          loadTextureUrl(gl, stage, url, (GLTexture texture) {
              stage.texture = texture;
          });
        //}
      }
  }
  
  void loadTextureUrl (rendering_context gl, stage_gl stage, String url, OnTextueLoad onload) 
  {
      fetch_texture(url,(GLTexture texture)
      {
        onload(texture);
      },
      (GLTexture texture, image)
      {
        bool isPowerOf2 = false;
        
        gl.bindTexture(RenderingContext.TEXTURE_2D, texture);
        gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, image);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, isPowerOf2 ? RenderingContext.LINEAR_MIPMAP_NEAREST : RenderingContext.LINEAR);
        if(stage.clamp==true) 
        {
            gl.texParameterf(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE );
            gl.texParameterf(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE );
        }
        if(isPowerOf2) gl.generateMipmap(RenderingContext.TEXTURE_2D);

        onload(texture);
      });
      
  }

  GLTexture createSolidTexture (rendering_context gl, color) 
  {
      Uint8List data = new Uint8List(color.length);
      data.setAll(0, color);
      
      GLTexture texture = gl.createTexture();
      gl.bindTexture(RenderingContext.TEXTURE_2D, texture);
      gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGB, 1, 1, 0, RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, data);
      gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.NEAREST);
      gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.NEAREST);
      gl.bindTexture(RenderingContext.TEXTURE_2D, null);
      return texture;
  }

  //
  // Render state setup
  //

  bool setShader (rendering_context gl, shader_gl shader) {
      if(shader == null) {
          gl.enable(RenderingContext.CULL_FACE);
          gl.cullFace(RenderingContext.BACK);
      } 
      else if(shader.cull !=null && shader.sky == false) {
          gl.enable(RenderingContext.CULL_FACE);
          gl.cullFace(shader.cull);
      } 
      else {
          gl.disable(RenderingContext.CULL_FACE);
      }
      
      return true;
  }

  setShaderStage (rendering_context gl, shader_gl shader, stage_gl shaderStage, time) 
  {
      stage_gl stage = shaderStage;
      if(stage == null) 
      {
          stage = defaultShader.stages[0];
      }
      
      if(stage.animFreq != null && stage.animFreq != 0) 
      {
          // Texture animation seems like a natural place for setInterval, but that approach has proved error prone. 
          // It can easily get out of sync with other effects (like rgbGen pulses and whatnot) which can give a 
          // jittery or flat out wrong appearance. Doing it this way ensures all effects are synced.
          num ff = time*stage.animFreq;
          
          //var animFrame = ff.floor() % stage.animTexture.length;
          stage.texture = stage.animTexture[stage.animFrame]; // stage.animTexture.animFrame;
      }
      
      gl.blendFunc(stage.blendSrc, stage.blendDest);
      
      if(stage.depthWrite == true && shader.sky == false) 
      {
          gl.depthMask(true);
      } 
      else 
      {
          gl.depthMask(false);
      }
      
      gl.depthFunc(stage.depthFunc);
      
      shader_prog_t program = stage.program;
      GLProgram prog = program != null ? program.program : null;
      
      if(prog == null) 
      { 
          if(shader.model==true) 
          {
            program = modelProgram;
            prog = program.program;
          } 
          else 
          {
            program = defaultProgram;
            prog = program.program;
          }
      }
      
      gl.useProgram(prog);
      
      if(shader.sky == true)
      {
        //q3bsp.skybox_env.bindSkyTexture(gl, stage, program, time);
        var a = 3;
        
      }
      else
      {
        var texture = stage.texture;
        if(texture == null) texture = defaultTexture;
        
        gl.activeTexture(RenderingContext.TEXTURE0);
        gl.uniform1i(program.uniform['texture'], 0);
        gl.bindTexture(RenderingContext.TEXTURE_2D, texture);
      }
      
      if(program.uniform['lightmap']!=null) 
      {
          gl.activeTexture(RenderingContext.TEXTURE1);
          gl.uniform1i(program.uniform['lightmap'], 1);
          gl.bindTexture(RenderingContext.TEXTURE_2D, q3bsp.lightmap);
      }
      
      if(program.uniform['time']!=null) 
      {
          gl.uniform1f(program.uniform['time'], time);
      }
      
      return program;
  }

  //
  // Shader program compilation
  //

  shader_prog_t compileShaderProgram (rendering_context gl, String vertexSrc, String fragmentSrc) 
  {
      GLShader fragmentShader = gl.createShader(RenderingContext.FRAGMENT_SHADER);
      gl.shaderSource(fragmentShader, fragmentSrc);
      gl.compileShader(fragmentShader);

      var xf = gl.getShaderParameter(fragmentShader, RenderingContext.COMPILE_STATUS); 
      
      if (!(xf != null && xf == true)) 
      {
          String si = gl.getShaderInfoLog(fragmentShader);
          si = si == null ? '' : si;
          
          print('[shader-exception] fragment compilation error ' + si);
          if(shader_source_tracing)
          {
            print('[shader].[begin]');
            print(vertexSrc);
            print('[shader].[end]');
            print('[shader].[begin]');
            print(fragmentSrc);
            print('[shader].[end]');
          }
          gl.deleteShader(fragmentShader);
          return null;
      }
      
      GLShader vertexShader = gl.createShader(RenderingContext.VERTEX_SHADER);
      gl.shaderSource(vertexShader, vertexSrc);
      gl.compileShader(vertexShader);
      
      var xv = gl.getShaderParameter(vertexShader, RenderingContext.COMPILE_STATUS);
      
      if (!(xv != null && xv == true)) 
      {
          String si = gl.getShaderInfoLog(vertexShader);
          si = si == null ? '' : si;
          
          print('[shader-exception] vertex compilation error: ' + si);
          if(shader_source_tracing)
          {
            print('[shader].[begin]');
            print(vertexSrc);
            print('[shader].[end]');
            print('[shader].[begin]');
            print(fragmentSrc);
            print('[shader].[end]');
          }
          gl.deleteShader(vertexShader);
          return null;
      }
      
      GLProgram shaderProgram = gl.createProgram();
      gl.attachShader(shaderProgram, vertexShader);
      gl.attachShader(shaderProgram, fragmentShader);
      gl.linkProgram(shaderProgram);

      var xp = gl.getProgramParameter(shaderProgram, RenderingContext.LINK_STATUS);
      
      if (!(xp != null && xp == true)) 
      {
          gl.deleteProgram(shaderProgram);
          gl.deleteShader(vertexShader);
          gl.deleteShader(fragmentShader);
          
          print('[shader-exception] Could not link shaders. Check if there are any additional errors.');
          /*
          console.debug(vertexSrc);
          console.debug(fragmentSrc);*/
          return null;
      }
      
      shader_prog_t shader_prog = new shader_prog_t();
      shader_prog.program = shaderProgram;
      shader_prog.attrib = {};
      shader_prog.uniform = {};
      
      var i;
      GLActiveInfo attrib; 
      GLActiveInfo uniform; 
      int attribCount;
      int uniformCount;
      
      attribCount = gl.getProgramParameter(shaderProgram, RenderingContext.ACTIVE_ATTRIBUTES);
      
      for (i = 0; i < attribCount; i++) 
      {
          attrib = gl.getActiveAttrib(shaderProgram, i);
          
          shader_prog.attrib[attrib.name] = gl.getAttribLocation(shaderProgram, attrib.name);
      }

      uniformCount = gl.getProgramParameter(shaderProgram, RenderingContext.ACTIVE_UNIFORMS);
      shader_prog.uniform = {};
      
      for (i = 0; i < uniformCount; i++) 
      {
          uniform = gl.getActiveUniform(shaderProgram, i);
          
          shader_prog.uniform[uniform.name] = gl.getUniformLocation(shaderProgram, uniform.name);
      }

      return shader_prog;
  }
}