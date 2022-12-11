part of tech3;

// double-precision floating point number constants from dartlang
const double INFINITY = 1.0 / 0.0;
const double NAN = 0.0 / 0.0;
const double NEGATIVE_INFINITY = -INFINITY;
const double MIN_POSITIVE = 5e-324;
const double MAX_FINITE = 1.7976931348623157e+308;
const double Pi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930382;
const double PiOver2 = PI / 2.0;
const double PiOver3 = PI / 3.0;
const double PiOver4 = PI / 4.0;
const double PiOver6 = PI / 4.0;
const double PiOver180 = PI / 180.0;
const double HalfPi = 0.5 * PI;
const double TwoPi = 2 * PI;
const double ThreePiOver2 = 3 * Pi / 2;
const double E = 2.71828182845904523536;
const double Log10E = 0.434294482;
const double Log2E = 1.442695041;

Vector3 UnitX = new Vector3(1.0, 0.0, 0.0); // Defines a unit-length Vector3 that points towards the X-axis.
Vector3 UnitY = new Vector3(0.0, 1.0, 0.0); // Defines a unit-length Vector3 that points towards the Y-axis
Vector3 UnitZ = new Vector3(0.0, 0.0, 1.0); // Defines a unit-length Vector3 that points towards the Z-axis.
Vector3 Zero = new Vector3(0.0, 0.0, 0.0); // Defines a zero-length Vector3.
Vector3 One = new Vector3(1.0, 1.0, 1.0); // Defines a vector with a magnitude of Ones

Vector4 V4UnitX = new Vector4(1.0, 0.0, 0.0, 0.0); // Defines a unit-length Vector4 that points towards the X-axis.
Vector4 V4UnitY = new Vector4(0.0, 1.0, 0.0, 0.0); // Defines a unit-length Vector4 that points towards the Y-axis.
Vector4 V4UnitZ = new Vector4(0.0, 0.0, 1.0, 0.0); // Defines a unit-length Vector4 that points towards the Z-axis.
Vector4 V4UnitW = new Vector4(0.0, 0.0, 0.0, 1.0); // Defines a unit-length Vector4 that points towards the W-axis.

List<double> vec3(Vector3 v)
{
  return [v.x, v.y, v.z];
}
Vector3 vector3(List<double> v)
{
  return new Vector3(v[0],v[1],v[2]);  
}

class MathHelper // like Microsoft.Xna.Framework
{ 
  static double Clamp(double value, double min, double max)
  {
      return value > max ? max : (value < min ? min : value);
  }
  static double ClampCircular(double n, double min, double max)
  {
    if (n >= max) n -= max;
    if (n < min) n += max;
    return n;
  }
}

Matrix4 ctor_mat4(Vector4 row0, 
                  Vector4 row1, 
                  Vector4 row2, 
                  Vector4 row3)
{
  Matrix4 m = new Matrix4.zero();
  m.setRow(0, row0);
  m.setRow(1, row1);
  m.setRow(2, row2);
  m.setRow(3, row3);
  return m;
}

Vector3 multiplyVec3(Vector3 a, 
                     double d)
{
  a.x *= d;
  a.y *= d;
  a.z *= d;
  return a;
}

Vector3 quaternionVec3(Quaternion quat)
{
  Vector3 v;
  
  v = new Vector3(quat.x,quat.y,quat.z );
  
  //v = quat.axis; // return xyz vector
  
  return v;
}
/// <summary>
/// Transforms a vector by a quaternion rotation.
/// </summary>
/// <param name="vec">The vector to transform.</param>
/// <param name="quat">The quaternion to rotate the vector by.</param>
/// <returns>The result of the operation.</returns>
Vector3 transformVec3(Vector3 vec, Quaternion quat)
{
  Vector3 result;
  Vector3 xyz = quaternionVec3(quat), temp; // //Vector3 xyz = quat.Xyz, temp, temp2;
    
   // Since vec.W == 0, we can optimize quat * vec * quat^-1 as follows:
   // vec + 2.0 * cross(quat.xyz, cross(quat.xyz, vec) + quat.w * vec)
    
  result = xyz.cross(vec); //Vector3.Cross(ref xyz, ref vec, out temp);
  temp = multiplyVec3(vec, quat.w); //Vector3.Multiply(ref vec, quat.W, out temp2);
  result = result + temp; //Vector3.Add(ref temp, ref temp2, out temp);
  result = xyz.cross(result); //Vector3.Cross(ref xyz, ref temp, out temp);
  result = multiplyVec3(result, 2.0); //Vector3.Multiply(ref temp, 2, out temp);
   
  return result;
}

vec3ToStr (a, prec) 
{
  prec = prec != null ? prec : 5;
  return "["+a[0].toStringAsFixed(prec)+", "+a[1].toStringAsFixed(prec)+", "+a[2].toStringAsFixed(prec)+"]";
}

