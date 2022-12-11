part of tech3;

class bsp_header_t
{
    String company;
    String tag;
    int version;
    Queue<bsp_header_lump_t> lumps;
}
class bsp_header_lump_t
{
  int offset;
  int length;
}

class bsp_parser_ibsp_v46
{
  // Parses the BSP file
  static void parse(binary_stream src, int tesselationLevel, OnBspIncompatible onIncompatible)
  {
     bsp_header_t header = bsp_parser_ibsp_v46.readHeader(src);
     
     // Check for appropriate format
     if(header.tag != 'IBSP' || header.version != 46)
     {
       onIncompatible(header);
       
       return;
     }
     
     // info on different versions: https://github.com/zturtleman/bsp-sekai
     
    /*---- LUMP INDEX ----
    Index       Lump Name         Description
    0           Entities          Game-related object descriptions.
    1           Textures          Surface descriptions.
    2           Planes            Planes used by map geometry.
    3           Nodes             BSP tree nodes.
    4           Leafs             BSP tree leaves.
    5           Leaffaces         Lists of face indices, one list per leaf.
    6           Leafbrushes       Lists of brush indices, one list per leaf.
    7           Models            Descriptions of rigid world geometry in map.
    8           Brushes           Convex polyhedra used to describe solid space.
    9           Brushsides        Brush surfaces.
    10          Vertexes          Vertices used to describe faces.
    11          Meshverts         Lists of offsets, one list per mesh.
    12          Effects           List of special map effects.
    13          Faces             Surface geometry.
    14          Lightmaps         Packed lightmap data.
    15          Lightvols         Local illumination data.
    16          Visdata           Cluster-cluster visibility data.*/
     
     
     // Read map entities
     bsp_parser_ibsp_v46.readEntities(header.lumps.elementAt(0), src); 
     /*  The entities lump stores game-related map information, 
      *  including information about the map name, weapons, health, armor, triggers, spawn points, 
      *  lights, and .md3 models to be placed in the map. 
      *  The lump contains only one record, a string that describes all of the entities */
     
     bsp_tree tree = new bsp_tree();
     
     // Load visual map components
     tree.surfaces = shaders = bsp_parser_ibsp_v46.readShaders(header.lumps.elementAt(1), src);
     List<lightmap_rect_t> lightmaps = bsp_parser_ibsp_v46.readLightmaps(header.lumps.elementAt(14), src);
     var verts = bsp_parser_ibsp_v46.readVerts(header.lumps.elementAt(10), src);
     var meshVerts = bsp_parser_ibsp_v46.readMeshVerts(header.lumps.elementAt(11), src);
     faces = bsp_parser_ibsp_v46.readFaces(header.lumps.elementAt(13), src);
     
     // COMPILE MAP
     bsp_compiler.compileMap(verts, faces, meshVerts, lightmaps, shaders, tesselationLevel);
     
     postMessage2({
         "type": 'status',
         "message": 'Geometry compiled, parsing collision tree...'
     },null);
     
     
     // Load bsp components
     tree.planes = bsp_parser_ibsp_v46.readPlanes(header.lumps.elementAt(2), src);
     tree.nodes = bsp_parser_ibsp_v46.readNodes(header.lumps.elementAt(3), src);
     tree.leaves = bsp_parser_ibsp_v46.readLeaves(header.lumps.elementAt(4), src);
     tree.leafFaces = bsp_parser_ibsp_v46.readLeafFaces(header.lumps.elementAt(5), src);
     tree.leafBrushes = bsp_parser_ibsp_v46.readLeafBrushes(header.lumps.elementAt(6), src);
     tree.brushes = bsp_parser_ibsp_v46.readBrushes(header.lumps.elementAt(8), src);
     tree.brushSides = bsp_parser_ibsp_v46.readBrushSides(header.lumps.elementAt(9), src);
     Map visData = bsp_parser_ibsp_v46.readVisData(header.lumps.elementAt(16), src);
     tree.visBuffer = visData['buffer'];
     tree.visSize = visData['size'];
     
     postMessage2({
         "type": 'bsp',
         "bsp": tree
     },null);
  }

