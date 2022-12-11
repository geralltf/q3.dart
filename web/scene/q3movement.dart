part of tech3;

/*
 * q3movement.js - Handles player movement through a bsp structure
 */

// Much of this file is a simplified/dumbed-down version of the Q3 player movement code
// found in bg_pmove.c and bg_slidemove.c


bool crouched = false;

class q3movement
{
  q3bsptree bsp;
  var groundTrace;
  
  q3movement(q3bsptree bsp)
  {
    this.bsp = bsp;
    
    this.groundTrace = null;
  }
  
  Vector3 crouchAmount = new Vector3(0.0, 0.0, 15.0);
  bool crouchDn()
  {
    if(crouched)
    {
      return crouchUp();
    }
    
    var cam = vec3(camera.getMovement());
    Vector3 moveTo = vector3(cam);
    Vector3 pos = -crouchAmount;
    
    moveTo = moveTo.add(pos);
    camera.applyMovement(moveTo);
    
    crouched = true;
    
    return true;
  }
  
  bool crouchUp()
  {
    var cam = vec3(camera.getMovement());
    Vector3 moveTo = vector3(cam);
    Vector3 pos = crouchAmount;
    
    moveTo = moveTo.add(pos);
    camera.applyMovement(moveTo);
    
    crouched = false;
    
    return true;
  }
  
  bool jump() 
  {
      //if(!camera.onGround) { return false; } // if your not on ground hold space you have jetpack
      
      camera.onGround = false;
      camera.velocity[2] = q3movement_jumpvelocity;
      
      if(this.groundTrace != null && this.groundTrace['plane']!= null)
      {
        // Make sure that the player isn't stuck in the ground
        
        double groundDist = vec3_dot( vec3(camera.getMovement()), vec3(this.groundTrace['plane'].normal) ) - this.groundTrace['plane'].distance - q3movement_playerRadius;
        
        var cam = vec3(camera.getMovement());
              
        var moveTo = vec3_scale(vec3(this.groundTrace['plane'].normal), groundDist + 5.0);
        
        camera.applyMovement(vector3(vec3_add(cam, moveTo)));
              
      }
      
      return true;
  }

  void move (List<double> direction, int frameTime) 
  {
      q3movement_frameTime = frameTime*0.0075;
      
      this.groundCheck();
      
      direction = vec3_normalize(direction);
      
      if(camera.onGround) 
      {
          this.walkMove(direction);
      } 
      else 
      {
          this.airMove(direction);
      }
  }

  void airMove (List<double> dir) 
  {
      double speed = vec3_length(dir) * q3movement_scale;
      
      this.accelerate(dir, speed, q3movement_airaccelerate);
      
      bool apply_gravity = true;
      this.stepSlideMove( apply_gravity );
  }

  void walkMove (List<double> direction) 
  {
      this.applyFriction();
      
      double speed = vec3_length(direction) * q3movement_scale;
      
      camera.velocity = vector3(this.accelerate(direction, speed, q3movement_accelerate));
      
      List<double> normal = vec3(this.groundTrace['plane'].normal);
      
      camera.velocity = vector3(this.clipVelocity(vec3(camera.velocity), normal));

      if(camera.velocity.x == 0 && camera.velocity.y == 0) { return; }      //if(!this.velocity[0] && !this.velocity[1]) { return; }

      
      bool apply_gravity = false;
      this.stepSlideMove( apply_gravity );
  }

