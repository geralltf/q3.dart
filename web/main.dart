// Copyright (c) 2015, Gerallt G. Franke. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library tech3;

/*
Symbol symGetError = new Symbol('getError');
Symbol symGetActiveAttrib = new Symbol('getActiveAttrib');
Symbol symTexImage2D = new Symbol('texImage2D');
Symbol symCreateTexture  = new Symbol('createTexture');
Symbol symBindTexture  = new Symbol('bindTexture');
Symbol symCreateShader  = new Symbol('createShader');
Symbol symShaderSource  = new Symbol('shaderSource');
Symbol symCompileShader = new Symbol('compileShader');
Symbol symGetShaderParameter = new Symbol('');
Symbol symGetShaderInfoLog = new Symbol('');
Symbol symDeleteShader = new Symbol('');
Symbol symCreateProgram = new Symbol('');
Symbol symAttachShader = new Symbol('');
*/

//texImage2D_06, texImage2D_09, getUniformLocation, getActiveUniform, getAttribLocation, deleteProgram, getProgramParameter, linkProgram, attachShader, createProgram, deleteShader, getShaderInfoLog, getShaderParameter

//@MirrorsUsed(symbols: 'getUniformLocation')

import 'dart:mirrors';
import 'dart:math';
import 'dart:html';
//import 'dart:json' as json;
import 'dart:web_gl';
import 'dart:async';
import 'dart:js';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:web_audio';
import 'package:vector_math/vector_math.dart';
import 'package:json_object/json_object.dart';
import 'dart:nativewrappers';

part 'tech3.dart';
part 'bsp/q3bsp.dart';
part 'gl/webgl_interface.dart';
part 'gl/rendering_context.dart';
part 'gl/rendering_context_dartwebgl.dart';
part 'gl/rendering_context___js_proxy.dart';
part 'gl/rendering_context_nativewebgljs_interop.dart';
part 'gl/rendering_context_dummy.dart';
part 'gl/rendering_context_helpers.dart';
part 'gl/rendering_context_unittest.dart';
part 'gl/hack_webgl_pipe.dart';
part 'VrHmdDevice.dart';
part 'Viewport.dart';
part 'StatsFps.dart';
part 'MathHelpers.dart';

part 'shading/sharder_parse_types.dart';
part 'shading/q3shader.dart';
part 'shading/q3glshader.dart';
part 'shading/shaderBuilder.dart';
part 'shading/shaderTokenizer.dart';

part 'bsp/binary_stream.dart';
part 'bsp/bsp_parser.dart';
part 'bsp/bsp_helpers.dart';
part 'bsp/bsp_tess.dart';
part 'bsp/bsp_collision_detection.dart';
part 'bsp/bsp_visibility_checking.dart';
part 'bsp/bsp_compiler.dart';
part 'bsp/bsp_webgl_builders.dart';
part 'bsp/bsp_webgl_binders.dart';
part 'bsp/q3bsptree.dart';
part 'bsp/geometric_properties.dart';

part 'md3/Byter.dart';
part 'md3/q3_texturepool.dart';
part 'md3/q3_surface_vbo.dart';
part 'md3/q3_surface_shader_pass_geom.dart';
part 'md3/q3_surface_shader.dart';
part 'md3/q3_object.dart';
part 'md3/q3_depnode.dart';
part 'md3/q3_player.dart';
part 'md3/q3_weapon.dart';
part 'md3/q3_surface_shader_generic.dart';
part 'md3/md3_tagframe.dart';
part 'md3/md3_skin_file.dart';
part 'md3/md3_tag.dart';
part 'md3/md3_surfaceframe.dart';
part 'md3/md3_surface.dart';
part 'md3/md3_shader.dart';
part 'md3/md3_frame.dart';
part 'md3/md3_header.dart';
part 'md3/md3_file.dart';

part 'scene/DwShader.dart';
part 'scene/q3movement.dart';
part 'scene/camera.dart';
part 'scene/texture.dart';
part 'scene/skybox.dart';
part 'scene/scene.dart';
part 'scene/audio_graph.dart';
part 'scene/viewport_ui.dart';
part 'scene/tone_marker.dart';
part 'scene/DwImage.dart';
part 'scene/DwImage_TGA.dart';
part 'scene/Input.dart';
part 'scene/DOF_shader.dart';
part 'scene/DwFBO.dart';
part 'scene/DwState.dart';

