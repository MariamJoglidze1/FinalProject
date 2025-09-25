import SwiftUI

extension View {
    func progressView(isShowing: Bool) -> some View {
        self
            .blocksHitTesting(isShowing)
            .overlay(content: {
                if isShowing {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            })
    }
    
    func blocksHitTesting(
        _ flag: Bool = true
    ) -> some View {
        self
            .overlay(content: {
                if flag {
                    Color.clear.contentShape(.rect)
                }
            })
    }
}

