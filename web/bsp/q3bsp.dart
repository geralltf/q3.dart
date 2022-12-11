part of tech3;

/*TODO: process using different Worker thread. Prroblem Worker needs its own 
  memory and cant clone objects or work off shared data.*/
Worker worker;
void postMessage2(params, replay) 
{
  
  //context['postMessage2'] = postMessage2;
  var type = params['type'];
  
  if(replay != null)
  {
    
    
    if(type == 'worker')
    {
       q3bsp.onMessage(replay);
       _onmessage(replay);
            
       return;
    }
  }
      switch(type) 
      {
          case 'geometry':
            
            //worker.postMessage(params);
            //_onmessage(params);
            //q3bsp.onMessage(params);
          //return;
      }
      
      _onmessage(params);
      q3bsp.onMessage(params);
      
      fetch_update("Plese Wait");
}

void init_worker()
{
  //context["onq3message"]  = onmessage;

//  worker = new Worker('tech3.worker.js');
//  worker.onMessage.listen((params) 
//  {
//    print('message baxck from wokrer');
//    //_onmessage(params);
//    //q3bsp.onMessage(params);
//  });
//  worker.onError.listen((error) {
//    print('[tech3.worker] line: ' + error.lineno.toString() + ', ' + error.message);
//  });
  
  
  //worker.postMessage('hi');
  // Spawn the web worker      ////// note code in bsp_compiler and bsp_parser needs to be in separate worker
   //this.worker = new Worker('js/q3bsp_worker.js');
   //this.worker.onmessage = (msg) {
   //   q3bsp.onMessage(msg);
   //};
   //this.worker.onerror = (msg) {
   //  window.console.error('Line: ' + msg.lineno + ', ' + msg.message);
   //};
  

}

typedef OnEntitiesParsed(Map entities);
typedef OnSurfacesParsed(List<shader_p> surfaces);
/*
 * q3bsp
 */
class q3bsp
{
  static rendering_context gl;
  static var onload = null;
  static OnBspLoadComplete onbsp = null;
  static OnEntitiesParsed onentitiesloaded = null;
  static OnSurfacesParsed onsurfaces = null;
  
  static Map entities;
  static GLBuffer vertexBuffer;
  static GLBuffer indexBuffer;
  
  static int indexCount;
  static GLTexture lightmap;
  static List<shader_p> surfaces;
  static Map<String,shader_gl> shaders;
  static var highlighted;
  
  static List<shader_p> unshadedSurfaces;
  static List<shader_p> defaultSurfaces;
  static List<shader_p> modelSurfaces;
  static List<shader_p> effectSurfaces;
  static q3bsptree bspTree;
  static int startTime;
  static var bgMusic;
  static Timer interval;
  static q3glshader glshading;
  static skybox skybox_env;
  
  q3bsp(rendering_context gl)
  {
    q3bsp.gl = gl;  
    map = this;
    glshading = new q3glshader();
    
    showLoadStatus();
    
     // Map elements
     skybox_env = null;
     
     vertexBuffer = null;
     indexBuffer = null;
     indexCount = 0;
     lightmap = glshading.createSolidTexture(gl, [255,255,255,255]);
     surfaces = null;
     shaders = {};
     
     highlighted = null;
     
     // Sorted draw elements
     unshadedSurfaces = [];
     defaultSurfaces = [];
     modelSurfaces = [];
     effectSurfaces = [];
     
     // BSP Elements
     bspTree = null;
     
     // Effect elements
     startTime = new DateTime.now().millisecondsSinceEpoch;
     bgMusic = null;
  }
  
  highlightShader(name) 
  {
      highlighted = name;
  }
  
  playMusic (play) 
  {
      if(!bgMusic) { return; }
      
      if(play) {
          bgMusic.play();
      } else {
          bgMusic.pause();
      }
  }
  
