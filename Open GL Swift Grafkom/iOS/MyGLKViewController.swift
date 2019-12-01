/*
menangis
 */

import GLKit
import OpenGLES

class MyGLKViewController: GLKViewController {
    var context: EAGLContext? = nil

    private var scene: Scene!
    private var ticks: UInt64 = MyGLKViewController.getTicks()

    deinit {
        if EAGLContext.current() === self.context {
            EAGLContext.setCurrent(nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.context = EAGLContext(api: .openGLES2)
        if self.context == nil {
            print("Failed to create ES context")
        }

        EAGLContext.setCurrent(self.context)

        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24

        // Do some GL setup.
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClearDepthf(1.0)
        glDisable(GLenum(GL_BLEND))
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LEQUAL))
        glEnable(GLenum(GL_CULL_FACE))
        glFrontFace(GLenum(GL_CCW))
        glCullFace(GLenum(GL_BACK))

        scene = Scene()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil

            if EAGLContext.current() === self.context {
                EAGLContext.setCurrent(nil)
            }
            self.context = nil
        }
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // Create projection matrix.
        let aspectRatio = Float(rect.size.width / rect.size.height)
        let projectionMatrix = Matrix4.perspectiveMatrix(fov: Float.pi / 2.0, aspect: aspectRatio, near: 0.1, far: 200.0)

        // Render the scene.
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        scene.render(projectionMatrix)
        glFlush()

        // Cycle the scene.
        let newTicks = MyGLKViewController.getTicks()
        let secondsElapsed = Float(newTicks - ticks) / 1000.0
        ticks = newTicks
        scene.cycle(secondsElapsed)
    }

    private class func getTicks() -> UInt64 {
        var t = timeval()
        gettimeofday(&t, nil)
        return UInt64(t.tv_sec * 1000) + UInt64(t.tv_usec / 1000)
    }
}
