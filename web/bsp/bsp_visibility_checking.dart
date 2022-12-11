part of tech3;

class bsp_visibility_checking
{
  //
  // Visibility Checking
  //

  static bool checkVis (visCluster, testCluster) 
  {
     if(visCluster == testCluster || visCluster == -1) 
     { 
       return true; 
     }
     
     var i = (visCluster * visSize) + (testCluster >> 3);
     var visSet = visBuffer[i];
     
     return (visSet & (1 << (testCluster & 7)) != 0);
  }
  
  static getLeaf (List<double> pos) 
  {
     var index = 0;
     
     var node = null;
     var plane = null;
     double distance = 0.0;
    
     while (index >= 0) 
     {
         node = nodes.elementAt(index);
         plane = planes.elementAt(node['plane']);
         
         distance = vec3_dot(plane['normal'], pos) - plane['distance'];
    
         if (distance >= 0) 
         {
             index = node.children[0];
         } 
         else 
         {
             index = node.children[1];
         }
     }
    
     return -(index+1);
  }
  
  static void buildVisibleList (int leafIndex) 
  {
     // Determine visible faces
     if(leafIndex == bsp_compiler.lastLeaf) { return; }
     bsp_compiler.lastLeaf = leafIndex;
     
     var curLeaf = leaves.elementAt(leafIndex);
     
     List visibleShaders = new List(shaders.length);
     
     for(var i = 0; i < leaves.length; ++i) 
     {
         var leaf = leaves.elementAt(i);
         
         if(checkVis(curLeaf['cluster'], leaf['cluster'])) 
         {
             for(var j = 0; j < leaf['leafFaceCount']; ++j) 
             {
                 var face = faces[leafFaces[[j + leaf['leafFace']]]];
                 
                 if(face!=null) 
                 {
                     visibleShaders[face['shader']] = true; // elementAt()
                 }
             }
         }
     }
     
     List ar = new List(visSize);
     
     for(var i = 0; i < visSize; ++i) 
     {
         ar[i] = visBuffer[(curLeaf['cluster'] * visSize) + i];
     }
     
     postMessage2({
         "type": 'visibility',
         "visibleSurfaces": visibleShaders
     },null);
  }
}