part of tech3;

class Byter
{
  binary_stream stream;
  bool buffer_is_valid;
  ByteBuffer bytearray;
  //ByteData data;
  var BIG_ENDIAN;
  var LITTLE_ENDIAN;
  int idx;
  int total_size;
  var byte_reading_counter;
  var byte_writing_counter;
  var byte_order;
  
  
  Byter(ByteBuffer arraybuffer)
  {
    //data = arraybuffer.asByteData(0, arraybuffer.lengthInBytes);
    stream = new binary_stream(arraybuffer);
    
    this.buffer_is_valid = (arraybuffer is ByteBuffer);

    if( !this.buffer_is_valid){
      var err = "ERROR (Byter.js): praram \"data\" of wrong type (" 
          + (  arraybuffer.runtimeType.toString()) 
          + "), MUST be of type \"ArrayBuffer\"";
      print(err);
    }

    this.bytearray = arraybuffer; // type of arrayBuffer

    this.BIG_ENDIAN    = 1;
    this.LITTLE_ENDIAN = 2;

    this.idx = 0;
    this.total_size = this.bytearray.lengthInBytes;

    this.byte_reading_counter = 0;
    this.byte_writing_counter = 0;

    this.byte_order = this.BIG_ENDIAN;

  }

  bool isValid ()
  {
    return this.buffer_is_valid;
  }
  
  getBytes ()
  {
    return this.bytearray;
  }
  
  getFloat32Value (int offset)
  {
    return stream.readFloat();
//    int number_of_bytes = Float32List.BYTES_PER_ELEMENT*1;
//    var result = this.getFloat32Array(offset, number_of_bytes)[0];
//
//    return result;
  }
  getInt32Value (int offset) 
  {
    return stream.readInt32();
//    int number_of_bytes = Int32List.BYTES_PER_ELEMENT*1;
//    var result = this.getInt32Array(offset, number_of_bytes)[0];
//    
//    return result;
  }
//  getInt16Value (int offset) 
//  {
//    int number_of_bytes = Int16List.BYTES_PER_ELEMENT*1;
//    var result = this.getInt16Array(offset, number_of_bytes)[0];
//    
//    return result;
//  }
//  getUint16Value (int offset) 
//  {
//    int number_of_bytes = Uint16List.BYTES_PER_ELEMENT*1;
//    var result = this.getUint16Array(offset, number_of_bytes)[0];
//    
//    return result;
//  }
//  getInt8Value (int offset) 
//  {
//    int number_of_bytes = Int8List.BYTES_PER_ELEMENT*1;
//    var result = this.getInt8Array(offset, number_of_bytes)[0];
//    
//    return result;
//  }
//  getUint8Value (int offset) 
//  {
//    int number_of_bytes = Uint8List.BYTES_PER_ELEMENT*1;
//    var result = this.getUint8Array(offset, number_of_bytes)[0];
//    
//    return result;
//  }
//  
// 
//  Uint16List getUint16Array (int offset, int number_of_elements) 
//  {
//    this.idx += offset;
//    
//    int number_of_bytes = number_of_elements;
//    Uint16List values = this.bytearray.asUint16List(this.byte_reading_counter + offset, number_of_bytes);
//    
//    this.idx += number_of_elements;
//    this.byte_reading_counter+= number_of_bytes;
//    
//    return values; 
//  }
//  
//  Int8List getInt8Array (int offset, int number_of_elements) 
//  {
//    this.idx += offset;
//    
//    int number_of_bytes = number_of_elements;
//    Int8List values = this.bytearray.asInt8List(this.byte_reading_counter + offset, number_of_bytes);
//    
//    this.idx += number_of_elements;
//    this.byte_reading_counter+= number_of_bytes;
//    
//    return values;
//  }
//  
//  Uint8List getUint8Array (int offset, int number_of_elements) 
//  {
//    this.idx += offset;
//    
//    int number_of_bytes = number_of_elements;
//    Uint8List values = this.bytearray.asUint8List(this.byte_reading_counter + offset, number_of_bytes) ;
//    
//    this.idx += number_of_elements;
//    this.byte_reading_counter+= number_of_bytes;
//   
//    return values;
//  }
  Int16List getInt16Array (int offset, int number_of_elements) 
  {
    List<int> lst = new List<int>(number_of_elements);
    int s;
    for(int index = 0; index < number_of_elements; index++)
    {
      s = stream.readShort();  
      lst.setAll(index, [s]);
    }
    Int16List values = new Int16List(number_of_elements);
    values.setAll(0, lst);
    return values;
//    this.idx += offset;
//    
//    int number_of_bytes = number_of_elements;
//    Int16List values = this.bytearray.asInt16List(this.byte_reading_counter + offset, number_of_bytes);
//    
//    this.idx += number_of_elements;
//    this.byte_reading_counter+= number_of_bytes;
//    
//    return values;
  }
  Float32List getFloat32Array (int offset, int number_of_elements)
  {
    List<double> lst = new List<double>(number_of_elements);
    double f;
    for(int index = 0; index < number_of_elements; index++)
    {
      f = stream.readFloat();  
      lst.setAll(index, [f]);
    }
    Float32List values = new Float32List(number_of_elements);
    values.setAll(0, lst);
    return values;
//    this.idx += offset;
//    byte_reading_counter += offset;
//    
//    //int number_of_bytes = Float32List.BYTES_PER_ELEMENT * number_of_elements;
//    //Float32List values = this.bytearray.asFloat32List(this.byte_reading_counter + offset, number_of_bytes);
//    
//    List<double> lst = new List<double>(number_of_elements);
//    double f;
//    int number_of_bytes = 4 * number_of_elements;
//    for(int index = 0; index < number_of_elements; index++)
//    {
//      f = _readFloat(this.byte_reading_counter + index);  
//      lst.setAll(index, [f]);
//      //lst.add(f);
//    }
//    Float32List values = new Float32List(number_of_elements);
//    values.setAll(0, lst);
//    
//    this.idx += number_of_elements;
//    this.byte_reading_counter+= number_of_bytes;
//    
//    return values;
  }
  
//  // Read a float (4 bytes) from the stream
//  double _readFloat(int index) 
//  {
//   bf_wuba[0] = data.getUint8(index) & 0xff;
//   bf_wuba[1] = data.getUint8(index+1) & 0xff;
//   bf_wuba[2] = data.getUint8(index+2) & 0xff;
//   bf_wuba[3] = data.getUint8(index+3) & 0xff;
//   //this.byte_reading_counter += 4;
//   double f = bf_wfa[0];
//   return f; // typecast combining 4 bytes into a float
//  }
  
