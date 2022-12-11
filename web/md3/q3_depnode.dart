part of tech3;

class Q3_DepNode
{
  Matrix4 mat4_transformation;
  Q3_Object q3_object;
  List<Q3_DepNode> child_nodes;
  Q3_DepNode parent_node;
  String tag_name;
  int tag_IDX_current;
  int tag_IDX_parent;
  int frame_IDX_cur;
  Q3_DepNode child;
  
  Q3_DepNode(Q3_Object q3_object)
  {
    // child/parent list
    this.parent_node = null;
    this.child_nodes = [];
  
    // wrapped md3-objecz
    this.q3_object = q3_object;
  
    //transformation matrix
    this.mat4_transformation = new Matrix4.identity(); //DwMat4.identity_new();
  
    // tag-connection to parent
    this.tag_name = ""; //name of the tag, that builds the connection to its parent
    this.tag_IDX_current = -1;
    this.tag_IDX_parent  = -1;
  
    // current frame, the transformation is based on
    this.frame_IDX_cur   = -1;
  }
  
  //----------------------------------------------------------------------------
  // SET/GET OBJECT
  //----------------------------------------------------------------------------
  setObject (Q3_Object q3_object_new)
  {
    var tmp_tag_names_new = q3_object_new.getNamesOfTags();
    var tmp_tag_names_cur = this.q3_object.getNamesOfTags();
    
    // TODO only check linked tags
    // check if the current childs tagnames are available within the new object
    //var match_count = 0;
    for(var i = 0; i < tmp_tag_names_cur.length; i++){
      var match = false;
      for(var j = 0; j < tmp_tag_names_new.length; j++){
        if( tmp_tag_names_new[i] == tmp_tag_names_cur[i]){
          match = true;
          break;
        }
      }
      if( !match ){
        return false;
      }
    }
    //ok, all tags exists in both objects
    this.q3_object = q3_object_new;
    
    //update this tag_IDX_current
    if( this.parent_node != null)
      this.tag_IDX_current = this.q3_object.getTagByName(this.tag_name, 0).INDEX;
    
    // update childs tag_IDX_parent
    for( var i = 0; i < this.child_nodes.length; i++){
      this.child_nodes[i].tag_IDX_parent =  this.q3_object.getTagByName(child.tag_name, 0).INDEX;
    }
    
    return true;
  }
  
  
  Q3_Object getObject()
  {
    return this.q3_object;
  }
  
  
  //----------------------------------------------------------------------------
  // MAKE/BREAK CONNECTIONS
  //----------------------------------------------------------------------------
  void clearParentConnection ()
  {
    if( this.parent_node != null)
    {
      int idx = this.parent_node.child_nodes.indexOf(this);
      
      this.parent_node.child_nodes = splice(this.parent_node.child_nodes, idx, 1);
      //this.parent_node.child_nodes.splice(idx, 1);
    }
    
    this.parent_node     = null;
    this.tag_name        = "";
    this.tag_IDX_current = -1;
    this.tag_IDX_parent  = -1;
  }
  
  void makeParentConnection (Q3_DepNode new_parent_node, String tag_name, int tag_idx_cur,  int tag_idx_par)
  {
    this.parent_node     = new_parent_node;
    this.tag_name        = tag_name;
    this.tag_IDX_current = tag_idx_cur;
    this.tag_IDX_parent  = tag_idx_par;
    this.parent_node.child_nodes.add(this);
  }
  
  bool setParentNode (Q3_DepNode new_parent_node, String tag_name)
  {
    // nape parent node is null
    if( new_parent_node == null){
      this.clearParentConnection();
      return true;
    }
    // tagname is null
    if( tag_name == null ){
      return false;
    }

    if( new_parent_node == this ){ //STUPID, but DAU's welcome  ;)
      return false;
    }

    // everything stays the same
    if( this.parent_node == new_parent_node && tag_name ==this.tag_name){
      return true;
    }

    // check if objetcs in each node are valid
    if( this.q3_object == null || new_parent_node.q3_object == null){
      return false;
    }
    // check if tag_name exists in in this and parent
    var tag_current = this.q3_object.getTagByName(tag_name, 0);
    var tag_parent  = new_parent_node.q3_object.getTagByName(tag_name, 0);
    
    if( tag_current == null ||  tag_parent == null) {
      return false;
    }

    // ready for new connection:
    // delete old connection
    this.clearParentConnection();
    // make new connection
    this.makeParentConnection(new_parent_node, tag_name, tag_current.INDEX, tag_parent.INDEX);
    return true;
  }
  
