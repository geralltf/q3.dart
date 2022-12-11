part of tech3;
//todo: create Tech3 wrapper class for map loader and character model loader

///////////////////////////////////


String mapName = 'atcs'; // 'q3tourney2', 'atcs', 'sw_oasis_b3'
String mapFileName = mapName + '.bsp';
String map_uri = q3bsp_base_folder+'/maps/' + mapFileName;
String map_levelshot = '../base/levelshots/' + mapName + '.jpg';
String map_title = mapName.toUpperCase();
int map_tasks_count = 58;
bool preserve_tga_images = false;

// Constants
var q3bsp_vertex_stride = 56;
var q3bsp_sky_vertex_stride = 20;
const String q3bsp_base_folder = 'base';
const String q3bsp_no_shader_default_texture_url = q3bsp_base_folder + '/webgl/no-shader.png';
const String q3bsp_no_shader_default_texture_url2 = q3bsp_base_folder + '/webgl/no-tex.png';

String splash_filename_format = './images/splash/{0}.jpg';
int splash_number_of_images = 8;
int splash_rotate_time = 3000;
bool splash_enabled = false;

var mapShaders = 
[
  //'scripts/sw_oasis_b3.shader', // Incompatible BSP version. IBSP V.47
  'scripts/atcs.shader', 
  //'scripts/atcs.arena', // problem loading this
  //'scripts/atcs.particle', // problem loading this
];

// If you're running from your own copy of Quake 3, you'll want to use these shaders
/*var mapShaders = [
'scripts/base.shader', 'scripts/base_button.shader', 'scripts/base_floor.shader',
'scripts/base_light.shader', 'scripts/base_object.shader', 'scripts/base_support.shader',
'scripts/base_trim.shader', 'scripts/base_wall.shader', 'scripts/common.shader',
'scripts/ctf.shader', 'scripts/eerie.shader', 'scripts/gfx.shader',
'scripts/gothic_block.shader', 'scripts/gothic_floor.shader', 'scripts/gothic_light.shader',
'scripts/gothic_trim.shader', 'scripts/gothic_wall.shader', 'scripts/hell.shader',
'scripts/liquid.shader', 'scripts/menu.shader', 'scripts/models.shader',
'scripts/organics.shader', 'scripts/sfx.shader', 'scripts/shrine.shader',
'scripts/skin.shader', 'scripts/sky.shader', 'scripts/test.shader'
];*/

// For my demo, I compiled only the shaders the map used into a single file for performance reasons
//var mapShaders = ['scripts/web_demo.shader'];

double playerDirectionMagnitude = 1.0;

// Some movement constants ripped from the Q3 Source code
double q3movement_stopspeed = 100.0;
double q3movement_duckScale = 0.25;
double q3movement_jumpvelocity = 50.0;

double q3movement_accelerate = 10.0;
double q3movement_airaccelerate = 0.1;
double q3movement_flyaccelerate = 8.0;

double q3movement_friction = 6.0;
double q3movement_flightfriction = 3.0;

double q3movement_frameTime = 0.30;
double q3movement_overclip = 0.501;
double q3movement_stepsize = 18.0;

double q3movement_gravity = 20.0;
//double q3movement_gravity = 10.0;

double q3movement_playerRadius = 10.0;
double q3movement_scale = 50.0;

double q3bsptree_trace_offset = 0.03125;


//
// Default Shaders
//

const String q3bsp_default_vertex = 
"""#ifdef GL_ES 
precision highp float;
#endif 

attribute vec3 position; 
attribute vec3 normal; 
attribute vec2 texCoord; 
attribute vec2 lightCoord; 
attribute vec4 color; 

varying vec2 vTexCoord; 
varying vec2 vLightmapCoord; 
varying vec4 vColor; 

uniform mat4 modelViewMat; 
uniform mat4 projectionMat; 

void main(void) { 
  vec4 worldPosition = modelViewMat * vec4(position, 1.0); 
  vTexCoord = texCoord; 
  vColor = color; 
  vLightmapCoord = lightCoord; 
  gl_Position = projectionMat * worldPosition; 
}""";

const String q3bsp_default_fragment = 
"""#ifdef GL_ES 
precision highp float; 
#endif 

varying vec2 vTexCoord; 
varying vec2 vLightmapCoord; 
uniform sampler2D texture;
uniform sampler2D lightmap;

void main(void) { 
        vec4 diffuseColor = texture2D(texture, vTexCoord); 
        vec4 lightColor = texture2D(lightmap, vLightmapCoord); 
        gl_FragColor = vec4(diffuseColor.rgb * lightColor.rgb, diffuseColor.a); 
}""";

const String q3bsp_model_fragment = 
"""#ifdef GL_ES 
precision highp float; 
#endif 

varying vec2 vTexCoord; 
varying vec4 vColor; 
uniform sampler2D texture; 

void main(void) { 
    vec4 diffuseColor = texture2D(texture, vTexCoord); 
    gl_FragColor = vec4(diffuseColor.rgb * vColor.rgb, diffuseColor.a);
}""";
