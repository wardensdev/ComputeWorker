#[compute]

#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;


struct Object{
    dvec4 position;
    dvec4 velocity;
    double mass;
    int radius;
    double effector;
};

layout(set = 0, binding = 0, std140) uniform Time{
    double time;
};

layout(set = 0, binding = 1, std430) buffer TestStructArray{
    Object obj_arr[10];
};

layout(set = 0, binding = 2, std430) buffer TestVector{
    dvec4 test_vector;
};

layout(set = 0, binding = 3, std430) buffer LookupResult{
    dvec4 result;
};

layout(set = 0, binding = 4, std140) uniform TestInteger{
    int test_int;
};

layout(set = 1, binding = 0, std430) buffer TestFloat{
    double test_float;
};

layout(set = 1, binding = 1, std140) uniform TestFloatArr{
    double[100] fl_arr;
};

layout(set = 1, binding = 2, std430) buffer TestVecArr{
    vec4[] vec_arr;
};

layout(set = 0, binding = 5, std430) buffer TestVec2{
    dvec4 test_vec;
};

void main() {
    result.xy = test_vector.xy;
    result.z = test_float;
    result.w = time;

    test_vec.x += 1.0;
}