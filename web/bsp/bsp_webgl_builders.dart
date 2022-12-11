part of tech3;

class bsp_webgl_builders
{
  static buildBuffers (List vertices, List indices) 
  {
    // Float32List
    // Uint16List
    Float32List verts = new Float32List(vertices.length);
    verts.setAll(0, vertices);
    Uint16List ind = new Uint16List(indices.length);
    ind.setAll(0, indices);
    
    q3bsp.vertexBuffer = gl.createBuffer();
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, q3bsp.vertexBuffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, verts, RenderingContext.STATIC_DRAW);
    
    q3bsp.indexBuffer = gl.createBuffer();
    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, q3bsp.indexBuffer);
    gl.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, ind, RenderingContext.STATIC_DRAW);
    
    q3bsp.indexCount = indices.length;      
  }
  
  static buildLightmaps (int size, lightmaps) 
  {      
      gl.bindTexture(RenderingContext.TEXTURE_2D, q3bsp.lightmap);
      
      //gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, size, size, 0, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE);
      gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, size, size, 0, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, null);
      gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.LINEAR);
      gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.LINEAR_MIPMAP_LINEAR);
      
      for(var i = 0; i < lightmaps.length; ++i) 
      {
        var lightmap_bytes = lightmaps[i].bytes;
     
        gl.texSubImage2D(RenderingContext.TEXTURE_2D, 
            0, 
            lightmaps[i].x.toInt(), 
            lightmaps[i].y.toInt(), 
            lightmaps[i].width.toInt(), 
            lightmaps[i].height.toInt(),
            RenderingContext.RGBA, 
            RenderingContext.UNSIGNED_BYTE, lightmap_bytes); // UNSIGNED_BYTE
      }
      
      gl.generateMipmap(RenderingContext.TEXTURE_2D);
      
      gl.bindTexture(RenderingContext.TEXTURE_2D, null);
      
      q3bsp.glshading.init(gl);
  }
  
  static buildShaders (List<shader_t> shaders) 
  {      
      q3bsp.shaders = new Map<String,shader_gl>();
      
      for(var i = 0; i < shaders.length; ++i) 
      {
          shader_t shader = shaders[i];
          
          if(shader==null)continue;
          
          shader_gl glShader = q3bsp.glshading.build(gl, shader, null);
          
          String shader_name = shader.name; 
          
          q3bsp.shaders[shader_name] = glShader;
      }
  }
}