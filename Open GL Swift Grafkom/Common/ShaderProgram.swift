/*
 
    This is the shader extention to create and run the program
    This program file works as the program that runs the shader for the object.
    
 */

// Why must we import Foundation? It's like importing iostream if you use c++
import Foundation

// This shows which emulator will be used, since this is through a macbook, it
// will directly go to the macOS and open OpenGL through
#if os(macOS)
import OpenGL
#else
import OpenGLES
#endif

class ShaderProgram {
    private var program: GLuint
    
    init() {
        program = glCreateProgram()
        if program == 0 {
            NSLog("Error.")
        }
    }
    
    deinit {
        glDeleteProgram(program)
    }

    
    func attachShader(_ file: String, withType type: GLint) {
        if let shader = compileShader(file, withType: GLenum(type)) {
            glAttachShader(program, shader)

            // We can safely delete the shader now - it won't
            // actually be destroyed until the program that it's
            // attached to has been destroyed.
            glDeleteShader(shader)
        }
    }

    
    func link() {
        glLinkProgram(program)

        // Check the linking results.
        var result: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &result)
        if result == GL_FALSE {
            NSLog("Program linking failed")
        }
    }

    func getAttributeLocation(_ name: String) -> GLuint? {
        let tmp = glGetAttribLocation(program, name.cString(using: String.Encoding.utf8)!)
        return tmp < 0 ? nil : GLuint(tmp)
    }

    func getUniformLocation(_ name: String) -> GLuint? {
        let tmp = glGetUniformLocation(program, name.cString(using: String.Encoding.utf8)!)
        return tmp < 0 ? nil : GLuint(tmp)
    }

    func use() {
        glUseProgram(program)
    }

    private func getGLShaderInfoLog(_ shader: GLuint) -> String {
        // Get the length of the info log.
        var length: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &length)

        // Retrieve the info log.
        var str = [GLchar](repeating: GLchar(0), count: Int(length) + 1)
        var size: GLsizei = 0
        glGetShaderInfoLog(shader, GLsizei(length), &size, &str)

        return String(cString: str)
    }

    private func compileShader(_ file: String, withType type: GLenum) -> GLuint? {
        // Load the shader source.
        let path = Bundle.main.resourcePath! + "/" + file
        let source = try? String(contentsOfFile: path, encoding: String.Encoding.ascii)
        if source == nil {
            NSLog("Unable to load \(file)")
            return nil
        }

        let cSource = source!.cString(using: String.Encoding.ascii)
        var glcSource = UnsafePointer<GLchar>? (cSource!)

        // Compile the shader.
        let shader = glCreateShader(type)
        var length = GLint((source!.utf8).count)
        glShaderSource(shader, 1, &glcSource, &length)
        glCompileShader(shader)

        // Make sure the compilation was successful.
        var result: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &result)
        if result == GL_FALSE {
            NSLog("Compilation of \(file) failed: \(getGLShaderInfoLog(shader))")
            glDeleteShader(shader)
            return nil
        }

        return shader
    }
}