part 'ui/jQuery.dart';
part 'game/player.dart';


typedef OnBspLoadComplete(q3bsptree bsp);
typedef OnBspIncompatible(bsp_header_t header);

//TODO: refactor engine and utilse these typedefs
typedef OnParse();
typedef OnCompilation();
typedef OnTesselateStage(int stage);

var q3_frame_IDX = 0;
rendering_context gl; //RenderingContext gl;
bool drawMap = true;
String keyspressed = '';
double xAngle = 0.0, yAngle  = 0.0;    
double roll_angle=0.0;

void main()
{
  scene_init();
  
  print("[initilising] retrofitted iDTech3/q3");  
  
  stats = new StatsFps();
  stats.display();
  
  canvas = query("#viewport");
  //gl = canvas.getContext3d();
  gl = new rendering_context();

  if(gl == null) 
  {
    query('#viewport-frame').style.display = 'none';
    query('#webgl-error').style.display = 'block';
  } 
  else 
  {
    query('#viewport-info').style.display = 'block';
    initEvents();
    initGL(gl);
      
    renderLoop(gl, canvas);
  }

  onResize(null);
  window.onResize.listen(onResize);

  CheckboxInputElement showFPS = query("#showFPS");
  showFPS.onChange.listen((event) {
    stats.domElement.style.display = showFPS.checked ? "block" : "none";
  });
  
  
  
  detectVR();

  /*var playMusic = document.getElementById("playMusic");
  playMusic.addEventListener("change", function() {
      if(map) {
          map.playMusic(playMusic.checked);
      }
  });*/

  bsp_compiler.init();
  
  
  leftViewport.width = canvas.clientWidth.toDouble();
  leftViewport.height = canvas.clientHeight.toDouble();
  player.LoadPlayerModels(gl,leftViewport);
  
  print("[initilised] iDTech3/q3");
}

String getQueryVariable(variable) 
{
  return Uri.base.queryParameters[variable]; // is value returned unescape() 'd
}

void showLoadStatus () 
{
    var loading = query('#LoadingIndicator');
    loading.style.display = 'block';
}

void onLoadStatus (message) 
{
  var loading = query('#LoadingIndicator');
    loading.innerHtml = message;
}

void clearLoadStatus() 
{
  var loading = query('#LoadingIndicator');
    loading.style.display = 'none';
}

void initGL(rendering_context gl) 
{
   gl.clearColor(0.0, 0.0, 0.0, 1.0);
   gl.clearDepth(1.0);
   
   gl.enable(RenderingContext.DEPTH_TEST);
   gl.enable(RenderingContext.BLEND);
   gl.enable(RenderingContext.CULL_FACE);
  
   leftViewMat = new Matrix4.identity();
   rightViewMat = new Matrix4.identity();
   leftProjMat = new Matrix4.identity();
   rightProjMat = new Matrix4.identity();
  
   leftViewport = Viewport.zero();
   rightViewport = Viewport.zero();
  
   initMap(gl);
   
   //oculus = new OculusRift(gl);
}

// Load the map
void initMap(rendering_context gl) 
{
   Element titleEl = query("#mapTitle");
   titleEl.innerHtml = map_title;
  
   String tesselation = getQueryVariable("tesselate");
   int tess_level;
   if(tesselation != null) 
   {
     tess_level = int.parse(tesselation); // radix =  10
   }
  
   var vrMode = getQueryVariable("vrDrawMode");
   if (vrMode != null) 
   {
     vrForced = true;
     vrDrawMode = int.parse(vrMode); // radix =  10
   }
  
   map = new q3bsp(gl);
   q3bsp.onentitiesloaded = bsp_entities_initilised;
   q3bsp.onbsp = bsp_initilised;
   //map.onsurfaces = initSurfaces;
   q3bsp.loadShaders(mapShaders);
   
   bsp_compiler.load(map_uri, tess_level, null);
}

void bsp_entities_initilised(Map entities) 
{
  // Process entities loaded from the map  
}

