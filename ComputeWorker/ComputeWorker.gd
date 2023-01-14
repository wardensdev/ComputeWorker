extends Node
class_name ComputeWorker
@icon("res://ComputeWorker/ComputeWorkerIcon.png")

## The GLSL shader file to execute
@export var shader_file: RDShaderFile = null
## The set of uniforms to bind to the compute pipeline. Must be GPU_* resources.
@export var uniforms: Array[GPUUniform] = []
## The ID of the uniform set used in this ComputeWorker's shader
@export var uniform_set_id: int = 0
## The size of the global work group to dispatch.
@export var work_group_size: Vector3i = Vector3i(1, 1, 1)

var rd: RenderingDevice = RenderingServer.create_local_rendering_device()

var uniform_set_rid: RID = RID()
var compute_pipeline: RID = RID()

var initialized = false


signal compute_begin
signal compute_end


## Call this to initialize and dispatch the compute list. 
## Initial uniform data can be set by getting the uniform using `get_uniform_by_binding()` or `get_uniform_by_alias()`,
## and setting the uniform data directly before calling this.
func initialize() -> void:
	
	# Load GLSL shader
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	
	# Generate uniform set from provided `GPU_*.tres` uniforms
	var uniform_set = []
	for i in range(uniforms.size()):
		
		var uniform = uniforms[i].initialize(rd)
		uniform_set.push_back(uniform)
	
	# Register uniform set with RenderingDevice
	uniform_set_rid = _create_uniform_set(uniform_set, shader, uniform_set_id)
	
	# Create the RenderingDevice compute pipeline
	compute_pipeline = _create_compute_pipeline(shader)
	
	# Bind uniform set and pipeline to compute list and dispatch
	dispatch_compute_list()
	
	initialized = true


## Fetch the data from a uniform by binding id
func get_uniform_data(binding: int) -> Variant:
	
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	
	var uniform = get_uniform_by_binding(binding)
	
	return uniform.get_uniform_data(rd)


## Fetch the data from a uniform by alias
func get_uniform_data_by_alias(alias: String) -> Variant:
	
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	
	var uniform = get_uniform_by_alias(alias)
	
	return uniform.get_uniform_data(rd)


## Set the data of a uniform by binding. If `dispatch` is true, the shader is executed and uniforms are updated immediately.
## `initialize()` must be called before setting uniform data with this function.
## To set uniform data before `initialized()` is called,
## get the GPU_* uniform object with `get_uniform_by_*()` and set the data directly.
func set_uniform_data(data: Variant, binding: int, dispatch: bool = true) -> void:
	
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	
	var uniform = get_uniform_by_binding(binding)
	
	uniform.set_uniform_data(rd, data)
	
	# Must dispatch new compute list with updated uniforms to take effect
	if dispatch:
		dispatch_compute_list()
		execute_compute_shader()


## Submit current compute list and wait for sync to update uniform values
func execute_compute_shader() -> void:
	
	emit_signal("compute_begin")
	rd.submit()
	
	rd.sync()
	emit_signal("compute_end")


## Internal. Register the generated uniform set with the RenderingDevice, returns uniform set RID
func _create_uniform_set(uniform_array: Array, shader: RID, set_id: int) -> RID:
	
	var uniforms_set = rd.uniform_set_create(uniform_array, shader, set_id)
	return uniforms_set


## Internal. Create the compute pipeline for the RenderingDevice, returns pipeline RID
func _create_compute_pipeline(shader: RID) -> RID:
	
	var pipeline := rd.compute_pipeline_create(shader)
	return pipeline


## Binds and dispatches the compute list using the current uniform set and pipeline
func dispatch_compute_list() -> void:
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, compute_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_rid, uniform_set_id)
	rd.compute_list_dispatch(compute_list, work_group_size.x, work_group_size.y, work_group_size.z)
	rd.compute_list_end()


## Get GPU_* uniform object by binding id
func get_uniform_by_binding(binding: int) -> GPUUniform:
	
	for uniform in uniforms:
		if uniform.binding == binding:
			return uniform
	return null


## Get the GPUUniform object by its user-defined `alias`
func get_uniform_by_alias(alias: String) -> GPUUniform:
	
	for uniform in uniforms:
		if uniform.alias == alias:
			return uniform
	return null


## Get the binding id of the GPU_* uniform by user-defined `alias`
func get_uniform_binding_by_alias(alias: String) -> int:
	
	for uniform in uniforms:
		if uniform.alias == alias:
			return uniform.binding
	return -1

