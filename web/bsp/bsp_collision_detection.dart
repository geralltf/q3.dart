part of tech3;

//
// BSP Collision Detection
//

class bsp_collision_detection
{

  static trace (traceId, List<double> start, List<double> end, double radius, bool slide) 
  {
   if(radius == null) { radius = 0.0; }
   if(slide == null) { slide = false; }
   
   if (brushSides == null) { return end; }
   
   var output = {
       "startsOut": true,
       "allSolid": false,
       "plane": null,
       "fraction": 1.0
   };
   
   traceNode(0, 0, 1, start, end, radius, output);
   
   if(output['fraction'] != 1) { // collided with something
       if(slide && output['plane']) {
           var endDist = (vec3_dot( end, output['plane']['normal'] ) - (output['plane']['distance'] + radius + 0.03125)).abs();
           for (var i = 0; i < 3; i++) {
               end[i] = end[i] + endDist * (output['plane']['normal'][i]);
           }
       } else {
           for (var i = 0; i < 3; i++) {
               end[i] = start[i] + output['fraction'] * (end[i] - start[i]);
           }
       }
   }
   
   postMessage2({
       "type": 'trace',
       "traceId": traceId,
       "end": end
   },null);
  }
  
  static traceNode (nodeIdx, startFraction, endFraction, 
      List<double> start, List<double> end, double radius, output) 
  {
   if (nodeIdx < 0) { // Leaf node?
       var leaf = leaves.elementAt(-(nodeIdx + 1));
       
       for (var i = 0; i < leaf['leafBrushCount']; i++) 
       {
           var brush = brushes[leafBrushes[leaf['leafBrush'] + i]];
           shader_p shader = shaders[brush['shader']];
           
           if (brush['brushSideCount'] > 0 && (shader.contents != null)) // (shader['contents'] & 1)) 
           {
               traceBrush(brush, start, end, radius, output);
           }
       }
       return;
   }
   
   // Tree node
   var node = nodes.elementAt(nodeIdx);
   var plane = planes.elementAt(node['plane']);
   
   double startDist = vec3_dot(plane['normal'], start) - plane['distance'];
   double endDist = vec3_dot(plane['normal'], end) - plane['distance'];
   
   if (startDist >= radius && endDist >= radius) 
   {
       traceNode(node.children[0], startFraction, endFraction, start, end, radius, output );
   } 
   else if (startDist < -radius && endDist < -radius) 
   {
       traceNode(node.children[1], startFraction, endFraction, start, end, radius, output );
   } 
   else 
   {
       var side;
       double fraction1, fraction2, middleFraction;
       List<double> middle = [0.0, 0.0, 0.0];
  
       if (startDist < endDist) 
       {
           side = 1; // back
           var iDist = 1 / (startDist - endDist);
           fraction1 = (startDist - radius + 0.03125) * iDist;
           fraction2 = (startDist + radius + 0.03125) * iDist;
       } 
       else if (startDist > endDist) 
       {
           side = 0; // front
           var iDist = 1 / (startDist - endDist);
           fraction1 = (startDist + radius + 0.03125) * iDist;
           fraction2 = (startDist - radius - 0.03125) * iDist;
       } 
       else 
       {
           side = 0; // front
           fraction1 = 1.0;
           fraction2 = 0.0;
       }
       
       if (fraction1 < 0) fraction1 = 0.0;
       else if (fraction1 > 1) fraction1 = 1.0;
       if (fraction2 < 0) fraction2 = 0.0;
       else if (fraction2 > 1) fraction2 = 1.0;
       
       middleFraction = startFraction + (endFraction - startFraction) * fraction1;
       
       for (var i = 0; i < 3; i++) 
       {
           middle[i] = start[i] + fraction1 * (end[i] - start[i]);
       }
       
       traceNode(node.children[side], startFraction, middleFraction, start, middle, radius, output );
       
       middleFraction = startFraction + (endFraction - startFraction) * fraction2;
       
       for (var i = 0; i < 3; i++) {
           middle[i] = start[i] + fraction2 * (end[i] - start[i]);
       }
       
       traceNode(node.children[side==0?1:0], middleFraction, endFraction, middle, end, radius, output );
   }
  }
  
  static traceBrush (brush, List<double> start, List<double> end, double radius, output) 
  {
   var startFraction = -1;
   var endFraction = 1;
   bool startsOut = false;
   bool endsOut = false;
   var collisionPlane = null;
   
   for (var i = 0; i < brush.brushSideCount; i++) {
       var brushSide = brushSides[brush['brushSide'] + i];
       var plane = planes.elementAt(brushSide['plane']);
       
       var startDist = vec3_dot( start, plane['normal'] ) - (plane['distance'] + radius);
       var endDist = vec3_dot( end, plane['normal'] ) - (plane['distance'] + radius);
  
       if (startDist > 0) startsOut = true;
       if (endDist > 0) endsOut = true;
  
       // make sure the trace isn't completely on one side of the brush
       if (startDist > 0 && endDist > 0) { return; }
       if (startDist <= 0 && endDist <= 0) { continue; }
  
       if (startDist > endDist) { // line is entering into the brush
           var fraction = (startDist - 0.03125) / (startDist - endDist);
           if (fraction > startFraction) {
               startFraction = fraction;
               collisionPlane = plane;
           }
       } else { // line is leaving the brush
           var fraction = (startDist + 0.03125) / (startDist - endDist);
           if (fraction < endFraction)
               endFraction = fraction;
       }
   }
   
   if (startsOut == false) 
   {
       output['startsOut'] = false;
       if (endsOut == false)
           output['allSolid'] = true;
       return;
   }
  
   if (startFraction < endFraction) 
   {
       if (startFraction > -1 && startFraction < output['fraction']) 
       {
           output['plane'] = collisionPlane;
           if (startFraction < 0)
               startFraction = 0;
           output['fraction'] = startFraction;
       }
   }
   
   return;
  }

}