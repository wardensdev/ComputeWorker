# GLSL data type encoding: `struct`

extends GPUUniform
class_name GPU_Struct

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## The structure of the Struct defined inside the shader.
## Add data types to the array that correspond to the data types defined in the shader, in the same order.
@export var struct_data: Array = []
@export var binding: int = 0 
@export var uniform_type: UNIFORM_TYPES = UNIFORM_TYPES.STORAGE_BUFFER

var uniform: RDUniform = RDUniform.new()
var data_rid: RID = RID()

var bytes: PackedByteArray = PackedByteArray()
var byte_length: int = 0


func initialize(rd: RenderingDevice) -> RDUniform:
	
	bytes = encode_struct(struct_data, true)
	byte_length = bytes.size()
	
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


func get_uniform_data(rd: RenderingDevice):
	var out := rd.buffer_get_data(data_rid)
	return decode_struct(out)
	
	


func set_uniform_data(rd: RenderingDevice, data: Array) -> void:
	var sb_data = encode_struct(data)
	rd.buffer_update(data_rid, 0 , sb_data.size(), sb_data)


## Encode the contents of the passed in `data` Array to PackedByteArray. 
## Contents of `data` must match the order and data types defined in `struct_data`.
func encode_struct(data: Array, init: bool = false) -> PackedByteArray:
	
	var arr: PackedByteArray = PackedByteArray()
	var data_index = 0
	
	for type_obj in struct_data:
		
		match typeof(type_obj):
			TYPE_VECTOR3I:
				arr.append_array(vec3i_to_byte_array(data[data_index]))
			TYPE_COLOR:
				arr.append_array(color_to_byte_array(data[data_index]))
			TYPE_VECTOR3:
				arr.append_array(vec3_to_byte_array(data[data_index]))
			TYPE_FLOAT:
				arr.append_array(float_to_byte_array_8(data[data_index]))
			TYPE_INT:
				arr.append_array(int_to_byte_array_4(data[data_index]))
		
		data_index += 1
	
	if !init:
		if pad_byte_array(arr).size() != byte_length && uniform.uniform_type == RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER:
			printerr("Data for uniform: " + str(alias) + " does not match struct requirements. Needs: " + str(byte_length) + " was given: " + str(arr.size()))
	
	return pad_byte_array(arr)


## Per the alignment spec for SPIR-V structs, struct alignments must be rounded to a multiple of 16.
func pad_byte_array(arr: PackedByteArray):
	
	var copy = arr.duplicate()
	while copy.size() % 16 != 0:
		copy.append(0)
	return copy


## Decode the contents of the passed in PackedByteArray to an Array matching
## the order and data types defined in `struct_data`. 
func decode_struct(data: PackedByteArray) -> Array:
	
	var arr: Array = []
	
	var offset: int = 0
	
	for i in range(struct_data.size()):
		
		match typeof(struct_data[i]):
			TYPE_VECTOR3I:
				var vec = byte_array_to_vec3(data.slice(offset, offset + 32))
				arr.push_back(vec)
				offset += 32
			TYPE_COLOR:
				var col = byte_array_to_color(data.slice(offset, offset + 32))
				arr.push_back(col)
				offset += 32
			TYPE_VECTOR3:
				var vec = byte_array_to_vec3(data.slice(offset, offset + 32))
				arr.push_back(vec)
				offset += 32
			TYPE_FLOAT:
				var flo = byte_array_to_float(data.slice(offset, offset + 8))
				arr.push_back(flo)
				offset += 8
			TYPE_INT:
				var integer = byte_array_to_int(data.slice(offset, offset + 4))
				arr.push_back(integer)
				offset += 4
				
	return arr
