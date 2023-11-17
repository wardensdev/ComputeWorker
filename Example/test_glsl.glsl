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


vec2 grad( ivec2 z )  {
	int n = z.x+z.y*11111;
	// Hugo Elias hash (feel free to replace by another one)
	n = (n<<13)^n;
	n = (n*(n*n*15731+789221)+1376312589)>>16;
	
	
	// simple random vectors
	// return vec2(cos(float(n)),sin(float(n)));        
	
	// Perlin style vectors    
	n &= 7;    
	vec2 gr = vec2(n&1,n>>1)*2.0-1.0;    
	return ( n>=6 ) ? vec2(0.0,gr.x) :            
	( n>=4 ) ? vec2(gr.x,0.0) : gr;
}


float noise( in vec2 p ){    
	ivec2 i = ivec2(floor( p ));
	vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f); // feel free to replace by a quintic smoothstep instead    

	return mix( mix( dot( grad( i+ivec2(0,0) ), f-vec2(0.0,0.0) ), 
				dot( grad( i+ivec2(1,0) ), f-vec2(1.0,0.0) ), u.x),
				mix( dot( grad( i+ivec2(0,1) ), f-vec2(0.0,1.0) ),
				dot( grad( i+ivec2(1,1) ), f-vec2(1.0,1.0) ), u.x), u.y);
}

float fbm( in vec2 uv, in int oct){    
	mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );    
	float n = 0.5;    
	float f = n * noise( uv );    
	for (int i = 0; i < oct; i++){        
		n *= 0.5;        
		f += n * noise( uv ); uv = m * uv;    
	}    
	return 0.5 + 0.5 * f;
}

void main() {
	result.xy = test_vector.xy;
	result.z = fbm(vec2(test_vector.xy)*float(time), test_int); //test_float;  
	result.w = time;
}