Matrix4 mat4Transpose_new (Matrix4 m4) 
{
  return m4.clone();
  
//  return 
//  [   m4[0], m4[4], m4[8], m4[12],    
//      m4[1], m4[5], m4[9], m4[13],    
//      m4[2], m4[6], m4[10], m4[14], 
//      m4[3], m4[7], m4[11], m4[15]    ];
}

mat4Transpose3to4_new (Matrix3 m3) 
{
  Matrix4 m4 = new Matrix4.zero();
  m4.setColumn(0, new Vector4(m3[0], m3[3], m3[6], 0.0));
  m4.setColumn(0, new Vector4(m3[1], m3[4], m3[7], 0.0));
  m4.setColumn(0, new Vector4(m3[2], m3[5], m3[8], 0.0));
  m4.setColumn(0, new Vector4(  0.0,   0.0,   0.0, 1.0));
  return m4;
}

mat4Mult_ref (Matrix4 m4_A, Matrix4 m4_B, dst_m4) 
{
  var
    a00 = m4_A[ 0], a10 = m4_A[ 4], a20 = m4_A[ 8], a30 = m4_A[12],
    a01 = m4_A[ 1], a11 = m4_A[ 5], a21 = m4_A[ 9], a31 = m4_A[13],
    a02 = m4_A[ 2], a12 = m4_A[ 6], a22 = m4_A[10], a32 = m4_A[14],
    a03 = m4_A[ 3], a13 = m4_A[ 7], a23 = m4_A[11], a33 = m4_A[15];
  var
    b00 = m4_B[ 0], b10 = m4_B[ 4], b20 = m4_B[ 8], b30 = m4_B[12],
    b01 = m4_B[ 1], b11 = m4_B[ 5], b21 = m4_B[ 9], b31 = m4_B[13],
    b02 = m4_B[ 2], b12 = m4_B[ 6], b22 = m4_B[10], b32 = m4_B[14],
    b03 = m4_B[ 3], b13 = m4_B[ 7], b23 = m4_B[11], b33 = m4_B[15];

  dst_m4[ 0] = b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30;
  dst_m4[ 1] = b00 * a01 + b01 * a11 + b02 * a21 + b03 * a31;
  dst_m4[ 2] = b00 * a02 + b01 * a12 + b02 * a22 + b03 * a32;
  dst_m4[ 3] = b00 * a03 + b01 * a13 + b02 * a23 + b03 * a33;
  dst_m4[ 4] = b10 * a00 + b11 * a10 + b12 * a20 + b13 * a30;
  dst_m4[ 5] = b10 * a01 + b11 * a11 + b12 * a21 + b13 * a31;
  dst_m4[ 6] = b10 * a02 + b11 * a12 + b12 * a22 + b13 * a32;
  dst_m4[ 7] = b10 * a03 + b11 * a13 + b12 * a23 + b13 * a33;
  dst_m4[ 8] = b20 * a00 + b21 * a10 + b22 * a20 + b23 * a30;
  dst_m4[ 9] = b20 * a01 + b21 * a11 + b22 * a21 + b23 * a31;
  dst_m4[10] = b20 * a02 + b21 * a12 + b22 * a22 + b23 * a32;
  dst_m4[11] = b20 * a03 + b21 * a13 + b22 * a23 + b23 * a33;
  dst_m4[12] = b30 * a00 + b31 * a10 + b32 * a20 + b33 * a30;
  dst_m4[13] = b30 * a01 + b31 * a11 + b32 * a21 + b33 * a31;
  dst_m4[14] = b30 * a02 + b31 * a12 + b32 * a22 + b33 * a32;
  dst_m4[15] = b30 * a03 + b31 * a13 + b32 * a23 + b33 * a33;
}

mat4Copy_ref (m4, dst) {
  dst[0] = m4[0]; dst[4] = m4[4]; dst[ 8] = m4[ 8]; dst[12] = m4[12];
  dst[1] = m4[1]; dst[5] = m4[5]; dst[ 9] = m4[ 9]; dst[13] = m4[13];
  dst[2] = m4[2]; dst[6] = m4[6]; dst[10] = m4[10]; dst[14] = m4[14];
  dst[3] = m4[3]; dst[7] = m4[7]; dst[11] = m4[11]; dst[15] = m4[15];
}
mat4Copy_new (m4) {
  return [m4[0], m4[1], m4[2], m4[3], m4[4], m4[5], m4[6], m4[7], m4[8], 
    m4[9], m4[10], m4[11], m4[12], m4[13], m4[14], m4[15]];
}

