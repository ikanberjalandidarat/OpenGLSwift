/*
    This is the App Delegate,
 
    The app delegate object manages the app's shared behaviors.
    The app delegate is effectively the root object of the app.
 
 
    */

import Cocoa
import OpenGL
import GLKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: MyNSOpenGLView!

    private var timer: Timer!
    private var scene: Scene!
    private var ticks: UInt64 = AppDelegate.getTicks()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Do some GL setup.
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClearDepth(1.0)
        glDisable(GLenum(GL_BLEND))
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LEQUAL))
        glEnable(GLenum(GL_CULL_FACE))
        glFrontFace(GLenum(GL_CCW))
        glCullFace(GLenum(GL_BACK))

        scene = Scene()

        // Create a timer to render.
        timer = Timer(timeInterval: 1.0 / 60.0, repeats: true, block: timerFireMethod)
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func timerFireMethod(_ sender: Timer!) {
        // Render the scene.
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        scene.render(view.projectionMatrix)
        glFlush()
        view.flush()

        // Cycle the scene.
        let newTicks = AppDelegate.getTicks()
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

