//
//  ChatView.swift
//  SwiftUI-WeChat
//
//  Created by Gesen on 2019/8/11.
//  Copyright © 2019 Gesen. All rights reserved.
//

import SwiftUI
import Combine
import ImSDK_Plus_Swift
import HandyJSON
import SDWebImageSwiftUI


class ChatMessageModel : HandyJSON{
    var id : Int = 0
    var uid : Int = 0
    var uidAvatar : String = ""
    var toUid: Int = 0
    var type : String = "text"
    var content : String = ""
    var createAt : String = ""
    var updateAt : String = ""
    required init() {
        
    }
}

class ChatModel :BaseModel,V2TIMAdvancedMsgListener{
    @Published var listData : [ChatMessageModel] = []
    @Published var toUserInfo : ReCommandModel = ReCommandModel()
    @Published var content: String = ""
    @Published var toUserId: String = ""
    @Published var page : Int = 1
    @Published var scrollToLast : Bool = false
    
    //MARK: 获取历史信息
    func requestHistoryMessageList(userID:String,state:RefreshState){
        if state == .normal {
            self.page = 1
            self.showLoading = true
            self.loadingBgColor = .white
        }else{
            self.page += 1
        }
        let params = ["page":self.page,"pageLimit":10,"toAccount":userID] as [String : Any]
        NW.request(urlStr: "get/history/message", method: .post, parameters: params) { response in
            self.showLoading = false
            self.pullDown = false
            if state == .normal {
                self.listData.removeAll()
            }
            guard let list = response.data["list"] as? [[String:Any]] else{return}
            var tempArr : [ChatMessageModel] = []
            for item in list {
                guard let model = ChatMessageModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                tempArr.append(model)
            }
            
            if state == .normal {
                self.scrollToLast = true
                self.listData.append(contentsOf: tempArr)
            }else{
                for item in tempArr.reversed() {
                    self.listData.insert(item, at: 0)
                }
               
            }
            
        } failedHandler: { response in
            self.showLoading = false
            self.pullDown = false
        }


    }
    
    //MARK: send message
    func requestSendMsg(userID:String){
        let param = ["fromAccount":UserCenter.shared.userInfoModel?.id ?? 0,"toAccount":userID,"msgType":"text","msgContent":self.content] as [String : Any]
        NW.request(urlStr: "send/single/message", method: .post, parameters:param) {  response in
//            requestHistoryMessageList(userID: userID, state: .normal)
        } failedHandler: { response in
            
        }

    }
    
    func requestGetToUserInfo(){
        let params = ["uid":toUserId]
        NW.request(urlStr: "get/user/info",method:.post,parameters:params) { response in
            let dic = response.data
            guard let userModel = ReCommandModel.deserialize(from: dic) else{
                return
            }
            self.toUserInfo = userModel
            
        } failedHandler: { response in

            
        }

    }
    
    /// Received a new message
    func onRecvNewMessage(msg: ImSDK_Plus_Swift.V2TIMMessage){
        if msg.elemType == .V2TIM_ELEM_TYPE_TEXT {
//            log.info(msg.textElem?.text)
//            let model = ImSDK_Plus_Swift.V2TIMMessage()
//            model.faceURL = msg.faceURL
//            model.nickName = msg.nickName
//            model.textElem?.text = msg.textElem?.text
            let model = ChatMessageModel()
            if msg.sender == "\(UserCenter.shared.userInfoModel?.id ?? 0)" {
                model.uid = Int(msg.sender!) ?? 0
                model.uidAvatar = msg.faceURL ?? ""
                model.toUid = Int(self.toUserId) ?? 0
            }else{
                model.uid = Int(self.toUserId) ?? 0
                model.uidAvatar = msg.faceURL ?? ""
                model.toUid = UserCenter.shared.userInfoModel?.id ?? 0
               
            }
            model.id = (self.listData.last?.id ?? 0) + 1
            model.content = msg.textElem?.text ?? ""
            self.listData.append(model)
            self.scrollToLast = true
            log.info("lastMsgId:\(msg.msgID)")
        }else if msg.elemType == .V2TIM_ELEM_TYPE_IMAGE{
            log.info(msg.imageElem?.imageList)
        }else if msg.elemType == .V2TIM_ELEM_TYPE_SOUND{
            
        }
    }

    /// Message read receipt notification (if you send a message that supports read receipts, the message receiver calls the sendMessageReadReceipts interface, and you will receive the callback)
    func onRecvMessageReadReceipts(receiptList: [ImSDK_Plus_Swift.V2TIMMessageReceipt]){
        
    }

    /// C2C peer user conversation read notification（If the peer user calls the markC2CMessageAsRead interface, you will receive the callback, and the callback will only carry the peer userID and peer read timestamp information）
    func onRecvC2CReadReceipt(receiptList: [ImSDK_Plus_Swift.V2TIMMessageReceipt]){
        
    }

    /// Received a message recall notification
    func onRecvMessageRevoked(msgID: String){
        
    }

    /// Message content modified
    func onRecvMessageModified(msg: ImSDK_Plus_Swift.V2TIMMessage){
        
    }

    /// Message extension changed
    func onRecvMessageExtensionsChanged(msgID: String, extensions: [ImSDK_Plus_Swift.V2TIMMessageExtension]){
        
    }

    /// Message extension deleted
    func onRecvMessageExtensionsDeleted(msgID: String, extensionKeys: [String]){
        
    }

}