mat4Mult_new (m4_A, m4_B) {
  var dst = new List(16);
  var
    a00 = m4_A[ 0], a10 = m4_A[ 4], a20 = m4_A[ 8], a30 = m4_A[12],
    a01 = m4_A[ 1], a11 = m4_A[ 5], a21 = m4_A[ 9], a31 = m4_A[13],
    a02 = m4_A[ 2], a12 = m4_A[ 6], a22 = m4_A[10], a32 = m4_A[14],
    a03 = m4_A[ 3], a13 = m4_A[ 7], a23 = m4_A[11], a33 = m4_A[15];
  var
    b00 = m4_B[ 0], b10 = m4_B[ 4], b20 = m4_B[ 8], b30 = m4_B[12],
    b01 = m4_B[ 1], b11 = m4_B[ 5], b21 = m4_B[ 9], b31 = m4_B[13],
    b02 = m4_B[ 2], b12 = m4_B[ 6], b22 = m4_B[10], b32 = m4_B[14],
    b03 = m4_B[ 3], b13 = m4_B[ 7], b23 = m4_B[11], b33 = m4_B[15];

  dst[ 0] = b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30;
  dst[ 1] = b00 * a01 + b01 * a11 + b02 * a21 + b03 * a31;
  dst[ 2] = b00 * a02 + b01 * a12 + b02 * a22 + b03 * a32;
  dst[ 3] = b00 * a03 + b01 * a13 + b02 * a23 + b03 * a33;
  dst[ 4] = b10 * a00 + b11 * a10 + b12 * a20 + b13 * a30;
  dst[ 5] = b10 * a01 + b11 * a11 + b12 * a21 + b13 * a31;
  dst[ 6] = b10 * a02 + b11 * a12 + b12 * a22 + b13 * a32;
  dst[ 7] = b10 * a03 + b11 * a13 + b12 * a23 + b13 * a33;
  dst[ 8] = b20 * a00 + b21 * a10 + b22 * a20 + b23 * a30;
  dst[ 9] = b20 * a01 + b21 * a11 + b22 * a21 + b23 * a31;
  dst[10] = b20 * a02 + b21 * a12 + b22 * a22 + b23 * a32;
  dst[11] = b20 * a03 + b21 * a13 + b22 * a23 + b23 * a33;
  dst[12] = b30 * a00 + b31 * a10 + b32 * a20 + b33 * a30;
  dst[13] = b30 * a01 + b31 * a11 + b32 * a21 + b33 * a31;
  dst[14] = b30 * a02 + b31 * a12 + b32 * a22 + b33 * a32;
  dst[15] = b30 * a03 + b31 * a13 + b32 * a23 + b33 * a33;
  return dst;
}

mat4ToMat3inverseTranspose_ref (m4, dst_m3) {
  var
    a00 = m4[0], a10 = m4[4], a20 = m4[8],
    a01 = m4[1], a11 = m4[5], a21 = m4[9],
    a02 = m4[2], a12 = m4[6], a22 = m4[10];
  var
    b01 =  a22 * a11 - a12 * a21,
    b11 = -a22 * a10 + a12 * a20,
    b21 =  a21 * a10 - a11 * a20;

  var det = a00 * b01 + a01 * b11 + a02 * b21;

  if (det==null)
    return null;

  var det_inv = 1 / det;

  dst_m3[0] = det_inv *  ( b01);
  dst_m3[3] = det_inv *  (-a22 * a01 + a02 * a21);
  dst_m3[6] = det_inv *  ( a12 * a01 - a02 * a11);

  dst_m3[1] = det_inv *  ( b11);
  dst_m3[4] = det_inv *  ( a22 * a00 - a02 * a20);
  dst_m3[7] = det_inv *  (-a12 * a00 + a02 * a10);

  dst_m3[2] = det_inv *  ( b21) ;
  dst_m3[5] = det_inv *  (-a21 * a00 + a01 * a20);
  dst_m3[8] = det_inv *  ( a11 * a00 - a01 * a10);
}

matrix4ToMat3(Matrix4 m)
{
  return m.getRotation();
//  var dst = new List(16);
//  dst[ 0] = m.row0;
//  dst[ 1] = m[1];
//  dst[ 2] = m[2];
//  dst[ 3] = m[3];
//  dst[ 4] = m[4];
//  dst[ 5] = m[5];
//  dst[ 6] = m[6];
//  dst[ 7] = m[7];
//  dst[ 8] = m[8];
//  dst[ 9] = m[9];
//  dst[10] = m[10];
//  dst[11] = m[11];
//  dst[12] = m[12];
//  dst[13] = m[13];
//  dst[14] = m[14];
//  dst[15] = m[15];
//  return dst;
}


