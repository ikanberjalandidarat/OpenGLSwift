/*
 
    This shader file is to create the light effect
    Supposedly, it's rotate-able throughout the object
 */

const int NUM_LIGHTS = 3;
const lowp vec3 AMBIENT = vec3(0.1, 0.1, 0.1);
const lowp float MAX_DIST = 2.5;
const lowp float MAX_DIST_SQUARED = MAX_DIST * MAX_DIST;

uniform sampler2D normalmap;
uniform lowp vec3 lightColor[NUM_LIGHTS];

varying lowp vec2 fragmentTexCoords;
varying lowp vec3 cameraVector;
varying lowp vec3 lightVector[NUM_LIGHTS];

void
main()
{
	// initialize diffuse/specular lighting
	lowp vec3 diffuse = vec3(0.0, 0.0, 0.0);
	lowp vec3 specular = vec3(0.0, 0.0, 0.0);

	// get the fragment normal and camera direction
	lowp vec3 fragmentNormal = (texture2D(normalmap, fragmentTexCoords).rgb * 2.0) - 1.0;
	lowp vec3 normal = normalize(fragmentNormal);
	lowp vec3 cameraDir = normalize(cameraVector);

	// loop through each light
    // the light effect is here
	for(int i = 0; i < NUM_LIGHTS; ++i) {
		// calculate distance between 0.0 and 1.0
		lowp float dist = min(dot(lightVector[i], lightVector[i]), MAX_DIST_SQUARED) / MAX_DIST_SQUARED;
		lowp float distFactor = 1.0 - dist;

		// diffuse
		lowp vec3 lightDir = normalize(lightVector[i]);
		lowp float diffuseDot = dot(normal, lightDir);
		diffuse += lightColor[i] * clamp(diffuseDot, 0.0, 1.0) * distFactor;

		// specular
		lowp vec3 halfAngle = normalize(cameraDir + lightDir);
		lowp vec3 specularColor = min(lightColor[i] + 0.5, 1.0);
		lowp float specularDot = dot(normal, halfAngle);
		specular += specularColor * pow(clamp(specularDot, 0.0, 1.0), 16.0) * distFactor;
	}

	lowp vec4 sample = vec4(1.0, 1.0, 1.0, 1.0);
	gl_FragColor = vec4(clamp(sample.rgb * (diffuse + AMBIENT) + specular, 0.0, 1.0), sample.a);
}
