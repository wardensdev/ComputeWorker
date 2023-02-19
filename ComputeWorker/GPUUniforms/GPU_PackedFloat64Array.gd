# GLSL data type encoding: `double[]`

extends GPUUniform
class_name GPU_PackedFloat64Array

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## The initial data supplied to the uniform
@export var data: PackedFloat64Array
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
	
	var bytes = data.to_byte_array()
	
	var buffer: RID = RID()
	
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	
	return buffer


func get_uniform_data(rd: RenderingDevice) -> PackedFloat64Array:
	var out := rd.buffer_get_data(data_rid)
	return out.to_float64_array()


func set_uniform_data(rd: RenderingDevice, array: PackedFloat64Array) -> void:
	var sb_data = array.to_byte_array()
	rd.buffer_update(data_rid, 0 , sb_data.size(), sb_data)
