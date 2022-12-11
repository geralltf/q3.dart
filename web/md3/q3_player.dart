part of tech3;

class Q3_Player
{
  Q3_DepNode n_head;
  Q3_DepNode n_upper;
  Q3_DepNode n_lower;
  Q3_DepNode node_system;
  Q3_Object lower;
  Q3_Object upper;
  Q3_Object head;
  rendering_context gl;
  String path;
  String team;
  Q3_TexturePool texturepool;
  Q3_Weapon weapon;
  var onload;
  bool AllLoaded = false;
  
  Q3_Player(rendering_context gl, String path, String team, Q3_TexturePool texturepool)
  {
    this.gl          = gl;
    this.path        = path;
    this.team        = team;
    this.texturepool = texturepool != null ? texturepool : new Q3_TexturePool(gl);

    this.head  = new Q3_Object(this.gl, this.path, "head.md3" ,  "head_" +this.team+".skin", this.texturepool );
    this.upper = new Q3_Object(this.gl, this.path, "upper.md3",  "upper_"+this.team+".skin", this.texturepool );
    this.lower = new Q3_Object(this.gl, this.path, "lower.md3",  "lower_"+this.team+".skin", this.texturepool );

    this.weapon = null;

    this.node_system = null;
    this.n_lower = null;
    this.n_upper = null;
    this.n_head  = null;

    this.onload = (){};

    this.head.onload  = ()
    {
      upper.load();
    };
    this.upper.onload = ()
    {
      lower.load();
    };
    this.lower.onload = ()
    {
      makeNodeSystem(); 
      AllLoaded = true;
      onload(); 
    };
  }

  void load()
  {
    this.head.load();
  }


  void setHead(Q3_Object md3)
  {
    this.head = md3;
    this. n_head.setObject(this.head);
  }
  void setUpper(Q3_Object md3)
  {
    this.upper = md3;
    this.n_upper.setObject(this.upper);
  }
  void setLower(Q3_Object md3)
  {
    this.lower = md3;
    this.n_lower.setObject(this.lower);
  }

  getHead()
  {
    return this.head;
  }
  getUpper()
  {
    return this.upper;
  }
  getLower()
  {
    return this.lower;
  }

  void setWeapon (Q3_Weapon weapon)
  {
    this.weapon = weapon;
    if( this.weapon != null && this.weapon.getNodeSystem() != null)
    {
      this.weapon.getNodeSystem().getTopLevelNode().setParentNode(this.n_upper, "tag_weapon");
    }
  }
  
  Q3_Weapon getWeapon()
  {
    return this.weapon;
  }

  void makeNodeSystem()
  {
    this.n_lower  = new Q3_DepNode(this.lower ); 
    this.n_upper  = new Q3_DepNode(this.upper ); 
    this.n_head   = new Q3_DepNode(this.head  ); 
  
    // RELATIONSHIPS
    this.n_lower.setParentNode(null,  null  );
    this.n_upper.setParentNode(this.n_lower,  "tag_torso"  );
    this.n_head .setParentNode(this.n_upper,  "tag_head"   );
  
    this.n_lower.setAsTopLevelNode();
    this.node_system = this.n_head.getTopLevelNode();
  }

  getNodeSystem()
  {
    return this.node_system;
  }
  getNodeHead()
  {
    return this.n_head;
  }
  getNodeUpper()
  {
    return this.n_upper;
  }
  getNodeLower()
  {
    return this.n_lower;
  }


  void drawModel (Q3_surface_shader_generic shader,int frame_IDX, Matrix4 mat4_modelview, Matrix4 mat4_modelworld )
  {
    if( this.node_system ==null)
      return;
    this.node_system.getTopLevelNode().mat4_transformation = mat4_modelworld;
    this.node_system.updateNodeSystem(frame_IDX);
    this.node_system.drawNodeSystem(shader, mat4_modelview, mat4_modelworld);
  }

  void delete()
  {
    if(this.head != null  ) this.head .delete();
    if(this.upper != null ) this.upper.delete();
    if(this.lower != null) this.lower.delete();
    this.head  = null;
    this.upper = null;
    this.lower = null;
    this.node_system = null;
    this.n_lower = null;
    this.n_upper = null;
    this.n_head  = null;
  }

  
}