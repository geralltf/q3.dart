part of tech3;

// http://netghost.narod.ru/gff/graphics/summary/tga.htm
//http://netghost.narod.ru/gff/graphics/book/ch09_03.htm#RUEN-CHP-09

class DwImage_TGA
{
  var path;
  var filename;
  var total_file_path;
  var onerror=(){};
  var onload=(){};
  
  DwImage_TGA(String path, String filename )
  {
  //  this.gl = gl;
   this.path = path != null ? path : "";
   this.filename = filename;
   this.total_file_path = this.path + this.filename;
   if(this.filename == null || this.filename == '')
   {
     print ("(Image_TGA) invalid filename, can't load TGA: "+this.total_file_path);
   }
   
   this.onload = (){};
   this.onerror = (){
     print("ERROR while loading TGA-Image: "+this.total_file_path);
   };
  }

  load (obj, bool async)
  {
   var _this = this;
  
   HttpRequest.request(this.total_file_path, responseType: 'arraybuffer').then((HttpRequest request)
   {
     _this.loadTGA(request.response);
     _this.onload();
   });
   
   // make request
  //
  //    try{
  //      XHR.send(obj); // usually null
  //    } catch (exception){
  ////    print(exception);
  //      _this.onerror();
  //    }
  }

  var ID;
  var col_map_type;
  var image_type;
  var col_map_start;
  var col_map_len;
  var col_map_depth;
  var x_pos;
  var y_pos;
  var width;
  var height;
  var pixel_depth;
  var pixel_attr;
  var pixel_count;
  var pixels;
  int loading_time;
  
  loadTGA (ByteBuffer arraybuffer)
  {
     int time_start = new DateTime.now().millisecondsSinceEpoch;
    
     
     Uint8List buf = arraybuffer.asUint8List(); // new Uint8List(arraybuffer);
     var IDX = 0;
     this.ID            = buf[IDX++];  // 0=no ID, otherwise length of id(0-255
     this.col_map_type  = buf[IDX++];  // 0=not existing, 1=existing
     this.image_type    = buf[IDX++];  // 0-11
     this.col_map_start = buf[IDX++] | (buf[IDX++] << 8); // 0=standard
     this.col_map_len   = buf[IDX++] | (buf[IDX++] << 8); // number of colors
     this.col_map_depth = buf[IDX++];  // 15,16,24,32
     this.x_pos         = buf[IDX++] | (buf[IDX++] << 8); // 0=standard
     this.y_pos         = buf[IDX++] | (buf[IDX++] << 8); // 0=standard
     this.width         = buf[IDX++] | (buf[IDX++] << 8); //
     this.height        = buf[IDX++] | (buf[IDX++] << 8); //
     this.pixel_depth   = buf[IDX++];  // 8, 15,16,24,32
     this.pixel_attr    = buf[IDX++];  //
    
     this.pixel_count = this.width*this.height;
    
    //  http://www.khronos.org/registry/webgl/specs/latest/#TEXIMAGE2D
     if( this.pixel_depth == 32 ){
    //    this.gl_target         = this.gl.TEXTURE_2D;
    //    this.gl_internalformat = this.gl.RGBA;
    //    this.gl_format         = this.gl.RGBA;
    //    this.gl_type           = this.gl.UNSIGNED_BYTE;
       this.pixels            = new Uint8List(this.pixel_count * 4);
     }
     if( this.pixel_depth == 24 ){
    //    this.gl_target         = this.gl.TEXTURE_2D;
    //    this.gl_internalformat = this.gl.RGB;
    //    this.gl_format         = this.gl.RGB;
    //    this.gl_type           = this.gl.UNSIGNED_BYTE;
       this.pixels            = new Uint8List(this.pixel_count * 3);
     }
    
    //  this.log();
    
     IDX += this.ID; //skip id-content
     if( this.col_map_type == 1 ){
       print("TGA_Loader currently not supports color \"color map format\"");
     }
    
    //  for(var i = 0; i < 1000; i++){
     switch( this.image_type ){
       case  0: break; //no data
       case  1: this.loadColorMap     (buf, IDX); break; // color_map_indices, uncompressed
       case  2: this.loadTrueColor    (buf, IDX); break; // true_color, uncompressed
       case  3: this.loadMonochrom    (buf, IDX); break; // monochrom/grayscale, uncompressed
       case  9: this.loadColorMap_RLE (buf, IDX); break; // color_map_indices, RLE
       case 10: this.loadTrueColor_RLE(buf, IDX); break; // true_color,, RLE
       case 11: this.loadMonochrom_RLE(buf, IDX); break; // monochrom/grayscale, RLE
     }
    //  }
    
     if( !true ){ //TODO
       print("(!CORRPUT FILE!)");
     } else {
       var size = buf.length;
       this.loading_time = new DateTime.now().millisecondsSinceEpoch - time_start;
    //    print(">>> loaded TGA-File ("+this.loading_time+" ms, "+size+" bytes): \""+this.filename+"\"");
     }
  }
  




  
  loadTrueColor (buf, IDX)
  {
     var pixl_idx = 0;
     var buff_idx = IDX;
     var counter =  this.pixel_count;
     if( this.pixel_depth == 32 ) {
       while(counter-- > 0){
         this.pixels[pixl_idx++] = buf[buff_idx+2];
         this.pixels[pixl_idx++] = buf[buff_idx+1];
         this.pixels[pixl_idx++] = buf[buff_idx  ];
         this.pixels[pixl_idx++] = buf[buff_idx+3];
         buff_idx+=4;
       }
     } else if( this.pixel_depth == 24 ){
       while(counter-- > 0){
         this.pixels[pixl_idx++] = buf[buff_idx+2];
         this.pixels[pixl_idx++] = buf[buff_idx+1];
         this.pixels[pixl_idx++] = buf[buff_idx  ];
         buff_idx+=3;
       }
     }
  }