  static onMessage (msg) 
  {
      //if(msg.data is String) return;
      
      var type = msg['type'];
      switch(type) 
      {
          case 'entities':
              entities = msg['entities'];
              processEntities(entities);
              break;
          case 'geometry':
              bsp_webgl_builders.buildBuffers(msg['vertices'], msg['indices']);
              skybox.buildSkyboxbuffers(gl);
              surfaces = msg['surfaces'];
              bindShaders();
              break;
          case 'lightmap':
              bsp_webgl_builders.buildLightmaps(msg['size'], msg['lightmaps']);
              break;
          case 'shaders':
              bsp_webgl_builders.buildShaders(msg['shaders']);
              break;
          case 'bsp':
              bspTree = new q3bsptree(msg['bsp']);
              if(onbsp != null) 
              {
                  onbsp(bspTree);
              }
              clearLoadStatus();
              break;
          case 'visibility':
              setVisibility(msg['visibleSurfaces']);
              break;
          case 'status':
              onLoadStatus(msg['message']);
              break;
          default:
              throw 'Unexpected message type: ' + msg['type'];
      }
  }
  
  static load (String url, int tesselationLevel) 
  {
      if(tesselationLevel == null) 
      {
          tesselationLevel = 5;
      }
      postMessage2({
          "type": 'load',
          "url": '../' + q3bsp_base_folder + '/' + url,
          "tesselationLevel": tesselationLevel
      },null);
  }
  
  static void loadShaders (List<String> urls) 
  {
      for(var i = 0; i < urls.length; ++i) 
      {
        urls[i] = q3bsp_base_folder + '/' + urls[i];
      }
      
      q3shader.loadList(urls, (List<shader_t> shaders) {
        bsp_webgl_builders.buildShaders(shaders);
      });
  }
  
  static processEntities (Map entities) 
  {
      if(onentitiesloaded != null) 
      {
          onentitiesloaded(entities);
      }
      
      // Background music
      /*if(entities.worldspawn[0].music) {
          this.bgMusic = new Audio(q3bsp_base_folder + '/' + entities.worldspawn[0].music.replace('.wav', '.ogg'));
          // TODO: When can we change this to simply setting the 'loop' property?
          this.bgMusic.addEventListener('ended', function(){
              this.currentTime = 0;
          }, false);
          this.bgMusic.play();
      }*/
      
      // It would be relatively easy to do some ambient sound processing here, but I don't really feel like
      // HTML5 audio is up to the task. For example, lack of reliable gapless looping makes them sound terrible!
      // Look into this more when browsers get with the program.
      /*var speakers = entities.target_speaker;
      for(var i = 0; i < 1; ++i) {
          var speaker = speakers[i];
          q3bspCreateSpeaker(speaker);
      }*/
  }
  
  static q3bspCreateSpeaker(speaker) 
  {
      //speaker.audio = new Audio(q3bsp_base_folder + '/' + speaker.noise.replace('.wav', '.ogg'));
      
      // TODO: When can we change this to simply setting the 'loop' property?
      //speaker.audio.addEventListener('ended', (){
      //    this.currentTime = 0;
      //}, false);
      //speaker.audio.play();
  }
  

  
  static void bindShaders () 
  {
      if(surfaces == null) { return; }
      
      if(onsurfaces != null) {
          onsurfaces(surfaces);
      }
      
      for(var i = 0; i < surfaces.length; ++i) 
      {
          shader_p surface = surfaces[i];
          
          if(surface.elementCount == 0 || surface.shader != null || surface.shaderName == 'noshader') { continue; }
          
          unshadedSurfaces.add(surface);
      }
      
      /* FAST dirty async code */
      interval = new Timer.periodic(const Duration(milliseconds: 1), (event) 
      {
        if(unshadedSurfaces.length == 0) { // Have we processed all surfaces?
            // Sort to ensure correct order of transparent objects
            effectSurfaces.sort((shader_p a, shader_p b) {
                int order = a.shader.sort - b.shader.sort;
                // TODO: Sort by state here to cut down on changes?
                return order; //(order == 0 ? 1 : order);
            });
            
            interval.cancel(); //clearInterval(interval);
            return;
        }
    
        shader_p surface = unshadedSurfaces.removeAt(0); // var surface = unshadedSurfaces.shift();
        
        String shader_name = surface.shaderName;
        //shader_name = shader_name.startsWith('"')?shader_name.substring(1):shader_name; // BUG
        shader_gl shader = q3bsp.shaders[shader_name];
        
        //shader_gl skyshader = q3bsp.shaders['textures/atcs/skybox_s'];
        
        
        if(shader == null) 
        {
            surface.shader = glshading.buildDefault(gl, surface);
            if(surface.geomType == 3) 
            {
                surface.shader.model = true;
                modelSurfaces.add(surface);
            } 
            else 
            {
                defaultSurfaces.add(surface);
            }
        } 
        else 
        {
            surface.shader = shader;
            if(shader.sky == true) 
            {
                skybox.skyShader = shader; // Sky does not get pushed into effectSurfaces. It's a separate pass
            } 
            else 
            {
                effectSurfaces.add(surface);
            }
            glshading.loadShaderMaps(gl, surface, shader);
        }
    });
      
    interval = new Timer.periodic(const Duration(seconds: 10), (event){}); //var interval = setInterval(() , 10);
  }
  