Matrix3 mat4ToMat3inverseTranspose_new (Matrix4 mat4) {
  Matrix3 mat3 = new Matrix3.zero();
  
  Float32List m4 = mat4.storage;
  
  double
    a00 = m4[0], a10 = m4[4], a20 = m4[8],
    a01 = m4[1], a11 = m4[5], a21 = m4[9],
    a02 = m4[2], a12 = m4[6], a22 = m4[10];
  double
    b01 =  a22 * a11 - a12 * a21,
    b11 = -a22 * a10 + a12 * a20,
    b21 =  a21 * a10 - a11 * a20;

  double det = a00 * b01 + a01 * b11 + a02 * b21;

  if (det==null)
  {
    return null;
  }

  double det_inv = 1 / det;

  mat3.storage[0] = det_inv *  ( b01);
  mat3.storage[3] = det_inv *  (-a22 * a01 + a02 * a21);
  mat3.storage[6] = det_inv *  ( a12 * a01 - a02 * a11);

  mat3.storage[1] = det_inv *  ( b11);
  mat3.storage[4] = det_inv *  ( a22 * a00 - a02 * a20);
  mat3.storage[7] = det_inv *  (-a12 * a00 + a02 * a10);

  mat3.storage[2] = det_inv *  ( b21) ;
  mat3.storage[5] = det_inv *  (-a21 * a00 + a01 * a20);
  mat3.storage[8] = det_inv *  ( a11 * a00 - a01 * a10);
 
  return mat3;
}


mat4setAxisXYZ_ref (Matrix4 m4, v3_x, v3_y, v3_z) 
{  
  m4[0] = v3_x[0];  m4[4] = v3_y[0];  m4[ 8] = v3_z[0];
  m4[1] = v3_x[1];  m4[5] = v3_y[1];  m4[ 9] = v3_z[1];
  m4[2] = v3_x[2];  m4[6] = v3_y[2];  m4[10] = v3_z[2];
}

mat4SetTranslation (Matrix4 m4, v3_t) 
{
  m4[12] = v3_t[0];
  m4[13] = v3_t[1];
  m4[14] = v3_t[2];
}
Matrix4 mat4Inverse_new (Matrix4 m4) {
  return mat4Inverse_ref(m4);
  //var dst = new List(16);
  //return mat4Inverse_ref(m4,dst);
  //return dst;
}
Matrix4 mat4Inverse_ref (Matrix4 m4)
{
  Matrix4 dst = new Matrix4.identity();
  double
    a00 = m4[ 0], a10 = m4[ 4], a20 = m4[ 8], a30 = m4[12],
    a01 = m4[ 1], a11 = m4[ 5], a21 = m4[ 9], a31 = m4[13],
    a02 = m4[ 2], a12 = m4[ 6], a22 = m4[10], a32 = m4[14],
    a03 = m4[ 3], a13 = m4[ 7], a23 = m4[11], a33 = m4[15];

  double
    b00 = a00 * a11 - a01 * a10,
    b01 = a00 * a12 - a02 * a10,
    b02 = a00 * a13 - a03 * a10,
    b03 = a01 * a12 - a02 * a11,
    b04 = a01 * a13 - a03 * a11,
    b05 = a02 * a13 - a03 * a12,
    b06 = a20 * a31 - a21 * a30,
    b07 = a20 * a32 - a22 * a30,
    b08 = a20 * a33 - a23 * a30,
    b09 = a21 * a32 - a22 * a31,
    b10 = a21 * a33 - a23 * a31,
    b11 = a22 * a33 - a23 * a32;

  double det = (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06);

  if (det == 0)
    return null;
  double det_inv = 1 / det;

  dst[ 0] = det_inv * ( a11 * b11 - a12 * b10 + a13 * b09);
  dst[ 1] = det_inv * (-a01 * b11 + a02 * b10 - a03 * b09);
  dst[ 2] = det_inv * ( a31 * b05 - a32 * b04 + a33 * b03);
  dst[ 3] = det_inv * (-a21 * b05 + a22 * b04 - a23 * b03);
  dst[ 4] = det_inv * (-a10 * b11 + a12 * b08 - a13 * b07);
  dst[ 5] = det_inv * ( a00 * b11 - a02 * b08 + a03 * b07);
  dst[ 6] = det_inv * (-a30 * b05 + a32 * b02 - a33 * b01);
  dst[ 7] = det_inv * ( a20 * b05 - a22 * b02 + a23 * b01);
  dst[ 8] = det_inv * ( a10 * b10 - a11 * b08 + a13 * b06);
  dst[ 9] = det_inv * (-a00 * b10 + a01 * b08 - a03 * b06);
  dst[10] = det_inv * ( a30 * b04 - a31 * b02 + a33 * b00);
  dst[11] = det_inv * (-a20 * b04 + a21 * b02 - a23 * b00);
  dst[12] = det_inv * (-a10 * b09 + a11 * b07 - a12 * b06);
  dst[13] = det_inv * ( a00 * b09 - a01 * b07 + a02 * b06);
  dst[14] = det_inv * (-a30 * b03 + a31 * b01 - a32 * b00);
  dst[15] = det_inv * ( a20 * b03 - a21 * b01 + a22 * b00);
  return dst;
}