  Q3_DepNode setAsTopLevelNode ()
  {
    if( this.parent_node != null ){
      this.parent_node.setToChildOf(this, this);
      this.setParentNode(null, null);
    }
    return this;
  }

  Q3_DepNode getTopLevelNode ()
  {
    Q3_DepNode top_level_node = this;
    while( top_level_node.parent_node != null ){
      top_level_node = top_level_node.parent_node;
      if( top_level_node == this ) // !!!! circular nodesystem
        return this;                // so "this" is returned as the toplevelnode
    }
    return top_level_node;
  }
  
  void setToChildOf (Q3_DepNode new_parent_node, Q3_DepNode new_top_level_node )
  {
    if( this.parent_node != null && this !=  new_top_level_node){
      this.parent_node.setToChildOf(this, new_top_level_node);
    }
    this.setParentNode(new_parent_node, new_parent_node.tag_name);
  }
  
  bool isInSameNodeSystemAs (Q3_DepNode node_2_find)
  {
    return this.getTopLevelNode().isParentOf(node_2_find);
  }

  bool isParentOf (Q3_DepNode node_2_find){
    if( this == node_2_find )
      return true;

//  for( NodeState node : child_nodes){
    for( var i = 0; i < this.child_nodes.length; i++){
      if ( this.child_nodes[i].isParentOf(node_2_find) )
        return true;
    }
    return false;
  }

  bool isChildOf (Q3_DepNode node_2_find){
    var current = this;

    while( current.parent_node != null ){
      current = current.parent_node;
      if( current == this ) // !!!! circular nodesystem
        return false;       // so node_2_find cant be in list
      if( current == node_2_find )
        return true;
    }
    return false;
  }

  Q3_DepNode getParentNode ()
  {
    return this.parent_node;
  }
  
  List<Q3_DepNode> getChilds ()
  {
    return this.child_nodes;
  }
  
  //----------------------------------------------------------------------------
  // PRINT TREE
  //----------------------------------------------------------------------------
  void printNodeSystem ()
  {
    this.getTopLevelNode().printChilds("  ");
  }
  
  void printChilds ( hierachy_indent)
  {
    var tag  = this.tag_name == "" ? null: this.tag_name;
    var name = this.q3_object.md3_filename;
    var path = this.q3_object.MD3_FILE.total_file_path;
    //  var path = "../"+f.getParentFile().getName() +"/"+f.getName();
    
    print(hierachy_indent+"."+name+" ("+tag+")  -  "+path);
    
    hierachy_indent += "    ";
    for( var i = 0; i < this.child_nodes.length; i++){
      this.child_nodes[i].printChilds(hierachy_indent);
    }
  }

  //----------------------------------------------------------------------------
  // FRAME_IDX
  //----------------------------------------------------------------------------
  void setNodeSystemFrameIDX (int frame_IDX)
  {
    this.getTopLevelNode().setChildsFrameIDX(frame_IDX);
  }
  void setChildsFrameIDX (int frame_IDX)
  {
    this.setFrameIDX(frame_IDX);
    
    for( var i = 0; i < this.child_nodes.length; i++)
    {
      this.child_nodes[i].setChildsFrameIDX(frame_IDX);
    }
  }
  
  void setFrameIDX (int frame_IDX)
  {
    this.frame_IDX_cur = this.q3_object.setCurrentFrameIDX(frame_IDX);
  }
  
  int getFrameIDX ()
  {
    return this.frame_IDX_cur;
  }
  
  //----------------------------------------------------------------------------
  // UPDATE - TRANSFORMATION
  //----------------------------------------------------------------------------
  
  Q3_DepNode updateNodeSystem (int frame_IDX)
  {
    return this.getTopLevelNode().updateChilds(frame_IDX);
  }
  
  Q3_DepNode updateChilds (int frame_IDX)
  {
    this.updateTransformation(frame_IDX);
    for( var i = 0; i < this.child_nodes.length; i++){
      this.child_nodes[i].updateChilds(frame_IDX);
    }
    return this;
  }
  
