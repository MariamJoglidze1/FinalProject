import Testing
internal import SwiftUI
@testable import FinalProject
@MainActor

//MARK: - View Extension Tests

struct ViewForceOrientationTests {
    @Test
    func testForceOrientationSetsAndRestores() async throws {
        
        AppDelegate.orientationLock = .portrait
        
        let initialOrientation = AppDelegate.orientationLock
        let setOrientation = {
            AppDelegate.orientationLock = .landscapeRight
        }
        
        let restoreOrientation = {
            AppDelegate.orientationLock = initialOrientation
        }
        
        setOrientation()
        #expect(AppDelegate.orientationLock == .landscapeRight)
        
        restoreOrientation()
        #expect(AppDelegate.orientationLock == initialOrientation)
    }
}
