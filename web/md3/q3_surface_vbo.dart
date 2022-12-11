part of tech3;

class Q3_surface_VBO
{
  rendering_context gl;
  int num_of_indices;
  var HANDLE_vbo_indices;
  int surface_idx;
  MD3_Surface MD3_surface;
  int num_of_frames;
  int num_of_vertices;
  var buffer_Int16_indices;
  var buffer_Float32_texcoords;
  var buffer_Float32_vertices;
  int active_frame_IDX;
  List<GLBuffer> HANDLE_vbo_vertices_xyzn;
  GLBuffer HANDLE_vbo_texcoords_st;
  bool frame_index_out_of_bounds;
  
  Q3_surface_VBO(rendering_context gl, MD3_File MD3_file, surface_idx)
  {
    this.gl = gl;
//  this.MD3_file = MD3_file;
    this.surface_idx = surface_idx;

    this.MD3_surface = MD3_file.surfaces[surface_idx];

    this.num_of_frames   = this.MD3_surface.S32_NUM_FRAMES;
    this.num_of_indices  = this.MD3_surface.Uint16_3_INDICES.length;
    this.num_of_vertices = this.MD3_surface.S32_NUM_VERTS;

//  console.log("this.num_of_frames   = "+this.num_of_frames);
//  console.log("this.num_of_indices  = "+this.num_of_indices);
//  console.log("this.num_of_vertices = "+this.num_of_vertices);

    // save references of the used bufers
    this.buffer_Int16_indices     = this.MD3_surface.Uint16_3_INDICES;
    this.buffer_Float32_texcoords = this.MD3_surface.S32_2_ST;

    this.buffer_Float32_vertices = new List( this.num_of_vertices );
    if(this.MD3_surface.surface_frames.length > 0){
      for(var i = 0; i <this.num_of_frames; i++ )
      {
        if(i<this.buffer_Float32_vertices.length){
          this.buffer_Float32_vertices[i] = this.MD3_surface.surface_frames[i].vertexbuffer_xyzn;
        }
      }
    }



    this.active_frame_IDX = 0;

    // create vbo-buffer ... INDICES
    this.HANDLE_vbo_indices       = gl.createBuffer();

    // create vbo-buffers ... VERTICES (1 array for each frame)
    this.HANDLE_vbo_vertices_xyzn = new List( this.num_of_vertices);
    for(var i = 0; i <this.num_of_frames; i++ ){
      if(i<this.HANDLE_vbo_vertices_xyzn.length)
      {
        this.HANDLE_vbo_vertices_xyzn[i] = gl.createBuffer();
      }
    }
    // create vbo-buffer ... TEXCOORDS
    this.HANDLE_vbo_texcoords_st  = gl.createBuffer();

    this.fillVBOs();

  }



  fillVBOs ()
  {
    var handle, data, size;

    // INDICES
    handle = this.HANDLE_vbo_indices;
    data   = this.buffer_Int16_indices;
    size   = this.num_of_indices * 2; // 2... int 16
    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, handle);
    gl.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, size, RenderingContext.STATIC_DRAW);
    gl.bufferSubData(RenderingContext.ELEMENT_ARRAY_BUFFER,  0, data );

    if(HANDLE_vbo_vertices_xyzn!=null)
    {
      // VERTICES
      for(var i = 0; i <this.num_of_frames; i++ )
      {
        if(i> this.HANDLE_vbo_vertices_xyzn.length-1) continue;
        
        handle = this.HANDLE_vbo_vertices_xyzn[i];
        data   = this.buffer_Float32_vertices[i];
        size   = this.num_of_vertices * 6 * 4; // 6=(vx,vy,vz)+(nx,ny,z); 4=Float32
        gl.bindBuffer(RenderingContext.ARRAY_BUFFER, handle);
        gl.bufferData(RenderingContext.ARRAY_BUFFER, size, RenderingContext.STATIC_DRAW);
        gl.bufferSubData(RenderingContext.ARRAY_BUFFER,  0, data );
  //    console.log("size = "+size);
  //    console.log("data.length = "+data.length);
      }
    }
    if(HANDLE_vbo_texcoords_st!=null)
    {
      // TEXCOORDS
      handle = this.HANDLE_vbo_texcoords_st;
      data   = this.buffer_Float32_texcoords;
      size   = this.num_of_vertices * 2 * 4; // 2=(tx,ty); 4=Float32
      gl.bindBuffer(RenderingContext.ARRAY_BUFFER, handle);
      gl.bufferData(RenderingContext.ARRAY_BUFFER, size, RenderingContext.STATIC_DRAW);
      gl.bufferSubData(RenderingContext.ARRAY_BUFFER,  0, data );
  //    console.log("size = "+size);
  //    console.log("data.length = "+data.length);
    }

    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, null);
  }

  delete ()
  {
    this.gl.deleteBuffer(this.HANDLE_vbo_indices);
    this.HANDLE_vbo_indices = null;

    this.HANDLE_vbo_vertices_xyzn = new List( this.num_of_vertices);
    for(var i = 0; i <this.HANDLE_vbo_vertices_xyzn.length; i++ ){
      this.gl.deleteBuffer(this.HANDLE_vbo_vertices_xyzn[i]);
      this.HANDLE_vbo_vertices_xyzn[i] = null;
    }
    this.HANDLE_vbo_vertices_xyzn = [];
  }


  beginDraw (Q3_surface_shader_generic shader, frame_idx)
  {
//  if( frame_idx >= this.num_of_frames){
//    frame_idx = this.num_of_frames-1;
//  }

    this.active_frame_IDX = frame_idx;
    this.frame_index_out_of_bounds = frame_idx >= HANDLE_vbo_vertices_xyzn.length -1;
    
    if(frame_index_out_of_bounds) frame_idx = 0;
    
    var handle_xyzn =  this.HANDLE_vbo_vertices_xyzn[frame_idx];
    var handle_st   =  this.HANDLE_vbo_texcoords_st;

    var shader_loc_xyz  = shader.IN_VEC3_POSITION;
    var shader_loc_n    = shader.IN_VEC3_NORMAL;
    var shader_loc_st   = shader.IN_VEC2_ST;

    // VERTICES
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, handle_xyzn);
    gl.vertexAttribPointer(shader_loc_xyz, 3, RenderingContext.FLOAT, false, 24,  0 );
    gl.vertexAttribPointer(shader_loc_n,   3, RenderingContext.FLOAT, false, 24, 12 );
    gl.enableVertexAttribArray(shader_loc_xyz);
    gl.enableVertexAttribArray(shader_loc_n);

    // TEXCOORDS
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, handle_st);
    if( shader_loc_st >= 0) gl.vertexAttribPointer(shader_loc_st, 2, RenderingContext.FLOAT, false, 8,  0 );
    if( shader_loc_st >= 0) gl.enableVertexAttribArray(shader_loc_st);

  }


  draw ()
  {
    // INDICES

    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, this.HANDLE_vbo_indices);
    gl.drawElements(RenderingContext.TRIANGLES, this.num_of_indices, RenderingContext.UNSIGNED_SHORT, 0);
    gl.flush();
  }


  endDraw (Q3_surface_shader_generic shader)
  {
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, null);
    if( shader.IN_VEC3_POSITION  >= 0 )gl.disableVertexAttribArray(shader.IN_VEC3_POSITION );
    if( shader.IN_VEC3_NORMAL    >= 0 )gl.disableVertexAttribArray(shader.IN_VEC3_NORMAL  );
    if( shader.IN_VEC2_ST        >= 0 )gl.disableVertexAttribArray(shader.IN_VEC2_ST);
  }

  
}


