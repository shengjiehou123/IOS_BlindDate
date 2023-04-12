//
//  LightWaveView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/12.
//

import SwiftUI
import SDWebImageSwiftUI

struct LightWaveView: ViewModifier {
    @Binding var isShowing: Bool
    @State var size : CGSize = CGSize.zero
    @State private var animateCircle = false
    @State private var animateCircleImage = false
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
            if isShowing {
                VStack(alignment: .center){
                    
                    
                }.frame(maxWidth:.infinity,maxHeight: .infinity, alignment: .leading).background(Color.white)
                ZStack{
                    Circle().stroke(lineWidth: 2).frame(width: 300, height: 300).foregroundColor(textFieldAccentColor).background(Circle().fill(Color.colorWithHexString(hex: "#F97676").opacity(0.2)))
                        .scaleEffect(animateCircle ? 1 : 0.3)
                            .opacity(animateCircle ? 0 : 1)
                    Circle().stroke(lineWidth: 2).frame(width: 240, height: 240).foregroundColor(textFieldAccentColor).background(Circle().fill(Color.colorWithHexString(hex: "#F97676").opacity(0.2)))
                        .scaleEffect(animateCircle ? 1 : 0.3)
                            .opacity(animateCircle ? 0 : 1)
                    Circle().stroke(lineWidth: 2).frame(width: 180, height: 180).foregroundColor(textFieldAccentColor).background(Circle().fill(Color.colorWithHexString(hex: "#F97676").opacity(0.2))).scaleEffect(animateCircle ? 1 : 0.3)
                        .opacity(animateCircle ? 0 : 1)
                    WebImage(url:URL(string: UserCenter.shared.userInfoModel?._avatar ?? "")).resizable().aspectRatio(contentMode: .fill).frame(width:animateCircleImage ? 130 : 50,height: animateCircleImage ? 130 : 50,alignment: .center).clipShape(Circle())
                }.onAppear {
                    withAnimation(.easeIn(duration: 0.25)){
                        animateCircleImage = true
                    }
                    withAnimation(.easeIn(duration: 2).repeatForever(autoreverses: false)){
                        animateCircle.toggle()
                    }
                }
                   
            }

                
        }
        
    }
}

extension View{
    func lightWaveView(isShow: Binding<Bool>) -> some View{
        ModifiedContent(content: self, modifier: LightWaveView(isShowing: isShow))
    }
}
