part of tech3;

//from x3d.dart;

Float32List storeMatrix4(Matrix4 m) { return m.storage; }

//Float32List unpack_indicies(Int32List index_set,Float32List coords, int stride){
//  int i=0,j,k;
//  Float32List arr = new Float32List(index_set.length*stride);
//  index_set.forEach((int ind){
//    k=stride*ind;
//    for(j=0;j<stride;j++){
//      arr[i+j]=coords.elementAt(k+j);
//    }
//    i+=stride;
//  });
//  return arr;
//}
//Uint16List normalize_indicies_as_uint16(Int32List index_set){
//  List<int> lst=new List<int>();
//  if(index_set!=null&&index_set.length>0) {
//    int facesetPointer;
//    for(int i=0;i<index_set.length;i++) {
//      facesetPointer=index_set[i];
//
//      if(facesetPointer!=-1){
//        lst.add(facesetPointer);
//      }
//    }
//  }
//  Uint16List norm=new Uint16List(lst.length);
//  norm.setAll(0, lst);
//  return norm;
//}
//Uint32List normalize_indicies_as_uint32(Int32List index_set){
//  List<int> lst=new List<int>();
//  if(index_set!=null&&index_set.length>0) {
//    int facesetPointer;
//    for(int i=0;i<index_set.length;i++) {
//      facesetPointer=index_set[i];
//
//      if(facesetPointer!=-1){
//        lst.add(facesetPointer);
//      }
//    }
//  }
//  Uint32List norm=new Uint32List(lst.length);
//  norm.setAll(0, lst);
//  return norm;
//}
//Int32List normalize_indicies(Int32List index_set){
//  List<int> lst=new List<int>();
//  if(index_set!=null&&index_set.length>0) {
//    int facesetPointer;
//    for(int i=0;i<index_set.length;i++) {
//      facesetPointer=index_set[i];
//
//      if(facesetPointer!=-1){
//        lst.add(facesetPointer);
//      }
//    }
//  }
//  Int32List norm=new Int32List(lst.length);
//  norm.setAll(0, lst);
//  return norm;
//}

//class X3DGeometricPropertyNode{}
//
//class Coordinate extends X3DGeometricPropertyNode{
//  toString()=>'Coordinate';
//  //MFVec3f point;
//  Buffer _geo_VertexPositionBuffer;
//  
//  Float32List toFloat32List() => point.toFloat32List();
//  
//  upload(RenderingContext gl){
//    _geo_VertexPositionBuffer = gl.createBuffer();
//    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, _geo_VertexPositionBuffer);
//    gl.bufferData(RenderingContext.ARRAY_BUFFER, this.toFloat32List(), RenderingContext.STATIC_DRAW);
//  }
//  
//}
//class Color extends X3DGeometricPropertyNode{
//  toString()=>'Color';
//  //MFColor color;
//  Buffer _geo_VertexColorCoordBuffer;
//  Float32List toFloat32List() => color.toFloat32List();
//  upload(RenderingContext gl,Int32List colorIndex){
//    _geo_VertexColorCoordBuffer = gl.createBuffer();
//    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, _geo_VertexColorCoordBuffer); 
//    gl.bufferData(RenderingContext.ARRAY_BUFFER, /* colors cant be indexed in wgl */
//        unpack_indicies(colorIndex,color.toFloat32List(),3), RenderingContext.STATIC_DRAW);
//  }
//}
//class TextureCoordinate extends X3DGeometricPropertyNode{
//  toString()=>'TextureCoordinate';
//  //MFVec2f point;
//  Buffer _geo_VertexTextureCoordBuffer;
//  
//  Float32List toFloat32List() => point.toFloat32List();
//  upload(RenderingContext gl,Int32List texCoordIndex){
//    _geo_VertexTextureCoordBuffer = gl.createBuffer();
//    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, _geo_VertexTextureCoordBuffer);
//    gl.bufferData(RenderingContext.ARRAY_BUFFER, /* tex-coords cant be indexed in wgl */
//        unpack_indicies(texCoordIndex,point.toFloat32List(),2), RenderingContext.STATIC_DRAW);
//  }  
//}


//  /**
//   * unpacks the [index] by lookup from [point]
//   * returning a webgl compatible float array.
//   * 
//   * the problem is that x3d indexes its texture coordinates, normals, and colors,
//   * but in webgl, only verticies can be indexed.
//   */
//  Float32List unpack(MFInt32 index){
//    
//  }
//  
//  /**
//   * Builds an index using [point],
//   * every [restart_interval] is delimited by [restart_index].
//   */
//  MFInt32 pack({int restart_interval, int restart_index}){
//    
//  }