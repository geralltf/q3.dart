part of tech3;

typedef OnShadersParsed(List<shader_t> shaders);

//
// Shader Loading
//s
class q3shader
{
  static loadList(List<String> urls, OnShadersParsed onload) 
  {
      for(var i = 0; i < urls.length; ++i) {
          q3shader.load(urls[i], onload);
      }
  }
  
  static load (String url, OnShadersParsed onload) 
  {
    fetch(url, 'text/plain').then((request)
    {
      q3shader.parse(url, request.responseText, onload);
    });
  }
  
  static parse (String url, String src, OnShadersParsed onload) 
  {
      List<shader_t> shaders = new List<shader_t>();
      
      shaderTokenizer tokens = new shaderTokenizer(src);
      
      // Parse a shader
      while(!tokens.EOF()) 
      {
          String name = tokens.next();
          shader_t shader = q3shader.parseShader(name, tokens);
          if(shader != null) 
          {
              shader.url = url;
              
              if(shader.stages != null) 
              {
                  for(var i = 0; i < shader.stages.length; ++i) 
                  {
                      // Build a WebGL shader program out of the stage parameters set here
                      shader.stages[i].shaderSrc = q3shader.buildShaderSource(shader, shader.stages[i]);
                  }
              }
          }
          shaders.add(shader);
      }
      
      // Send shaders to gl Thread
      onload(shaders);
  }
  

  
  static shader_t parseShader (String name, shaderTokenizer tokens) 
  {
      String brace = tokens.next();
      if(brace != '{') 
      {
          return null;
      }
      
      shader_t shader = new shader_t();
      shader.name = name;

      // Parse a shader
      while(!tokens.EOF()) 
      {
          String token = tokens.next().toLowerCase();
          if(token == '}') { break; }
          
          switch (token) 
          {
              case '{': 
              {                
                  stage_t stage = q3shader.parseStage(tokens);
                  
                  // I really really really don't like doing this, which basically just forces lightmaps to use the 'filter' blendmode
                  // but if I don't a lot of textures end up looking too bright. I'm sure I'm jsut missing something, and this shouldn't
                  // be needed.
                  if(stage.isLightmap == true && (stage.hasBlendFunc == true)) 
                  {
                      stage.blendSrc = 'GL_DST_COLOR';
                      stage.blendDest = 'GL_ZERO';
                  }
                  
                  // I'm having a ton of trouble getting lightingSpecular to work properly,
                  // so this little hack gets it looking right till I can figure out the problem
                  if(stage.alphaGen == 'lightingspecular') 
                  {
                      stage.blendSrc = 'GL_ONE';
                      stage.blendDest = 'GL_ZERO';
                      stage.hasBlendFunc = false;
                      stage.depthWrite = true;
                      shader.stages = [];
                  }
                  
                  if(stage.hasBlendFunc == true) 
                  { 
                    shader.blend = true; 
                  } 
                  else 
                  { 
                    shader.opaque = true; 
                  }
                  
                  shader.stages.add(stage);
              } break;
              
              case 'cull':
                  shader.cull = tokens.next();
                  break;
                  
              case 'deformvertexes':
                  deform_t deform = new deform_t();
                  deform.type = tokens.next().toLowerCase();
                  
                  switch(deform.type) 
                  {
                      case 'wave':
                          deform.spread = 1.0 / double.parse(tokens.next());
                          deform.waveform = q3shader.parseWaveform(tokens);
                          break;
                      default: deform = null; break;
                  }
                  
                  if(deform != null) 
                  { 
                    shader.vertexDeforms.add(deform); 
                  }
                  break;
                  
              case 'sort':
                  String sort = tokens.next().toLowerCase();
                  
                  switch(sort) 
                  {
                      case 'portal': shader.sort = 1; break;
                      case 'sky': shader.sort = 2; break;
                      case 'opaque': shader.sort = 3; break;
                      case 'banner': shader.sort = 6; break;
                      case 'underwater': shader.sort = 8; break;
                      case 'additive': shader.sort = 9; break;
                      case 'nearest': shader.sort = 16; break;
                      default: shader.sort = int.parse(sort); break; 
                  };
                  break;
                  
              case 'surfaceparm':
                  String param = tokens.next().toLowerCase();
                  
                  switch(param) 
                  {
                      case 'sky':
                          shader.sky = true;
                          break;
                      default: break;
                  }
                  break;
              case 'skyparms':
                String param = tokens.next().toLowerCase();
                
                shader.sky_env_map = new sky_env_map_p(param);;
                
                break;
              default: break;
          }
      }
      
      if(shader.sort == null || shader.sort == 0)
      {
        shader.sort = (shader.opaque ? 3 : 9);
      }
      //if(!shader['sort']) {
        //shader['sort'] = (shader['opaque'] ? 3 : 9);
      //}
      
      return shader;
  }
  
