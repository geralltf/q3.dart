part of tech3;

class trace_output
{
  bool allSolid;
  bool startSolid;
  double fraction;
  Vector3 endPos;
  Plane plane;
}
class Plane
{
  Vector3 normal;
  double distance;
}

class bsp_tree
{
  Queue<Plane> planes;
  Queue nodes;
  Queue leaves;
  List leafFaces;
  List leafBrushes;
  List brushes;
  List brushSides;
  List<shader_p> surfaces;
  var visBuffer;
  var visSize;
}

class bsp_tree_node
{
  int plane; // long
  List children;
  var min;
  var max;
}

class sky_env_map_p
{
  String params;
  List<String> cubemap_urls;
  bool single_textured;
  
  sky_env_map_p(String skyparams)
  {
    this.params = skyparams;
    
    single_textured = true;
    cubemap_urls = [];
  }
}

class shader_p
{
  String shaderName;
  int flags;
  int contents;
  shader_gl shader;
  List faces;
  int indexOffset;
  int elementCount = 0;
  bool visible = true;
  var geomType;
}
class shader_t
{
    String url;
    String name = null;
    String cull = 'back';
    bool sky = false;
    bool blend = false;
    bool opaque = false;
    int sort = 0;
    List<deform_t> vertexDeforms = [];
    List<stage_t> stages = [];
    sky_env_map_p sky_env_map;
}
class shader_gl
{
  String name;
  List<stage_gl> stages;
  var cull;
  bool blend;
  int sort;
  bool sky;
  bool model;
  sky_env_map_p sky_env_map;
}
class stage_t 
{
    var map = null;
    bool clamp = false;
    String tcGen = 'base';
    String rgbGen = 'identity';
    var rgbWaveform = null;
    String alphaGen = '1.0';
    var alphaFunc = null;
    var alphaWaveform = null;
    var blendSrc = 'GL_ONE';//can be int problem
    var blendDest = 'GL_ZERO';
    bool hasBlendFunc = false;
    List tcMods = [];
    List animMaps = [];
    var animFreq = 0;
    var depthFunc = 'lequal';// can be int problem
    bool depthWrite = true;
    bool isLightmap = false;
    bool depthWriteOverride = false;
    List<stage_t> stages = [];
    bool blend;
    bool opaque;
    shader_src_t shaderSrc;
    var texture;
    var animFrame;
    var animTexture;
}
class stage_gl
{
  String map;
  var animFreq;
  GLTexture texture;
  List<GLTexture> animTexture;
  shader_prog_t program;
  var blendSrc;
  var blendDest;
  bool depthWrite;
  var depthFunc;
  bool isLightmap;
  List animMaps = [];
  int animFrame;
  shader_src_t shaderSrc;
  bool clamp;

  String tcGen = 'base';
  String rgbGen = 'identity';
  var rgbWaveform = null;
  String alphaGen = '1.0';
  var alphaFunc = null;
  var alphaWaveform = null;
  bool hasBlendFunc = false;
  List tcMods = [];
  bool depthWriteOverride = false;
  List<stage_t> stages = [];
  bool blend;
  bool opaque;
}

class shader_src_t
{
  vertex_shader_src_t vertex;
  fragment_shader_src_t fragment;
}

class tcMod_t
{
  String type;
  double angle;
  double scaleX;
  double scaleY;
  double sSpeed;
  double tSpeed;
  waveform_t waveform;
  turbulance_t turbulance;
}

class turbulance_t
{
  double base;
  double amp;
  double phase;
  double freq;
}

class waveform_t
{
  String funcName;
  double base;
  double amp;
  dynamic phase; // string then set as double 
  double freq;
}

class deform_t
{
  String type;
  double spread;
  waveform_t waveform;
}

class vertex_shader_src_t
{
  String source_code;
}

class fragment_shader_src_t
{
  String source_code;
}

class shader_prog_t
{
  GLProgram program;
  Map attrib;
  Map uniform;
}

class surface_t
{
  String shaderName;
  int geomType;
  shader_gl shader;
  int elementCount;
  int indexOffset;
  bool visible;
}
class lightmap_t
{
  int x;
  int y;
  var width;
  var height;
  var bytes;
}
class lightmap_rect_t
{
  var x;
  var y;
  var xScale;
  var yScale;
}