// from: https://github.com/toji/gl-matrix/blob/master/dist/gl-matrix.js
/**
   * Computes the cross product of two vec3's
   *
   * @param {vec3} out the receiving vector
   * @param {vec3} a the first operand
   * @param {vec3} b the second operand
   * @returns {vec3} out
   */
List<double> vec3_cross(List<double> a, List<double> b) 
{
  List<double> out=[0.0,0.0,0.0];
  var ax = a[0], ay = a[1], az = a[2],
      bx = b[0], by = b[1], bz = b[2];

  out[0] = ay * bz - az * by;
  out[1] = az * bx - ax * bz;
  out[2] = ax * by - ay * bx;
  return out;
}

/**
   * Normalize a vec3
   *
   * @param {vec3} out the receiving vector
   * @param {vec3} a vector to normalize
   * @returns {vec3} out
   */
List<double> vec3_normalize(List<double> a) 
{
    List<double> out=[0.0,0.0,0.0];
    double x = a[0], y = a[1], z = a[2];
    double len = x*x + y*y + z*z;
    if (len > 0) 
    {
        //TODO: evaluate use of glm_invsqrt here?
        len = 1.0 / sqrt(len);
        out[0] = a[0] * len;
        out[1] = a[1] * len;
        out[2] = a[2] * len;
    }
    return out;
}

/**
   * Subtracts vector b from vector a
   *
   * @param {vec3} out the receiving vector
   * @param {vec3} a the first operand
   * @param {vec3} b the second operand
   * @returns {vec3} out
   */
List<double> vec3_subtract (List<double> a, List<double> b) {
    List<double> out=[0.0,0.0,0.0];
    out[0] = a[0] - b[0];
    out[1] = a[1] - b[1];
    out[2] = a[2] - b[2];
    return out;
}
  
/**
   * Calculates the length of a vec3
   *
   * @param {vec3} a vector to calculate length of
   * @returns {Number} length of a
   */
double vec3_length(List<double> a) {
    var x = a[0],
        y = a[1],
        z = a[2];
    return sqrt(x*x + y*y + z*z);
}

/**
   * Set the components of a vec3 to the given values
   *
   * @param {vec3} out the receiving vector
   * @param {Number} x X component
   * @param {Number} y Y component
   * @param {Number} z Z component
   * @returns {vec3} out
   */
List<double> vec3_set(List<double> v) {
    List<double> out=[0.0,0.0,0.0];
    out[0] = v[0]; //x
    out[1] = v[1]; //y
    out[2] = v[2]; //z
    return out;
}

Vector3 clone(Vector3 v)
{
  return vector3(vec3_set(vec3(v)));
  //return new Vector3(v.x, v.y, v.z);
}
  
/**
   * Scales a vec3 by a scalar number
   *
   * @param {vec3} out the receiving vector
   * @param {vec3} a the vector to scale
   * @param {Number} b amount to scale the vector by
   * @returns {vec3} out
   */
List<double> vec3_scale (List<double> a, double b) 
{
    var out=[0.0,0.0,0.0];
    out[0] = a[0] * b;
    out[1] = a[1] * b;
    out[2] = a[2] * b;
    return out;
}

/**
   * Calculates the dot product of two vec3's
   *
   * @param {vec3} a the first operand
   * @param {vec3} b the second operand
   * @returns {Number} dot product of a and b
   */
double vec3_dot (List<double> a, List<double> b) 
{
  return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}
  
/**
   * Adds two vec3's
   *
   * @param {vec3} out the receiving vector
   * @param {vec3} a the first operand
   * @param {vec3} b the second operand
   * @returns {vec3} out
   */
List<double> vec3_add (List<double> a, List<double> b) 
{
  List<double> out=[0.0,0.0,0.0];
    out[0] = a[0] + b[0];
    out[1] = a[1] + b[1];
    out[2] = a[2] + b[2];
    return out;
}

double clamp(double value, double min, double max) 
{
  return (value < min ? min : (value > max ? max : value));
}

