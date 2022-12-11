part of tech3;

//
// BSP Tree Collision Detection
//
class q3bsptree
{
  bsp_tree bsp;
  
  q3bsptree(bsp_tree bsp_data)
  {
    this.bsp = bsp_data;
  }
  
  trace (List<double> start, List<double> end, double radius) 
  {
      var output = {
          "allSolid": false,
          "startSolid": false,
          "fraction": 1.0,
          "endPos": end,
          "plane": null
      };
      
      if(this.bsp ==null) { return output; }
      if(radius == null) { radius = 0.0; }
      
      output = this.traceNode(0, 0.0, 1.0, start, end, radius, output);
      
      if(output['fraction'] != 1.0) { // collided with something
          for (var i = 0; i < 3; i++) {
              output['endPos'][i] = start[i] + output['fraction'] * (end[i] - start[i]);
          }
      }
      
      return output;
  }
  
  traceNode (int nodeIdx, double startFraction, double endFraction, 
             List<double> start, List<double> end, double radius, output) 
  {
      if (nodeIdx < 0) // Leaf node? 
      { 
          var leaf = this.bsp.leaves.elementAt(-(nodeIdx + 1));
          for (var i = 0; i < leaf['leafBrushCount']; i++) 
          {
              var brush = this.bsp.brushes[this.bsp.leafBrushes[leaf['leafBrush'] + i]];
              shader_p surface = this.bsp.surfaces[brush['shader']];
              
              if (brush['brushSideCount'] > 0 && surface.contents != null) // surface['contents'] & 1 
              {
                output = this.traceBrush(brush, start, end, radius,output);
              }
          }
          return output;
      }
      
      // Tree node
      bsp_tree_node node = this.bsp.nodes.elementAt(nodeIdx);
      Plane plane = this.bsp.planes.elementAt(node.plane);
      
      double startDist = vec3_dot(vec3(plane.normal), start) - plane.distance;
      double endDist = vec3_dot(vec3(plane.normal), end) - plane.distance;
      
      if (startDist >= radius && endDist >= radius) 
      {
        output = this.traceNode(node.children[0], startFraction, endFraction, start, end, radius, output );
      } 
      else if (startDist < -radius && endDist < -radius) 
      {
        output = this.traceNode(node.children[1], startFraction, endFraction, start, end, radius, output );
      } 
      else 
      {
          int side;
          double fraction1;
          double fraction2;
          double middleFraction;
          
          List<double> middle = [0.0, 0.0, 0.0];

          if (startDist < endDist) 
          {
              side = 1; // back
              var iDist = 1 / (startDist - endDist);
              fraction1 = (startDist - radius + q3bsptree_trace_offset) * iDist;
              fraction2 = (startDist + radius + q3bsptree_trace_offset) * iDist;
          } 
          else if (startDist > endDist) 
          {
              side = 0; // front
              var iDist = 1 / (startDist - endDist);
              fraction1 = (startDist + radius + q3bsptree_trace_offset) * iDist;
              fraction2 = (startDist - radius - q3bsptree_trace_offset) * iDist;
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
          
          for (var i = 0; i < 3; i++) {
              middle[i] = start[i] + fraction1 * (end[i] - start[i]);
          }
          
          output = this.traceNode(node.children[side], startFraction, middleFraction, start, middle, radius, output );
          
          middleFraction = startFraction + (endFraction - startFraction) * fraction2;
          
          for (var i = 0; i < 3; i++) 
          {
              middle[i] = start[i] + fraction2 * (end[i] - start[i]);
          }
          
          output = this.traceNode(node.children[side == 0 ? 1 : 0], middleFraction, endFraction, middle, end, radius, output );
      }
      
      return output;
  }
  
  traceBrush (brush, List<double> start, List<double> end, double radius, output) 
  {
      double startFraction = -1.0;
      double endFraction = 1.0;
      bool startsOut = false;
      bool endsOut = false;
      Plane collisionPlane = null;
      
      for (var i = 0; i < brush['brushSideCount']; i++) 
      {
          var brushSide = this.bsp.brushSides[brush['brushSide'] + i];
          Plane plane = this.bsp.planes.elementAt(brushSide['plane']);
          
          //Vector3
          double startDist = vec3_dot( start, vec3(plane.normal) ) - (plane.distance + radius);
          double endDist = vec3_dot( end, vec3(plane.normal) ) - (plane.distance + radius);

          if (startDist > 0) startsOut = true;
          if (endDist > 0) endsOut = true;

          // make sure the trace isn't completely on one side of the brush
          if (startDist > 0 && endDist > 0) 
          { 
            return output; 
          }
          if (startDist <= 0 && endDist <= 0) 
          { 
            continue; 
          }

          if (startDist > endDist) 
          { // line is entering into the brush
              double fraction = (startDist - q3bsptree_trace_offset) / (startDist - endDist);
              
              if (fraction > startFraction) 
              {
                  startFraction = fraction;
                  collisionPlane = plane;
              }
          } 
          else 
          { // line is leaving the brush
              double fraction = (startDist + q3bsptree_trace_offset) / (startDist - endDist);
              if (fraction < endFraction)
                  endFraction = fraction;
          }
      }
      
      if (startsOut == false) 
      {
          output['startSolid'] = true;
          if (endsOut == false)
              output['allSolid'] = true;
          return output;
      }

      if (startFraction < endFraction) 
      {
          if (startFraction > -1 && startFraction < output['fraction']) 
          {
              output['plane'] = collisionPlane;
              if (startFraction < 0)
                  startFraction = 0.0;
              output['fraction'] = startFraction;
          }
      }
      
      return output;
  }
}