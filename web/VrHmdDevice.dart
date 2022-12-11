part of tech3;

String oculus_fragment_shader = '''
#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D tex;
uniform float leftEye;
varying vec2 fragTexCoord;

void main()
{
  float distortionScale = 0.7; //0.685;
  //float distortionK[4] = float[](1.0, 0.22, 0.24, 0.0);
  vec2 lensCenter = vec2(0.151976495726, 0.0);
  if (leftEye == 0.0) {
      lensCenter.x *= -1.0;
  }

  vec2 theta = (fragTexCoord * 2.0) - 1.0;
  float rSq = theta.x * theta.x + theta.y * theta.y;
  vec2 rvec = theta * (1.0 + 0.22 * rSq + 0.24 * rSq * rSq); //+ 0.0 * rSq * rSq * rSq);
  vec2 texCoord = (distortionScale*rvec+(1.0-distortionScale)*lensCenter + 1.0) / 2.0;

  if (any(notEqual(clamp(texCoord, vec2(0.0, 0.0), vec2(1.0, 1.0)) - texCoord,
                   vec2(0.0, 0.0)))) {
      //if (leftEye == 0.0) gl_FragColor = vec4(1.0,1.0,0.0,1.0);
      //else gl_FragColor = vec4(1.0,0.0,0.0,1.0);
      discard;
  }
  else {
      vec3 col = texture2D(tex, texCoord).rgb;
      gl_FragColor = vec4(col, 1.0);
  }
  //gl_FragColor = texture2D(tex, fragTexCoord);
}
''';
String oculus_vertex_shader_right_eye = '''
attribute vec3 position;
attribute vec2 texcoord;

uniform mat4 modelViewProjectionMatrix;
varying vec2 fragTexCoord;

void main()
{
  vec2 pos = sign(position.xy);
  fragTexCoord = texcoord;

  gl_Position = vec4((pos.x - 1.0) / 2.0, pos.y, 0.0, 1.0);
  //gl_Position = vec4(pos.xy / 4.0 + vec2(-0.75,0.75), 0.0, 1.0);
}
''';
String oculus_vertex_shader_left_eye = '''
attribute vec3 position;
attribute vec2 texcoord;

uniform mat4 modelViewProjectionMatrix;
varying vec2 fragTexCoord;

void main()
{
  vec2 pos = sign(position.xy);
  fragTexCoord = texcoord;

  gl_Position = vec4((pos.x + 1.0) / 2.0, pos.y, 0.0, 1.0);
  //gl_Position = vec4(pos.xy / 4.0 + vec2(-0.75,0.75), 0.0, 1.0);
}
''';

//TODO: implement render scene-to-texture and apply oculus shader to it. 

//see X3D examples: http://examples.x3dom.org/Demos/ClassroomVR/classroom-rift.html
// https://github.com/x3dom/x3dom/blob/master/src/nodes/Texturing/RenderedTexture.js
class OculusRift
{
  OculusRift(rendering_context gl)
  {
    this.gl = gl;
  }
  
  rendering_context gl;
  DwShader shader;
  int IN_VEC3_POSITION;
  int IN_VEC3_TEXCOORD;
  GLUniformLocation UN_MAT4_MODELVIEW;
  
  void init()
  {
    shader = DwShader.FromSource(gl, oculus_vertex_shader_left_eye, oculus_fragment_shader);
    //shader_right_eye = DwShader.FromSource(gl, oculus_vertex_shader_right_eye, oculus_fragment_shader);
    
    saveShaderLocations();
  }
  
  void saveShaderLocations ()
  {
    gl.useProgram(shader.HANDLE_program);
    {
      this.IN_VEC3_POSITION    = gl.getAttribLocation (shader.HANDLE_program,  "position"   );
      this.IN_VEC3_TEXCOORD    = gl.getAttribLocation (shader.HANDLE_program,  "texcoord"   );
      this.UN_MAT4_MODELVIEW   = gl.getUniformLocation(shader.HANDLE_program,  "modelViewProjectionMatrix"  );      
    }
    gl.useProgram(null);
  }
  
  void setMat4_ModelView (Matrix4 MAT4)
  {
    this.gl.uniformMatrix4fv( this.UN_MAT4_MODELVIEW, false, MAT4.storage);
  }
  
