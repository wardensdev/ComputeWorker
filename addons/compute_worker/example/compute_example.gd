extends Node3D

# This simple example demonstrates setting intial uniform data,
# and the setting and getting of uniform data, including Structs.

@export var test_vector: Vector3 = Vector3(0, 0, 0)
var test_shader_file = preload("res://addons/compute_worker/example/test_glsl.glsl")


func _ready():
	
	# Example of setting uniform data before calling `initialize()`
	var test_vector_uniform: GPU_Vector3 = $ComputeWorker.get_uniform_by_alias("test_vector")
	test_vector_uniform.data = test_vector
	
	
	# The float array is defined as a uniform buffer in our shader,
	# and thus can't be dynamically sized. So it's good practice to
	# use the `array_size` value from the Uniform object that was set in the editor.
	var float_arr: PackedFloat64Array = PackedFloat64Array()
	var float_arr_uniform: GPU_PackedFloat64Array = $ComputeWorker.get_uniform_by_alias("fl_arr", 1)
	
	float_arr.resize(float_arr_uniform.array_size)
	float_arr_uniform.data = float_arr
	
	
	# The vector array is defined as a storage buffer,
	# and thus is dynamically sized (because it's last in the storage block).
	# We can pass in whatever size array we want here.
	var vec_arr: PackedVector3Array = PackedVector3Array()
	vec_arr.resize(200)
	
	var vec_arr_uniform: GPU_PackedVector3Array = $ComputeWorker.get_uniform_by_alias("vec_arr", 1)
	vec_arr_uniform.data = vec_arr
	
	
	$ComputeWorker.initialize()


func _process(delta):
	
	var dispatch = false
	
	# An example of how to restart the ComputeWorker with a new shader.
	if Input.is_key_pressed(KEY_SPACE):
		
		$ComputeWorker.destroy()
		$ComputeWorker.shader_file = test_shader_file
		$ComputeWorker.initialize()
	
	
	if $ComputeWorker.initialized:
	
		# Here we add `delta` to the time uniform's current data to get an accumulated time inside the shader.
		var gpu_time: float = $ComputeWorker.get_uniform_data_by_alias("time")
		$ComputeWorker.set_uniform_data_by_alias(gpu_time + delta, "time", 0, dispatch)
		
		
		# Grab a list of struct objects matching the struct's format, and pass it into the shader.
		var obj_arr: Array[Array] = get_obj_array()
		$ComputeWorker.set_uniform_data_by_alias(obj_arr, "obj_arr", 0, dispatch)
		
		
		# Note that we didn't dispatch the shader until this point. This is for multiple reasons:
		#     1. We don't want to wait for the shader to execute multiple times in a single frame.
		#     2. We want to make sure the shader has all the data necessary for computation before executing.
		dispatch = true
		
		# Assign a random value to `test_float` in set 1, and dispatch.
		var rand_float: float = randf() * 100
		$ComputeWorker.set_uniform_data_by_alias(rand_float, "test_float", 1, dispatch)
		
		# Poll the result of the shader execution. (result == Color(test_vector.xy, test_float, time))
		var result: Color = $ComputeWorker.get_uniform_data_by_alias("result")
		print(result)


# Generates a list of struct objects to pass into the shader.
# The array must be the same length as defined in the uniform.
func get_obj_array() -> Array[Array]:
	
	# Here we get the StructArray uniform and grab its `struct_data`
	# to use as a template for our array elements.
	var uniform: GPU_StructArray = $ComputeWorker.get_uniform_by_alias("obj_arr")
	var structure: Array = uniform.struct_data
	
	var obj_arr: Array[Array] = []
	
	for i in range(uniform.array_size):
		
		var struct: Array = structure.duplicate()
		obj_arr.push_back(struct)
		
	return obj_arr