// "Respawns" the player at a specific spawn point. Passing -1 will move the player to the next spawn point.
void respawnPlayer(int index) 
{
    if(q3bsp.entities != null && playerMover != null) 
    {
        String spawn_point_param_name;
        
        spawn_point_param_name = 'info_player_deathmatch'; // Quake 3 bsp file
        if(!q3bsp.entities.containsKey(spawn_point_param_name))
        {
          spawn_point_param_name = 'info_player_start'; // TREMULOUS bsp file
        }
      
        if(index == -1) {
            index = (lastIndex+1)% q3bsp.entities[spawn_point_param_name].length;
        }
        lastIndex = index;

        var spawnPoint = q3bsp.entities[spawn_point_param_name][index];
        double zAngle = -((spawnPoint['angle'] != null ? spawnPoint['angle'] : 0.0)) * (PI/180.0) + (PI*0.5); // Negative angle in radians + 90 degrees
        double xAngle = 0.0;
        Vector3 rotation = new Vector3(xAngle, 0.0, zAngle);
        camera.setOrigin(new Vector3(
            spawnPoint['origin'][0], 
            spawnPoint['origin'][1],
            spawnPoint['origin'][2]+30 // Start a little ways above the floor) [
        ),rotation);
        
        camera.velocity = new Vector3.zero();

        //camera.Reset();
    }
}

void onFrame(rendering_context gl, int timestamp, int elapsed, int frameTime) 
{
    if(map == null || playerMover == null) 
    { 
      return; 
    }

    const int timing = 16;
    
    // Update player movement to 60FPS
    // The while ensures that we update at a fixed rate even if the rendering bogs down
    while(elapsed - lastMove >= timing) 
    {
        updateInput(timing);
       lastMove += timing;
    }

    // For great laggage!
    for (var i = 0; i < REPEAT_FRAMES; ++i)
    {
      drawFrame(gl);
    }
}

Matrix4 getViewMatrix(bool translated, vrPosition, eyeOffset, Matrix4 projection) 
{
  Matrix4 out = new Matrix4.identity();

  if (vrPosition != null) 
  {
    Quaternion orientationQuaternion = getQuaternionXYZW(-vrPosition['orientation']['x'], -vrPosition['orientation']['y'], -vrPosition['orientation']['z'], vrPosition['orientation']['w']);
    hmdOrientationMatrix = mat4FromQuat(orientationQuaternion);
    //quat4.toMat4([-vrPosition.orientation.x, -vrPosition.orientation.y, -vrPosition.orientation.z, vrPosition.orientation.w], hmdOrientationMatrix);
    
    if (eyeOffset != null) 
    {
      out = out.translate(-eyeOffset['x']*vrIPDScale, -eyeOffset['y']*vrIPDScale, -eyeOffset['z']*vrIPDScale);
      //mat4.translate(out, [-eyeOffset[0]*vrIPDScale, -eyeOffset[1]*vrIPDScale, -eyeOffset[2]*vrIPDScale]);
    }
    
    out = out.multiply(hmdOrientationMatrix);
    //mat4.multiply(out, hmdOrientationMatrix, out);
    
    if (translated && vrPosition['position']) 
    {
      out = out.translate(-vrPosition.position.x*vrIPDScale, -vrPosition.position.y*vrIPDScale, -vrPosition.position.z*vrIPDScale);
      //mat4.translate(out, [-vrPosition.position.x*vrIPDScale, -vrPosition.position.y*vrIPDScale, -vrPosition.position.z*vrIPDScale]);
    }
    
    return out;
  }
  
  camera.ApplyTransformations();
  out = out.multiply(camera.Matrix);

  display_player_position(camera.Position);
  
  return out;
}

