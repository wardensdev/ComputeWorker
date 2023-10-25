@icon("res://ComputeWorker/GPUUniforms/GPUUniformIcon.png")

extends Resource
class_name GPUUniform


## Base class for uniforms used with ComputeWorker. 
## Contains functions used for serializing Godot data types to and from GLSL equivalents.

## User-defined name for the uniform. Used for accessing the GPUUniform object via ComputeWorker.
@export var alias: String = ""


## Set up uniform buffer and register with RenderingDevice. Returns the resulting RDUniform.
func initialize(_rd: RenderingDevice): pass
## Set uniform type (Uniform or Storage Buffer), register buffer RID and binding with RDUniform.
func create_uniform(): pass
## Determine size of buffer based on initial data provided, and register with RenderingDevice. Returns buffer RID.
func create_rid(_rd: RenderingDevice): pass
## Retrieves and decodes the data that is currently in the uniform/storage buffer.
func get_uniform_data(_rd: RenderingDevice): pass
## Encodes and sets the data in the uniform/storage buffer.
func set_uniform_data(_rd: RenderingDevice, _value): pass


func bool_to_byte_array(value: bool) -> PackedByteArray:
	var arr = PackedByteArray()
	if value:
		arr.encode_u32(0, 1)
		return arr
	else:
		arr.encode_u32(0, 0)
		return arr


func byte_array_to_bool(array: PackedByteArray) -> bool:
	var num = array.decode_u32(0)
	if num != 0:
		return true
	else:
		return false


## Convert Color to GLSL equivalent `dvec4`
func color_to_byte_array(color: Color) -> PackedByteArray:
	return PackedFloat64Array([color.r, color.g, color.b, color.a]).to_byte_array()


## Convert GLSL `dvec4` to Color
func byte_array_to_color(array: PackedByteArray) -> Color:
	var col = Color()
	col.r = array.decode_double(0)
	col.g = array.decode_double(8)
	col.b = array.decode_double(16)
	col.a = array.decode_double(24)
	return col


## Convert a float to GLSL equivalent `double` format without padding. For use inside structs
func float_to_byte_array_8(num: float) -> PackedByteArray:
	return PackedFloat64Array([num]).to_byte_array()


## Convert a float to GLSL equivalent `double` format
func float_to_byte_array(num: float) -> PackedByteArray:
	return PackedFloat64Array([num, 0.0]).to_byte_array()


## Convert GLSL `double, float` to float
func byte_array_to_float(array: PackedByteArray) -> float:
	return array.decode_double(0)


## Convert an int to GLSL equivalent `int` format
## Note the loss of precision here. GLSL integers are 32bit, while Godot's are 64bit
func int_to_byte_array(num: int) -> PackedByteArray:
	return PackedInt32Array([num, 0, 0, 0]).to_byte_array()


## Convert an int to GLSL equivalent `int` format without padding. For use inside structs
func int_to_byte_array_4(num: int) -> PackedByteArray:
	return PackedInt32Array([num]).to_byte_array()


## Convert GLSL `int` to int
func byte_array_to_int(array: PackedByteArray) -> int:
	return array.decode_s32(0)


func byte_array_to_uint(array: PackedByteArray) -> int:
	return array.decode_u32(0)


## Convert GLSL `vec3, ivec3` to Vector3
func byte_array_to_vec3(array: PackedByteArray) -> Vector3:
	
	var dup = array.duplicate()
	
	dup.to_float64_array()
	var vec = Vector3()
	vec.x = dup.decode_double(0)
	vec.y = dup.decode_double(8)
	vec.z = dup.decode_double(16)
	
	return vec


## Convert a Vector3 to GLSL equivalent `dvec3, dvec4` format
func vec3_to_byte_array(vector: Vector3) -> PackedByteArray:
	
	return PackedFloat64Array([vector.x, vector.y, vector.z, 0.0]).to_byte_array()


## Convert a Vector3i to GLSL equivalent `ivec3, ivec4` format
func vec3i_to_byte_array(vector: Vector3i) -> PackedByteArray:
	
	# We have to add a value for the "w" field for the vector,
	# because the alignment spec for GLSL vec3s requires 16bytes
	return PackedInt32Array([vector.x, vector.y, vector.z, 0]).to_byte_array()


## Convert an array of Vector3s to GLSL equivalent `vec3[], vec4[]` format
func vec3_array_to_byte_array(array: PackedVector3Array):
	
	var bytes: PackedByteArray = PackedByteArray()
	
	for vector in array:
		var vec: Vector4 = Vector4()
		
		vec.x = vector.x
		vec.y = vector.y
		vec.z = vector.z
		vec.w = 0.0
		
		# We have to add a value for the "w" field for the vector,
		# because the alignment spec for GLSL vec3s requires 16bytes 
		var float_arr = PackedFloat32Array([vector.x, vector.y, vector.z, 0.0]).to_byte_array()
		bytes.append_array(float_arr)
	
	return bytes


## Convert GLSL `vec3[]` to an Array of Vector3s
func byte_array_to_vec3_array(bytes: PackedByteArray) -> PackedVector3Array:
	
	var arr: PackedVector3Array = PackedVector3Array()
	
	for v in range(bytes.size() / 16.0):
		
		var vec = Vector3()
		
		vec.x = bytes.decode_float(0 + (v * 16))
		vec.y = bytes.decode_float(4 + (v * 16))
		vec.z = bytes.decode_float(8 + (v * 16))
		
		arr.append(vec)
	
	return arr


## Convert an array of Floats to GLSL equivalent `double[]`
func float_array_to_byte_array_64(array: Array[float]) -> PackedByteArray:
	var bytes = PackedFloat64Array(array).to_byte_array()
	return bytes
	

## Convert a GLSL `double[]` to an Array of Floats
func byte_array_64_to_float_array(array: PackedByteArray) -> Array[float]:
	return Array(array.to_float64_array())