  // Read all lump headers
  static bsp_header_t readHeader(binary_stream src) 
  {
    // Read the magic number and the version
    bsp_header_t header = new bsp_header_t();
    header.tag = src.readString(0,4);
    header.version = src.readULong();
    header.lumps = new Queue();
   
    header.company = 'GoldSrc'; // GoldSrc doesnt have a magic number
    if(header.tag.startsWith("I"))
    {
      header.company = 'iD Software';
    }
    else if(header.tag.startsWith("V"))
    {
      header.company = 'Valve Software';
    }
    
    // Read the lump headers
    for(var i = 0; i < 17; ++i) 
    {
        bsp_header_lump_t lump = new bsp_header_lump_t();
        lump.offset=src.readULong();
        lump.length=src.readULong();
        header.lumps.addLast(lump);
    }
    
    return header;
  }
  
  // Read all entity structures
  static void readEntities (lump, binary_stream src) 
  {
    src.seek(lump.offset);
    String entities = src.readString(0,lump.length);
  
    // general entities parser and loader
    //TODO: note may need tools like md3 viewer to complete this.
    
    // info_player_deathmatch
    
    Map elements = {
        "targets": {}
    };
    
    RegExp patt_match_elements = new RegExp(r'\{([^}]*)\}*');
    RegExp patt_match_entities = new RegExp(r'"(.+)"* "(.+)"*'); // "(.+)" "(.+)"$mg
    RegExp patt_match_origin_coord = new RegExp(r'(.+) (.+) (.+)');
    
    patt_match_elements
    .allMatches(entities)
    .forEach((Match m)
    {      
      var g1 =  m.groups([0,1]);
      var entity = { "classname": 'unknown' };
      
      var ma0 = patt_match_entities.allMatches(m.groups([0])[0]).toList();
      for(int j =0;j<ma0.length;j++)
      {   
        Match m1 = ma0[j];
        var ma1 = patt_match_entities.allMatches(m1.groups([0])[0]).toList();
        
        for(int i =0;i<ma1.length;i++)
        {
          Match m2 = ma1[i];
          
          var g0 = m2.groups([1,2]);
          String entity_key = g0[0];
          String entity_value = g0[1];
          entity_key = entity_key.startsWith('"') ? entity_key.substring(1) : entity_key;
          entity_key = entity_key.endsWith('"') ? entity_key.substring(0,entity_key.length-1) : entity_key;
          entity_value = entity_value.startsWith('"') ? entity_value.substring(1) : entity_value;
          entity_value = entity_value.endsWith('"') ? entity_value.substring(0,entity_value.length-1) : entity_value;
//          entity_key = entity_key.startsWith('"') == false ? '"'+entity_key : entity_key;
//          entity_key = entity_key.endsWith('"') == false ? entity_key + '"' : entity_key;
//          entity_value = entity_value.startsWith('"') == false ? '"'+entity_value : entity_value;
//          entity_value = entity_value.endsWith('"') == false ? entity_value + '"' : entity_value;
          switch(entity_key) 
          {
             case 'origin':
                patt_match_origin_coord
                .allMatches(entity_value)
                .forEach((Match m)
                {
                   var coord = m.groups([1,2,3]);
                   entity[entity_key] = [double.parse(coord[0]), double.parse(coord[1]), double.parse(coord[2])];
                });
                break;
             case 'angle':
                   entity[entity_key] = double.parse(entity_value);
                break;
               default:
                   entity[entity_key] = entity_value;
                break;
           }
        }
    
        if(entity['targetname'] != null) 
        {
          elements['targets'][entity['targetname']] = entity;
        }
        if(elements[entity['classname']] == null) 
        {  
          elements[entity['classname']] = [];
        }
        elements[entity['classname']].add(entity);
      };
    });
  
     // Send the entity data back to the render thread
     postMessage2({
         "type": 'entities',
         "entities": elements
     },null);
  }
  
