part of tech3;

/* scene state */

const double zNear = 1.0;
const double zFar = 4096.0;

// ===========================================
// Everything below here is common to all maps
Matrix4 leftViewMat, rightViewMat, leftProjMat, rightProjMat;
Viewport leftViewport, rightViewport;
var activeShader;
q3bsp map;
q3movement playerMover;
bool mobileSite = false;


// VR Globals
bool vrEnabled = false;
bool vrForced = false;
var vrHMD = null;
var vrSensor = null;
var vrTimewarp = true;
bool webvr_enabled = false;
bool gamepad_enabled = false;
var gamepads = [];

// These values are in meters
List<double> vrEyeLeft = [-0.03, 0.0, 0.0];
List<double> vrEyeRight = [0.03, 0.0, 0.0];
double playerHeight = 57.0; // Roughly where my eyes sit (1.78 meters off the ground)
double vrIPDScale = 32.0; // There are 32 units per meter in Quake 3
var vrFovLeft = null;
var vrFovRight = null;
var vrPosition = null;

var vrDrawMode = 0;

var SKIP_FRAMES = 0;
var REPEAT_FRAMES = 1;

StatsFps stats;
int startTime;
int lastTimestamp;
int lastFps;
int frameId;
var lastIndex = 0;
var lastMove = 0;
Matrix4 hmdOrientationMatrix = new Matrix4.identity();

Map pressed = new Map(); // length of 128 elements
Matrix4 cameraMat = new Matrix4.identity(); //.create()
Vector3 vrEuler = new Vector3.zero();

CanvasElement canvas;
int request_number=0;
ImageElement splashscreen_img;
DivElement splashscreen_ui;
Timer tmr_rotate;
Input input = new Input();
jQuery JQuery = new jQuery();

typedef OnMapLoadComplete(String map_name);

void scene_init()
{
  display_splash_screen();
  hide_crosshair_ui();
  hide_audio_graph();
  hide_viewport_ui();
  display_progress_bar();
  set_levelshot(map_levelshot);
  init_worker();
}

OnMapLoadComplete OnMapLoaded=(String map)
{
  hide_progress_bar();
  hide_levelshot();
  hide_splash();
 
  //display_audio_graph();
  display_viewport_ui();
  display_crosshair_ui();
  
  respawnPlayer(0);
  document.getElementById('viewport').style.display = 'block';
  onResize(null);
};

void bsp_initilised(q3bsptree bsp) 
{
    playerMover = new q3movement(bsp);
}

void display_player_position(Vector3 position)
{
  query('.TopMiddleView .Text').innerHtml = 'PLAYER ${position.x}, ${position.y}, ${position.z} ${keyspressed}';
}

void update_progress_bar(int request_number, String url)
{
  String pbws = query('#progress-bar').style.width;
  
  
  var pbw = pbws.replaceAll('px', '');
  pbw = pbw == null ? '' : pbw;
  
  double progress_width = double.parse(pbw,(String e){
    print("weird error with progress width: "+e);
    return 0;
  });
  double progress = progress_width * (request_number / map_tasks_count);
  query('#progress').style.width = progress.toString() +'px';
  query('#progress-url').innerHtml = url;
  //query('#progress-url').innerHtml = request_number.toString() +'; '+url;
  
  if(request_number == map_tasks_count && OnMapLoaded != null)
  {
    OnMapLoaded(mapName);
  }
}

void display_splash_screen()
{
  if(!splash_enabled) {
    return;
  }
  splashscreen_ui  = query('.Splashscreen');
  splashscreen_img = document.createElement('img');
  splashscreen_ui.style.display = 'block';
  splashscreen_ui.children.add(splashscreen_img);
  splashscreen_img.style.display = 'none';
  splashscreen_img.className = 'SplashscreenImg';
  splashscreen_img.onLoad.listen((e)
  {
    splashscreen_img.style.display = 'none';
    var ui = JQuery.find('.SplashscreenImg');
    ui.fadeIn(1000);
  });
  //splashscreen_img.src = splash_uri();
  
  if(splash_enabled) {
    tmr_rotate = new Timer.periodic(new Duration(milliseconds: splash_rotate_time), (Timer tmr)
    {
      if(!splash_enabled) return;
      splashscreen_img.src = splash_uri();  
    });
  }
  else{
    tmr_rotate = null;
  }
}

void hide_splash()
{
  if(tmr_rotate!= null)
  {
    tmr_rotate.cancel();
    tmr_rotate=null;
  }
  if(splashscreen_img != null) splashscreen_img.remove();
  if(splashscreen_ui != null) splashscreen_ui.remove();
}

String splash_uri()
{
  /* gets a random splash image defined by config */
  
  String splash = q3bsp_no_shader_default_texture_url;
  
  Random rand = new Random();
  
  int splash_index = rand.nextInt(splash_number_of_images);
  
  splash = splash_filename_format.replaceFirst('{0}', splash_index.toString());
  
  return splash;
}

void display_crosshair_ui()
{  
  var ui = JQuery.find('.CrosshairUI');
  ui.fadeIn(2000);
}

void hide_crosshair_ui()
{
  DivElement crosshairUI  = query('.CrosshairUI');
  
  crosshairUI.style.display = 'none';
}

void display_audio_graph()
{
  query('#audio-graph').style.display = 'block';
  audio_graph.init();
}

void hide_audio_graph()
{
  query('#audio-graph').style.display = 'none';  
}

void display_viewport_ui()
{
  query('#viewport-ui').style.display = 'block';
  
  viewport_ui.init();
}

void hide_viewport_ui()
{
  query('#viewport-ui').style.display = 'none';  
}

void display_progress_bar()
{
    query('#progress-bar').style.display = 'block';
    query('#progress').style.width = '0px';
}
void hide_progress_bar()
{
  query('#progress-bar').style.display = 'none';
}
void hide_levelshot()
{
  query('html.LoadingMap').style.background = 'none';
  query('html.LoadingMap .layer').style.display = 'none';
  //query('#loading_anim').style.display = 'none';
}

void set_levelshot(String url)
{
  context['q3levelshot'] = url;
  
  var style = new StyleElement();
  document.head.append(style);
  
  var styleSheet = document.styleSheets[0] as CssStyleSheet;
  var rule = 'html.LoadingMap { background: url($url) no-repeat center center fixed;}';
  styleSheet.insertRule(rule, 0);
  
  query('html.LoadingMap .layer').style.display = 'block';
  query('#loading_anim').style.display = 'block';
  
}
fetch_update(url){
  update_progress_bar(++request_number, url);
}
Future<HttpRequest> fetch(String url, String response_type)
{
  fetch_update(url);
  return HttpRequest.request(url, responseType: response_type);
}