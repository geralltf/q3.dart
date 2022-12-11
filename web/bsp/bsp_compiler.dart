part of tech3;

// note: IBSP iD3 spec http://www.mralligator.com/q3/#Entities

Queue leaves;
Queue planes;
Queue nodes;
var faces;
var brushes;
List brushSides;
var leafFaces, leafBrushes;
var visBuffer, visSize;
List<shader_p> shaders; // This needs to be kept here for collision detection (indicates non-solid surfaces)

typedef OnLoadError();

void _onmessage(msg) 
{  
    switch(msg['type']) 
    {
        case 'load':
            String url = msg['url'];
            int tessLevel = msg['tesselationLevel'];
          
            bsp_compiler.load(url, tessLevel, () {
                // Fallback to account for Opera handling URLs in a worker 
                // differently than other browsers. 
                bsp_compiler.load("../" + url, tessLevel,null);
            });
            break;
        case 'loadShaders':
            q3shader.loadList(msg['sources'],null);
            break;
        case 'trace':
            bsp_collision_detection.trace(msg['traceId'], msg['start'], msg['end'], msg['radius'], msg['slide']);
            break;
        case 'visibility':
            bsp_visibility_checking.buildVisibleList(bsp_visibility_checking.getLeaf(msg['pos']));
            break;
        //default:
            //print 'Unexpected message type: ' + msg['data'];
    }
}

class bsp_compiler
{
  static int lastLeaf = -1;
  
  static void init(){
    
//    context["onq3message"] = (params) {
//       //call any dart method
//      onmessage(params);
//      
//      q3bsp.onMessage(params);
//    };
  }
  
  static void load (String mapURL, int tesselationLevel, OnLoadError errorCallback)
  {
    fetch(mapURL, 'arraybuffer').then((request)
    {
      if(request.response is ByteBuffer)
      {
        postMessage2({
           "type": 'status',
           "message": 'Map downloaded, parsing level geometry...'
        },null);
        
        bsp_parser_ibsp_v46.parse(new binary_stream(request.response), tesselationLevel, (bsp_header_t header) {
            postMessage2({
             "type": 'status',
             "message": 'Incompatible BSP version. '+ header.company + ' ' + header.tag + ' V.' + header.version.toString()
            },null);
        });
        
        // TODO: could potentially hit compileMap now instead of within parse
      }
    });
  }
  
  //
  // Compile the map into a stream of WebGL-compatible data
  //
  
  static compileMap   ( List verts, 
                        List faces, 
                        List meshVerts, 
                        List<lightmap_rect_t> lightmaps, 
                        List<shader_p> shaders, 
                        int tesselationLevel ) 
  {
     postMessage2({
         "type": 'status',
         "message": 'Map geometry parsed, compiling shaders...'
     },null);
     
     // Find associated shaders for all clusters
     
     // Per-face operations
     for(int i = 0; i < faces.length; ++i) 
     {
         var face = faces[i];
     
         if(face['type']==1 || face['type']==2 || face['type']==3) 
         {
             // Add face to the appropriate texture face list
             shader_p shader = shaders[face['shader']];
             shader.faces.add(face);
             lightmap_rect_t lightmap = face['lightmap'] > 0 ? lightmaps[face['lightmap']] : null;
         
             if(lightmap == null) 
             {
                 lightmap = lightmaps[0];
             }
         
             if(face['type']==1 || face['type']==3) 
             {
                 shader.geomType = face['type'];
                 // Transform lightmap coords to match position in combined texture
                 for(var j = 0; j < face['meshVertCount']; ++j) 
                 {
                     var vert = verts[face['vertex'] + meshVerts[face['meshVert'] + j]];
    
                     vert['lmNewCoord'][0] = (vert['lmCoord'][0] * lightmap.xScale) + lightmap.x;
                     vert['lmNewCoord'][1] = (vert['lmCoord'][1] * lightmap.yScale) + lightmap.y;
                 }
             } 
             else 
             {
                 postMessage2({
                     "type": 'status',
                     "message": 'Tesselating face ' + i.toString() + " of " + faces.length.toString()
                 },null);
                 
                 // Build Bezier curve
                 bsp_tess.tesselate(face, verts, meshVerts, tesselationLevel);
                 
                 for(int j = 0; j < face['vertCount']; ++j) 
                 {
                     var vert = verts[face['vertex'] + j];
                 
                     vert['lmNewCoord'][0] = (vert['lmCoord'][0] * lightmap.xScale) + lightmap.x;
                     vert['lmNewCoord'][1] = (vert['lmCoord'][1] * lightmap.yScale) + lightmap.y;
                 }
             }
         }
     }
     
     // needs to be Float32List
     // Compile vert list
     //var vertices = new Array(verts.length*14);
     Float32List vertices = new Float32List(verts.length * 14);
     int offset = 0;
     for(int i = 0; i < verts.length; ++i) 
     {
         var vert = verts[i];
         
         vertices[offset++] = vert['pos'][0];
         vertices[offset++] = vert['pos'][1];
         vertices[offset++] = vert['pos'][2];
         
         vertices[offset++] = vert['texCoord'][0];
         vertices[offset++] = vert['texCoord'][1];
         
         vertices[offset++] = vert['lmNewCoord'][0];
         vertices[offset++] = vert['lmNewCoord'][1];
         
         vertices[offset++] = vert['normal'][0];
         vertices[offset++] = vert['normal'][1];
         vertices[offset++] = vert['normal'][2];
         
         vertices[offset++] = vert['color'][0];
         vertices[offset++] = vert['color'][1];
         vertices[offset++] = vert['color'][2];
         vertices[offset++] = vert['color'][3];
     }
   
     // Compile index list
     Uint16List indices = new Uint16List(0);
     List lst_indices = indices.toList();
     
     for(int i = 0; i <  shaders.length; ++i) 
     {
         shader_p shader = shaders[i];
         
         if(shader.faces.length > 0) 
         {
             shader.indexOffset = lst_indices.length * 2; // Offset is in bytes
             
             for(int j = 0; j < shader.faces.length; ++j) 
             {
                 var face = shader.faces[j];
                 face['indexOffset'] = lst_indices.length * 2;
                 
                 for(int k = 0; k < face['meshVertCount']; ++k) 
                 {
                   lst_indices.add(face['vertex'] + meshVerts[face['meshVert'] + k]);
                 }
                 shader.elementCount += face['meshVertCount'];
             }
         }
         shader.faces = null; // Don't need to send this to the render thread.
     }
   
     
     indices = new Uint16List(lst_indices.length);
     indices.setAll(0,lst_indices);
   
   
     // Send the compiled vertex/index data back to the render thread
     postMessage2({
         "type": 'geometry',
         "vertices": vertices,
         "indices": indices,
         "surfaces": shaders
     },null);
  }
}