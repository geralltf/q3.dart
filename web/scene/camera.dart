part of tech3;

typedef OnCameraRotate(x,y);

Camera camera = new Camera();

class Camera
{
  Vector3 velocity;
  bool onGround;
  bool inverted = false;
  
  Vector3 Forward, Up, Right, Look;
  Vector3 Position, Origin;
  Vector3 Rotation, OriginRotation;
  Quaternion Orientation;
  Matrix4 Matrix;
  
  Quaternion orientation_quat;
  
  Quaternion yaw;
  Quaternion pitch;
  Quaternion roll;
  
  Vector3 Direction;
  Vector3 movement;
  
  double camera_yaw = 0.0;
  double camera_pitch = 0.0;
  double max_pitch = 5.0;
  double max_yaw = 5.0;
  
  Vector3 getMovement() => Position;
  Vector3 applyMovement(Vector3 direction) => Position = direction;
  
  void invert()
  {
    invNeg();
  }
  
  bool invNeg()
  {
    if(inverted)
    {
      return invPos();
    }
    
    var cam = vec3(camera.getMovement());
    Vector3 moveTo = vector3(cam);
    Vector3 pos = UnitZ.scale(-1.0);
    
    moveTo = moveTo.add(pos);
    camera.applyMovement(moveTo);
    
    crouched = true;
    
    return true;
  }
  
  bool invPos()
  {
    if(!inverted)
    {
      return invNeg();
    }
    
    var cam = vec3(camera.getMovement());
    Vector3 moveTo = vector3(cam);
    Vector3 pos = UnitZ.scale(1.0);
    
    moveTo = moveTo.add(pos);
    camera.applyMovement(moveTo);
    
    crouched = false;
    
    return true;
  }
  
  void move(Vector3 direction, int frame_time)
  {
    //MoveX(direction.x);
    //MoveY(direction.y);
    
    moveViewOriented(direction, frame_time);
  }
  
  void update(int frame_time)
  {
    // todo: apply any current movement animations here
  }

  void MakeOrthogonal()
  {
    Look = Look.normalize();
    Up = Look.cross(Right);
    Right = Up.cross(Look);
    Up.normalize();
    Right.normalize();
  }
  
  void Yaw(double angle)
  {
    // Up
    Matrix4 m = new Matrix4.identity();
    m = m.rotate(Up, angle);
    
    // Transform vector by matrix, project result back into w = 1.0f
    Right = m.transform3(Right); // TransformVectorCoord
    Up = m.transform3(Look);
  }
  
  void Pitch(double angle)
  {
    // Right
    Matrix4 m = new Matrix4.identity();
    m = m.rotate(Right, angle);
    
    // Transform vector by matrix, project result back into w = 1.0f
    Right = m.transform3(Up); // TransformVectorCoord
    Up = m.transform3(Look);
  }
  
  void Roll(double angle)
  {
    // Look, Right and Up
    Matrix4 m = new Matrix4.identity();
    m = m.rotate(Look, angle);
    
    // Transform vector by matrix, project result back into w = 1.0f
    Right = m.transform3(Right); // TransformVectorCoord
    Up = m.transform3(Up);
  }
  
  void ForwardOne(double magnitude)
  {
    
  }
  
  void Walk(double magnitude)
  {
    Position += Look * magnitude;
  }
  
  void Strafe(double magnitude)
  {
    Vector3 Right = UnitX;
    Position += Right * magnitude;
  }
  
  void Fly(double units)
  {
    Position += Up * units;
  }
  
  void ApplyPitch(double degrees) 
  {
    //Check bounds with the max pitch rate so that we aren't moving too fast
//    if (degrees < -max_pitch) {
//      degrees = -max_pitch;
//    } else if (degrees > max_pitch) {
//      degrees = max_pitch;
//    }
//    camera_pitch += degrees;
//
//    //Check bounds for the camera pitch
//    if (camera_pitch > 360.0) {
//      camera_pitch -= 360.0;
//    } else if (camera_pitch < -360.0) {
//      camera_pitch += 360.0;
//    }
    
    camera_pitch = degrees 
        //* PiOver180
        ;
  }
  void ApplyYaw(double degrees) 
  {     
    //Check bounds with the max heading rate so that we aren't moving too fast
//    if (degrees < -max_yaw) {
//      degrees = -max_yaw;
//    } else if (degrees > max_yaw) {
//      degrees = max_yaw;
//    }
//    //This controls how the heading is changed if the camera is pointed straight up or down
//    //The heading delta direction changes
//    if (camera_pitch > 90 && camera_pitch < 270 || (camera_pitch < -90 && camera_pitch > -270)) {
//      camera_yaw -= degrees;
//    } else {
//      camera_yaw += degrees;
//    }
//    //Check bounds for the camera heading
//    if (camera_yaw > 360.0) {
//      camera_yaw -= 360.0;
//    } else if (camera_yaw < -360.0) {
//      camera_yaw += 360.0;
//    }
    
    camera_yaw = degrees 
        //* PiOver180
        
        ;
  }
  
