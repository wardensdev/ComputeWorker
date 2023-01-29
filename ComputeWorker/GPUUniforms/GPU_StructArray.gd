# GLSL data type encoding: `struct[]`

extends GPU_Struct
class_name GPU_StructArray

## The size of the Struct array defined in the shader.
@export var array_size: int = 1


func initialize(rd: RenderingDevice) -> RDUniform:
	
	var arr: PackedByteArray = PackedByteArray()
	
	for i in range(array_size):
		var by = encode_struct(struct_data.duplicate())
		arr.append_array(by)
	
	bytes = arr
	
	@warning_ignore("integer_division")
	byte_length = arr.size() / array_size
	
	data_rid = create_rid(rd)
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
	
	var buffer: RID = RID()
	
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	
	return buffer


func get_uniform_data(rd: RenderingDevice) -> Array[Array]:
	
	var out := rd.buffer_get_data(data_rid)
	
	var arr: Array = []
	
	@warning_ignore("integer_division")
	var num_arr_elements = out.size() / byte_length
	
	for i in range(num_arr_elements):
		
		var i_bytes = out.slice(i * byte_length, (i * byte_length) + byte_length)
		var st = decode_struct(i_bytes)
		arr.push_back(st)
	
	return arr


func set_uniform_data(rd: RenderingDevice, data: Array[Array]) -> void:
	
	var i_bytes: PackedByteArray = PackedByteArray()
	
	for i in range(data.size()):
		var by = encode_struct(data[i], true)
		i_bytes.append_array(by)
	
	rd.buffer_update(data_rid, 0 , i_bytes.size(), i_bytes)
