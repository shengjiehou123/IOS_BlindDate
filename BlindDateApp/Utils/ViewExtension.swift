//
//  ViewExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI



extension View{
    func toast(isShow:Binding<Bool>,msg:String) -> some View{
        ZStack(alignment: .center) {
            self
            Toast(isShow: isShow,msg: msg,duration: 2)
        }
    }
}


//struct ToastModifier:ViewModifier{
//    @Binding var isShow: Bool
//    var msg : String
//    func body(content: Content) -> some View {
//        ZStack(alignment: .center) {
//            content
//            Toast(isShow: $isShow,msg: msg,duration: 0.3)
//        }
//    }
//}

struct Toast:View{
    @Binding var isShow : Bool
    var msg : String
    var duration:Double
    var body: some View{
        if isShow && !msg.isEmpty{
            HStack(alignment: .center, spacing: 0) {
                Text(msg).foregroundColor(.white).padding()
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.black.withAlphaComponent(0.9)))).frame(maxWidth:screenWidth - 60).onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isShow = false
                }
            }
            
        }
        
    }
}

struct Toast_Previews:PreviewProvider{
    static var previews: some View{
        Toast(isShow: .constant(true), msg: "12345dfsfgsdggfs", duration: 3)

    }
}