  static stage_t parseStage (shaderTokenizer tokens) 
  {
      stage_t stage = new stage_t();
      
      // Parse a shader
      while(!tokens.EOF()) 
      {
          String token = tokens.next();
          if(token == '}') { break; }
          
          switch(token.toLowerCase()) 
          {
              case 'clampmap':
                  stage.clamp = true;
                  break;
              case 'map':
                  String map;
                  map = tokens.next();
                  if(!preserve_tga_images)
                  {
                    map = map.replaceAll(new RegExp(r'(\.jpg|\.tga)'), '.jpg');
                  }
                  stage.map = map;
                  //stage.map = tokens.next().replaceAll(/(\.jpg|\.tga)/, '.jpg');
                  break;
                  
              case 'animmap':
                  stage.map = 'anim';
                  stage.animFreq = double.parse(tokens.next());
                  String nextMap = tokens.next();
                  
                  while(nextMap.contains(new RegExp(r'(\.jpg|\.tga)'))) //while(nextMap.match(/(\.jpg|\.tga)/)) 
                  {
                    String map;
                    map = nextMap;
                    if(!preserve_tga_images)
                    {
                      map = nextMap.replaceAll(new RegExp(r'(\.jpg|\.tga)'), '.jpg');
                    }
                    //
                    
                    stage.animMaps.add(map);
                    //stage.animMaps.push(nextMap.replace(/(\.jpg|\.tga)/, '.jpg'));
                    nextMap = tokens.next();
                  }
                  tokens.prev();
                  break;
                  
              case 'rgbgen':
                  stage.rgbGen = tokens.next().toLowerCase();;
                  switch(stage.rgbGen) {
                      case 'wave':
                          stage.rgbWaveform = q3shader.parseWaveform(tokens);
                          if(stage.rgbWaveform==null) { stage.rgbGen == 'identity'; }
                          break;
                  };
                  break;
                  
              case 'alphagen':
                  stage.alphaGen = tokens.next().toLowerCase();
                  switch(stage.alphaGen) {
                      case 'wave':
                          stage.alphaWaveform = q3shader.parseWaveform(tokens);
                          if(stage.alphaWaveform==null) { stage.alphaGen == '1.0'; }
                          break;
                      default: break;
                  };
                  break;
                  
              case 'alphafunc':
                  stage.alphaFunc = tokens.next().toUpperCase();
                  break;
                  
              case 'blendfunc':
                  stage.blendSrc = tokens.next();
                  stage.hasBlendFunc = true;
                  if(stage.depthWriteOverride==null) {
                      stage.depthWrite = false;
                  }
                  switch(stage.blendSrc) {
                      case 'add':
                          stage.blendSrc = 'GL_ONE';
                          stage.blendDest = 'GL_ONE';
                          break;
                          
                      case 'blend':
                          stage.blendSrc = 'GL_SRC_ALPHA';
                          stage.blendDest = 'GL_ONE_MINUS_SRC_ALPHA';
                          break;
                          
                      case 'filter':
                          stage.blendSrc = 'GL_DST_COLOR';
                          stage.blendDest = 'GL_ZERO';
                          break;
                          
                      default:
                          stage.blendDest = tokens.next();
                          break;
                  }
                  break;
                  
              case 'depthfunc':
                  stage.depthFunc = tokens.next().toLowerCase();
                  break;
                  
              case 'depthwrite':
                  stage.depthWrite = true;
                  stage.depthWriteOverride = true;
                  break;
                  
              case 'tcmod':
                  tcMod_t tcMod = new tcMod_t();
                  tcMod.type = tokens.next().toLowerCase();
                  
                  switch(tcMod.type) {
                      case 'rotate': 
                          tcMod.angle = double.parse(tokens.next()) * (PI / 180);
                          break;
                      case 'scale':
                          tcMod.scaleX = double.parse(tokens.next());
                          tcMod.scaleY = double.parse(tokens.next());
                          break;
                      case 'scroll':
                          tcMod.sSpeed = double.parse(tokens.next());
                          tcMod.tSpeed = double.parse(tokens.next());
                          break;
                      case 'stretch':
                          tcMod.waveform = q3shader.parseWaveform(tokens);
                          if(tcMod.waveform == null) { tcMod.type == null; }
                          break;
                      case 'turb':
                          tcMod.turbulance = new turbulance_t();
                          tcMod.turbulance.base = double.parse(tokens.next());
                          tcMod.turbulance.amp = double.parse(tokens.next());
                          tcMod.turbulance.phase = double.parse(tokens.next());
                          tcMod.turbulance.freq = double.parse(tokens.next());
                          break;
                      default: tcMod.type == null; break;
                  }
                  if(tcMod.type!=null) 
                  {
                      stage.tcMods.add(tcMod);
                  }
                  break;
              case 'tcgen':
                  stage.tcGen = tokens.next();
                  break;
              default: break;
          }
      }
      
      if(stage.blendSrc == 'GL_ONE' && stage.blendDest == 'GL_ZERO') 
      {
          stage.hasBlendFunc = false;
          stage.depthWrite = true;
      }
      
      stage.isLightmap = stage.map == "\$lightmap";
      
      return stage;
  }
  