enum VrPositionCoordinateOrder
{
  XYZ,
  YXZ,
  ZXY,
  ZYX,
  YZX,
  XZY
}
eulerFromQuaternion(q, VrPositionCoordinateOrder order) 
{
  var out = [0.0,0.0,0.0];
  // Borrowed from Three.JS :)
  // q is assumed to be normalized
  // http://www.mathworks.com/matlabcentral/fileexchange/20696-function-to-convert-between-dcm-euler-angles-quaternions-and-euler-vectors/content/SpinCalc.m
  var sqx = q.x * q.x;
  var sqy = q.y * q.y;
  var sqz = q.z * q.z;
  var sqw = q.w * q.w;

  if ( order == VrPositionCoordinateOrder.XYZ ) 
  {
    out[0] = atan2( 2 * ( q.x * q.w - q.y * q.z ), ( sqw - sqx - sqy + sqz ) );
    out[1] = asin(  clamp( 2 * ( q.x * q.z + q.y * q.w ), -1.0, 1.0 ) );
    out[2] = atan2( 2 * ( q.z * q.w - q.x * q.y ), ( sqw + sqx - sqy - sqz ) );
  } 
  else if ( order ==  VrPositionCoordinateOrder.YXZ ) 
  {
    out[0] = asin(  clamp( 2 * ( q.x * q.w - q.y * q.z ), -1.0, 1.0 ) );
    out[1] = atan2( 2 * ( q.x * q.z + q.y * q.w ), ( sqw - sqx - sqy + sqz ) );
    out[2] = atan2( 2 * ( q.x * q.y + q.z * q.w ), ( sqw - sqx + sqy - sqz ) );
  } 
  else if ( order == VrPositionCoordinateOrder.ZXY ) 
  {
    out[0] = asin(  clamp( 2 * ( q.x * q.w + q.y * q.z ), -1.0, 1.0 ) );
    out[1] = atan2( 2 * ( q.y * q.w - q.z * q.x ), ( sqw - sqx - sqy + sqz ) );
    out[2] = atan2( 2 * ( q.z * q.w - q.x * q.y ), ( sqw - sqx + sqy - sqz ) );
  } 
  else if ( order == VrPositionCoordinateOrder.ZYX ) 
  {
    out[0] = atan2( 2 * ( q.x * q.w + q.z * q.y ), ( sqw - sqx - sqy + sqz ) );
    out[1] = asin(  clamp( 2 * ( q.y * q.w - q.x * q.z ), -1.0, 1.0 ) );
    out[2] = atan2( 2 * ( q.x * q.y + q.z * q.w ), ( sqw + sqx - sqy - sqz ) );
  } 
  else if ( order == VrPositionCoordinateOrder.YZX ) 
  {
    out[0] = atan2( 2 * ( q.x * q.w - q.z * q.y ), ( sqw - sqx + sqy - sqz ) );
    out[1] = atan2( 2 * ( q.y * q.w - q.x * q.z ), ( sqw + sqx - sqy - sqz ) );
    out[2] = asin(  clamp( 2 * ( q.x * q.y + q.z * q.w ), -1.0, 1.0 ) );
  } 
  else if ( order == VrPositionCoordinateOrder.XZY ) 
  {
    out[0] = atan2( 2 * ( q.x * q.w + q.y * q.z ), ( sqw - sqx + sqy - sqz ) );
    out[1] = atan2( 2 * ( q.x * q.z + q.y * q.w ), ( sqw + sqx - sqy - sqz ) );
    out[2] = asin(  clamp( 2 * ( q.z * q.w - q.x * q.y ), -1.0, 1.0 ) );
  } 
  else 
  {
    print('No order given for quaternion to euler conversion.');
  }
  return out;
}

Matrix4 mat4PerspectiveFromVRFieldOfView(fov, double zNear, double zFar) 
{
  Matrix4 out = new Matrix4.zero();
  
  var upTan, downTan, leftTan, rightTan;
  if (fov == null) {
    // If no FOV is given plug in some dummy values
    upTan = tan(50 * PI/180.0);
    downTan = tan(50 * PI/180.0);
    leftTan = tan(45 * PI/180.0);
    rightTan = tan(45 * PI/180.0);
  } else {
    upTan = tan(fov['upDegrees'] * PI/180.0);
    downTan = tan(fov['downDegrees'] * PI/180.0);
    leftTan = tan(fov['leftDegrees'] * PI/180.0);
    rightTan = tan(fov['rightDegrees'] * PI/180.0);
  }

  double xScale = 2.0 / (leftTan + rightTan);
  double yScale = 2.0 / (upTan + downTan);

  out[0] = xScale;
  out[4] = 0.0;
  out[8] = -((leftTan - rightTan) * xScale * 0.5);
  out[12] = 0.0;

  out[1] = 0.0;
  out[5] = yScale;
  out[9] = ((upTan - downTan) * yScale * 0.5);
  out[13] = 0.0;

  out[2] = 0.0;
  out[6] = 0.0;
  out[10] = zFar / (zNear - zFar);
  out[14] = (zFar * zNear) / (zNear - zFar);

  out[3] = 0.0;
  out[7] = 0.0;
  out[11] = -1.0;
  out[15] = 0.0;
  
  return out;
}