  /*
   * Applies transformations using camera configuration and camera vectors and assigns a new View Matrix.
   */
  void ApplyTransformations()
  {
    
    Vector3 PlayerPosition = new Vector3(Position.x, Position.y, Position.z + playerHeight);
    
    Look = PlayerPosition + (Direction) * 1.0;
      
    Matrix4 out = new Matrix4.identity();
     
    Matrix = LookAt(PlayerPosition, Look, Up, out);
  }
  
  void ApplyRotation()
  {       
    Vector3 direction = (Look - Position).normalize();
    //MakeOrthogonal();
    
    Vector3 pitch_axis = direction.cross(Up);
    
    pitch = new Quaternion.axisAngle(pitch_axis, camera_pitch  ); // radians
    yaw = new Quaternion.axisAngle(Up, camera_yaw); // PiOver180
    //roll = new Quaternion.axisAngle(Right+Up, roll_angle);

    Orientation = yaw * pitch  /* roll */ ;
    
    Orientation = Orientation.normalize();
    
    this.Direction = Orientation.rotate(UnitX);
  }

  Matrix4 lookAt(Vector3 eye, Vector3 center, Vector3 up) 
  {
    return LookAt(eye,center,up, this.Matrix);
  }
  
  /*
  void RotateX(double a)
  {
    //TurnX(a);
    //Rotation.x += a;//MathHelper.Clamp(a, -1.57, 1.57);
  }
  
  void RotateY(double a)
  {
    //TurnY(a);
    //Rotation.y *= a;//MathHelper.ClampCircular(a, 0.0, TwoPi);
    //Rotation.y += a;
    //Rotation.y = MathHelper.ClampCircular(Rotation.y, 0.0, TwoPi);
    
  }

  void TurnX(double a)
  {
    Rotation.x = a;
    //Rotation.x = MathHelper.Clamp(Rotation.x, -1.57, 1.57);
    //Rotation.x = MathHelper.ClampCircular(Rotation.x, 0.0, TwoPi);
  }
 
  void TurnY(double a)
  {
    Rotation.y = a;
    //Rotation.y = MathHelper.ClampCircular(Rotation.y, 0.0, TwoPi);
  }
 
  void MoveX(double a)
  {
    Position += transformVec3(UnitX * a, new Quaternion.axisAngle(UnitY, Rotation.y));
    //Position += Vector3.Transform(UnitX * a, Quaternion.FromAxisAngle(UnitY, Rotation.Y));
  }
 
  void MoveY(double a)
  {
    Position += transformVec3(UnitY * a, new Quaternion.axisAngle(UnitY, Rotation.y));
    //Position += Vector3.Transform(UnitY * a, Quaternion.FromAxisAngle(UnitY, Rotation.Y));
  }
 
  void MoveZ(double a)
  {
    Position += transformVec3(UnitZ * a, new Quaternion.axisAngle(UnitY, Rotation.y));
    //Position += Vector3.Transform(UnitZ * a, Quaternion.FromAxisAngle(UnitY, Rotation.Y));
  }
 
  void MoveYLocal(double a)
  {
    Position += transformVec3(UnitY * a, Orientation);
    //Position += Vector3.Transform(UnitY * a, Orientation);
  }
 
  void MoveZLocal(double a)
  {
    Position += transformVec3(UnitZ * a, Orientation);
    //Position += Vector3.Transform(UnitZ * a, Orientation);
  }*/
 
  void Reset()
  {
    // Could be used for respawning
    Position = Origin;
    Rotation = OriginRotation;
    Orientation = new Quaternion.identity();
    //xAngle = 0.0;
  }
  
  void setOrigin(Vector3 origin, Vector3 rotation)
  {
    Position = Origin = origin;
    Rotation = OriginRotation = rotation;
    Orientation = new Quaternion.identity();
    //xAngle = 0.0;
    camera_pitch = OriginRotation.x * PiOver180;
    camera_yaw = OriginRotation.z * PiOver180 ;
  }
  
  Camera()
  {
    velocity = new Vector3.zero();
    onGround = false;
    
    Matrix = new Matrix4.identity();
    Orientation = new Quaternion.identity();
    Position = Origin = movement = new Vector3.zero();
    Rotation = new Vector3.zero();
    yaw = new Quaternion.identity();
    pitch = new Quaternion.identity();
    roll = new Quaternion.identity();
    
    Look = new Vector3.zero();
    Up = new Vector3.zero();
    Right = new Vector3.zero();
    
    Up = UnitZ; // glm::vec3(0, 1, 0)
    Right = UnitX;
    Forward = UnitY;
    Direction = Forward;
  }
  
}