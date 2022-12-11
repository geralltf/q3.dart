part of tech3;

class MD3_TagFrame
{
  static bool logging =false;
  MD3_File md3_reader;
  int INDEX;
  int _start_pos;
  int _end_pos;
  List<MD3_Tag> tags;
  
  MD3_TagFrame(MD3_File md3_reader, int index)
  {
    this.md3_reader = md3_reader;
    this.INDEX = index;

    this._start_pos = md3_reader.byter.getPos();
    this._end_pos   = md3_reader.byter.getPos();

    if( MD3_TagFrame.logging )
      this.log();

    // load Tags
    this.tags = new List(this.md3_reader.header.S32_NUM_TAGS);
    
    for(int i = 0; i < this.tags.length; i++)
    {
      this.tags[i] = new MD3_Tag(this.md3_reader, this, i);
    }
  }

  log ()
  {
    print("---------------------------- MD3_TagFrame[${this.INDEX}] ----------------------------");
    print("    file: ${this.md3_reader.filename}");
    print("    _start_pos         = ${this._start_pos}"        );
    print("    _end_pos           = ${this._end_pos}"          );
    print("---------------------------/ MD3_TagFrame[${this.INDEX}] ----------------------------");
  }
}