  void stepSlideMove (bool apply_gravity) 
  {
      List<double> start_o = vec3_set(vec3(camera.getMovement()));
      List<double> start_v = vec3_set(vec3(camera.velocity));
      
      if ( this.slideMove( apply_gravity ) == false ) 
      { 
        return; // we got exactly where we wanted to go first try 
      } 

      List<double> down = vec3_set(start_o); // var down = vec3_set(start_o, [0,0,0]);
      
      down[2] -= q3movement_stepsize;
      var trace = this.bsp.trace(start_o, down, q3movement_playerRadius);
      
      List<double> up = [0.0, 0.0, 1.0];
      
      // never step up when you still have up velocity
      if ( camera.velocity.z > 0 && (trace['fraction'] == 1.0 || vec3_dot(vec3(trace['plane'].normal), up) < 0.7)) { return; }
      
      //var down_o = vec3.set(this.position, [0,0,0]);
      //var down_v = vec3.set(this.velocity, [0,0,0]);
      
      //start_o = vec3_set (up);
      up = vec3_set(start_o); // vec3_set(start_o, up);
      up[2] += q3movement_stepsize;
      
      // test the player position if they were a stepheight higher
      trace = this.bsp.trace(start_o, up, q3movement_playerRadius);
      if ( trace['allSolid'] ) { return; } // can't step up
      
      double stepSize = trace['endPos'][2] - start_o[2];
      // try slidemove from this position
      //trace['endPos'] = vec3_set(this.position);
      camera.applyMovement(vector3(vec3_set(trace['endPos']))); // vec3_set(trace.endPos, this.position);
      camera.velocity = vector3(vec3_set(start_v)); // vec3_set(start_v, this.velocity);
      
      this.slideMove( apply_gravity );
      
      // push down the final amount
      //this.position = vec3_set(down);
      down = vec3_set(vec3(camera.getMovement())); // vec3_set(this.position, down);
      down[2] -= stepSize;
      trace = this.bsp.trace(vec3(camera.getMovement()), down, q3movement_playerRadius);
      
      if ( trace['allSolid'] ==false ) 
      {
        //trace['endPos'] = vec3_set(this.position);
        camera.applyMovement(vector3(vec3_set(trace['endPos']))); // vec3_set(trace.endPos, this.position);
      }
      if ( trace['fraction'] < 1.0 ) 
      {
        camera.velocity = vector3(this.clipVelocity( vec3(camera.velocity), vec3(trace['plane'].normal) ));
      }
  }
  
  bool slideMove (bool apply_gravity) 
  {
      int bumpcount;
      int numbumps = 4;
      //List planes = [];
      Queue planes = new Queue();
      
      List<double> endVelocity = [0.0, 0.0, 0.0];
      
      if ( apply_gravity ) 
      {
          endVelocity = vec3_set(vec3(camera.velocity) ); // vec3_set(this.velocity, endVelocity );
          endVelocity[2] -= q3movement_gravity * q3movement_frameTime;
          camera.velocity.z = ( camera.velocity.z + endVelocity[2] ) * 0.5;
          
          if ( this.groundTrace != null && this.groundTrace['plane'] != null) {
              // slide along the ground plane
            camera.velocity = vector3(this.clipVelocity(vec3(camera.velocity), vec3(this.groundTrace['plane'].normal)));
          }
      }

      // never turn against the ground plane
      if ( this.groundTrace != null && this.groundTrace['plane'] != null ) 
      {
          planes.addLast(vec3_set(vec3(this.groundTrace['plane'].normal)));
      }

      // never turn against original velocity
      planes.addLast(vec3_normalize(vec3(camera.velocity)));
      
      double time_left = q3movement_frameTime;
      List<double> end = [0.0, 0.0, 0.0];
      
      for(bumpcount=0; bumpcount < numbumps; ++bumpcount) 
      {
        
        var pos = camera.getMovement();
          
          // calculate position we are trying to move to
          end = vec3_add(vec3(pos), vec3_scale(vec3(camera.velocity), time_left));
          
          // see if we can make it there
          var trace = this.bsp.trace(vec3(pos), end, q3movement_playerRadius);

          if (trace['allSolid']) 
          {
              // entity is completely trapped in another solid
            camera.velocity.z = 0.0;   // don't build up falling damage, but allow sideways acceleration
              return true;
          }

          if (trace['fraction'] > 0) 
          {
              // actually covered some distance
              //vec3_set(trace.endPos, this.position);
            camera.applyMovement(vector3(vec3_set(trace['endPos'])));
          }

          if (trace['fraction'] == 1) 
          {
               break;     // moved the entire distance
          }
          
          time_left -= time_left * trace['fraction'];
          
          planes.addLast(vec3_set(vec3(trace['plane'].normal)));

          //
          // modify velocity so it parallels all of the clip planes
          //

          // find a plane that it enters
          for(int i = 0; i < planes.length; ++i) 
          {
            
              var into = vec3_dot(vec3(camera.velocity), planes.elementAt(i));
              if ( into >= 0.1 ) { continue; } // move doesn't interact with the plane
              
              // slide along the plane
              List<double> clipVelocity = this.clipVelocity(vec3(camera.velocity), planes.elementAt(i));
              List<double> endClipVelocity = this.clipVelocity(endVelocity, planes.elementAt(i));

              // see if there is a second plane that the new move enters
              for (int j = 0; j < planes.length; j++) 
              {
                  if ( j == i ) { continue; }
                  if ( vec3_dot( clipVelocity, planes.elementAt(j) ) >= 0.1 ) { continue; } // move doesn't interact with the plane
                  
                  // try clipping the move to the plane
                  clipVelocity = this.clipVelocity( clipVelocity, planes.elementAt(j) );
                  endClipVelocity = this.clipVelocity( endClipVelocity, planes.elementAt(j) );

                  // see if it goes back into the first clip plane
                  if ( vec3_dot( clipVelocity, planes.elementAt(i) ) >= 0 ) { continue; }

                  // slide the original velocity along the crease
                  List<double> direction = [0.0, 0.0, 0.0];
                  direction=vec3_cross(planes.elementAt(i), planes.elementAt(j));
                  direction=vec3_normalize(direction);
                  var d = vec3_dot(direction, vec3(camera.velocity));
                  clipVelocity = vec3_scale(direction, d);

                  direction =vec3_cross(planes.elementAt(i), planes.elementAt(j));
                  direction = vec3_normalize(direction);
                  d = vec3_dot(direction, endVelocity);
                  endClipVelocity = vec3_scale(direction, d);

                  // see if there is a third plane the the new move enters
                  for(var k = 0; k < planes.length; ++k) 
                  {
                      if ( k == i || k == j ) { continue; }
                      if ( vec3_dot( clipVelocity, planes.elementAt(k) ) >= 0.1 ) { continue; } // move doesn't interact with the plane
                      
                      // stop dead at a tripple plane interaction
                      camera.velocity = vector3([0.0, 0.0, 0.0]);
                      return true;
                  }
              }

              // if we have fixed all interactions, try another move
              camera.velocity =  vector3(vec3_set( clipVelocity )); // vec3_set( clipVelocity, this.velocity );
              endVelocity = vec3_set( endClipVelocity ); // vec3_set( endClipVelocity, endVelocity );
              break;
          }
      }

      if ( apply_gravity ) 
      {
        camera.velocity  = vector3(vec3_set( endVelocity)); // vec3_set( endVelocity, this.velocity );
      }

      return ( bumpcount != 0 );
  }

