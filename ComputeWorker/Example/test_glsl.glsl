#[compute]

#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

struct Object{
    dvec4 position;
    dvec4 velocity;
    double mass;
    double radius;
    double effector;
};

layout(set = 0, binding = 0, std140) buffer Globals{
    double time;
};

layout(set = 0, binding = 1, std430) buffer ObjectArray{
    Object obj_arr[10];
};

layout(set = 0, binding = 2, std430) buffer Vector{
    dvec4 test_vector;
};

layout(set = 0, binding = 3, std430) buffer Result{
    dvec4 result;
};

void main() {
    result.xyz = test_vector.xyz;
    result.w = time;
}