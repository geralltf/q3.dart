part of tech3;
//TODO: implement async texture loading
typedef OnTextueLoad(dynamic texture);
typedef OnTextueImageLoadComplete(dynamic texture, Object image);

Map<String,Texture> url_cache_texture = new Map<String,Texture>();
Map<String,Object> data_cache_texture = new Map<String,Object>();
fetch_texture(String url, 
              OnTextueLoad onGlTexture, 
              OnTextueImageLoadComplete onloadComplete)
{
  dynamic texture = null;
  var image = null;
  
  if(onGlTexture!=null)
  {
    if(url_cache_texture.containsKey(url))
    {
      texture = url_cache_texture[url];
    }
    else
    {
      texture = gl.createTexture();
    }
    onGlTexture(texture);
  }
  
  if(onloadComplete!=null)
  {
    if(data_cache_texture.containsKey(url))
    {
      image = data_cache_texture[url];
      
      onloadComplete(texture,image);
    }
    else
    {
//      fetch(url,'arraybuffer').then((HttpRequest request){
//        var respp = request.response;
//        
//        print("["+request.statusText+"] "+request.responseUrl);
//        
//        var image = respp;
//        onloadComplete(texture,image);
//      });
      
      
      image = new ImageElement();
      image.onLoad.listen((event)
      {
        onloadComplete(texture,image);
        fetch_update(url);
      });
      image.src = url;
    }
  }
}