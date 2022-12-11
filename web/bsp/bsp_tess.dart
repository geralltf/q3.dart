part of tech3;

class bsp_tess
{
  // Build Bezier curve
  static tesselate (Map face, List verts, List meshVerts, int level) 
  {
    if(level == null) level = 0;
    
    int i,j,row,col,px,py;
    var off = face['vertex'];
    //int count = face['vertCount'];
   
    var L1 = level + 1;
   
   face['vertex'] = verts.length;
   face['meshVert'] = meshVerts.length;
   
   face['vertCount'] = 0;
   face['meshVertCount'] = 0;
   
   for(py = 0; py < face['size'][1]-2; py += 2) 
   {
       for(px = 0; px < face['size'][0]-2; px += 2) 
       {
           
           var rowOff = (py*face['size'][0]);
           
           // Store control points
           Map c0 = verts[off+rowOff+px], c1 = verts[off+rowOff+px+1], c2 = verts[off+rowOff+px+2];
           rowOff += face['size'][0];
           Map c3 = verts[off+rowOff+px], c4 = verts[off+rowOff+px+1], c5 = verts[off+rowOff+px+2];
           rowOff += face['size'][0];
           Map c6 = verts[off+rowOff+px], c7 = verts[off+rowOff+px+1], c8 = verts[off+rowOff+px+2];
           
           var indexOff = face['vertCount'];
           face['vertCount'] += L1 * L1;
           
           // Tesselate!
           for(var i = 0; i < L1; ++i) 
           {
               double a = i.toDouble() / level.toDouble();
               
               List<double> pos = getCurvePoint3(c0['pos'], c3['pos'], c6['pos'], a);
               List<double> lmCoord = getCurvePoint2(c0['lmCoord'], c3['lmCoord'], c6['lmCoord'], a);
               List<double> texCoord = getCurvePoint2(c0['texCoord'], c3['texCoord'], c6['texCoord'], a);
               List<double> color = getCurvePoint3(c0['color'], c3['color'], c6['color'], a);
               
               var vert = {
                   "pos": pos,
                   "texCoord": texCoord,
                   "lmCoord": lmCoord,
                   "color": [color[0], color[1], color[2], 1.0],
                   "lmNewCoord": [ 0.0, 0.0 ],
                   "normal": [0.0, 0.0, 1.0]
               };
               
               verts.add(vert);
           }
           
           for(i = 1; i < L1; i++) 
           {
               double a = i.toDouble() / level.toDouble();
               
               List<double> pc0 = getCurvePoint3(c0['pos'], c1['pos'], c2['pos'], a);
               List<double> pc1 = getCurvePoint3(c3['pos'], c4['pos'], c5['pos'], a);
               List<double> pc2 = getCurvePoint3(c6['pos'], c7['pos'], c8['pos'], a);
               
               List<double> tc0 = getCurvePoint3(c0['texCoord'], c1['texCoord'], c2['texCoord'], a);
               List<double> tc1 = getCurvePoint3(c3['texCoord'], c4['texCoord'], c5['texCoord'], a);
               List<double> tc2 = getCurvePoint3(c6['texCoord'], c7['texCoord'], c8['texCoord'], a);
               
               List<double> lc0 = getCurvePoint3(c0['lmCoord'], c1['lmCoord'], c2['lmCoord'], a);
               List<double> lc1 = getCurvePoint3(c3['lmCoord'], c4['lmCoord'], c5['lmCoord'], a);
               List<double> lc2 = getCurvePoint3(c6['lmCoord'], c7['lmCoord'], c8['lmCoord'], a);
               
               List<double> cc0 = getCurvePoint3(c0['color'], c1['color'], c2['color'], a);
               List<double> cc1 = getCurvePoint3(c3['color'], c4['color'], c5['color'], a);
               List<double> cc2 = getCurvePoint3(c6['color'], c7['color'], c8['color'], a);
               
               for(j = 0; j < L1; j++)
               {
                   double b = i.toDouble() / level.toDouble();
                   
                   List<double> pos = getCurvePoint3(pc0, pc1, pc2, b);
                   List<double> texCoord = getCurvePoint2(tc0, tc1, tc2, b);
                   List<double> lmCoord = getCurvePoint2(lc0, lc1, lc2, b);
                   List<double> color = getCurvePoint3(cc0, cc1, cc2, a);
                   
                   var vert = {
                       "pos": pos,
                       "texCoord": texCoord,
                       "lmCoord": lmCoord,
                       "color": [color[0], color[1], color[2], 1.0],
                       "lmNewCoord": [ 0.0, 0.0 ],
                       "normal": [0.0, 0.0, 1.0]
                   };
               
                   verts.add(vert);
               }
           }
           
           face['meshVertCount'] += level * level * 6;
           
           for(row = 0; row < level; ++row) 
           {
               for(col = 0; col < level; ++col) 
               {
                   meshVerts.add(indexOff + (row + 1) * L1 + col);
                   meshVerts.add(indexOff + row * L1 + col);
                   meshVerts.add(indexOff + row * L1 + (col+1));
                   
                   meshVerts.add(indexOff + (row + 1) * L1 + col);
                   meshVerts.add(indexOff + row * L1 + (col+1));
                   meshVerts.add(indexOff + (row + 1) * L1 + (col+1));
               }
           }
   
       }
   }
  }
  
  //
  // Curve Tesselation
  //

  static List<double> getCurvePoint3 (List<double> c0, List<double> c1, List<double> c2, double dist) 
  {
   var b = 1.0 - dist;

   return vec3_add(
       vec3_add(
           vec3_scale(c0, b*b ),
           vec3_scale(c1, (2*b*dist) )
       ),
       vec3_scale(c2, (dist*dist) )
     );
       
//   return vec3.add(
//       vec3.add(
//           vec3.scale(c0, (b*b), [0, 0, 0]),
//           vec3.scale(c1, (2*b*dist), [0, 0, 0])
//       ),
//       vec3.scale(c2, (dist*dist), [0, 0, 0])
//   );
  }

  // This is kinda ugly. Clean it up at some point?
  static List<double> getCurvePoint2 (List<double> c0, List<double> c1, List<double> c2, double dist) 
  {
     double b = 1.0 - dist;
     
     List<double> c30 = [c0[0], c0[1], 0.0];
     List<double> c31 = [c1[0], c1[1], 0.0];
     List<double> c32 = [c2[0], c2[1], 0.0];
     
     var res = vec3_add(
         vec3_add(
             vec3_scale(c30, (b*b)),
             vec3_scale(c31, (2*b*dist))
         ),
         vec3_scale(c32, (dist*dist))
     );
     
     return [res[0], res[1]];
  }
}