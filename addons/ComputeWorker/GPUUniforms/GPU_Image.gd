# GLSL data type encoding: `image2D`

extends GPUUniform
class_name GPU_Image

## The initial data supplied to the uniform
@export var data: Image = Image.new()
## The image dimensions to initialize the uniform with
@export var image_size: Vector2i = Vector2i(1,1)
## The shader binding for this uniform
@export var binding: int = 0
## RenderingDevice DATA_FORMAT enum values only
@export var image_format: int = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT


var data_rid: RID = RID()
var uniform: RDUniform = RDUniform.new()

var texture_type = RenderingDevice.TEXTURE_TYPE_2D
var uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE


func initialize(rd: RenderingDevice) -> RDUniform:
	
	# Generate the initial Image using the provided `image_size`
	data.create(image_size.x, image_size.y, false, Image.FORMAT_RGBAF)
	
	# Create the texture using our initial data
	data_rid = create_rid(rd)
	
	# Create RDUniform object using the provided binding id and data
	return create_uniform()


func create_rid(rd: RenderingDevice) -> RID:
	
	var texture_format = RDTextureFormat.new()
	
	texture_format.texture_type = texture_type
	texture_format.format = image_format
	
	texture_format.width = data.get_width()
	texture_format.height = data.get_height()
	
	texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	var image_data: PackedByteArray = data.get_data()
	
	var tex = rd.texture_create(texture_format, RDTextureView.new(), [image_data])
	
	return tex


func create_uniform() -> RDUniform:
	
	uniform.uniform_type = uniform_type
	uniform.binding = binding
	uniform.add_id(data_rid)
	
	return uniform
	
	
func get_uniform_data(rd: RenderingDevice) -> Image:
	
	var t_data = rd.texture_get_data(data_rid, 0)
	var image = Image.new()
	image.create_from_data(data.get_width(), data.get_height(), false, Image.FORMAT_RGBAF, t_data)
	
	return image


func set_uniform_data(rd: RenderingDevice, image: Image) -> void:
	
	var layer_data = image.get_data()
	rd.texture_update(data_rid, 0, layer_data)
	
