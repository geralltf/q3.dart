part of tech3;

class bsp_webgl_binders
{
  // Draw the map
  
  static bindShaderMatrix (shader_prog_t shader, Matrix4 modelViewMat, Matrix4 projectionMat) 
  {  
    
   // Set uniforms
   gl.uniformMatrix4fv(shader.uniform['modelViewMat'], false, storeMatrix4(modelViewMat));
   gl.uniformMatrix4fv(shader.uniform['projectionMat'], false, storeMatrix4(projectionMat));
  }
  
  static void bindShaderAttribs (shader_prog_t shader) 
  {
   
   // Setup vertex attributes
   gl.enableVertexAttribArray(shader.attrib['position']);
   gl.vertexAttribPointer(shader.attrib['position'], 3, 
                          RenderingContext.FLOAT, 
                          false, 
                          q3bsp_vertex_stride, 
                          0);
       
   if(shader.attrib['texCoord'] != null) 
   {
       gl.enableVertexAttribArray(shader.attrib['texCoord']);
       gl.vertexAttribPointer(shader.attrib['texCoord'], 2, 
                              RenderingContext.FLOAT, 
                              false, 
                              q3bsp_vertex_stride, 
                              3*4);
   }
   
   if(shader.attrib['lightCoord'] != null) 
   {
       gl.enableVertexAttribArray(shader.attrib['lightCoord']);
       gl.vertexAttribPointer(shader.attrib['lightCoord'], 
                              2, 
                              RenderingContext.FLOAT, 
                              false, 
                              q3bsp_vertex_stride, 
                              5*4);
   }
   
   if(shader.attrib['normal'] != null) 
   {
       gl.enableVertexAttribArray(shader.attrib['normal']);
       gl.vertexAttribPointer(shader.attrib['normal'], 
           3, 
           RenderingContext.FLOAT, 
           false, 
           q3bsp_vertex_stride, 
           7*4);
   }
   
   if(shader.attrib['color'] != null) 
   {
       gl.enableVertexAttribArray(shader.attrib['color']);
       gl.vertexAttribPointer(shader.attrib['color'], 
           4, 
           RenderingContext.FLOAT, 
           false, 
           q3bsp_vertex_stride, 
           10*4);
   }
  }


}