void drawFrame(rendering_context gl) 
{
    CanvasElement canvas = query("#viewport");
    
    // Clear back buffer but not color buffer (we expect the entire scene to be overwritten)
    gl.depthMask(true);
    gl.clear(RenderingContext.DEPTH_BUFFER_BIT);
    //gl.clearColor(0.0, 0.0, 0.0,1.0);
    
    if(map == null || playerMover == null) { return; }

    if (!vrEnabled && !vrForced) 
    {
      bool translated = true;
      // Matrix setup
      leftViewMat = getViewMatrix(translated, null, null, leftProjMat);
      
      leftViewport.width = canvas.clientWidth.toDouble();
      leftViewport.height = canvas.clientHeight.toDouble();
      leftViewport.x = 0.0;
      leftViewport.y = 0.0;
      
      if(drawMap)
      {
        q3bsp.draw(leftViewMat, leftProjMat, null, null,null,null);
      }
      
      
      player.RenderPlayerModels(gl, leftViewMat, leftProjMat, leftViewport);
    } 
    else if (vrDrawMode == 1) 
    {      
      leftViewport.width = canvas.clientWidth.toDouble() / 2.0;
      leftViewport.height = canvas.clientHeight.toDouble();

      rightViewport.x = canvas.clientWidth.toDouble() / 2.0; 
      rightViewport.width = canvas.clientWidth.toDouble() / 2.0;
      rightViewport.height = canvas.clientHeight.toDouble();

      leftProjMat = mat4PerspectiveFromVRFieldOfView(vrFovLeft, zNear, zFar);
      leftViewMat = getViewMatrix(true, vrPosition, vrEyeLeft, leftProjMat);
      
      rightProjMat = mat4PerspectiveFromVRFieldOfView(vrFovRight, zNear, zFar);
      rightViewMat = getViewMatrix(true, vrPosition, vrEyeRight, rightProjMat);
      
      //render_oculus_eye_distortion(gl, leftViewMat, leftProjMat, leftViewport);
      q3bsp.draw(leftViewMat, leftProjMat, leftViewport,    rightViewMat, rightProjMat, rightViewport);
    } 
    else 
    {
      int hw = (canvas.clientWidth ~/ 2.0);
      
      // Left Eye
      gl.viewport(0, 0, hw, gl.drawingBufferWidth);
      leftProjMat = mat4PerspectiveFromVRFieldOfView(vrFovLeft, zNear, zFar);
      leftViewMat = getViewMatrix(true, vrPosition, vrEyeLeft, leftProjMat);

      q3bsp.draw(leftViewMat, leftProjMat ,null,null,null,null);

      // Right Eye
      gl.viewport(hw, 0, hw, gl.drawingBufferHeight);
      rightProjMat = mat4PerspectiveFromVRFieldOfView(vrFovRight, zNear, zFar);
      rightViewMat = getViewMatrix(true, vrPosition, vrEyeRight, rightProjMat);

      q3bsp.draw(rightViewMat, rightProjMat ,null,null,null,null);
    }
}

void moveLookLocked(int xDelta, int yDelta) 
{
  
  
  xAngle = xDelta*0.0025;
  yAngle = yDelta*0.0025;
  
  //xAngle = MathHelper.ClampCircular(xAngle, 0.0, TwoPi);
  //yAngle = MathHelper.ClampCircular(yAngle, 0.0, TwoPi);
  
  //xAngle = MathHelper.ClampCircular(xAngle, 0.0, TwoPi);
  //yAngle = MathHelper.ClampCircular(yAngle, 0.0, HalfPi);
  
//    while (xAngle < 0)
//      xAngle += TwoPi;
//    while (xAngle >= TwoPi)
//      xAngle -= TwoPi;
//
//    while (yAngle < -HalfPi)
//      yAngle = -HalfPi;
//    while (yAngle > HalfPi)
//      yAngle = HalfPi;
    
  camera.ApplyYaw(xAngle);
  camera.ApplyPitch(yAngle);
  
  camera.ApplyRotation();   
}

num filterDeadzone(num value) 
{
    return value.abs() > 0.35 ? value : 0;
}

void moveViewOriented(Vector3 direction, int frameTime) 
{  
//  if(direction[0] != 0 || direction[1] != 0 || direction[2] != 0) 
//  {      
//      cameraMat = new Matrix4.identity();
//      
//      if (vrEnabled == true) 
//      {
//        vrEuler = eulerFromQuaternion(vrPosition['orientation'], VrPositionCoordinateOrder.YXZ);
//
//        cameraMat = cameraMat.rotateZ(camera.zAngle - vrEuler[1]);
//      } 
//      else 
//      {
//        cameraMat = cameraMat.rotateZ(camera.zAngle);
//      }
//      
//      cameraMat = mat4_inverse(cameraMat);
//      cameraMat = mat4MultiplyVec3(cameraMat, direction);
//  }

  // Send desired movement direction to the player mover for collision detection against the map
  playerMover.move(vec3(direction), frameTime);
  
  
}

