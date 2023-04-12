//
//  ChatRow.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/30.
//

import SwiftUI
import ImSDK_Plus_Swift
import SDWebImageSwiftUI
import JFHeroBrowser

struct ChatRow: View {
    let message: ChatMessageModel
    let isMe: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isMe { Spacer() } else { Avatar(message: message ) }
            if message.type == "text" { TextMessage(isMe: isMe, text: message.tempContent == nil ? message.content : message.tempContent as! String,isTemp: (message.tempContent != nil) ? true : false) }
            else if message.type == "image"{ImageMessage(message:message)}
            if isMe { Avatar(message: message ) } else { Spacer() }
        }
        .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12)).onAppear {
            log.info("userID:\(String(describing: message.uid))")
        }
    }
    
    struct Avatar: View {
        let message: ChatMessageModel
        
        var body: some View {
            NavigationLink {
                UserIntroduceView(uid: message.uid)
            } label: {
                WebImage(url: URL(string: message._uidAvatar))
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40,alignment: .center).clipShape(RoundedRectangle(cornerRadius: 3))
            }
           
        }
    }
    
    struct ImageMessage:View{
        let message: ChatMessageModel
        @State var imageSize : CGSize = CGSize(width: 150, height: 200)
        var body: some View{
            if message.tempContent != nil{
                HStack{
                    ActivityRep()
                    Image(uiImage: message.tempContent as! UIImage).resizable().aspectRatio(contentMode: .fill).frame(width: getImageWidth(),height: getImageHeight(),alignment: .center).background(Color.gray).clipShape(RoundedRectangle(cornerRadius: 10))
                }
               
            }else{
                WebImage(url: URL(string: message._content)).onSuccess(perform: { image, data, cacheType in
                    imageSize = image.size
                }).resizable().aspectRatio(contentMode: .fill).frame(width: getImageWidth(),height: getImageHeight(),alignment: .center).background(Color.gray).clipShape(RoundedRectangle(cornerRadius: 10)).onTapGesture {
                    var list: [HeroBrowserViewModule] = []
                    list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: message._content, originImgUrl: message._content))
                    myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: 0)
                }
            }
           
        }
        
        func getImageWidth() ->CGFloat{
            if imageSize.width > imageSize.height {
                return 230
            }
            return 150
        }
        
        func getImageHeight() -> CGFloat{
            if imageSize.width > imageSize.height {
                return 230 * imageSize.height / imageSize.width
            }
            let height = 150 * imageSize.height / imageSize.width
            if height > 250 {
                return 250
            }
            return height
        }
        
        
    }
    
    struct TextMessage: View {
        let isMe: Bool
        let text: String
        let isTemp : Bool
        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                if !isMe { Arrow(isMe: isMe) }
                HStack{
                    if isTemp{
                        ActivityRep()
                    }
                    Text(text)
                        .font(.system(size: 17))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(background)
                }
            
                
                if isMe { Arrow(isMe: isMe) }
            }
        }
        
        private var background: some View {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color("chat_\(isMe ? "me" : "friend")_background"))
        }
    }
    
    struct Arrow: View {
        let isMe: Bool
        
        var body: some View {
            Path { path in
                path.move(to: .init(x: isMe ? 0 : 6, y: 14))
                path.addLine(to: .init(x: isMe ? 0 : 6, y: 26))
                path.addLine(to: .init(x: isMe ? 6 : 0, y: 20))
                path.addLine(to: .init(x: isMe ? 0 : 6, y: 14))
            }
            .fill(Color("chat_\(isMe ? "me" : "friend")_background"))
            .frame(width: 6, height: 30)
        }
    }
}

//struct ChatRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatRow()
//    }
//}
