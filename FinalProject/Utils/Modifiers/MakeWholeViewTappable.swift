import SwiftUI

struct MakeWholeViewTapable: ViewModifier {
    init() {}
 
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle()) // make whole area tappable
    }
}

extension View {
    func makeWholeViewTapable() -> some View {
        self.modifier(MakeWholeViewTapable())
    }
}