  // Update which portions of the map are visible based on position
  
  static updateVisibility (pos) 
  {
   postMessage2({
       "type": 'visibility',
       "pos": pos
   },null);
  }
  
  static setVisibility (List visibilityList) 
  {
     if(surfaces.length > 0) 
     {
         for(var i = 0; i < surfaces.length; ++i) 
         {
             surfaces[i].visible = (visibilityList[i] == true);
         }
     }
  }
  


  static void setViewport (Viewport viewport) 
  {
   if (viewport != null) 
   {
     if(viewport.x == null) viewport.x = 0.0;
     if(viewport.y == null) viewport.y = 0.0;
     if(viewport.width == null) viewport.width = 0.0;
     if(viewport.height == null) viewport.height = 0.0;
     
     gl.viewport(viewport.x.toInt(), viewport.y.toInt(), 
           viewport.width.toInt(), viewport.height.toInt());
   }
  }
  
  static void draw (Matrix4 leftViewMat, Matrix4 leftProjMat, Viewport leftViewport, 
                    Matrix4 rightViewMat, Matrix4 rightProjMat, Viewport rightViewport) 
  {
     if(vertexBuffer == null || indexBuffer == null) { return; } // Not ready to draw yet
     
     // Seconds passed since map was initialized
     double time = (new DateTime.now().millisecondsSinceEpoch - startTime)/1000.0;
     int i = 0;
     
     if(skybox_env != null)
     {
       skybox_env.render(gl,time);
     }
  
     // Loop through all shaders, drawing all surfaces associated with them
     if(surfaces.length > 0) 
     {
        render_default_surfaces(leftViewMat, leftProjMat, leftViewport, rightViewMat, rightProjMat, rightViewport, time);
  
    
         // Model shader surfaces (can bind shader once and draw all of them very quickly)
         if(modelSurfaces.length > 0) 
         {
           render_model_surfaces(leftViewMat, leftProjMat, leftViewport, rightViewMat, rightProjMat, rightViewport, time);
         }
         
         render_effect_surfaces(leftViewMat, leftProjMat, leftViewport, rightViewMat, rightProjMat, rightViewport, time);
     }
     
     render_models(leftViewMat, leftProjMat, leftViewport, rightViewMat, rightProjMat, rightViewport, time);
  }
  
  
 
  
  static void render_models (Matrix4 leftViewMat, Matrix4 leftProjMat, Viewport leftViewport, 
                    Matrix4 rightViewMat, Matrix4 rightProjMat, Viewport rightViewport, double time) 
  {
    // barrel
    //model.drawModel(shader, frame, Mat4_ModelView, Mat4_ModelWorld);
    
    
    //drawModel(gl, player_1, q3_shader, q3_frame_IDX, [0, +50, 0] );
  }
  
  static void render_default_surfaces (Matrix4 leftViewMat, Matrix4 leftProjMat, Viewport leftViewport, 
                    Matrix4 rightViewMat, Matrix4 rightProjMat, Viewport rightViewport, double time) 
  {
    // Map Geometry buffers
    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, vertexBuffer);
    
