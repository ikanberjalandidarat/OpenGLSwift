/*
GATAU APA YA DESCRIBE NYA
 */
 
#version 150

const int NUM_LIGHTS = 3;

uniform mat4 projectionMatrix;
uniform mat4 modelviewMatrix;

uniform vec3 cameraPosition;
uniform vec3 lightPosition[NUM_LIGHTS];

in vec3 vertexPosition;
in vec2 vertexTexCoords;
in vec3 vertexTangent;
in vec3 vertexBitangent;
in vec3 vertexNormal;

out vec2 fragmentTexCoords;
out vec3 cameraVector;
out vec3 lightVector[NUM_LIGHTS];

void
main()
{
	mat3 tangentSpace = mat3(vertexTangent, vertexBitangent, vertexNormal);

	// set the vector from the vertex to the camera
	cameraVector = (cameraPosition - vertexPosition.xyz) * tangentSpace;

	// set the vectors from the vertex to each light
	for(int i = 0; i < NUM_LIGHTS; ++i)
		lightVector[i] = (lightPosition[i] - vertexPosition.xyz) * tangentSpace;

	// output the transformed vertex
	fragmentTexCoords = vertexTexCoords;
	gl_Position = (projectionMatrix * modelviewMatrix) * vec4(vertexPosition, 1.0);
}
