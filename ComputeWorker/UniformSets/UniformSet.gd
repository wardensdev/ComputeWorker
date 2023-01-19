@icon("res://ComputeWorker/UniformSets/UniformSetIcon.png")

extends Resource
class_name UniformSet

## The list of GPUUniforms to be bound to the shader
@export var uniforms: Array[GPUUniform] = []
## The set id as defined in the shader
@export var set_id: int = 0

var uniform_set_rid: RID = RID()


func initialize(rd: RenderingDevice, shader: RID) -> void:
	
	var uniform_set = []
	
	for i in range(uniforms.size()):
		
		var uniform = uniforms[i].initialize(rd)
		uniform_set.push_back(uniform)
	
	uniform_set_rid = rd.uniform_set_create(uniform_set, shader, set_id)


func destroy(rd: RenderingDevice) -> void:
	
	# Must free the uniform set before the uniforms themselves, else the uniform_set RID will become invalid.
	# Not sure if it's because it is freed when it becomes invalid, but we clean it up anyway.
	rd.free_rid(uniform_set_rid)
	
	for uniform in uniforms:
		
		rd.free_rid(uniform.data_rid)
		uniform.uniform.clear_ids()
	
	