void updateInput(frameTime) 
{
    if(playerMover == null) { return; }
    
    Vector3 direction = new Vector3.zero();
    
    if(input.KeyPressed[Key.W]) 
    {
      direction += camera.Direction * playerDirectionMagnitude; 
    }
    if(input.KeyPressed[Key.S]) 
    {
      direction -= camera.Direction * playerDirectionMagnitude;  
    }
    if(input.KeyPressed[Key.A]) 
    {
      camera.Right = camera.Up.cross(camera.Direction);
      direction += camera.Right * playerDirectionMagnitude; 
    }
    if(input.KeyPressed[Key.D]) 
    {
      camera.Right = camera.Up.cross(camera.Direction);
      direction -= camera.Right * playerDirectionMagnitude;
    }
    
    if(input.KeyPressed[Key.PageUp]) 
    {
      drawMap = false;
      //roll_angle+=0.001;
      //camera.Roll(roll_angle);
      //camera.applyRotation();
    }
    if(input.KeyPressed[Key.PageDown]) 
    {
      drawMap = true;
//      roll_angle-=0.001;
//      camera.Roll(roll_angle);
//      camera.applyRotation();
    }

    bool rotated = false;
    if(input.KeyPressed[Key.Left]) 
    {
      //camera.TurnY(0.01);
      camera.ApplyYaw(-0.1);
      rotated = true;
    }
    if(input.KeyPressed[Key.Right]) 
    {
      //camera.TurnY(-0.01);
      camera.ApplyYaw(0.1);
      rotated = true;
    }
    if(input.KeyPressed[Key.Up]) 
    {
      //camera.TurnX(0.01);
      camera.ApplyPitch(-0.1); // yaw
      rotated = true;
    }
    if(input.KeyPressed[Key.Down]) 
    {
      //camera.TurnX(-0.01);
      camera.ApplyPitch(0.1); // yaw
      rotated = true;
    }
    
    if(rotated)
    {
      camera.ApplyRotation();
    }
//    detectGamepad();
//
//    for (var i = 0; i < gamepads.length; ++i) 
//    {
//        var pad = gamepads[i];
//        if(pad) 
//        {
//            dir[0] += filterDeadzone(pad.axes[0]);
//            dir[1] -= filterDeadzone(pad.axes[1]);
//
//            moveLookLocked(
//                filterDeadzone(pad.axes[2]) * 25.0,
//                filterDeadzone(pad.axes[3]) * 25.0
//            );
//
//            for(var j = 0; j < max(pad.buttons.length, 4); ++j) 
//            {
//                var button = pad.buttons[j];
//                
//                if (button is num && button == 1.0) 
//                {
//                    playerMover.jump();
//                } 
//                else if (button.pressed) 
//                {
//                    playerMover.jump();
//                }
//            }
//        }
//    }
//
//    if (vrEnabled && vrSensor) 
//    {
//      vrPosition = vrSensor.getState();
//    }

    //playerMover.move(vec3(direction),frameTime);
    
    camera.move(direction, frameTime);
    //camera.update(frameTime);
}

