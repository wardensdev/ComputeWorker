extends Node3D

# This simple example demonstrates setting intial uniform data,
# and the setting and getting of uniform data, including Structs.

# The `time` variable is accumulated and updated each frame,
# and the shader returns `result`, a dvec4 in the form of a Color,
# which contains the `test_vector` in rg, `test_float` in b, and the `time` in the alpha channel.
# A randomized array of objects is also passed into the shader every frame

@export var test_vector: Vector3 = Vector3(0, 0, 0)
var test_shader_file = preload("res://ComputeWorker/Example/test_glsl.glsl")


func _ready():
	
	# Example of setting uniform data before calling `initialize()`
	var test_vector_uniform: GPU_Vector3 = $ComputeWorker.get_uniform_by_alias("test_vector")
	test_vector_uniform.data = test_vector
	
	$ComputeWorker.initialize()


func _process(delta):
	
	# An example of how to restart the ComputeWorker with a new shader.
	if Input.is_key_pressed(KEY_SPACE):
		
		$ComputeWorker.destroy()
		$ComputeWorker.shader_file = test_shader_file
		$ComputeWorker.initialize()
	
	if $ComputeWorker.initialized:
	
		# Here we add `delta` to the uniform's current data to get an accumulated time inside the shader.
		var gpu_time = $ComputeWorker.get_uniform_data_by_alias("time")
		$ComputeWorker.set_uniform_data_by_alias(gpu_time + delta, "time", 0, false)
		
		# Grab a list of (randomized for demo's sake) objects matching the struct's format, and pass it into the shader.
		var obj_arr = get_random_obj_array()
		$ComputeWorker.set_uniform_data_by_alias(obj_arr, "obj_arr", 0, false)
		
		# Assign a random value to `test_float` in set 1, and dispatch.
		var rand_float = randf() * 100
		$ComputeWorker.set_uniform_data_by_alias(rand_float, "test_float", 1)
		
		# Poll the result of the shader execution. (result == Color(test_vector.xy, test_float, time))
		var result = $ComputeWorker.get_uniform_data_by_alias("result")
		print(result)


# Generates a list of struct objects to pass into the shader.
# The array must be the same length as defined in the uniform.
func get_random_obj_array() -> Array[Array]:
	
	var uniform: GPU_StructArray = $ComputeWorker.get_uniform_by_alias("obj_arr")
	var structure = uniform.struct_data
	
	var obj_arr: Array[Array] = []
	
	for i in range(uniform.array_size):
		
		var struct = structure.duplicate()
		
		# Assign random values to the floats, just for some visible changes.
		for x in range(struct.size()):
			match typeof(struct[x]):
				TYPE_FLOAT:
					struct[x] += randf() * 100
			
		obj_arr.push_back(struct)
		
	return obj_arr
