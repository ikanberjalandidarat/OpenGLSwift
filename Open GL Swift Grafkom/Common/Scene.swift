/*

    
 */

import Foundation
#if os(macOS)
import OpenGL
#else
import OpenGLES
#endif

let NUM_LIGHTS = 3

class Scene {
    private var program: ShaderProgram
    private var programProjectionMatrixLocation: GLuint
    private var programModelviewMatrixLocation: GLuint
    private var programCameraPositionLocation: GLuint
    private var programLightPositionLocation: GLuint
    private var programLightColorLocation: GLuint

    private var lightPosition = [Float](repeating: 0.0, count: NUM_LIGHTS * 3)
    private var lightColor: [Float] = [1.0, 0.0, 0.6,
                                       1.0, 0.5, 0.2,
                                       1.0, 0.4, 0.7]
    private var lightRotation: Float = 0.0

    private var normalmap: Texture?
    private var renderable: Renderable

    private var cameraRotation: Float = 0.0
    private var cameraPosition: [Float] = [0.0, 0.0, 4.0]

    init() {
        // Create the program, attach shaders, and link.
        program = ShaderProgram()
        program.attachShader("shader.vs", withType: GL_VERTEX_SHADER)
        program.attachShader("shader.fs", withType: GL_FRAGMENT_SHADER)
        program.link()

        // Get uniform locations.
        programProjectionMatrixLocation = program.getUniformLocation("projectionMatrix")!
        programModelviewMatrixLocation = program.getUniformLocation("modelviewMatrix")!
        programCameraPositionLocation = program.getUniformLocation("cameraPosition")!
        programLightPositionLocation = program.getUniformLocation("lightPosition")!
        programLightColorLocation = program.getUniformLocation("lightColor")!

        // LOAD THE TEXTURE
        normalmap = Texture.loadFromFile("normalmap.png")
        renderable = Cylinder(program: program, numberOfDivisions: 36)
    }

    func render(_ projectionMatrix: Matrix4) {
        let translationMatrix = Matrix4.translationMatrix(x: -cameraPosition[0], y: -cameraPosition[1], z: -cameraPosition[2])
        let rotationMatrix = Matrix4.rotationMatrix(angle: cameraRotation, x: 0.0, y: -1.0, z: 0.0) // 0 -1 0
        // 0 -2 0
        let modelviewMatrix = translationMatrix * rotationMatrix

        // Enable the program and set uniform variables.
        program.use()
        glUniformMatrix4fv(GLint(programProjectionMatrixLocation), 1, GLboolean(GL_FALSE), UnsafePointer<GLfloat>(projectionMatrix.matrix))
        glUniformMatrix4fv(GLint(programModelviewMatrixLocation), 1, GLboolean(GL_FALSE), UnsafePointer<GLfloat>(modelviewMatrix.matrix))
        glUniform3fv(GLint(programCameraPositionLocation), 1, UnsafePointer<GLfloat>(cameraPosition))
        glUniform3fv(GLint(programLightPositionLocation), GLint(NUM_LIGHTS), UnsafePointer<GLfloat>(lightPosition))
        glUniform3fv(GLint(programLightColorLocation), GLint(NUM_LIGHTS), UnsafePointer<GLfloat>(lightColor))

        // Render the object.
        renderable.render()

        // Disable the program.
        glUseProgram(0)
    }

    func cycle(_ secondsElapsed: Float) {
        // Update the light positions.
        // Lamanya rotasi
        lightRotation += (Float.pi / 4.0) * secondsElapsed
        
        for i in 0..<NUM_LIGHTS {
            let radius: Float = 1.50 // 1.75 is ok juga
            let r = (((Float.pi * 2.0) / Float(NUM_LIGHTS)) * Float(i)) + lightRotation

            lightPosition[i * 3 + 0] = cosf(r) * radius
            lightPosition[i * 3 + 1] = cosf(r) * sinf(r)
            lightPosition[i * 3 + 2] = sinf(r) * radius
        }

        // Update the camera position.
        cameraRotation -= (Float.pi / 20.0) * secondsElapsed //  20
        cameraPosition[0] = sinf(cameraRotation) * 8.0 //  4
        cameraPosition[1] = 0.0
        cameraPosition[2] = cosf(cameraRotation) * 4.0
    }
}