// Set up event handling
void initEvents() 
{
    var movingModel = false;
    var lastX = 0;
    var lastY = 0;
    var lastMoveX = 0;
    var lastMoveY = 0;
    var viewport = query("#viewport");
    var viewportFrame = query("#viewport-frame");

    Element fullscreenButton = query("#fullscreenBtn");
    Element mobileFullscreenBtn = query("#mobileFullscreenBtn");
    Element vrBtn = query("#vrBtn");
    Element mobileVrBtn = query("#mobileVrBtn");

    fullscreenButton.onClick.listen((MouseEvent event) {
      goFullscreen();
    });
    mobileFullscreenBtn.onClick.listen((MouseEvent event) {
      goFullscreen();
    });
    vrBtn.onClick.listen((MouseEvent event) {
      goVrFullscreen();
    });
    mobileVrBtn.onClick.listen((MouseEvent event) {
      goVrFullscreen();
    });
    
    document.on['fullscreenchange'].listen((event) {
      if(document.fullscreenElement != null) {
          viewport.requestPointerLock(); // Attempt to lock the mouse automatically on fullscreen
      } 
      else {
        vrEnabled = false;
      }
      onResize(null);
    });
    
    window.onKeyDown.listen((KeyboardEvent event) 
    {
      keyspressed = event.keyCode.toString(); 
      
      if(event.keyCode == input.Keys[Key.C] && input.KeyPressed[Key.C] == false) 
      {
          playerMover.crouchDn();
      }
      if(event.keyCode == input.Keys[Key.I] && input.KeyPressed[Key.I] == false) 
      {
          camera.invert();
      }
      if(event.keyCode == 32 && input.KeyPressed[Key.Space] == false) 
      {
          playerMover.jump();
      }
      if(input.KeyCodes.containsKey(event.keyCode))
      {
        input.KeyPressed[input.KeyCodes[event.keyCode]] = true;  
      }
      //input.pressed[event.keyCode] = true;
      
      if ((event.keyCode == input.Keys[Key.W] ||
           event.keyCode == input.Keys[Key.S] ||
           event.keyCode == input.Keys[Key.A] ||
           event.keyCode == input.Keys[Key.D] ||
           event.keyCode == input.Keys[Key.C] ||
           event.keyCode == input.Keys[Key.I] ||
           event.keyCode == input.Keys[Key.Space] ||
           event.keyCode == input.Keys[Key.Left] ||
           event.keyCode == input.Keys[Key.Right] ||
           event.keyCode == input.Keys[Key.Up] ||
           event.keyCode == input.Keys[Key.Down]) && !event.ctrlKey) 
      {
          event.preventDefault();
      }
    });
    
    window.onKeyUp.listen((KeyboardEvent event) 
    {
      if(input.KeyCodes.containsKey(event.keyCode))
      {
        if(event.keyCode == input.Keys[Key.C]) 
        {
            playerMover.crouchUp();
        }
        else{
          if(crouched)
          {
            //playerMover.crouchUp();
          }
        }
        
        input.KeyPressed[input.KeyCodes[event.keyCode]] = false;  
      }
      //input.pressed[event.keyCode] = false;
    });
  
    window.onKeyPress.listen((KeyboardEvent event) {
      if(event.charCode == 'R'.codeUnitAt(0) || event.charCode == 'r'.codeUnitAt(0)) 
      {
          respawnPlayer(-1);
      }
//      if(event.charCode == 'C'.codeUnitAt(0) || event.charCode == 'c'.codeUnitAt(0)) 
//      {
//          if (vrSensor && vrSensor.zeroSensor != null) 
//          {
//            vrSensor.zeroSensor();
//          }
//      }
//      if(event.charCode == 'T'.codeUnitAt(0) || event.charCode == 't'.codeUnitAt(0)) 
//      {
//          if (vrHMD && vrHMD.setTimewarp != null) 
//          {
//            vrTimewarp = !vrTimewarp;
//            vrHMD.setTimewarp(vrTimewarp);
//          }
//      }
//      if(event.charCode == '='.codeUnitAt(0)) {
//        vrIPDScale += 5.0;
//      }
//      if(event.charCode == '-'.codeUnitAt(0)) {
//        vrIPDScale -= 5.0;
//      }
    });

    void startLook(x, y) {
        movingModel = true;

        lastX = x;
        lastY = y;
    }

    void endLook() 
    {
        movingModel = false;
    }

    void moveLook(x, y) 
    {
        var xDelta = x - lastX;
        var yDelta = y - lastY;
        lastX = x;
        lastY = y;

        if (movingModel) 
        {
            moveLookLocked(xDelta, yDelta);
        }
    }

    void startMove(x, y) 
    {
        lastMoveX = x;
        lastMoveY = y;
    }

    void moveUpdate(x, y, frameTime) 
    {
        double xDelta = x - lastMoveX;
        double yDelta = y - lastMoveY;
        
        lastMoveX = x;
        lastMoveY = y;

        Vector3 dir = new Vector3(xDelta, yDelta * -1.0, 0.0);

        moveViewOriented(dir, frameTime*2);
    }
    
    viewport.onClick.listen((MouseEvent event) {
      viewport.requestPointerLock();
    });

    // Mouse handling code
    // When the mouse is pressed it rotates the players view
    viewport.onMouseDown.listen((MouseEvent event) {
      if(event.which == 1) {
        startLook(event.page.x, event.page.y);
      }
    });
    
    viewport.onMouseUp.listen((MouseEvent event) {
      endLook();
    });

    viewport.onMouseMove.listen((MouseEvent event) {
      if(document.pointerLockElement != null) 
      {
          moveLookLocked(event.movement.x, event.movement.y);
      } 
      else 
      {
          moveLook(event.page.x, event.page.y);
      }
    });

    // Touch handling code
    viewport.onTouchStart.listen((TouchEvent event) {
      var touches = event.touches;
              
      switch(touches.length) {
          case 1: // Single finger looks around
              startLook(touches.elementAt(0).page.x, touches.elementAt(0).page.y);
              break;
          case 2: // Two fingers moves
              startMove(touches.elementAt(0).page.x, touches.elementAt(0).page.y);
              break;
          case 3: // Three finger tap jumps
              playerMover.jump();
              break;
          default:
              return;
      }
      event.stopPropagation();
      event.preventDefault();
    });
    
    viewport.onTouchEnd.listen((TouchEvent event) {
      endLook();
      return false;
    });
    
    viewport.onTouchMove.listen((TouchEvent event) {
      var touches = event.touches;
      switch(touches.length) {
          case 1:
              moveLook(touches.elementAt(0).page.x, touches.elementAt(0).page.y);
              break;
          case 2:
              moveUpdate(touches.elementAt(0).page.x, touches.elementAt(0).page.y, 16);
              break;
          default:
              return;
      }
      event.stopPropagation();
      event.preventDefault();
    });
}