  Int32List getInt32Array (int offset, int number_of_elements) 
  {
    List<int> lst = new List<int>(number_of_elements);
    int i;
    for(int index = 0; index < number_of_elements; index++)
    {
      i = stream.readInt32();  
      lst.setAll(index, [i]);
    }
    Int32List values = new Int32List(number_of_elements);
    values.setAll(0, lst);
    return values;
//    this.idx += offset;
//    
//    int number_of_bytes = number_of_elements;
//    Int32List values = this.bytearray.asInt32List(this.byte_reading_counter + offset, number_of_bytes);
//    
//    this.idx += number_of_elements;
//    this.byte_reading_counter+= number_of_bytes;
//    
//    return values;
  }
  
  String getString (int offset, int length) 
  {
    return stream.readString(offset, length);
//    String result;
//    this.idx += offset;
//    
//    int number_of_bytes = length; //Uint8List.BYTES_PER_ELEMENT*length;
//    Uint8List characters = this.bytearray.asUint8List(this.byte_reading_counter + offset, number_of_bytes) ;
//
//    result = UTF8.decode(characters);
//
//    String lastchar = "\0";
//    
//    if( lastchar != null )
//    {
//      int idx = result.indexOf(lastchar);
//      if( idx >= 0)
//      {
//        result = result.substring(0, idx);
//      }
//    }
//      
//    result = result.replaceAll(new RegExp(r'\0+')  ,''); // /\0+$/
//    
//    this.idx += length;
//    this.byte_reading_counter+= number_of_bytes;
//    
//    return result;
  }
 
  
  
  /*
   MAGIC
   http://stackoverflow.com/questions/1240408/reading-bytes-from-a-javascript-string
   http://stackoverflow.com/questions/3195865/javascript-html-converting-byte-array-to-string
   http://stackoverflow.com/questions/6965107/converting-between-strings-and-arraybuffers
   */
  conv_byteArray_to_intArray (byte_array)
  {
    int len = byte_array.length;
    List int_array = new List(byte_array.length);
    
    for (int i = 0; i < len; i++)
    {
      int_array[i] = byte_array[i];
    }
    return int_array; // = int/ascii array
  }
  
  
  //getInteger3 (offset, number_of_elements) {
  //  number_of_elements *= 3;
  //  this.idx += offset;
  //  var values = new Int32Array (this.data, idx, number_of_elements);
  //
  //  var number_of_bytes = Int32Array.BYTES_PER_ELEMENT*number_of_elements;
  //  this.idx += number_of_bytes;
  //  this.byte_reading_counter+= number_of_bytes;
  //  return values; // returns Int32Array [a0, a1, a2, b0, b1, b2, ...]
  //}
  
  
  
  Byter forward (int offset)
  {
    stream.forward(offset);
    //this.byte_reading_counter += offset;
    return this;
  }
  
  Byter backward (int offset)
  {
    stream.backward(offset);
    //this.byte_reading_counter -= offset;
    return this;
  }
  
  int available ()
  {
    return stream.available();
    //return this.total_size -  this.byte_reading_counter;
  }
  
  int totalSize ()
  {
    return stream.totalSize();
    //return this.total_size;
  }
  
  
  int getPos ()
  {
    return stream.getPos();
    //return this.byte_reading_counter;
  }
  
  void setPos (int newpos)
  {
    stream.setPos(newpos);
    //this.byte_reading_counter = newpos;
  }
    //conversion
  //  public static final long convert_UInteger2Long(int v){
  //    return v & 0xffffffffL;
  //  }
  //
  //  public static final int convert_UShort2Integer(short v){
  //    return v & 0xffff;
  //  }
  
  
  
  
  static loadBinaryFile (String filename, callback(String filename, arrayBuffer))
  {
    
    HttpRequest.request(filename, responseType:'arraybuffer').then((HttpRequest request){
      var arrayBuffer = request.response; // Note: not oXHR.responseText
  //        console.log("___arrayBuffer        = "+arrayBuffer);
  //        console.log("___typeof arrayBuffer = "+(typeof arrayBuffer));
      if (arrayBuffer!= null) {
  //          console.log("___arrayBuffer.length = "+arrayBuffer.byteLength);
  //      loadMD3(filename, arrayBuffer);
        callback(filename, arrayBuffer);
      }
    });
  }


}


