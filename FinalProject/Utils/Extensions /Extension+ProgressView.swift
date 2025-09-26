import SwiftUI

extension View {
    func progressView(isShowing: Bool) -> some View {
        self
            .blocksHitTesting(isShowing)
            .overlay(content: {
                if isShowing {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 60, height: 60)
                            .cornerRadius(4)
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
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