void onRequestedFrame(double time)
{
    int timestamp = new DateTime.now().millisecondsSinceEpoch; //timestamp = new Date().getTime();
    
    window.requestAnimationFrame(onRequestedFrame); // window.requestAnimationFrame(onRequestedFrame, element);

    frameId++;
    if (SKIP_FRAMES != 0 && frameId % SKIP_FRAMES != 0)
      return;

    stats.begin();

    int elapsed = timestamp - startTime;
    int frameTime = timestamp - lastTimestamp;
    
    onFrame(gl, timestamp, elapsed, frameTime);

    stats.end();
}

void renderLoop(rendering_context gl, CanvasElement element) {
    startTime = new DateTime.now().millisecondsSinceEpoch;
    lastTimestamp = startTime;
    lastFps = startTime;

    frameId = 0;

    
    window.requestAnimationFrame(onRequestedFrame); // window.requestAnimationFrame(onRequestedFrame, element);
}

void onResize(event)
{
  if (vrEnabled && vrHMD) {
    if (vrHMD.getEyeParameters != null) 
    {
      var leftEyeViewport = vrHMD.getEyeParameters("left").renderRect;
      var rightEyeViewport = vrHMD.getEyeParameters("right").renderRect;
      canvas.width = rightEyeViewport.left + rightEyeViewport.width;
      canvas.height = max(leftEyeViewport.height, rightEyeViewport.height);
    } 
    else if (vrHMD.getRecommendedEyeRenderRect != null) 
    {
      var leftEyeViewport = vrHMD.getRecommendedEyeRenderRect("left");
      var rightEyeViewport = vrHMD.getRecommendedEyeRenderRect("right");
      canvas.width = rightEyeViewport.left + rightEyeViewport.width;
      canvas.height = max(leftEyeViewport.height, rightEyeViewport.height);
    } 
    else 
    {
      // Hard-coded fallback, Oculus DK1 values.
      canvas.width = 2000;
      canvas.height = 1056;
    }
  } 
  else 
  {
    num devicePixelRatio = context['devicePixelRatio'] != null ? context['devicePixelRatio'] : 1.0;

    if(document.fullscreenElement != null) 
    {
        canvas.width = window.screen.width * devicePixelRatio;
        canvas.height = window.screen.height * devicePixelRatio;
    } 
    else 
    {
        canvas.width = canvas.clientWidth * devicePixelRatio;
        canvas.height = canvas.clientHeight * devicePixelRatio;
    }

    if (!vrEnabled) 
    {
      rendering_context gl = new rendering_context();
      //RenderingContext gl = canvas.getContext3d();
      
      if(gl == null) return ;
      
      //gl.viewport(0, 0, canvas.clientWidth, canvas.clientHeight);
      gl.viewport(0, 0, gl.drawingBufferWidth , gl.drawingBufferHeight);
      
      double aspectRatio = canvas.clientWidth.toDouble() / canvas.clientHeight.toDouble();
      double zNear = 1.0;
      double zFar = 4096.0;
      double fovYRadians = 45.0;
            
      leftProjMat = makePerspectiveMatrix(fovYRadians, aspectRatio, zNear, zFar);
      //mat4.perspective(45.0, canvas.width/canvas.height, 1.0, 4096.0, leftProjMat);
      
    }
  }
}