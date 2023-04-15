//
//  LineView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/14.
//

import SwiftUI

struct LineHorizontalView: View {
    var body: some View {
        Spacer().frame(maxWidth:.infinity,maxHeight: 1).background(Color.colorWithHexString(hex: "#F3F3F3"))
    }
}

struct LineVerticalView: View {
    var body: some View {
        Spacer().frame(maxWidth:1,maxHeight: .infinity).background(Color.colorWithHexString(hex: "#F3F3F3"))
    }
}

