# ComputeWorker
 A Godot plug-in that wraps the RenderingDevice compute API. Provides a custom ComputeWorker class and node that simplifies setup and execution of the compute pipeline, and handles encoding of Godot data types into GLSL data buffers.
 
 ## The ComputeWorker Node
 A ComputeWorker can be added to a scene through the `Create New Node` dialog, or instanced from the `ComputeWorker.tscn` file.
 It can also be instanced in scripts with `ComputeWorker.new()`.
 
 **Note**: The maximum amount of ComputeWorkers allowed in your project will vary depending on the device the project is running on. This is because each ComputeWorker creates its own local RenderingDevice, which takes a portion of the gpu's resources for itself. If too many are created at the same time, it *will* cause a crash.

### Setup
First, drag your `.glsl` shader file into the `shader_file` field in the Inspector.

![image](https://user-images.githubusercontent.com/69459114/212461962-ab461f48-21d5-412e-95fb-b17d32cd8734.png)


Second, add the uniforms that are defined in your shader to the `uniforms` array. Start by opening the `Array` and clicking `Add Element`. Then click the empty array element to open the list of uniform options. (`GPUUniform` is the base class and shouldn't be used here)

![image](https://user-images.githubusercontent.com/69459114/212462368-ffb9ea87-24f1-43aa-ba06-7aba695aebde.png)



Note: The `GPU_*` objects listed represent different Godot data types, and they each correspond to their respective data types in GLSL. More on the specifics of it later.

Add a GPU_* uniform to the array for each uniform in your shader that you want to access/write to from Godot. (See **GPUUniforms** below)

When you inspect the GPUUniform you added, there are some properties to set. 
The first one is `Data`, which is the initial data that the shader will be supplied with.
Second is the uniform's `Binding`, which should be set to correspond with the binding of the uniform in the shader.
Third is `Uniform Type`, which is whether the variable in the shader is defined as a Uniform or Storage Buffer.
Fourth is `Alias`, which is a user-defined (that's you!) identifier that can be used to access your uniforms in a more readable manner.

![image](https://user-images.githubusercontent.com/69459114/212462025-570069cf-80b7-4872-a231-441ddddf6c7a.png)


Once your uniforms are set up, set the ComputeWorker's `Uniform Set ID` to the set ID used in your shader. (Currently does not support multiple sets)

Last, set the shader's *Global* `Work Group Size`.

And now you're done setting it up! Let's get into how to use it.

### Use
Before the ComputeWorker can be used, its `initialize()` function must be called. This is the function that sets up and dispatches the compute pipeline. However, if you need to set the initial data that the shader will receive through code, you can get the GPUUniform objects with the `get_uniform_by_*()` functions and set their `data` variable directly.

Once `initialize()` has been called, you can use `get_uniform_data(binding: int)` or `get_uniform_data_by_alias(alias: String)` to retrieve the resulting data from the shader. You can also use `set_uniform_data(data, binding, dispatch)` to set the value of the uniform in the shader. If `dispatch` is true, the shader will execute immediately after setting the uniform data.

If you want more control over the dispatching and executing of your shader, you can call `dispatch_compute_list()` and `execute_compute_shader()` manually to run it. If you make changes to the data in your uniforms, you must call `dispatch_compute_list()` before calling `execute_compute_shader()`, or the shader won't receive the updated data.

Calling `destroy()` will stop execution and free the ComputeWorker's RenderingDevice (and all the resources created by it). This can be used to swap out the worker's shader or uniforms. After `destroy()` has been called, `initialize()` must be called again to resume execution and enable the use of the `get_uniform_data` and `set_uniform_data` functions. The `initialized` variable can be used to check if those functions can be called.


## GPUUniforms

GPUUniforms are custom resources that encapsulate the setting/getting of uniform data through the RenderingDevice API, and the encoding of data from Godot variants to/from GLSL data types.

Below is a list of the GPU_* types and their corresponding GLSL data types:

- GPU_Boolean: `bool`
- GPU_Color: `dvec4`
- GPU_Float: `double`, `float`
- GPU_Image: `image2D`
- GPU_Integer: `int`
- GPU_PackedByteArray: Can be used for custom encoding
- GPU_PackedFloat64Array: `double[]`
- GPU_PackedVector3Array: `vec3[]`, `vec4[]`
- GPU_Struct: `struct` (see below)
- GPU_StructArray: `struct[]` (see below)
- GPU_Texture2DArray: `image2DArray`
- GPU_Vector3: `dvec3`, `dvec4`
- GPU_Vector3i: `ivec3`, `ivec4`

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
