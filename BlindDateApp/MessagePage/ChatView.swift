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
    
    func requestSendMsg(userID:String){
        let param = ["fromAccount":UserCenter.shared.userInfoModel?.id ?? 0,"toAccount":userID,"msgType":"text","msgContent":self.content] as [String : Any]
        NW.request(urlStr: "send/single/message", method: .post, parameters:param) {  response in
//            requestHistoryMessageList(userID: userID, state: .normal)
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
                ChatList(userID: userId).environmentObject(chatModel)
                
                Send(proxy: proxy,userID: userId).environmentObject(chatModel)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color("light_gray"))
        .navigationBarTitle(nickName, displayMode: .inline).onAppear {
            chatModel.toUserId = userId
            V2TIMManager.shared.addAdvancedMsgListener(listener: chatModel)
            chatModel.requestHistoryMessageList(userID: userId, state: .normal)
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

struct ChatList: View {
    let userID : String
    @EnvironmentObject var chatModel : ChatModel
    var body: some View {
    ScrollViewReader { proxy in
        RefreshableScrollView(refreshing: $chatModel.pullDown, pullDown: {
            chatModel.requestHistoryMessageList(userID: userID, state: .pullDown)
        }, footerRefreshing: $chatModel.footerRefreshing, loadMore: $chatModel.loadMore, onFooterRefreshing: nil){
            ForEach(chatModel.listData,id:\.id) { model in
//                if let createdAt = model.timestamp {
//                    Time(date: createdAt)
//                }
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