/**
 * Generates a look-at matrix with the given eye position, focal point, and up axis
 *
 * @param {vec3} eye Position of the viewer
 * @param {vec3} center Point the viewer is looking at
 * @param {vec3} up vec3 pointing "up"
 * @param {mat4} [dest] mat4 frustum matrix will be written into
 *
 * Returns result if specified, a new mat4 otherwise
 */
Matrix4 LookAt(Vector3 eye, Vector3 center, Vector3 up, [Matrix4 result]) {
    if(result == null) result = new Matrix4.zero();

    double x0, x1, x2, y0, y1, y2, z0, z1, z2, len;

    if (eye.x == center.x && eye.y == center.y && eye.z == center.z) 
    {
      result = new Matrix4.identity();
      return result;
    }

    //static Vector3 direction(eye, center, z);
    z0 = eye.x - center.x;
    z1 = eye.y - center.y;
    z2 = eye.z - center.z;

    // normalize (no check needed for 0 because of early return)
    len = 1.0 / sqrt(z0 * z0 + z1 * z1 + z2 * z2);
    z0 *= len;
    z1 *= len;
    z2 *= len;

    //static Vector3 normalize(static Vector3 cross(up, z, x));
    x0 = up.y * z2 - up.z * z1;
    x1 = up.z * z0 - up.x * z2;
    x2 = up.x * z1 - up.y * z0;
    len = sqrt(x0 * x0 + x1 * x1 + x2 * x2);
    if (len.isNaN) 
    {
        x0 = 0.0;
        x1 = 0.0;
        x2 = 0.0;
    } 
    else 
    {
        len = 1 / len;
        x0 *= len;
        x1 *= len;
        x2 *= len;
    }

    //static Vector3 normalize(static Vector3 cross(z, x, y));
    y0 = z1 * x2 - z2 * x1;
    y1 = z2 * x0 - z0 * x2;
    y2 = z0 * x1 - z1 * x0;

    len = sqrt(y0 * y0 + y1 * y1 + y2 * y2);
    
    if (len.isNaN) 
    {
        y0 = 0.0;
        y1 = 0.0;
        y2 = 0.0;
    } 
    else 
    {
        len = 1.0 / len;
        y0 *= len;
        y1 *= len;
        y2 *= len;
    }

    result.storage[0] = x0;
    result.storage[1] = y0;
    result.storage[2] = z0;
    result.storage[3] = 0.0;
    result.storage[4] = x1;
    result.storage[5] = y1;
    result.storage[6] = z1;
    result.storage[7] = 0.0;
    result.storage[8] = x2;
    result.storage[9] = y2;
    result.storage[10] = z2;
    result.storage[11] = 0.0;
    result.storage[12] = -(x0 * eye.x + x1 * eye.y + x2 * eye.z);
    result.storage[13] = -(y0 * eye.x + y1 * eye.y + y2 * eye.z);
    result.storage[14] = -(z0 * eye.x + z1 * eye.y + z2 * eye.z);
    result.storage[15] = 1.0;

    return result;
}

Quaternion getQuaternionXYZW(double orientationX, double orientationY, double orientationZ, double orientationW)
{
  return new Quaternion(orientationX,orientationY,orientationZ,orientationW);
}

Matrix4 mat4FromQuat(Quaternion q)
{
  Matrix4 out = new Matrix4.zero();
  
  var x = q[0], y = q[1], z = q[2], w = q[3],
      x2 = x + x,
      y2 = y + y,
      z2 = z + z,

      xx = x * x2,
      yx = y * x2,
      yy = y * y2,
      zx = z * x2,
      zy = z * y2,
      zz = z * z2,
      wx = w * x2,
      wy = w * y2,
      wz = w * z2;

  out[0] = 1 - yy - zz;
  out[1] = yx + wz;
  out[2] = zx - wy;
  out[3] = 0.0;

  out[4] = yx - wz;
  out[5] = 1 - xx - zz;
  out[6] = zy + wx;
  out[7] = 0.0;

  out[8] = zx + wy;
  out[9] = zy - wx;
  out[10] = 1 - xx - yy;
  out[11] = 0.0;

  out[12] = 0.0;
  out[13] = 0.0;
  out[14] = 0.0;
  out[15] = 1.0;

  return out;
}

/*
 * mat4.translate
 * Translates a matrix by the given vector
 *
 * Params:
 * mat - mat4 to translate
 * vec - vec3 specifying the translation
 * dest - Optional, mat4 receiving operation result. If not specified result is written to mat
 *
 * Returns:
 * dest if specified, mat otherwise
 */