    // Default shader surfaces (can bind shader once and draw all of them very quickly)
    if(defaultSurfaces.length > 0 || unshadedSurfaces.length > 0) 
    {
        // Setup State
        shader_gl shader = glshading.defaultShader;
        glshading.setShader(gl, shader);
        stage_gl stage = shader.stages[0];
        shader_prog_t shaderProgram = glshading.setShaderStage(gl, shader, stage, time);
        bsp_webgl_binders.bindShaderAttribs(shaderProgram);

        gl.activeTexture(RenderingContext.TEXTURE0);
        gl.bindTexture(RenderingContext.TEXTURE_2D, glshading.defaultTexture);

        bsp_webgl_binders.bindShaderMatrix(shaderProgram, leftViewMat, leftProjMat);
        setViewport(leftViewport);
        int i;
        
        for(i = 0; i < unshadedSurfaces.length; ++i) {
            var surface = unshadedSurfaces[i];
            gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
        }
        for(i = 0; i < defaultSurfaces.length; ++i) {
            var surface = defaultSurfaces[i];
            var stage = surface.shader.stages[0];
            gl.bindTexture(RenderingContext.TEXTURE_2D, stage.texture);
            gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
        }

        if (rightViewMat != null) {
            gl.activeTexture(RenderingContext.TEXTURE0);
            gl.bindTexture(RenderingContext.TEXTURE_2D, glshading.defaultTexture);

            bsp_webgl_binders.bindShaderMatrix(shaderProgram, rightViewMat, rightProjMat);
            setViewport(rightViewport);
            for(i = 0; i < unshadedSurfaces.length; ++i) 
            {
               shader_p surface = unshadedSurfaces[i];
                gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
            }

            for(i = 0; i < defaultSurfaces.length; ++i) 
            {
               shader_p surface = defaultSurfaces[i];
                stage_gl stage = surface.shader.stages[0];
                gl.bindTexture(RenderingContext.TEXTURE_2D, stage.texture);
                gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
            }
        }
    }
  }
  
  static void render_effect_surfaces (Matrix4 leftViewMat, Matrix4 leftProjMat, Viewport leftViewport, 
                    Matrix4 rightViewMat, Matrix4 rightProjMat, Viewport rightViewport, double time) 
  {
    // Effect surfaces
    for(var i = 0; i < effectSurfaces.length; ++i) {
        var surface = effectSurfaces[i];
        if(surface.elementCount == 0 || surface.visible != true) { continue; }
        
        // Bind the surface shader
        shader_gl shader = surface.shader;
        
        if(highlighted != null && highlighted == surface.shaderName) 
        {
            shader = glshading.defaultShader;
        }
        
        if(!glshading.setShader(gl, shader)) { continue; }
        
        for(var j = 0; j < shader.stages.length; ++j) 
        {
            stage_gl stage = shader.stages[j];
            
            var shaderProgram = glshading.setShaderStage(gl, shader, stage, time);
            if(shaderProgram==null) { continue; }
            bsp_webgl_binders.bindShaderAttribs(shaderProgram);
            bsp_webgl_binders.bindShaderMatrix(shaderProgram, leftViewMat, leftProjMat);
            setViewport(leftViewport);
            // Draw all geometry that uses this textures
            gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);

            if (rightViewMat != null) {
              bsp_webgl_binders.bindShaderMatrix(shaderProgram, rightViewMat, rightProjMat);
                setViewport(rightViewport);
                // Draw all geometry that uses this textures
                gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
            }
        }
    }
  }
  static void render_model_surfaces (Matrix4 leftViewMat, Matrix4 leftProjMat, Viewport leftViewport, 
                    Matrix4 rightViewMat, Matrix4 rightProjMat, Viewport rightViewport, double time) 
  {
    // Setup State
    shader_gl shader = modelSurfaces[0].shader;
    glshading.setShader(gl, shader);
    stage_gl stage = shader.stages[0];
    shader_prog_t shaderProgram = glshading.setShaderStage(gl, shader, stage, time);
    bsp_webgl_binders.bindShaderAttribs(shaderProgram);
    gl.activeTexture(RenderingContext.TEXTURE0);

    bsp_webgl_binders.bindShaderMatrix(shaderProgram, leftViewMat, leftProjMat);
    setViewport(leftViewport);
    for(int i = 0; i < modelSurfaces.length; ++i) 
    {
        var surface = modelSurfaces[i];
        stage_gl stage = surface.shader.stages[0];
        gl.bindTexture(RenderingContext.TEXTURE_2D, stage.texture);
        gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
    }

    if (rightViewMat != null) {
       bsp_webgl_binders.bindShaderMatrix(shaderProgram, rightViewMat, rightProjMat);
        setViewport(rightViewport);
        for(int i = 0; i < modelSurfaces.length; ++i) 
        {
            var surface = modelSurfaces[i];
            stage_gl stage = surface.shader.stages[0];
            gl.bindTexture(RenderingContext.TEXTURE_2D, stage.texture);
            gl.drawElements(RenderingContext.TRIANGLES, surface.elementCount, RenderingContext.UNSIGNED_SHORT, surface.indexOffset);
        }
    }
  }
  

}