  // Read all shader structures
  static List<shader_p> readShaders (bsp_header_lump_t lump, binary_stream src) 
  {
    var count = lump.length / 72;
    List elements = new List();
    
    src.seek(lump.offset);
    
    for(var i = 0; i < count; ++i) 
    {
        shader_p shader = new shader_p();
        shader.shaderName = src.readString(0,64);
        shader.flags = src.readLong();
        shader.contents = src.readLong();
        shader.shader = null;
        shader.faces = [];
        shader.indexOffset = 0;
        shader.elementCount = 0;
        shader.visible = true;
        elements.add(shader);
    }
  
    return elements;
  }
  
  // Read all lightmaps
  static List<lightmap_rect_t> readLightmaps (bsp_header_lump_t lump, binary_stream src) 
  {
   var lightmapSize = 128 * 128;
   var count = lump.length / (lightmapSize*3);
   
   var gridSize = 2;
   
   while(gridSize * gridSize < count) 
   {
       gridSize *= 2;
   }
   
   var textureSize = gridSize * 128;
   
   int xOffset = 0;
   int yOffset = 0;
   
   List<lightmap_t> lightmaps = new List<lightmap_t>();
   List<lightmap_rect_t> lightmapRects = new List<lightmap_rect_t>();
   List<int> rgb = [ 0, 0, 0 ];
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) 
   {
       Uint8List elements = new Uint8List(lightmapSize*4);
       for(var j = 0; j < lightmapSize*4; j+=4) 
       {
           rgb[0] = src.readUByte();
           rgb[1] = src.readUByte();
           rgb[2] = src.readUByte();
           
           brightnessAdjust(rgb, 4.0);
           
           elements[j] = rgb[0].toInt();
           elements[j+1] = rgb[1].toInt();
           elements[j+2] = rgb[2].toInt();
           elements[j+3] = 255;
       }
       lightmap_t l = new lightmap_t();
       l.x = xOffset;
       l.y = yOffset;
       l.width=128;
       l.height=128;
       l.bytes=elements;
       lightmaps.add(l);
       
       lightmap_rect_t r =new lightmap_rect_t();
       r.x = xOffset/textureSize;
       r.y = yOffset/textureSize;
       r.xScale = 128/textureSize;
       r.yScale = 128/textureSize;
       lightmapRects.add(r);
       
       xOffset += 128;
       if(xOffset >= textureSize) {
           yOffset += 128;
           xOffset = 0;
       }
   }
   
   // Send the lightmap data back to the render thread
   postMessage2({
       "type": 'lightmap',
       "size": textureSize,
       "lightmaps": lightmaps
   },null);
   
