part of tech3;

//TODO: refactor!!!!!! REEEEEEEEFACCCCCTTTOOORRRR!
var rectangle;
var rectangle_shader;
var screen_quad;
var screen_quad_shader;
Q3_TexturePool texturepool;
Q3_surface_shader_pass_geom q3_shader_pass_geom;
Q3_surface_shader q3_shader;
//int q3_frame_IDX = 0;
Q3_Player player_1, player_2, player_3, player_4;
Q3_Weapon weapon_1, weapon_2, weapon_3, weapon_4;
Vector4 v4_light_1_world = new Vector4(  0.0,   0.0,   30.0, 1.0);
Vector4 v4_light_2_world = new Vector4( 100.0, -110.0, 10.0, 1.0);
Vector4 v4_light_3_world = new Vector4 (-100.0,  100.0, 100.0, 1.0);
Matrix4 Mat4_ModelView  = new Matrix4.identity(); //DwMat4.identity_new();
Matrix4 Mat4_ModelWorld = new Matrix4.identity(); //DwMat4.identity_new();
Matrix4 Mat4_Projection = new Matrix4.identity(); //DwMat4.identity_new();
Matrix3 Mat3_Normal     = new Matrix3.identity(); //DwMat3.identity_new();
DwFBO FBO_render;
DwFBO FBO_pass_geom;
var use_DOF = true;
DOF_shader DOF_shader_v1;
var DOF_STRENGTH = 500;
var DOF_DISTANCE = 120;
Map GUI_VALUES;
var _camera;
var camera_state = null;

void init_player()
{
  GUI_VALUES = {
    'ANIMATION_FRAME' : 0,
    'DOF_DISTANCE'    : 120,
    'USE_DOF'         : true
  };
  
  MD3_File.logging = !true;
  MD3_Header.logging = !true;
  MD3_Frame.logging = !true;
  MD3_TagFrame.logging = !true;
  MD3_Tag.logging = !true;
  MD3_Surface.logging = !true;
  MD3_Shader.logging = !true;
  MD3_SurfaceFrame.logging = !true;
}

//TODO: rotate Q3_Player to correct orientation in scene. and do this using Quations 

class player
{
  //static Q3_TexturePool texturepool;
  static List<Q3_Player> player_models;
  
  //static Q3_surface_shader q3_shader;
  //static Q3_surface_shader_pass_geom q3_shader_pass_geom;
  
  static LoadPlayerModels(rendering_context gl, Viewport leftViewport)
  {
    
    init_player();
    
    player_models = new List<Q3_Player>();
    texturepool = new Q3_TexturePool(gl);
   
    q3_shader = new Q3_surface_shader(gl);
    q3_shader_pass_geom = new Q3_surface_shader_pass_geom(gl);
    
    player_1 = new Q3_Player(gl, // 
        //q3bsp_base_folder+'/models/barrel/', 
        //q3bsp_base_folder+'/models/sarge/',
        q3bsp_base_folder+'/models/human_bsuit/',
        //q3bsp_base_folder+'/models/human_base/',
        //q3bsp_base_folder+'/models/builder/',
        //q3bsp_base_folder+'/models/level0/', 
        "default", texturepool);
    
    player_1.load();
    
    player_models.add(player_1);
    
    
    var EXT_tex_float = gl.getExtension("OES_texture_float");
    print("EXT: OES_texture_float = ${EXT_tex_float}");
    FBO_render    = new DwFBO(gl, leftViewport.width.toInt() , leftViewport.height.toInt(), RenderingContext.UNSIGNED_BYTE);
    FBO_pass_geom = new DwFBO(gl, leftViewport.width.toInt(), leftViewport.height.toInt(), RenderingContext.FLOAT);

//    DOF_shader_v1 = new DOF_shader(gl);
//    DOF_shader_v1.bind();
//    DOF_shader_v1.setViewportSize(leftViewport.width , leftViewport.height);
//    DOF_shader_v1.setDOF(120, 500);
//    DOF_shader_v1.setCamNearFar(0.5, 1000);
//    DOF_shader_v1.unbind();
  }
  
