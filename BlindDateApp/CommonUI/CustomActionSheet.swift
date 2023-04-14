//
//  CustomActionSheet.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/14.
//

import SwiftUI

struct CustomActionSheet<A>: View where  A : View  {
    @Binding var  isPresented: Bool
    @ViewBuilder var actions: () -> A
    @State var isShow : Bool = false
    var body: some View {
        
        ZStack(alignment: .bottom) {
            Rectangle().fill(Color.black.opacity(0.3)).frame(maxWidth:.infinity,maxHeight:.infinity).ignoresSafeArea()
            if isShow{
                VStack(spacing:0){
                    actions().frame(maxWidth:.infinity)
                }.background(RoundedCorner(corners: [.topLeft,.topRight],radius: 10).fill(Color.white)).transition(.move(edge: .bottom))
            }
            
        }.ignoresSafeArea().onChange(of: isPresented, perform: { newValue in
            if !newValue{
                withAnimation(){
                    isShow = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                    self.topViewController()?.dismiss(animated: false)
                })
                
            }
        }).onAppear{
            withAnimation(){
                isShow = true
            }
        }
        
        
    }
}


