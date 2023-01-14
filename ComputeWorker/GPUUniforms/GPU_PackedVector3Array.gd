# GLSL data type encoding: `ivec3`

extends GPUUniform
class_name GPU_PackedVector3Array

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## The initial data supplied to the uniform
@export var data: Array[Vector3] = Array()
## The shader binding for this uniform
@export var binding: int = 0
## Type of uniform to create. `UNIFORM_BUFFER`s cannot be altered from within the shader
@export var uniform_type: UNIFORM_TYPES = UNIFORM_TYPES.UNIFORM_BUFFER

var data_rid: RID = RID()
var uniform: RDUniform = RDUniform.new()


func initialize(rd: RenderingDevice) -> RDUniform:
	
	# Create the buffer using our initial data
	data_rid = create_rid(rd)
	
	# Create RDUniform object using the provided binding id and data
	return create_uniform()


func create_uniform() -> RDUniform:
	
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		UNIFORM_TYPES.STORAGE_BUFFER:
			uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
			
	uniform.binding = binding
	uniform.add_id(data_rid)
	
	return uniform


func create_rid(rd: RenderingDevice) -> RID:
	
	var bytes = vec3_array_to_byte_array(data)
	print(bytes)
	var buffer: RID = RID()
	
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	
	return buffer


func get_uniform_data(rd: RenderingDevice) -> Array[Vector3]:
	var out := rd.buffer_get_data(data_rid)
	return byte_array_to_vec3_array(out)


func set_uniform_data(rd: RenderingDevice, array: Array[Vector3]) -> void:
	var sb_data = vec3_array_to_byte_array(array)
	rd.buffer_update(data_rid, 0 , sb_data.size(), sb_data)