  static waveform_t parseWaveform (shaderTokenizer tokens) 
  {
    waveform_t waveform = new waveform_t();
    waveform.funcName = tokens.next().toLowerCase();
    waveform.base = double.parse(tokens.next());
    waveform.amp = double.parse(tokens.next());
    waveform.phase = double.parse(tokens.next());
    waveform.freq = double.parse(tokens.next());
    return waveform;
  }
  
  //
  // WebGL Shader creation
  //

  // This whole section is a bit ugly, but it gets the job done. The job, in this case, is translating
  // Quake 3 shaders into GLSL shader programs. We should probably be doing a bit more normalization here.

  static shader_src_t buildShaderSource(shader_t shader, stage_t stage) 
  {
      shader_src_t src = new shader_src_t();
      src.vertex = q3shader.buildVertexShader(shader, stage);
      src.fragment = q3shader.buildFragmentShader(shader, stage);
      return src;
  }
  
  static vertex_shader_src_t buildVertexShader (shader_t stageShader, stage_t stage) 
  {
      shaderBuilder shader = new shaderBuilder();
      
      shader.addAttribs({
          "position": 'vec3',
          "normal": 'vec3',
          "color": 'vec4',
      });
      
      shader.addVaryings({
          "vTexCoord": 'vec2',
          "vColor": 'vec4',
      });
      
      shader.addUniforms({
          "modelViewMat": 'mat4',
          "projectionMat": 'mat4',
          "time": 'float',
      });
      
      if(stage.isLightmap == true) 
      {
          shader.addAttribs({ "lightCoord": 'vec2' });
      } 
      else 
      {
          shader.addAttribs({ "texCoord": 'vec2' });
      }
      
      shader.addLines(['vec3 defPosition = position;']);
      
      for(var i = 0; i < stageShader.vertexDeforms.length; ++i) 
      {
          deform_t deform = stageShader.vertexDeforms[i];
          
          switch(deform.type) 
          {
              case 'wave':
                  String name = 'deform' + i.toString();
                  String offName = 'deformOff' + i.toString();
                  
                  shader.addLines([
                      'float ' + offName + ' = (position.x + position.y + position.z) * ' + deform.spread.toStringAsFixed(4) + ';'
                  ]);
                  
                  var phase = deform.waveform.phase;
                  deform.waveform.phase = phase.toStringAsFixed(4) + ' + ' + offName;
                  shader.addWaveform(name, deform.waveform,null);
                  deform.waveform.phase = phase;
                  
                  shader.addLines([
                      'defPosition += normal * ' + name + ';'
                  ]);
                  break;
              default: break;
          }
      }
      
      shader.addLines(['vec4 worldPosition = modelViewMat * vec4(defPosition, 1.0);']);
      shader.addLines(['vColor = color;']);

      if(stage.tcGen == 'environment') 
      {
          shader.addLines([
              'vec3 viewer = normalize(-worldPosition.xyz);',
              'float d = dot(normal, viewer);',
              'vec3 reflected = normal*2.0*d - viewer;',
              'vTexCoord = vec2(0.5, 0.5) + reflected.xy * 0.5;'
          ]);
      } 
      else 
      {
          // Standard texturing
          if(stage.isLightmap==true) 
          {
              shader.addLines(['vTexCoord = lightCoord;']);
          } 
          else 
          {
              shader.addLines(['vTexCoord = texCoord;']);
          }
      }
      
      // tcMods
      for(int i = 0; i < stage.tcMods.length; ++i) 
      {
          tcMod_t tcMod = stage.tcMods[i];
          switch(tcMod.type) 
          {
              case 'rotate':
                  shader.addLines([
                      'float r = ' + tcMod.angle.toStringAsFixed(4) + ' * time;',
                      'vTexCoord -= vec2(0.5, 0.5);',
                      'vTexCoord = vec2(vTexCoord.s * cos(r) - vTexCoord.t * sin(r), vTexCoord.t * cos(r) + vTexCoord.s * sin(r));',
                      'vTexCoord += vec2(0.5, 0.5);',
                  ]);
                  break;
              case 'scroll':
                double sSpeed = tcMod.sSpeed; // was tcMod['sSpeed'].toFixed(4)
                double tSpeed = tcMod.tSpeed;
                
                  shader.addLines([
                      'vTexCoord += vec2(' + sSpeed.toStringAsFixed(4) + ' * time, ' + tSpeed.toStringAsFixed(4) + ' * time);'
                  ]);
                  break;
              case 'scale':
                double  scaleX = tcMod.scaleX;
                double  scaleY = tcMod.scaleY;
                
                  shader.addLines([
                      'vTexCoord *= vec2(' + scaleX.toStringAsFixed(4) + ', ' + scaleY.toStringAsFixed(4) + ');'
                  ]);
                  break;
              case 'stretch':
                  shader.addWaveform('stretchWave', tcMod.waveform, null);
                  shader.addLines([
                      'stretchWave = 1.0 / stretchWave;',
                      'vTexCoord *= stretchWave;',
                      'vTexCoord += vec2(0.5 - (0.5 * stretchWave), 0.5 - (0.5 * stretchWave));',
                  ]);
                  break;
              case 'turb':
                  String tName = 'turbTime' + i.toString();
                  shader.addLines([
                      'float ' + tName + ' = ' + tcMod.turbulance.phase.toStringAsFixed(4) + ' + time * ' + tcMod.turbulance.freq.toStringAsFixed(4) + ';',
                      'vTexCoord.s += sin( ( ( position.x + position.z )* 1.0/128.0 * 0.125 + ' + tName + ' ) * 6.283) * ' + tcMod.turbulance.amp.toStringAsFixed(4) + ';',
                      'vTexCoord.t += sin( ( position.y * 1.0/128.0 * 0.125 + ' + tName + ' ) * 6.283) * ' + tcMod.turbulance.amp.toStringAsFixed(4) + ';'
                  ]);
                  break;
              default: break;
          }
      }
      
      switch(stage.alphaGen) 
      {
          case 'lightingspecular':
              shader.addAttribs({ "lightCoord": 'vec2' });
              shader.addVaryings({ "vLightCoord": 'vec2' });
              shader.addLines([ 'vLightCoord = lightCoord;' ]);
              break;
          default: 
              break;
      }
      
      shader.addLines(['gl_Position = projectionMat * worldPosition;']);


      vertex_shader_src_t vertex_shader = new vertex_shader_src_t();
      vertex_shader.source_code = shader.getSource();
      return vertex_shader;
  }
  