  Matrix4 updateTransformation (int frame_IDX)
  {
    //  if( frame_IDX >= 0 )
      this.setFrameIDX(frame_IDX);
    
    if ( this.parent_node == null )
      return this.mat4_transformation;
    
    var tag_matrix_parent  = this.parent_node.getLocalTagMatrix(  this.tag_IDX_parent );
    var tag_matrix_current = this.getLocalTagMatrixInverted    (  this.tag_IDX_current);
    
    Matrix4 mat4_par = this.parent_node.mat4_transformation;
    Matrix4 mat4_cur = this.mat4_transformation;
    //  console.log(this.tag_IDX_parent);
    
    //  var tag_mat4_parent      = tag_parent  ? tag_parent.matrix     : DwMat4.identity_new() ;
    //  var tag_mat4_current_inv = tag_current ? tag_current.matrix_inv: DwMat4.identity_new() ;
    
    mat4Copy_ref(mat4_par, mat4_cur);
    mat4_cur = mat4_cur.multiply(tag_matrix_parent); //mat4Mult_ref(mat4_cur, tag_matrix_parent, mat4_cur);
    mat4_cur = mat4_cur.multiply(tag_matrix_current); // mat4Mult_ref(mat4_cur, tag_matrix_current, mat4_cur);
    
    //TODO check
    
    //  transformation.set(parent_node.transformation);
    //  transformation.apply(tag_matrix_parent);
    //  transformation.apply(tag_matrix_current);
    return null;
  }
  
  
  Matrix4 getLocalTagMatrix ( tag_idx )
  {
    List<MD3_Tag> tags = this.q3_object.MD3_FILE.tag_frames[this.frame_IDX_cur].tags;
    MD3_Tag tag = tags[tag_idx]; 
    return tag.getMatrix();
  }
  
  Matrix4 getLocalTagMatrixInverted ( tag_idx )
  {
    List<MD3_Tag> tags = this.q3_object.MD3_FILE.tag_frames[this.frame_IDX_cur].tags;
    MD3_Tag tag = tags[tag_idx]; 
    return tag.getMatrixInv();
  }
  
  void setTransformation (Matrix4 mat4_transformation)
  {
    mat4Copy_ref(mat4_transformation, this.mat4_transformation);
  }
  
  Matrix4 getTransformation()
  {
    return this.mat4_transformation;
  }
  
  //----------------------------------------------------------------------------
  // DRAW NODES
  //----------------------------------------------------------------------------
  void drawNodeSystem (Q3_surface_shader_generic shader, Matrix4 mat4_modelview, Matrix4 mat4_modelworld)
  {
    this.getTopLevelNode().drawChilds(shader, mat4_modelview, mat4_modelworld);
  }
  
  void drawChilds (Q3_surface_shader_generic shader, Matrix4 mat4_modelview, Matrix4 mat4_modelworld)
  {
    this.draw(shader, mat4_modelview, mat4_modelworld);
    
    for( var i = 0; i < this.child_nodes.length; i++)
    {
      this.child_nodes[i].drawChilds(shader, mat4_modelview, mat4_modelworld);
    }
  }
  
  void draw (Q3_surface_shader_generic shader, Matrix4 mat4_modelview, Matrix4 mat4_modelworld)
  {
    this.drawShaded(shader, mat4_modelview, mat4_modelworld);
  }
  
  void drawShaded (Q3_surface_shader_generic shader, Matrix4 mat4_modelview, Matrix4 mat4_modelworld)
  {
    //  var mat4_modelworld_tmp = DwMat4.mult_new( mat4_modelworld, this.mat4_transformation);
    Matrix4 mat4_modelworld_tmp = this.mat4_transformation;
    Matrix4 mat4_modelworldview = mat4_modelview * mat4_modelworld_tmp;
    //Matrix4 mat4_modelworldview = mat4Mult_new( mat4_modelview, mat4_modelworld_tmp);
    //Matrix3 mat3_normals = mat4_modelworldview.getRotation();
    Matrix3 mat3_normals = mat4ToMat3inverseTranspose_new(mat4_modelworldview);
    
    shader.setMat3_Normals   (mat3_normals);
    shader.setMat4_ModelView (mat4_modelview);
    shader.setMat4_ModelWorld(mat4_modelworld_tmp);
    
    this.q3_object.draw(shader, this.frame_IDX_cur);
  }
}

/*
 * Array/list splice helper function
 ***/
List splice(List list, int index, [num howMany=0, dynamic elements])
{
  int endIndex = index + howMany.truncate();
  
  list.removeRange(index, endIndex >= list.length ? list.length : endIndex);
  
  if (elements != null)
    list.insertAll(index, elements is List ? elements : [elements]);
  
  return list;
}
