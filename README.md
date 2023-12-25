# ComputeWorker
 A Godot plug-in that wraps the RenderingDevice compute API. Provides a custom ComputeWorker class and node that simplifies setup and execution of the compute pipeline, and handles encoding of Godot data types into GLSL data buffers.
 
 ## The ComputeWorker Node
 A ComputeWorker can be added to a scene through the `Create New Node` dialog, or instanced from the `ComputeWorker.tscn` file.
 It can also be instanced in scripts with `ComputeWorker.new()`.
 
 **Note**: The maximum amount of ComputeWorkers allowed in your project will vary depending on the device the project is running on. This is because each ComputeWorker creates its own local RenderingDevice, which takes a portion of the gpu's resources for itself. If too many are created at the same time, it *will* cause a crash.

### Setup

#### Shader
First, drag your `.glsl` shader file into the `shader_file` field in the Inspector.

![image](https://user-images.githubusercontent.com/69459114/213370862-bfdca080-8004-417e-8f26-5a012645203b.png)

#### UniformSets

The second property of the ComputeWorker is `uniform_sets`. This is where you'll define what uniforms you want to be able to access/write to in the shader. UniformSet resources hold an array of GPUUniform resources and a `set_id` that corresponds to the uniform sets in your shader. 

First add a new element to the `uniform_sets` array, and create a new `UniformSet` in the empty element.

![image](https://user-images.githubusercontent.com/69459114/213363116-5e750fb1-755d-4622-88ff-d2f07b2111d2.png)

Inside the UniformSet, add a GPU_* resource to the `uniforms` array for each uniform in your shader. See **GPUUniforms** below for a list of GPU_* resources and their respective GLSL data types.

![image](https://user-images.githubusercontent.com/69459114/213362774-9234722b-66f1-4ae9-a9e0-fa50a0cb962c.png)

When you inspect the GPUUniforms that you added, there are some properties that need to be set. 
- `Data`, which is the initial data that the shader will be supplied with. (Can be set from script, see ComputeExample.gd)
- `Binding`, which should be set to correspond with the binding of the uniform in the shader.
- `Uniform Type`, which is whether the variable in the shader is defined as a Uniform or Storage Buffer.
- `Alias`, which is a user-defined identifier that can be used to access your uniforms in a more readable manner.

![image](https://user-images.githubusercontent.com/69459114/213363420-5c8c1e2d-c9a3-4817-8179-a3e70db1414f.png)


Finally, set the UniformSet's `set_id` to correspond with the set in your shader.

#### Work Group Size
After your UniformSets are set up, set the ComputeWorker's `Work Group Size`. This is the *global* work group size that the shader will be dispatched with.

#### Use Global Device
Setting this boolean to `true` will make the ComputeWorker use the project's *global* RenderingDevice (as returned by `RenderingServer.get_rendering_device()`).
The global RenderingDevice executes once per frame, so this is a good option if want your shader's execution to be synchronized with the engine's. **Only one ComputeWorker can have this enabled at a time**.

### Use
Before the ComputeWorker can be used, its `initialize()` function must be called. This is the function that sets up the compute pipeline. If you need to set the initial data that the shader will receive through code, you can get the GPUUniform object with the `get_uniform_by_*()` functions and set their `data` variable directly.

Once `initialize()` has been called, you can use `get_uniform_data(binding: int, set: int)` or `get_uniform_data_by_alias(alias: String, set: int)` to retrieve the resulting data from the shader. 

Use `set_uniform_data(data, binding, set, dispatch)` or `set_uniform_data_by_alias(data, alias, set, dispatch)` to set the value of the uniform in the shader. If `dispatch` is true, the shader will execute immediately after setting the uniform data.

Calling `destroy()` will stop execution and free the ComputeWorker's RenderingDevice (and all the resources created by it). This can be used to swap out the worker's shader and uniforms. After `destroy()` has been called, `initialize()` must be called again to resume execution and enable the use of the `get_uniform_data` and `set_uniform_data` functions. The `initialized` variable can be used to check if those functions can be called.

If you want more control over the dispatching and executing of your shader, you can call `dispatch_compute_list()` and `execute_compute_shader()` manually to run it. If you make changes to the data in your uniforms, you must call `dispatch_compute_list()` before calling `execute_compute_shader()`, or the shader won't receive the updated data.


## GPUUniforms

GPUUniforms are custom resources that encapsulate the setting/getting of uniform data through the RenderingDevice API, and the encoding of data from Godot variants to/from GLSL data types.

Below is a list of the GPU_* types and their corresponding GLSL data types:

- GPU_Boolean: `bool`
- GPU_Color: `dvec4`
- GPU_Float: `double`, `float`
- GPU_Image: `image2D`
- GPU_Integer: `int`, `uint`
- GPU_PackedByteArray: Can be used for custom encoding
- GPU_PackedFloat64Array: `double[]`
- GPU_PackedVector3Array: `vec3[]`, `vec4[]`
- GPU_Struct: `struct` (see below)
- GPU_StructArray: `struct[]` (see below)
- GPU_Texture2DArray: `image2DArray`
- GPU_Vector3: `dvec3`, `dvec4`
- GPU_Vector3i: `ivec3`, `ivec4`, `uvec3`, `uvec4`

### Structs
Structs have an extra setup step compared to the other basic types. `GPU_Struct` has a property called `struct_data`. This property is the initial data that the struct will take in, and its structure must match the structure of the `struct` in your shader.

So if your GLSL shader struct looks like this:
```
struct Object{
  dvec4 position;
  dvec4 velocity;
  double mass;
  double radius;
  double effector;
};
```
The `struct_data` array could look like this:

![image](https://user-images.githubusercontent.com/69459114/212461849-0b48b3f7-7e6e-4652-a2be-1b5a43e42c0f.png)

The same concept applies to `GPU_StructArray` (which inherits GPU_Struct), but you also need to set `array_size` to the size of the array defined in the shader.


## Contributor Resources

Below are some resources that you might find useful if you wish to contribute to this project. If you have any recommendations for additional references, please feel free to open an issue with the link to it, and how you find it useful.


[OpenGL Buffer Alignment Docs](https://registry.khronos.org/OpenGL/specs/gl/glspec45.core.pdf#page=158)

[OpenGL Data Type Docs](https://www.khronos.org/opengl/wiki/Data_Type_(GLSL))