  void bind()
  {
    gl.useProgram(shader.HANDLE_program);
  }
  
  void unbind()
  {
    gl.useProgram(null);
  }
  
  void delete ()
  {
    shader.delete();
    shader = null;
  }
}

OculusRift oculus;

void render_oculus_eye_distortion(rendering_context gl, Matrix4 eyeViewMat, Matrix4 eyeProjMat, Viewport eyeViewport)
{
  //DwShader
}

void detectGamepad()
{
  JsObject jsNavigator = context['jsinterop'];
  
  if(jsNavigator.callMethod('enum_gamepads',[(GamepadList){
    print('[gamepad-enabled]');
    gamepad_enabled = true;
    gamepads = GamepadList;
  }]));
}

void detectVR()
{
  //JsObject jsNavigator = new JsObject.fromBrowserObject(context['navigator']);
  
  JsObject interop = context['jsinterop'];
  
  if(interop.callMethod('enum_vr_devices',[(devices){
    print('[VR-Enabled] enumerating vr devices');
    EnumerateVRDevice(devices);
  }]) == true)
  {
    webvr_enabled = true;
  }
  
  /*
  if (window.navigator.getVRDevices != null) 
  {
    webvr_enabled = true;
    window.navigator.getVRDevices().then(EnumerateVRDevice);
  } 
  else if (window.navigator.mozGetVRDevices != null) 
  {
    webvr_enabled = true;
    window.navigator.mozGetVRDevices(EnumerateVRDevice);
  }*/
}

void EnumerateVRDevice(devices) 
{
  JsArray jsDevices = new JsArray.from(devices);
  
    // Yay! We support WebVR!
    for (var i = 0; i < jsDevices.length; ++i) {
      JsObject jsDevice = new JsObject.fromBrowserObject(jsDevices[i]);
      
      if (jsDevice.instanceof(context['HMDVRDevice'])) 
      {
          vrHMD = devices[i];

          if (vrHMD.getEyeParameters != null) 
          {
            var leftEye = vrHMD.getEyeParameters("left");
            var rightEye = vrHMD.getEyeParameters("right");

            var e = leftEye.eyeTranslation;
            vrEyeLeft = [e.x, e.y, e.z];
            e = rightEye.eyeTranslation;
            vrEyeRight = [e.x, e.y, e.z];

            vrFovLeft = leftEye.recommendedFieldOfView;
            vrFovRight = rightEye.recommendedFieldOfView;
          } 
          else 
          {
            var e = vrHMD.getEyeTranslation("left");
            vrEyeLeft = [e.x, e.y, e.z];
            e = vrHMD.getEyeTranslation("right");
            vrEyeRight = [e.x, e.y, e.z];

            vrFovLeft = vrHMD.getRecommendedEyeFieldOfView("left");
            vrFovRight = vrHMD.getRecommendedEyeFieldOfView("right");
          }

          break;
      }
    }

    for (var i = 0; i < jsDevices.length; ++i) 
    {
      JsObject jsDevice = new JsObject.fromBrowserObject(jsDevices[i]);
      
      if (jsDevice.instanceof(context['PositionSensorVRDevice']))
      {
        // If we have an HMD, make sure to get the associated sensor
        if (vrHMD == null || vrHMD.hardwareUnitId == devices[i].hardwareUnitId) {
            vrSensor = devices[i];
            break;
        }
      }
    }

    if (vrHMD != null || vrSensor != null) 
    {
        var vrToggle = query("#vrToggle");
        var mobileVrBtn = query("#mobileVrBtn");
        
        vrToggle.style.display = "block";
        mobileVrBtn.style.display = "block";
    }
}

// Handle fullscreen transition
Element viewportFrame = query("#viewport-frame");
var viewport = query("#viewport");


// Fullscreen
void goFullscreen() 
{
  viewportFrame.requestFullscreen();
}

// VR
void goVrFullscreen() 
{
    vrEnabled = true;
    //xAngle = 0.0;
    
    //viewport.requestFullScreen({ vrDisplay: vrHMD });
    
    JsObject jsViewport = new JsObject.fromBrowserObject(viewport);
    var fullscreenOptions = new JsObject.jsify({ "vrDisplay": vrHMD });
    jsViewport.callMethod('requestFullScreen',[fullscreenOptions]);
}