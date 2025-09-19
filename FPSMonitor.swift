import Foundation
import CoreVideo
import Combine

class FPSMonitor: ObservableObject {
    @Published var fps: Double = 0

    private var displayLink: CVDisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    init() {
        setupDisplayLink()
    }

    private func setupDisplayLink() {
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        displayLink = link
        if let displayLink = displayLink {
            let callback: CVDisplayLinkOutputCallback = { (_, inNow, _, _, _, userInfo) -> CVReturn in
                guard let userInfo = userInfo else { return kCVReturnSuccess }
                let monitor = Unmanaged<FPSMonitor>.fromOpaque(userInfo).takeUnretainedValue()
                monitor.tick(inNow.pointee)
                return kCVReturnSuccess
            }
            CVDisplayLinkSetOutputCallback(displayLink, callback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        }
    }

    private func tick(_ timestamp: CVTimeStamp) {
        // Convert CVTimeStamp to seconds
        let time = CFTimeInterval(timestamp.videoTime) / CFTimeInterval(timestamp.videoTimeScale)
        if lastTimestamp == 0 {
            lastTimestamp = time
            return
        }
        frameCount += 1
        let delta = time - lastTimestamp
        // Update every ~0.25s for stability
        if delta >= 0.25 {
            let fpsValue = Double(frameCount) / delta
            frameCount = 0
            lastTimestamp = time
            DispatchQueue.main.async {
                self.fps = fpsValue
            }
        }
    }

    func start() {
        if let displayLink = displayLink, !CVDisplayLinkIsRunning(displayLink) {
            CVDisplayLinkStart(displayLink)
        }
    }

    func stop() {
        if let displayLink = displayLink, CVDisplayLinkIsRunning(displayLink) {
            CVDisplayLinkStop(displayLink)
        }
    }

    deinit {
        stop()
    }
}
