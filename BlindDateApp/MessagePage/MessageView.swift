//
//  MessageView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/11.
//

import SwiftUI
import Alamofire
import ImSDK_Plus_Swift



struct MessageView: View {
    @State var userSig : String = ""
    var listener : TIMListener = TIMListener()
    var msgListener : TIMMsgListener = TIMMsgListener()
    var body: some View {
        Text("Hello, World!").onAppear {
            initTIMSDK()
            requestChatUserSig()
        }
    }
    func initTIMSDK(){
        let config = V2TIMSDKConfig.init()
        config.logLevel = .V2TIM_LOG_INFO
        V2TIMManager.shared.addIMSDKListener(listener: listener)
        _ = V2TIMManager.shared.initSDK(sdkAppID: 1400794630, config: config)
        V2TIMManager.shared.addAdvancedMsgListener(listener: msgListener)
    }
    
    func loginTIM(){
        if let model =  UserCenter.shared.userInfoModel{
            let userId = "\(model.id)"
            V2TIMManager.shared.login(userID: userId, userSig: userSig) {
//                requestSendMsg()
            } fail: { code, desc in
                // 如果返回以下错误码，表示使用 UserSig 已过期，请您使用新签发的 UserSig 进行再次登录。
                   // 1. ERR_USER_SIG_EXPIRED（6206）
                   // 2. ERR_SVR_ACCOUNT_USERSIG_EXPIRED（70001）
                   // 注意：其他的错误码，请不要在这里调用登录接口，避免 IM SDK 登录进入死循环
//                log.info("failure, code:%d, desc:%@", code, desc)
                log.info("ailure, code:\(code), desc:\(desc)")
            }
            

        }else{
            UserCenter.shared.requestUserInfo()
        }
       
    }
    
    func requestChatUserSig(){
        if !UserCenter.shared.isLogin {
            return
        }
        NW.request(urlStr: "chat/user/sig", method: .post, parameters: nil) { response in
            guard let sig = response.data["sig"] as? String else{
                return
            }
           userSig = sig
           loginTIM()
        } failedHandler: { response in
            
        }
    }
    
    func requestSendMsg(){
        let param = ["fromAccount":68,"toAccount":69,"msgType":"text","msgContent":["Text":"hello"]] as [String : Any]
        NW.request(urlStr: "send/single/message", method: .post, parameters:param) { response in
            
        } failedHandler: { response in
            
        }

    }
}

class TIMListener : V2TIMSDKListener{
    
    /// The SDK is connecting to the CVM instance
    func onConnecting(){
        log.info("onConnecting")
    }

    /// The SDK is successfully connected to the CVM instance
    func onConnectSuccess(){
        log.info("onConnectSuccess")
    }

    /// The SDK failed to connect to the CVM instance
    func onConnectFailed(code: Int32, err: String){
        log.info("onConnectFailed code:\(code) err:\(err)")
    }

    /// The current user is kicked offline: the SDK notifies the user on the UI, and the user can choose to call the login() function of V2TIMManager to log in again.
    func onKickedOffline(){
        log.info("onKickedOffline")
    }

    /// The ticket expires when the user is online: the user needs to generate a new userSig and call the login() function of V2TIMManager to log in again.
    func onUserSigExpired(){
        log.info("onUserSigExpired")
    }

    /// The profile of the current user was updated
    func onSelfInfoUpdated(info: ImSDK_Plus_Swift.V2TIMUserFullInfo){
        log.info("onSelfInfoUpdated")
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
        log.info("onUserStatusChanged")
    }
    
}

class TIMMsgListener : V2TIMAdvancedMsgListener{
    /// Received a new message
    func onRecvNewMessage(msg: ImSDK_Plus_Swift.V2TIMMessage){
        log.info("onRecvNewMessage\(String(describing: msg.description))")
    }

    /// Message read receipt notification (if you send a message that supports read receipts, the message receiver calls the sendMessageReadReceipts interface, and you will receive the callback)
    func onRecvMessageReadReceipts(receiptList: [ImSDK_Plus_Swift.V2TIMMessageReceipt]){
        log.info("onRecvMessageReadReceipts\(receiptList[0].userID)")
    }

    /// C2C peer user conversation read notification（If the peer user calls the markC2CMessageAsRead interface, you will receive the callback, and the callback will only carry the peer userID and peer read timestamp information）
    func onRecvC2CReadReceipt(receiptList: [ImSDK_Plus_Swift.V2TIMMessageReceipt]){
        log.info("onRecvC2CReadReceipt\(receiptList[0].userID)")
    }

    /// Received a message recall notification
    func onRecvMessageRevoked(msgID: String){
        log.info("onRecvMessageRevoked\(msgID)")
    }

    /// Message content modified
    func onRecvMessageModified(msg: ImSDK_Plus_Swift.V2TIMMessage){
        log.info("onRecvMessageModified\(msg.textElem?.text)")
    }

    /// Message extension changed
    func onRecvMessageExtensionsChanged(msgID: String, extensions: [ImSDK_Plus_Swift.V2TIMMessageExtension]){
        log.info("onRecvMessageExtensionsChanged\(msgID)")
    }

    /// Message extension deleted
    func onRecvMessageExtensionsDeleted(msgID: String, extensionKeys: [String]){
        log.info("onRecvMessageExtensionsDeleted\(msgID)")
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