  static void RenderPlayerModels(rendering_context gl, Matrix4 leftViewMat, Matrix4 leftProjMat, Viewport leftViewport)
  {
    //_camera.update();
    
    Mat4_ModelView  = leftViewMat.clone();  //_camera.getMat_ModelView_cpy();
    Mat4_Projection = leftProjMat.clone(); //_camera.getMat_Projection_cpy();
    
    
    Vector3 pos2 = new Vector3( camera.Origin.x, camera.Origin.y,  camera.Origin.z + playerHeight);
            
            //pos = camera.Position;
            
            // 0.0, 0.0, 40.0
    //Mat4_ModelWorld = Mat4_ModelWorld.translate(pos2);
    
            
            
    
    //q3_frame_IDX = GUI_VALUES['ANIMATION_FRAME'];
    q3_frame_IDX++;
    
    if(q3_frame_IDX == 100) q3_frame_IDX=0;
    
    //Mat4_ModelWorld = Mat4_ModelView;
    
    Vector4 v4_light_1_eye, v4_light_2_eye, v4_light_3_eye;
    Vector4 v4_light_1_eye_mirror, v4_light_2_eye_mirror, v4_light_3_eye_mirror;

    // transform lights into eye-space
    // not mirrored
    DwState.pushMat4(Mat4_ModelWorld);
    {
      Matrix4 scaled = Mat4_ModelWorld.scale(1.0, 1.0, 1.0); //DwMat4.scale_ref_slf(Mat4_ModelWorld, [1, 1, 1]);
      Mat4_ModelView = Mat4_ModelView * scaled; //DwMat4.mult_ref( Mat4_ModelView, Mat4_ModelWorld,Mat4_ModelWorld);
      
      v4_light_1_eye = Mat4_ModelWorld * v4_light_1_world;
      v4_light_2_eye = Mat4_ModelWorld * v4_light_2_world;
      v4_light_3_eye = Mat4_ModelWorld * v4_light_3_world;
      
      //v4_light_1_eye = DwMat4.multVec4_new(Mat4_ModelWorld, v4_light_1_world);
      //v4_light_2_eye = DwMat4.multVec4_new(Mat4_ModelWorld, v4_light_2_world);
      //v4_light_3_eye = DwMat4.multVec4_new(Mat4_ModelWorld, v4_light_3_world);
    }
    Mat4_ModelWorld = DwState.popMat4();

    // mirrored (xy-plane)
    DwState.pushMat4(Mat4_ModelWorld);
    {
      Matrix4 scaled = Mat4_ModelWorld.scale(1.0, 1.0, -1.0); //DwMat4.scale_ref_slf(Mat4_ModelWorld, [1, 1, -1]);
      Mat4_ModelView = Mat4_ModelView * scaled; //DwMat4.mult_ref( Mat4_ModelView, Mat4_ModelWorld,Mat4_ModelWorld);
      
      v4_light_1_eye_mirror = Mat4_ModelWorld * v4_light_1_world;
      v4_light_2_eye_mirror = Mat4_ModelWorld * v4_light_2_world;
      v4_light_3_eye_mirror = Mat4_ModelWorld * v4_light_3_world;
            
      //v4_light_1_eye_mirror = DwMat4.multVec4_new(Mat4_ModelWorld, v4_light_1_world);
      //v4_light_2_eye_mirror = DwMat4.multVec4_new(Mat4_ModelWorld, v4_light_2_world);
      //v4_light_3_eye_mirror = DwMat4.multVec4_new(Mat4_ModelWorld, v4_light_3_world);
    }
    Mat4_ModelWorld = DwState.popMat4();
    
    
    //------------------------------------------------------------------------
    // FBO: RENDER PASS
    //------------------------------------------------------------------------
    //gl.enable(RenderingContext.DEPTH_TEST);
    //gl.enable(RenderingContext.BLEND);
    //FBO_render.bind();
    {
      //gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT );
//        xyz_axis_shader.bind();
//        {
//          gl.lineWidth(2.0); //TODO find issue
//          xyz_axis_shader.setMat4_ModelView(Mat4_ModelView);
//          xyz_axis_shader.setMat4_Projection(Mat4_Projection);
//          xyz_axis.draw(xyz_axis_shader);
//        }
//        xyz_axis_shader.unbind();

      q3_shader.bind();
      {
        q3_shader.setMat4_Projection(Mat4_Projection);
        // set Lights for floor
        //q3_shader.setVec4_Light(1, v4_light_1_eye);
        //q3_shader.setVec4_Light(2, v4_light_2_eye);
        //q3_shader.setVec4_Light(3, v4_light_3_eye);
        // make stencil-mask
        //gl.disable(RenderingContext.DEPTH_TEST);
        //gl.enable(RenderingContext.STENCIL_TEST);
        //gl.clearStencil(0);
        //gl.clear(RenderingContext.STENCIL_BUFFER_BIT);
        //gl.stencilFuncSeparate(RenderingContext.FRONT, RenderingContext.NEVER, 0x1, 0x1);
        //gl.stencilFuncSeparate(RenderingContext.BACK,  RenderingContext.ALWAYS, 0x1, 0x1);
        //gl.stencilOp(RenderingContext.KEEP, RenderingContext.KEEP, RenderingContext.REPLACE);
        // make stencil mask
        //q3_shader.setMirrored(false);
        // draw into stencil buffer
        //drawFloor(gl, rectangle, q3_shader);

        //gl.stencilFunc(RenderingContext.EQUAL,  0x1, 0x1);
        //gl.stencilOp(RenderingContext.KEEP, RenderingContext.KEEP, RenderingContext.KEEP);
        gl.enable(RenderingContext.DEPTH_TEST);

        //Vector3 pos = new Vector3(-566.05908203125, 399.0882568359375, -117.8561782836914);
        //Vector3 pos = new Vector3(0,0,0);
        Vector3 pos;
        Vector3 pos_mirrored;
         
        //pos = camera.Position;
        pos = camera.Origin;
        pos.z = (camera.Position.z) + playerHeight;
        
        pos_mirrored = camera.Origin;
        pos_mirrored.z = (-camera.Position.z) - playerHeight;
        
        // DRAW MIRRORED
        q3_shader.setMirrored(true);
        // set light-positions
        //q3_shader.setVec4_Light(1, v4_light_1_eye_mirror);
        //q3_shader.setVec4_Light(2, v4_light_2_eye_mirror);
        //q3_shader.setVec4_Light(3, v4_light_3_eye_mirror);
        q3_shader.setDefaultColor(new Vector4(0.4, 0.4, 0.4, 1.0));
        double gray = 0.15;
        q3_shader.setDefaultColor(new Vector4(gray, gray, gray, 1.00));
        DwState.pushMat4(Mat4_ModelWorld);
        {
          //Mat4_ModelWorld = Mat4_ModelWorld.scale(1.0, 1.0, -1.0); // DwMat4.scale_ref_slf(Mat4_ModelWorld, [1, 1, -1]);
          //Mat4_ModelView = Mat4_ModelView.rotate(UnitY, PiOver2);
          Mat4_ModelWorld = Mat4_ModelWorld.translate(pos); //DwMat4.translate_ref_slf(Mat4_ModelWorld, [0, 0, 25]);
          //q3_shader.setMat4_ModelView(Mat4_ModelView);
          
          drawModel(gl, player_1, q3_shader, q3_frame_IDX, new Vector3(0.0, 0.0, 0.0) );
        }
        Mat4_ModelWorld = DwState.popMat4();

        // DRAW REAL
        q3_shader.setMirrored(false);
        // set light-positions
        //q3_shader.setVec4_Light(1, v4_light_1_eye);
        //q3_shader.setVec4_Light(2, v4_light_2_eye);
        //q3_shader.setVec4_Light(3, v4_light_3_eye);
        //gl.disable(RenderingContext.STENCIL_TEST);
        gl.enable(RenderingContext.DEPTH_TEST);
        gl.enable(RenderingContext.BLEND);
        // drawFloor(gl, rectangle, q3_shader, groundplane_tex.HANDLE_TEX);
        q3_shader.setDefaultColor(new Vector4(0.0, 0.0, 0.0, 0.0));
        DwState.pushMat4(Mat4_ModelWorld);
        {
          //Mat4_ModelView = Mat4_ModelView.rotate(UnitY, PiOver2);
          Mat4_ModelWorld = Mat4_ModelWorld.translate(pos); //DwMat4.translate_ref_slf(Mat4_ModelWorld, [0, 0, 25]);
          q3_shader.setMat4_ModelView(Mat4_ModelView);
          
          // q3_shader_pass_geom
          drawModel(gl, player_1,  q3_shader, q3_frame_IDX, new Vector3(0.0, 00.0, 0.0) );
        }
        Mat4_ModelWorld = DwState.popMat4();

      }
      q3_shader.unbind();
    }
    FBO_render.unbind();

//      drawScreenQuad( gl, screen_quad_shader, screen_quad, FBO_render.getTexture() );

    //------------------------------------------------------------------------
    // FBO: GEOMETRY PASS (normals, depth)
    //------------------------------------------------------------------------
//    gl.disable(RenderingContext.BLEND);
//    FBO_pass_geom.bind();
//    {
//      gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT );
//      q3_shader_pass_geom.bind();
//      {
//        q3_shader_pass_geom.setMat4_Projection(Mat4_Projection);
//        // drawFloor(gl, rectangle, q3_shader_pass_geom, groundplane_tex.HANDLE_TEX);
//        DwState.pushMat4(Mat4_ModelView);
//        {
//          Mat4_ModelView = Mat4_ModelView.translate(0.0,0.0,40.0); //DwMat4.translate_ref_slf(Mat4_ModelView, [0, 0, 25]);
//          
//          drawModel(gl, player_1, q3_shader_pass_geom, q3_frame_IDX, new Vector3(0.0, 50.0, 0.0));
//          
//          
//        }
//        Mat4_ModelView = DwState.popMat4();
//      }
//      q3_shader_pass_geom.unbind();
//    }
//    FBO_pass_geom.unbind();






//    if( CTX.key_info.keypressed ){
//      if( CTX.key_info.keychar === 'D'){
//        use_DOF = !use_DOF;
//      }
//    }
//    use_DOF = GUI_VALUES.USE_DOF;
//    if( !use_DOF ){
//      drawScreenQuad( gl, screen_quad_shader, screen_quad, FBO_render.getTexture() );
//      return ;
//    }

    //------------------------------------------------------------------------
    // FBO: DOF PASS
    //------------------------------------------------------------------------
    //FBO_render.bind();
    //gl.disable(RenderingContext.DEPTH_TEST);
    //gl.disable(RenderingContext.BLEND);

//    if( CTX.key_info.keypressed ){
//      if( CTX.key_info.keychar === 'F'){
//        var m = CTX.mouse_info;
//        DOF_DISTANCE += parseInt( (m.mouseX-m.pmouseX)/2);
//        if( DOF_DISTANCE < 50) DOF_DISTANCE = 50;
//      }
//    }
//    DOF_DISTANCE = GUI_VALUES['DOF_DISTANCE'];
//
//    DOF_shader_v1.bind();
//    {
//      DOF_shader_v1.setViewportSize(leftViewport.width , leftViewport.height);
//      DOF_shader_v1.setDOF(DOF_DISTANCE, DOF_STRENGTH);
//      DOF_shader_v1.setCamNearFar(0.2, 1000);
//
//      
//      
//      DOF_shader_v1.setMat4_Projection(leftProjMat);
//      //DOF_shader_v1.setMat4_Projection(screen_quad.Mat4_Projection);
//
//      DOF_shader_v1.activeTexture(DOF_shader_v1.UN_SAMP2D_RENDERING, 0);
//      gl.activeTexture(RenderingContext.TEXTURE0);
//      gl.bindTexture(RenderingContext.TEXTURE_2D, FBO_render.getTexture() );
//
//      DOF_shader_v1.activeTexture(DOF_shader_v1.UN_SAMP2D_NORMAL_Z, 1);
//      gl.activeTexture(RenderingContext.TEXTURE1);
//      gl.bindTexture(RenderingContext.TEXTURE_2D, FBO_pass_geom.getTexture() );
//
//      //screen_quad.draw(DOF_shader_v1);
//      //screen_quad.draw(DOF_shader_v1);
//      
//      gl.activeTexture(RenderingContext.TEXTURE0); 
//      gl.bindTexture(RenderingContext.TEXTURE_2D, null );
//      
//      gl.activeTexture(RenderingContext.TEXTURE1); 
//      gl.bindTexture(RenderingContext.TEXTURE_2D, null);
//    }
//    DOF_shader_v1.unbind();
//
//    FBO_render.unbind();

    //drawScreenQuad( gl, screen_quad_shader, screen_quad, FBO_render.getTexture() );
    
    
    
    
    
    
/// test code from eariler (could load files with this but couldnt get a rendering)
//    q3_shader.bind();
//    player_models.forEach((Q3_Player player)
//    {
//      if(player.AllLoaded == true)
//      {
//        int frame_IDX = 0;
//        
//        Matrix4 mat4_modelview = leftViewMat;
//        Matrix4 mat4_modelworld =leftProjMat;
//        
//        
//        // DRAW REAL
//        q3_shader.setMirrored(false);
//        // set light-positions
//        //q3_shader.setVec4_Light(1, v4_light_1_eye);
//        //q3_shader.setVec4_Light(2, v4_light_2_eye);
//        //q3_shader.setVec4_Light(3, v4_light_3_eye);
//        gl.disable(RenderingContext.STENCIL_TEST);
//        gl.enable(RenderingContext.DEPTH_TEST);
//        gl.enable(RenderingContext.BLEND);
//        q3_shader.setDefaultColor([0.0, 0.0, 0.0, 0.0]);
//        
//        
//        //mat4_modelview = mat4_translate(mat4_modelview, playerMover.position);
//        
//        player.drawModel(q3_shader, frame_IDX, mat4_modelview, mat4_modelworld);
//      }      
//    });
//    q3_shader.unbind();
  }
  
  static drawModel(rendering_context gl, Q3_Player model,Q3_surface_shader_generic shader, int frame, Vector3 v3_transl)
  {
    DwState.pushMat4(Mat4_ModelWorld);
    {
      Mat4_ModelWorld = Mat4_ModelWorld.translate(v3_transl); //DwMat4.translate_ref_slf(Mat4_ModelWorld, v3_transl);
      
      model.drawModel(shader, frame, Mat4_ModelView, Mat4_ModelWorld);
    }
    Mat4_ModelWorld = DwState.popMat4();
  }
}