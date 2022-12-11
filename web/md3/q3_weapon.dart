part of tech3;

class Q3_Weapon
{
  var n_barrel;
  var n_flash;
  var n_weapon;
  var n_hand;
  var node_system;
  var barrel;
  var flash;
  var weapon;
  var hand;
  var path;
  var name;
  var onload;
  Q3_TexturePool texturepool;
  rendering_context gl;
  
  Q3_Weapon(rendering_context gl, path, name, texturepool){
    this.gl   = gl;
    this.path = path;
    this.name = name; //name of the weapon
    this.texturepool = texturepool != null ? texturepool : new Q3_TexturePool(gl);

    this.weapon = new Q3_Object(this.gl, this.path, name+".md3",         name+".skin",        this.texturepool );
    this.hand   = new Q3_Object(this.gl, this.path, name+"_hand.md3",    name+"_hand.skin",   this.texturepool ); // just tags, not surfaces
    this.barrel = new Q3_Object(this.gl, this.path, name+"_barrel.md3",  name+"_barrel.skin", this.texturepool );
//  this.flash  = new Q3_Object(this.gl, this.path, name+"_flash.md3",   name+"_flash.skin",  this.texturepool );

    this.node_system = null;
    this.n_hand   = null;
    this.n_weapon = null;
    this.n_flash  = null;
    this.n_barrel = null;

//  this.makeNodeSystem();

    this.onload = (){};

    this.weapon.onload = (){ makeNodeSystem();hand.load();  onload();   };
    this.hand.onload   = (){ makeNodeSystem(); barrel.load();  onload(); };
    this.barrel.onload = (){ makeNodeSystem(); onload(); };
//  this.weapon.load();
  }


  load  ()
  {
    this.weapon.load();
  }


  makeNodeSystem  (){
    this.n_hand   = new Q3_DepNode(this.hand  ); this.n_hand   .setParentNode(null,  null );
    this.n_weapon = new Q3_DepNode(this.weapon); this.n_weapon .setParentNode(this.n_hand,   "tag_weapon" );
//  this.n_flash  = new Q3_DepNode(this.flash ); this.n_flash  .setParentNode(this.n_weapon, "tag_flash"  );
    this.n_barrel = new Q3_DepNode(this.barrel); this.n_barrel .setParentNode(this.n_weapon, "tag_barrel" );
    this.n_hand.setAsTopLevelNode();
    this.node_system = this.n_hand.getTopLevelNode();
  }



  Q3_DepNode getNodeSystem  (){
    return this.node_system;
  }
  getNodeHand  (){
    return this.n_hand;
  }
  getNodeWeapon  (){
    return this.n_weapon;
  }
  getNodeFlash  (){
    return this.n_flash;
  }
  getNodeBarrel  (){
    return this.n_barrel;
  }


  setHand ( md3){
    this.hand = md3;
    this.n_hand.setObject(this.hand);
  }
  setWeapon ( md3){
    this.weapon = md3;
    this.n_weapon.setObject(this.weapon);
  }
  setFlash ( md3){
    this.flash = md3;
    this.n_flash.setObject(this.flash);
  }
  setBarrel ( md3){
    this.barrel = md3;
    this.n_barrel.setObject(this.barrel);
  }


  getHand (){
    return this.hand;
  }
  getWeapon (){
    return this.weapon;
  }
  getFlash (){
    return this.flash;
  }
  getBarrel (){
    return this.barrel;
  }


  drawModel (  shader, frame_IDX, mat4_modelview, mat4_modelworld){
    this.node_system.updateNodeSystem(frame_IDX);
    this.node_system.drawChilds(shader, mat4_modelview, mat4_modelworld);
  }


  delete ( ){
    if( this.hand   ) this.hand  .delete();
    if( this.weapon ) this.weapon.delete();
    if( this.flash  ) this.flash .delete();
    if( this.barrel ) this.barrel.delete();
    this.hand   = null;
    this.weapon = null;
    this.flash  = null;
    this.barrel = null;

    this.node_system = null;
    this.n_hand   = null;
    this.n_weapon = null;
    this.n_flash  = null;
    this.n_barrel = null;
  }
}