struct ChatView: View {
    var userId : String
    var nickName : String
    @ObservedObject var chatModel : ChatModel = ChatModel()
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ChatHeaderView().padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 0)).environmentObject(chatModel)
                ChatList(userID: userId).environmentObject(chatModel)
                Send(proxy: proxy,userID: userId).environmentObject(chatModel)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color("light_gray"))
        .modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: nickName)).onAppear {
            chatModel.toUserId = userId
            V2TIMManager.shared.addAdvancedMsgListener(listener: chatModel)
            chatModel.requestHistoryMessageList(userID: userId, state: .normal)
            chatModel.requestGetToUserInfo()
        }
    }
    
    struct Send: View {
        let proxy: GeometryProxy
        let userID : String
        
        @State private var text: String = ""
        @EnvironmentObject var chatModel : ChatModel
        
        var body: some View {
            VStack(spacing: 0) {
                Separator(color: Color("chat_send_line"))
                
                ZStack {
                    Color("chat_send_background")
                    
                    VStack {
                        HStack(spacing: 12) {
                            Image("chat_send_voice")
                            
                            TextField("和喜欢的人聊天吧", text: $text,onCommit: {
                                if text.isEmpty {
                                    return
                                }
                                chatModel.content = text
                                text = ""
                                chatModel.requestSendMsg(userID: userID)
                            })
                                .frame(height: 40)
                                .background(Color("chat_send_text_background"))
                                .cornerRadius(4).introspectTextField { UITextField in
                                    UITextField.returnKeyType = .send
                                }
                            
                            Image("chat_send_emoji")
                            Image("chat_send_more")
                        }
                        .frame(height: 56)
                        .padding(.horizontal, 12)
                        
                        Spacer()
                    }
                }
                .frame(height: proxy.safeAreaInsets.bottom + 56)
            }
        }
    }
}

struct ChatHeaderView:View{
    @EnvironmentObject  var chatModel : ChatModel
    var body: some View{
        VStack(alignment: .leading,spacing: 20){
            HStack(alignment: .center,spacing: 15) {
                NavigationLink(destination: UserIntroduceView(uid:chatModel.toUserInfo.id)) {
                    WebImage(url: URL(string: chatModel.toUserInfo.avatar)).resizable().aspectRatio(contentMode: .fill).frame(width: 60,height: 60,alignment: .center).background(Color.gray).clipShape(Circle())
                }
                VStack(alignment: .leading,spacing: 10) {
                    Text(chatModel.toUserInfo.nickName).font(.system(size: 17,weight:.medium))
                    HStack(alignment: .center,spacing: 3){
                        let date = Date.init(timeIntervalSince1970: chatModel.toUserInfo.birthday)
                        Text("\(date.getAge())").font(.system(size: 14,weight:.medium))
                        Text(chatModel.toUserInfo.job).font(.system(size: 14,weight:.medium))
                    }
                }
            }

            Text(chatModel.toUserInfo.aboutMeDesc).font(.system(size: 13)).lineLimit(2)
            ScrollView(.horizontal,showsIndicators: false){
                LazyHStack(alignment: .top){
                    ForEach(chatModel.toUserInfo.userPhotos,id:\.id){ model in
                        ChartHeaderImageItem(photoModel: model)
                    }
                }
            }.frame(height:110)
        }
    }
}

struct ChartHeaderImageItem:View{
    let photoModel : UserPhotoModel
    var body: some View{
        ZStack(alignment: .topLeading) {
            WebImage(url: URL(string: photoModel.photo)).resizable().aspectRatio(contentMode: .fill).frame(width: 100,height: 100,alignment: .center).background(Color.gray).clipShape(RoundedRectangle(cornerRadius: 5))
            let scenes = getScenesStr()
            if !scenes.isEmpty{
                Text(scenes).font(.system(size: 12)).foregroundColor(.white).padding(5).background(RoundedRectangle(cornerRadius: 5).fill(Color.black.opacity(0.2))).padding(10)
            }
        }
    }
    
    func getScenesStr() -> String{
        if photoModel.scenes == "life" {
            return "日常生活"
        }
        if photoModel.scenes == "interest" {
            return "兴趣照"
        }
        
        if photoModel.scenes == "travel" {
            return "旅行照"
        }
        return ""
    }
}

struct ChatList: View {
    let userID : String
    @EnvironmentObject var chatModel : ChatModel
    var body: some View {
    ScrollViewReader { proxy in
        RefreshableScrollView(refreshing: $chatModel.pullDown, pullDown: {
            chatModel.requestHistoryMessageList(userID: userID, state: .pullDown)
        }, footerRefreshing: $chatModel.footerRefreshing, loadMore: $chatModel.loadMore, onFooterRefreshing: nil){
            ForEach(chatModel.listData,id:\.id) { model in
                ChatRow(message: model, isMe: model.uid == UserCenter.shared.userInfoModel?.id ?? 0)
                .id(model.id)
            } .background(Color("light_gray"))
        }.onChange(of: chatModel.scrollToLast) { _ in
            if chatModel.scrollToLast {
                if let lastId = chatModel.listData.last?.id {
                    proxy.scrollTo(lastId) // 消息变化时跳到最后一条消息
                }
                chatModel.scrollToLast = false
            }
          
        }
    }.onAppear {
        chatModel.requestHistoryMessageList(userID: userID, state: .normal)
    }
       
}
    
   
    
    struct Time: View {
        let date: Date
        
        var body: some View {
            Text("")
                .foregroundColor(Color("chat_time"))
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
    }
}

struct Separator: View {
    let color: Color
    
    var body: some View {
        Divider()
            .overlay(color)
            .padding(.zero)
    }
    
    init(color: Color = Color("separator")) {
        self.color = color
    }
}


struct ChatHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHeaderView().padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 0))
    }
}



