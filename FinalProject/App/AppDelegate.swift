import UIKit
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock: UIInterfaceOrientationMask = .portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                        
                        if let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
                        }
                    }
                }
            } else {
                let orientation: UIInterfaceOrientation = orientationLock == .portrait ? .portrait : .landscapeRight
                UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }
}
