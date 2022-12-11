part of tech3;

//
// Shader Tokenizer
//

class shaderTokenizer
{
  List<String> tokens;
  var offset;
  
  shaderTokenizer(String src)
  {
    //String no_comments_patt = "(\/\*[\w\'\s\r\n\*]*\*\/)|(\/\/[\w\s\']*)|(\<![\-\-\s\w\>\/]*\>)";
    //String no_comments_patt = r"\\*([^*]|[\r\n]|(\\*+([^*/]|[\r\n])))*\\*+";
    
    JsObject jsinterop = context['jsinterop'];
    
    src = jsinterop.callMethod('strip_comments',[src]);
    
    // Strip out comments    
     //src = src.replaceAll(new RegExp(no_comments_patt, multiLine: true, caseSensitive: false), '');
     
     // (\/\*[\w\'\s\r\n\*]*\*\/)|(\/\/[\w\s\']*)|(\<![\-\-\s\w\>\/]*\>)
     
     //src = src.replace(/\/\/.*$/mg, ''); // C++ style (//...)       
     //src = src.replace(/\/\*[^*\/]*\*\//mg, ''); // C style (/*...*/) (Do the shaders even use these?)
     
     
     //this.tokens = src.match(/[^\s\n\r\"]+/mg);
    this.tokens = jsinterop.callMethod('tokenise_shader',[src]); 
    
    //RegExp reg = new RegExp("[^\s\n\r\"]+");
     //this.tokens = reg.allMatches(src);
     
     
     
     this.offset = 0;
  }
  
  bool EOF () 
  {
      if(this.tokens == null) { return true; }
      if(this.tokens.length == 0) { return true; }
      
      //if(this.offset >= this.tokens.length) return true;
      
//      var token = this.tokens[this.offset];
//      while(token == '' && this.offset < this.tokens.length) {
//          this.offset++;
//          token = this.tokens[this.offset];
//      }
      return this.offset >= this.tokens.length;
  }
  String next () 
  {
      if(this.tokens == null) { return null; }
      var token = '';
      while(token == '' && this.offset < this.tokens.length) 
      {
          if(this.offset>=this.tokens.length) return null;
          
          token = this.tokens[this.offset];
          
          this.offset++;
      }
      return token;
  }
  String prev() 
  {
      if(this.tokens == null) { return null; }
      var token = '';
      while(token == '' && this.offset >= 0) 
      {
        this.offset--;  
        token = this.tokens[this.offset];
          
      }
      return token;
  }
  
}