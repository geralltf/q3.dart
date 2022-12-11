part of tech3;

// Binary Stream Reader
class binary_stream
{
  //String buffer;
  ByteBuffer bytes;
  ByteData data;
  int length;
  int offset;
  
  binary_stream(ByteBuffer bytes)
  {
    this.bytes = bytes;
    this.length = bytes.lengthInBytes;
    this.data = bytes.asByteData(0,this.length);
    this.offset = 0;
  }
  
  binary_stream forward (offset){
    this.offset += offset;
    return this;
  }
  binary_stream backward (offset){
    this.offset -= offset;
    return this;
  }
  
  int available ()
  {
    return this.length -  this.offset;
  }
  
  int totalSize ()
  {
    return this.length;
  }
  
  
  int getPos ()
  {
    return this.offset;
  }
  
  void setPos (int newpos)
  {
    this.offset = newpos;
  }
  
  bool eof()
  {
    return this.offset >= this.length;
  }
  
  // Seek to the given byt offset within the stream
  void seek(int offset) 
  {
    this.offset = offset;
  }
  
  int tell() 
  { 
    return this.offset; 
  }
  
  int readInt32()
  {
    Int32List values = this.bytes.asInt32List(this.offset ,1);
    int number_of_bytes = Int32List.BYTES_PER_ELEMENT*1;
    this.offset += number_of_bytes; 
    return values.elementAt(0); // returns Int32Array
  }

  // Read a signed byte from the stream
  readByte()
  {
    var byte = data.getInt8(this.offset) & 0xff;
    this.offset += 1;
    return byte - (byte & 0x80); // signed
  }
  
  // Read an unsigned byte from the stream
  readUByte()
  {
    var byte = data.getUint8(this.offset) & 0xff;
    this.offset += 1;
    return byte;
  }
  
  // Read a signed short (2 bytes) from the stream
  int readShort() 
  {
    var i = this.offset;
    bf_wuba[0] = data.getUint8(i) & 0xff;
    bf_wuba[1] = data.getUint8(i+1) & 0xff;
    this.offset += 2;
    int s;
    s = bf_wsa[0];
    return s; // typecast combining 2 bytes into a short
  }
  
  // Read an unsigned short (2 bytes) from the stream
  readUShort () 
  {
    var i = this.offset;
    bf_wuba[0] = data.getUint8(i)    & 0xff;
    bf_wuba[1] = data.getUint8(i+1)    & 0xff;
    this.offset += 2;
    return bf_wusa[0]; // typecast combining 2 bytes into an unsigned short
  }

  // Read a signed long (4 bytes) from the stream
  readLong() 
  {
    var i = this.offset;
    bf_wuba[0] = data.getUint8(i)    & 0xff;
    bf_wuba[1] = data.getUint8(i+1)  & 0xff;
    bf_wuba[2] = data.getUint8(i+2)  & 0xff;
    bf_wuba[3] = data.getUint8(i+3)  & 0xff;
   this.offset += 4;
   return bf_wia[0]; // typecast combining 4 bytes into long
  }
  
  // Read an unsigned long (4 bytes) from the stream
  readULong() 
  {
    int i = this.offset;
    bf_wuba[0] = data.getUint8(i)    & 0xff;
    bf_wuba[1] = data.getUint8(i+1)  & 0xff;
    bf_wuba[2] = data.getUint8(i+2)  & 0xff;
    bf_wuba[3] = data.getUint8(i+3)  & 0xff;
    this.offset += 4;
    return bf_wuia[0]; // typecast combining 4 bytes into an unsigned long
  }

  // Read a float (4 bytes) from the stream
  double readFloat() 
  {
   var i = this.offset;
   bf_wuba[0] = data.getUint8(i) & 0xff;
   bf_wuba[1] = data.getUint8(i+1) & 0xff;
   bf_wuba[2] = data.getUint8(i+2) & 0xff;
   bf_wuba[3] = data.getUint8(i+3) & 0xff;
   this.offset += 4;
   double f;
   f = bf_wfa[0];
   return f; // typecast combining 4 bytes into a float
  }

  expandHalf(h) 
  {
   var s = (h & 0x8000) >> 15;
   var e = (h & 0x7C00) >> 10;
   var f = h & 0x03FF;
   
   if(e == 0) 
   {
       return (s?-1:1) * pow(2,-14) * (f/pow(2, 10));
   } 
   else if (e == 0x1F) 
   {
     return (f != null) ? NAN : (((s != null) ? -1 : 1) * INFINITY);
   }
   
   return (s?-1:1) * pow(2, e-15) * (1+(f/pow(2, 10)));
  }

  readHalf() 
  {
    var h = this.readUShort();
    return this.expandHalf(h);
  }

//  // Read an ASCII string of the given length from the stream
//  String readString (int length) 
//  {    
//    String str;
//    Uint8List characters = getUint8Array(offset,length);
//    
//    offset+=Uint8List.BYTES_PER_ELEMENT*length;
//    
//    str = UTF8.decode(characters, allowMalformed: false);
//
//    str = str.replaceAll(new RegExp(r'\0+')  ,''); // /\0+$/
//    
//    /*
//     * 
//     if( lastchar ){
//      var idx = str.indexOf("\0");
//      if( idx >= 0){
//        str = str.substring(0, idx);
//      }
//    }
//     */
//    
//    return str;
//  }
  
  String readString (int offset, int length) 
  {
    String result;
    this.offset += offset;
    
    int number_of_bytes = length; //Uint8List.BYTES_PER_ELEMENT*length;
    Uint8List chrset = this.bytes.asUint8List(this.offset, number_of_bytes) ;

    List<int> characters = new List<int>();
    
    for(int i = 0; i < chrset.length; i++)
    {
      int char = chrset[i];
      
      if(char == 0)
      {
        break;
      }
      
      characters.add(char);
    }
    
    result = UTF8.decode(characters, allowMalformed:  true);

//    int idx = result.indexOf('\0');
//    if( idx >= 0)
//    {
//      result = result.substring(0, idx);
//    }
      
    //result = result.replaceAll(new RegExp(r'\0+')  ,''); // /\0+$/
    
    this.offset+= number_of_bytes;
    
    return result;
  }
}

// This is the result of an interesting trick that Google does in their
// GWT port of Quake 2. (For floats, anyway...) Rather than parse and 
// calculate the values manually they share the contents of a byte array
// between several types of buffers, which allows you to push into one and
// read out the other. The end result is, effectively, a typecast!

/* memory sharing behind lists not available in dart so js interop is used here */

var bf_byteBuff = context['bf_byteBuff']; 
var bf_wba = context['bf_wba'];
var bf_wuba = context['bf_wuba'];
var bf_wsa = context['bf_wsa'];
var bf_wusa = context['bf_wusa'];
var bf_wia = context['bf_wia'];
var bf_wuia = context['bf_wuia'];
var bf_wfa = context['bf_wfa'];

//var bf_byteBuff = new ArrayBuffer(4);
//var bf_wba = new Int8Array(bf_byteBuff);
//var bf_wuba = new Uint8Array(bf_byteBuff);
//
//var bf_wsa = new Int16Array(bf_byteBuff);
//var bf_wusa = new Uint16Array(bf_byteBuff);
//
//var bf_wia = new Int32Array(bf_byteBuff);
//var bf_wuia = new Uint32Array(bf_byteBuff);
//
//var bf_wfa = new Float32Array(bf_byteBuff);
