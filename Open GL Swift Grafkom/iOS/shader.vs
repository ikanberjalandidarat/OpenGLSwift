/*
    To adjust the camera, tangent space, and light vectors from the previous
    shader.fs file of the project.
 */

const int NUM_LIGHTS = 3;

uniform mat4 projectionMatrix;
uniform mat4 modelviewMatrix;

uniform vec3 cameraPosition;
uniform vec3 lightPosition[NUM_LIGHTS];

attribute vec3 vertexPosition;
attribute vec2 vertexTexCoords;
attribute vec3 vertexTangent;
attribute vec3 vertexBitangent;
attribute vec3 vertexNormal;

varying vec2 fragmentTexCoords;
varying vec3 cameraVector;
varying vec3 lightVector[NUM_LIGHTS];

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