  loadTrueColor_RLE (buf, IDX)
  {
   var pixl_idx = 0;
   var buff_idx = IDX;
   var counter =  this.pixel_count;
  
   if( this.pixel_depth == 32 ) {
     while (counter > 0) {
       var num = buf[buff_idx++];
       var RLE = (num & 0x80) != 0;
       if (RLE) { // compressed
  //        num -= 127;  // (num & 0x7F) + 1
         while(num-- > 127 && --counter> 0){
           this.pixels[pixl_idx++] = buf[buff_idx+2];
           this.pixels[pixl_idx++] = buf[buff_idx+1];
           this.pixels[pixl_idx++] = buf[buff_idx  ];
           this.pixels[pixl_idx++] = buf[buff_idx+3];
  //          --counter;
         }
         buff_idx+=4;
       } else { // uncompressed
         while(num-- >= 0 && --counter> 0){
           this.pixels[pixl_idx++] = buf[buff_idx+2];
           this.pixels[pixl_idx++] = buf[buff_idx+1];
           this.pixels[pixl_idx++] = buf[buff_idx  ];
           this.pixels[pixl_idx++] = buf[buff_idx+3];
  //          --counter;
           buff_idx+=4;
         }
       }
     }
   } else if( this.pixel_depth == 24 ) { //24 bit
     while (counter > 0) {
       var num = buf[buff_idx++];
       var RLE = (num & 0x80) != 0;
       if (RLE) { // compressed
  //        num -= 127;  // (num & 0x7F) + 1
         while(num-- > 127 && --counter> 0){
           this.pixels[pixl_idx++] = buf[buff_idx+2];
           this.pixels[pixl_idx++] = buf[buff_idx+1];
           this.pixels[pixl_idx++] = buf[buff_idx  ];
  //          --counter;
         }
         buff_idx+=3;
       } else { // uncompressed
         while(num-- >= 0 && --counter> 0){
           this.pixels[pixl_idx++] = buf[buff_idx+2];
           this.pixels[pixl_idx++] = buf[buff_idx+1];
           this.pixels[pixl_idx++] = buf[buff_idx  ];
  //          --counter;
           buff_idx+=3;
         }
       }
     }
   }
  }


  
  loadColorMap (buf, IDX){
   throw new Exception("TGA_Loader currently not supports color \"colorMap\""); // TODO
  }
  loadColorMap_RLE (buf, IDX){
   throw new Exception("TGA_Loader currently not supports color \"colorMap, RLE\""); // TODO
  }
  
  
  
  loadMonochrom (buf, IDX){
   throw new Exception("TGA_Loader currently not supports color \"monochrom\""); // TODO
  }
  loadMonochrom_RLE (bufb, IDX){
   throw new Exception("TGA_Loader currently not supports color \"monochrom, RLE\""); // TODO
  }



  
  log ()
  {
   print("ID            = "+ this.ID            );
   print("col_map_type  = "+ this.col_map_type  );
   print("image_type    = "+ this.image_type    );
   print("col_map_start = "+ this.col_map_start );
   print("col_map_len   = "+ this.col_map_len   );
   print("col_map_depth = "+ this.col_map_depth );
   print("x_pos         = "+ this.x_pos         );
   print("y_pos         = "+ this.y_pos         );
   print("width         = "+ this.width         );
   print("height        = "+ this.height        );
   print("pixel_depth   = "+ this.pixel_depth   );
   print("pixel_attr    = "+ this.pixel_attr    );
  }
}