  static fragment_shader_src_t buildFragmentShader (shader_t stageShader, stage_t stage) 
  {
      shaderBuilder shader = new shaderBuilder();
      
      shader.addVaryings({
          "vTexCoord": 'vec2',
          "vColor": 'vec4',
      });
      
      shader.addUniforms({
          "texture": 'sampler2D',
          "time": 'float',
      });
      
      shader.addLines(['vec4 texColor = texture2D(texture, vTexCoord.st);']);
      
      switch(stage.rgbGen) 
      {
          case 'vertex':
              shader.addLines(['vec3 rgb = texColor.rgb * vColor.rgb;']);
              break;
          case 'wave':
              shader.addWaveform('rgbWave', stage.rgbWaveform, null);
              shader.addLines(['vec3 rgb = texColor.rgb * rgbWave;']);
              break;
          default:
              shader.addLines(['vec3 rgb = texColor.rgb;']);
              break;
      }
      
      switch(stage.alphaGen) 
      {
          case 'wave':
              shader.addWaveform('alpha', stage.alphaWaveform, null);
              break;
          case 'lightingspecular':
              // For now this is VERY special cased. May not work well with all instances of lightingSpecular
              shader.addUniforms({
                  "lightmap": 'sampler2D'
              });
              shader.addVaryings({
                  "vLightCoord": 'vec2',
                  "vLight": 'float'
              });
              shader.addLines([
                  'vec4 light = texture2D(lightmap, vLightCoord.st);',
                  'rgb *= light.rgb;',
                  'rgb += light.rgb * texColor.a * 0.6;', // This was giving me problems, so I'm ignorning an actual specular calculation for now
                  'float alpha = 1.0;'
              ]);
              break;
          default: 
              shader.addLines(['float alpha = texColor.a;']);
              break;
      }
      
      if(stage.alphaFunc!=null) 
      {
          switch(stage.alphaFunc) 
          {
              case 'GT0':
                  shader.addLines([
                      'if(alpha == 0.0) { discard; }'
                  ]);
                  break;
              case 'LT128':
                  shader.addLines([
                      'if(alpha >= 0.5) { discard; }'
                  ]);
                  break;
              case 'GE128':
                  shader.addLines([
                      'if(alpha < 0.5) { discard; }'
                  ]);
                  break;
              default: 
                  break;
          }
      }
      
      shader.addLines(['gl_FragColor = vec4(rgb, alpha);']);
      
      fragment_shader_src_t frag_shader = new fragment_shader_src_t();
      frag_shader.source_code = shader.getSource();
      return frag_shader;
  }
  
  
}