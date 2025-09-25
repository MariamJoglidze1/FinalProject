import SwiftUI

extension View {
    @ViewBuilder
    func force(orientation: UIInterfaceOrientationMask) -> some View {
        let currentOrientation = AppDelegate.orientationLock
        self
            .onAppear {
                AppDelegate.orientationLock = orientation
            }
            .onDisappear {
                AppDelegate.orientationLock = currentOrientation
            }
    }
}
