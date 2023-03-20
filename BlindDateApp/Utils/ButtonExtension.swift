//
//  ButtonExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/19.
//

import SwiftUI

struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.colorWithHexString(hex: "#F3F3F3") : Color.clear)
    }
}

extension Button {
    func highlighted() -> some View {
        self.buttonStyle(HighlightButtonStyle())
    }
}