  void applyFriction () 
  {
      if(!camera.onGround) { return; }
      
      double speed = vec3_length(vec3(camera.velocity));
      
      double drop = 0.0;
      
      double control = speed < q3movement_stopspeed ? q3movement_stopspeed : speed;
      drop += control*q3movement_friction*q3movement_frameTime;
      
      double newSpeed = speed - drop;
      if (newSpeed < 0.0) 
      {
          newSpeed = 0.0;
      }
      if(speed != 0.0) 
      {
          newSpeed /= speed;
          camera.velocity = vector3(vec3_scale(vec3(camera.velocity), newSpeed));
      } 
      else 
      {
        camera.velocity = vector3([0.0, 0.0, 0.0]);
      }
  }

  void groundCheck() 
  {
    Vector3 pos = camera.getMovement();
    List<double> checkPoint = [pos.x, pos.y, pos.z - q3movement_playerRadius - 0.25];
      
    this.groundTrace = this.bsp.trace(vec3(pos), checkPoint, q3movement_playerRadius);
    
    if(this.groundTrace['fraction'] == 1.0) { // falling
        camera.onGround = false;
        return;
    }
    
    if ( camera.velocity.z > 0 && vec3_dot( vec3(camera.velocity), vec3(this.groundTrace['plane'].normal) ) > 10 ) 
    { // jumping
        camera.onGround = false;
        return;
    }
    
    if(this.groundTrace['plane'].normal.z < 0.7) 
    { // steep slope
        camera.onGround = false;
        return;
    }
    
    camera.onGround = true;
  }

  List<double> clipVelocity (List<double> velIn, List<double> normal) 
  {
      double backoff = vec3_dot(velIn, normal);
      
      if ( backoff < 0 ) 
      {
          backoff *= q3movement_overclip;
      } 
      else 
      {
          backoff /= q3movement_overclip;
      }
      
      List<double> change = vec3_scale(normal, backoff);
      change = vec3_subtract(velIn, change);
      return change;
  }
  
  List<double> accelerate (List<double> dir, double speed, double accel) 
  {
      double currentSpeed = vec3_dot(vec3(camera.velocity), dir);
      double addSpeed = speed - currentSpeed;
      
      if (addSpeed <= 0) 
      {
          return [0.0, 0.0, 0.0];
      }
      
      double accelSpeed = accel*q3movement_frameTime*speed;
      if (accelSpeed > addSpeed) {
          accelSpeed = addSpeed;
      }
      
      List<double> accelDir = vec3_scale(dir, accelSpeed);
      
      
      return vec3_add(vec3(camera.velocity),accelDir);
  }
}