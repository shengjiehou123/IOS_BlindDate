//
//  MessageView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/11.
//

import SwiftUI
import Alamofire
import ImSDK_Plus_Swift
import SDWebImageSwiftUI

class MessageModel : BaseModel,V2TIMSDKListener{
    static let shared = MessageModel()
    @Published var listData : [ImSDK_Plus_Swift.V2TIMConversation] = []
//    override init() {
//        super.init()
//        requestConversionList()
//    }
    //MARK: SDK登录状态
    func TiMIsLoginSuc() ->Bool{
       let loginStatus = V2TIMManager.shared.getLoginStatus()
        if loginStatus == .V2TIM_STATUS_LOGINED {
            return true
        }
        return false
    }
    
    //MARK: 会话列表
    func requestConversionList(state:RefreshState){
        if state == .normal {
            self.showLoading = true
            self.loadingBgColor = .white
        }
        V2TIMManager.shared.getConversationList(nextSeq: 0, count: 50) { list, nextSeq, isFinished in
            self.showLoading = false
            self.listData.removeAll()
            self.listData.append(contentsOf: list)
            for item in self.listData {
                log.info("item:\(item)")
            }
        } fail: { code, desc in
            log.info("list fail:\(code) \(desc)")
            self.showLoading = false
            self.showToast = true
            self.toastMsg = desc
        }

    }
    
    func onConnecting(){
        
    }

    /// The SDK is successfully connected to the CVM instance
    func onConnectSuccess(){
        
    }

    /// The SDK failed to connect to the CVM instance
    func onConnectFailed(code: Int32, err: String){
        
    }

    /// The current user is kicked offline: the SDK notifies the user on the UI, and the user can choose to call the login() function of V2TIMManager to log in again.
    func onKickedOffline(){
        
    }

    /// The ticket expires when the user is online: the user needs to generate a new userSig and call the login() function of V2TIMManager to log in again.
    func onUserSigExpired(){
        
    }

    /// The profile of the current user was updated
    func onSelfInfoUpdated(info: ImSDK_Plus_Swift.V2TIMUserFullInfo){
        
    }

    /**
     * User status changed notification
     *
     * @note You will receive this callback in the following cases：
     * 1. The status (including status and custom status) changed of the subscribed user.
     * 2. The status (including status and custom status) changed of the friends. (Need to turn on the switch on console).
     * 3. The custom status changed of yourself.
     */
    func onUserStatusChanged(userStatusList: [ImSDK_Plus_Swift.V2TIMUserStatus]){
        
    }
}


struct MessageView: View {
    @StateObject var msgModel : MessageModel = MessageModel()
    var body: some View {
        VStack{
            ForEach(msgModel.listData,id:\.conversationID){ model in
                ConversationRow(model: model).id(model.conversationID)
            }
            Spacer()
        }.onAppear {
            if msgModel.TiMIsLoginSuc() {
                msgModel.requestConversionList(state: .normal)
            }else{
                UserCenter.shared.loginTIM()
            }
          
        }
    }
   
   
}


struct ConversationRow: View {
    var model : ImSDK_Plus_Swift.V2TIMConversation
    var body: some View {
        NavigationLink {
            ChatView(userId: model.userID ?? "", nickName: model.showName ?? "")
        } label: {
            HStack(spacing: 12) {
                WebImage(url: URL(string: model.faceUrl ?? ""))
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .cornerRadius(8)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top) {
                        Text(model.showName ?? "")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                        Spacer()
                        Text(getLastMsgTime())
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(getLastMsg())
                        .lineLimit(1)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }

    }
    
    func getLastMsgTime() ->String{
        let date = model.lastMessage?.timestamp
        let lastMsgTimeStr = date?.stringFormat(format: "yyyy/MM/dd HH:mm") ?? ""
        return lastMsgTimeStr
    }
    
    func getLastMsg() ->String{
        if model.lastMessage?.elemType == .V2TIM_ELEM_TYPE_TEXT{
            return model.lastMessage?.textElem?.text ?? ""
        }else if model.lastMessage?.elemType == .V2TIM_ELEM_TYPE_IMAGE{
            return "图片"
        }else if model.lastMessage?.elemType == .V2TIM_ELEM_TYPE_SOUND{
            return "语音"
        }
        return ""
    }
}



struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