Matrix4 mat4_translate(Matrix4 mat, List<double> vec) 
{
    var x = vec[0], y = vec[1], z = vec[2];
    
    if(mat == null) 
    {
        mat[12] = mat[0]*x + mat[4]*y + mat[8]*z + mat[12];
        mat[13] = mat[1]*x + mat[5]*y + mat[9]*z + mat[13];
        mat[14] = mat[2]*x + mat[6]*y + mat[10]*z + mat[14];
        mat[15] = mat[3]*x + mat[7]*y + mat[11]*z + mat[15];
        return mat;
    }
    
    double a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3];
    double a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7];
    double a20 = mat[8], a21 = mat[9], a22 = mat[10], a23 = mat[11];
    
    mat[0] = a00;
    mat[1] = a01;
    mat[2] = a02;
    mat[3] = a03;
    mat[4] = a10;
    mat[5] = a11;
    mat[6] = a12;
    mat[7] = a13;
    mat[8] = a20;
    mat[9] = a21;
    mat[10] = a22;
    mat[11] = a23;
    
    mat[12] = a00*x + a10*y + a20*z + mat[12];
    mat[13] = a01*x + a11*y + a21*z + mat[13];
    mat[14] = a02*x + a12*y + a22*z + mat[14];
    mat[15] = a03*x + a13*y + a23*z + mat[15];
    
    return mat;
}
Matrix4 mat4_inverse(Matrix4 mat)
{
  //mat.invert();
  
  // Cache the matrix values (makes for huge speed increases!)
  double a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3];
  double a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7];
  double a20 = mat[8], a21 = mat[9], a22 = mat[10], a23 = mat[11];
  double a30 = mat[12], a31 = mat[13], a32 = mat[14], a33 = mat[15];
  
  double b00 = a00*a11 - a01*a10;
  double b01 = a00*a12 - a02*a10;
  double b02 = a00*a13 - a03*a10;
  double b03 = a01*a12 - a02*a11;
  double b04 = a01*a13 - a03*a11;
  double b05 = a02*a13 - a03*a12;
  double b06 = a20*a31 - a21*a30;
  double b07 = a20*a32 - a22*a30;
  double b08 = a20*a33 - a23*a30;
  double b09 = a21*a32 - a22*a31;
  double b10 = a21*a33 - a23*a31;
  double b11 = a22*a33 - a23*a32;
  
  // Calculate the determinant (inlined to avoid double-caching)
  double invDet = 1/(b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);
  
  mat[0] = (a11*b11 - a12*b10 + a13*b09)*invDet;
  mat[1] = (-a01*b11 + a02*b10 - a03*b09)*invDet;
  mat[2] = (a31*b05 - a32*b04 + a33*b03)*invDet;
  mat[3] = (-a21*b05 + a22*b04 - a23*b03)*invDet;
  mat[4] = (-a10*b11 + a12*b08 - a13*b07)*invDet;
  mat[5] = (a00*b11 - a02*b08 + a03*b07)*invDet;
  mat[6] = (-a30*b05 + a32*b02 - a33*b01)*invDet;
  mat[7] = (a20*b05 - a22*b02 + a23*b01)*invDet;
  mat[8] = (a10*b10 - a11*b08 + a13*b06)*invDet;
  mat[9] = (-a00*b10 + a01*b08 - a03*b06)*invDet;
  mat[10] = (a30*b04 - a31*b02 + a33*b00)*invDet;
  mat[11] = (-a20*b04 + a21*b02 - a23*b00)*invDet;
  mat[12] = (-a10*b09 + a11*b07 - a12*b06)*invDet;
  mat[13] = (a00*b09 - a01*b07 + a02*b06)*invDet;
  mat[14] = (-a30*b03 + a31*b01 - a32*b00)*invDet;
  mat[15] = (a20*b03 - a21*b01 + a22*b00)*invDet;
  
  return mat;
}

Matrix4 mat4MultiplyVec3(Matrix4 mat, List<double> vec)
{
  //mat4.multiplyVec3(cameraMat, dir);
  // from https://code.google.com/p/glmatrix/source/browse/glMatrix.js/
  
  Matrix4 dest = new Matrix4.zero();
    
  var x = vec[0], y = vec[1], z = vec[2];
  
  dest[0] = mat[0]*x + mat[4]*y + mat[8]*z + mat[12];
  dest[1] = mat[1]*x + mat[5]*y + mat[9]*z + mat[13];
  dest[2] = mat[2]*x + mat[6]*y + mat[10]*z + mat[14];
  
  return dest;
}

Matrix4 mat4Set (Matrix4 mat, Matrix4 dest) 
{
  dest[0] = mat[0];
  dest[1] = mat[1];
  dest[2] = mat[2];
  dest[3] = mat[3];
  dest[4] = mat[4];
  dest[5] = mat[5];
  dest[6] = mat[6];
  dest[7] = mat[7];
  dest[8] = mat[8];
  dest[9] = mat[9];
  dest[10] = mat[10];
  dest[11] = mat[11];
  dest[12] = mat[12];
  dest[13] = mat[13];
  dest[14] = mat[14];
  dest[15] = mat[15];
  return dest;
}