   return lightmapRects;
  }
  
  static List readVerts (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length/44;
   List elements = [];
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) {
     
       elements.add({
           "pos": [ src.readFloat(), src.readFloat(), src.readFloat() ],
           "texCoord": [ src.readFloat(), src.readFloat() ],
           "lmCoord": [ src.readFloat(), src.readFloat() ],
           "lmNewCoord": [ 0.0, 0.0 ],
           "normal": [ src.readFloat(), src.readFloat(), src.readFloat() ],
           "color": brightnessAdjustVertex(colorToVec(src.readULong()), 4.0)
       });
   }
  
   return elements;
  }
  
  static List readMeshVerts (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length/4;
   List meshVerts = [];
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) {
       meshVerts.add(src.readLong());
   }
   
   return meshVerts;
  }
  
  // Read all face structures
  static List readFaces (bsp_header_lump_t lump, binary_stream src) 
  {
   var faceCount = lump.length / 104;
   List faces = [];
   
   src.seek(lump.offset);
   for(var i = 0; i < faceCount; ++i) {
       var face = {
           "shader": src.readLong(),
           "effect": src.readLong(),
           "type": src.readLong(),
           "vertex": src.readLong(),
           "vertCount": src.readLong(),
           "meshVert": src.readLong(),
           "meshVertCount": src.readLong(),
           "lightmap": src.readLong(),
           "lmStart": [ src.readLong(), src.readLong() ],
           "lmSize": [ src.readLong(), src.readLong() ],
           "lmOrigin": [ src.readFloat(), src.readFloat(), src.readFloat() ],
           "lmVecs": [[ src.readFloat(), src.readFloat(), src.readFloat() ],
                   [ src.readFloat(), src.readFloat(), src.readFloat() ]],
           "normal": [ src.readFloat(), src.readFloat(), src.readFloat() ],
           "size": [ src.readLong(), src.readLong() ],
           "indexOffset": -1
       };
       
       faces.add(face);
   }
  
   return faces;
  }
  
  // Read all Plane structures
  static Queue<Plane> readPlanes (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 16;
   Queue elements = new Queue();
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) 
   {
      Plane p = new Plane();
      
      p.normal = new Vector3(src.readFloat(), src.readFloat(), src.readFloat() );
      p.distance = src.readFloat();
     
      elements.addLast(p);
   }
   
   return elements;
  }
  
  // Read all Node structures
  static Queue<bsp_tree_node> readNodes (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 36;
   Queue<bsp_tree_node> elements = new Queue<bsp_tree_node>();
   
   src.seek(lump.offset);
   
   for(var i = 0; i < count; ++i) 
   {
     bsp_tree_node node = new bsp_tree_node();
     node.plane = src.readLong();
     node.children = [src.readLong(), src.readLong()];
     node.min = [ src.readLong(), src.readLong(), src.readLong() ];
     node.max = [ src.readLong(), src.readLong(), src.readLong() ];
     elements.add(node);
   }
   
   return elements;
  }
  
  // Read all Leaf structures
  static Queue readLeaves (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 48;
   Queue elements = new Queue();
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) {
       elements.addLast({
           "cluster": src.readLong(),
           "area": src.readLong(),
           "min": [ src.readLong(), src.readLong(), src.readLong() ],
           "max": [ src.readLong(), src.readLong(), src.readLong() ],
           "leafFace": src.readLong(),
           "leafFaceCount": src.readLong(),
           "leafBrush": src.readLong(),
           "leafBrushCount": src.readLong()
       });
   }
   
   return elements;
  }
  
  // Read all Leaf Faces
  static List readLeafFaces (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 4;
   List elements = [];
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) 
   {
       elements.add(src.readLong());
   }
   
   return elements;
  }
  
  // Read all Brushes
  static List readBrushes (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 12;
   List elements = [];
   
   src.seek(lump.offset);
   for(var i = 0; i < count; ++i) {
       elements.add({
           "brushSide": src.readLong(),
           "brushSideCount": src.readLong(),
           "shader": src.readLong()
       });
   }
   
   return elements;
  }
  
  // Read all Leaf Brushes
  static List readLeafBrushes (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 4;
   List elements = [];
   
   src.seek(lump.offset);
   
   for(var i = 0; i < count; ++i) 
   {
       elements.add(src.readLong());
   }
   
   return elements;
  }
  
  // Read all Brush Sides
  static List readBrushSides (bsp_header_lump_t lump, binary_stream src) 
  {
   var count = lump.length / 8;
   List elements = [];
   
   src.seek(lump.offset);
   
   for(var i = 0; i < count; ++i) 
   {
       elements.add({
           "plane": src.readLong(),
           "shader": src.readLong()
       });
   }
   
   return elements;
  }
  
  // Read all Vis Data
  static Map readVisData (bsp_header_lump_t lump, binary_stream src) 
  {
   src.seek(lump.offset);
   var vecCount = src.readLong();
   var size = src.readLong();
   
   var byteCount = vecCount * size;
   //var elements = new Array(byteCount);
   List elements = new List(byteCount);
   
   for(var i = 0; i < byteCount; ++i) 
   {
       elements[i] = src.readUByte();
   }
   
   return {
       "buffer": elements,
       "size": size
   };
  }
  
  
}