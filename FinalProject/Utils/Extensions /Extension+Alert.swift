//
//  Extension+Alert.swift
//  FinalProject
//
//  Created by Mariam Joglidze on 25.09.25.
//

import SwiftUI

struct AlertParameters {
    var title: String = ""
    var message: String? = nil
    var actionTitle: String = "Okay"
    var action: (() -> Void)? = nil
}

extension View {
    func alert(parameters: Binding<AlertParameters?>) -> some View {
        self.alert(
            parameters.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { parameters.wrappedValue != nil },
                set: { if !$0 { parameters.wrappedValue = nil } }
            )
        ) {
            if let action = parameters.wrappedValue?.action {
                Button(parameters.wrappedValue?.actionTitle ?? "Okay", action: action)
            } else {
                Button("Okay") { parameters.wrappedValue = nil }
            }
        } message: {
            if let message = parameters.wrappedValue?.message {
                Text(message)
            }
        }
    }
}
