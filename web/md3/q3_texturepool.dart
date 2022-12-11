part of tech3;

class Q3_TexturePool
{
  rendering_context gl;
  List<DwImage> tex_list;
  
  Q3_TexturePool(rendering_context gl)
  {
    this.gl = gl;
    this.tex_list = new List<DwImage>();
  }
  
  DwImage getTexture  (String path, String filename)
  {
    int len = this.tex_list.length;
    for(int i = 0; i < len; i++){
      var tex = this.tex_list[i];
      if( path == tex.path && filename == tex.filename){
        return tex;
      }
    }
    DwImage tex = new DwImage( this.gl, path, filename);
    this.tex_list.add(tex);
    return tex;
  }

  void delete  ()
  {
//  console.log("deleting textures: "+this.tex_list.length);
    var len = this.tex_list.length;
    for(var i = 0; i < len; i++){
      var tex = this.tex_list[i];
      tex.delete(null);
    }
    this.tex_list = [];
  }
}