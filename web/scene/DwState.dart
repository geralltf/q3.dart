part of tech3;

class DwState
{
  static List<Matrix4> mat4_stack = new List<Matrix4>();
  static List<Matrix3> mat3_stack = new List<Matrix3>();
  
  static pushMat4 (Matrix4 src_mat4)
  {
    mat4_stack.add(src_mat4.clone());
  }

  static Matrix4 popMat4 ()
  {
    return mat4_stack.removeLast();
  }

  static pushMat3 (Matrix3 src_mat3)
  {
    mat3_stack.add(src_mat3.clone());
  }

  static Matrix3 popMat3 ()
  {
    return mat3_stack.removeLast();
  }
}