//
//  LoadingView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI
import UIKit

struct LoadingView: ViewModifier {
    @Binding var isShowing: Bool
    @Binding var bgColor : Color
    @State var size : CGSize = CGSize.zero
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {

            content.disabled(self.isShowing && bgColor != .clear).background(
                    GeometryReader{ reader ->AnyView in
                        DispatchQueue.main.async {
                            size = reader.size
                        }
                        return AnyView(EmptyView())
                    }
            )
                

            if self.isShowing && bgColor != .clear {
                VStack(alignment: .center){
                    
                    
                }.frame(width: size.width, height: size.height, alignment: .leading).background(bgColor)
            }

            
            if isShowing {
                VStack(alignment: .center) {
                    ActivityLoading(isAnimating: $isShowing).frame(width:50,height:50,alignment:.center)
                }.frame(width: 100, height: 100, alignment: .center).background(Color(UIColor.black).cornerRadius(10)).opacity(self.isShowing ? 1 : 0)
            }

                
        }
        
    }
}

struct ActivityLoading :UIViewRepresentable{
    @Binding var isAnimating  : Bool
    func makeUIView(context: UIViewRepresentableContext<ActivityLoading>) ->  UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .white
        activityView.hidesWhenStopped = true
        return activityView
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityLoading>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

