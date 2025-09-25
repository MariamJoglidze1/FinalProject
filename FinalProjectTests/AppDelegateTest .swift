import Testing
import SwiftUI
@testable import FinalProject
@MainActor

// MARK: - AppDelegate Tests
struct AppDelegateTests {
    
    @Test
    func testOrientationLockChange() async throws {

        AppDelegate.orientationLock = .portrait
        #expect(AppDelegate.orientationLock == .portrait)
        
        AppDelegate.orientationLock = .landscapeRight
        
        #expect(AppDelegate.orientationLock == .landscapeRight)
    }
    
    @Test
    func testSupportedInterfaceOrientations() async throws {
        let appDelegate = AppDelegate()
        AppDelegate.orientationLock = .portrait
        
        let orientations = appDelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: nil)
        
        #expect(orientations == .portrait)
        
        AppDelegate.orientationLock = .landscapeRight
        let orientations2 = appDelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: nil)
        
        #expect(orientations2 == .landscapeRight)
    }
}
