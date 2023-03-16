//
//  MessageView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/11.
//

import SwiftUI
import Alamofire
import UIKit




struct MessageView: View {
    @State var userSig : String = ""
    @State var toUserId : String = ""
    @State var isActive : Bool = false
    @State var tabBarVc : UITabBarController? = nil
//    var listener : TIMListener = TIMListener()
//    var msgListener : TIMMsgListener = TIMMsgListener()
    var body: some View {
//        Text("Hello, World!").onAppear {
//            initTIMSDK()
//
//        }
        NavigationView{
           
            VStack(alignment: .leading, spacing: 0){
                NavigationLink(isActive: $isActive) {
                    ChatVc(userID: $toUserId).introspectTabBarController { tabbarVc in
                        tabBarVc = tabbarVc
                        tabbarVc.tabBar.isHidden = true
                    }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "")).edgesIgnoringSafeArea(.bottom).onDisappear {
                        tabBarVc?.tabBar.isHidden = false
                    }
                } label: {
                    Text("")
                }

                ConversationVc(clickCellHandle: { toUserID in
                    toUserId = toUserID
                    isActive = true
                }).navigationBarTitleDisplayMode(.inline).toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("消息").font(.system(size: 30, weight: .medium, design: .default))
                    }
                }).onAppear {
                    
                        NotificationCenter.default.addObserver(forName: .init(rawValue: kNotiChatToUserId), object: nil, queue: OperationQueue.main) { noti in
                            
                            toUserId = String(noti.object as? Int ?? 0)
                            log.info("toUserId:\(toUserId)")
                            isActive = true
                        }
                    
                }
            }
           
            
         
        }
        
    }
    func initTIMSDK(){
        
       
        
//        let config = V2TIMSDKConfig.init()
//        config.logLevel = .V2TIM_LOG_INFO
//        V2TIMManager.shared.addIMSDKListener(listener: listener)
//        _ = V2TIMManager.shared.initSDK(sdkAppID: 1400794630, config: config)
//        V2TIMManager.shared.addAdvancedMsgListener(listener: msgListener)
    }
    
   
    func requestSendMsg(){
        let param = ["fromAccount":68,"toAccount":69,"msgType":"text","msgContent":["Text":"hello"]] as [String : Any]
        NW.request(urlStr: "send/single/message", method: .post, parameters:param) { response in
            
        } failedHandler: { response in
            
        }

    }
}

//会话列表
struct ConversationVc:UIViewControllerRepresentable{
    var clickCellHandle : (_ toUserID:String) ->Void
    func makeUIViewController(context: UIViewControllerRepresentableContext<ConversationVc>) -> TUIConversationListController {

        let conversationVc = TUIConversationListController()
        conversationVc.delegate = context.coordinator
        return conversationVc
//        conversationVc.delegate = self
//        topViewController()?.addChild(conversationVc)
//        topViewController()?.view.addSubview(conversationVc.view)
            
        }

        func updateUIViewController(_ uiViewController: TUIConversationListController, context: UIViewControllerRepresentableContext<ConversationVc>) {

        }
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
    
    final class Coordinator: NSObject, TUIConversationListControllerListener {

        var parent: ConversationVc

        init(_ parent: ConversationVc) {
            self.parent = parent
        }
        
        func conversationListController(_ conversationController: UIViewController, didSelectConversation conversation: TUIConversationCellData) {
            // 会话列表点击事件，通常是打开聊天界面
            self.parent.clickCellHandle(conversation.userID)
        }

    }
    
}

//聊天页面
struct ChatVc:UIViewControllerRepresentable{
    @Binding var userID : String
    func makeUIViewController(context: UIViewControllerRepresentableContext<ChatVc>) -> TUIC2CChatViewController {
        let chatVc = TUIC2CChatViewController()
        chatVc.hidesBottomBarWhenPushed = true
        let data = TUIChatConversationModel()
        data.userID = userID
        chatVc.conversationData = data
        return chatVc
    }

    func updateUIViewController(_ uiViewController: TUIC2CChatViewController, context: UIViewControllerRepresentableContext<ChatVc>) {

    }
        
}



//class TIMListener : V2TIMSDKListener{
//
//    /// The SDK is connecting to the CVM instance
//    func onConnecting(){
//        log.info("onConnecting")
//    }
//
//    /// The SDK is successfully connected to the CVM instance
//    func onConnectSuccess(){
//        log.info("onConnectSuccess")
//    }
//
//    /// The SDK failed to connect to the CVM instance
//    func onConnectFailed(code: Int32, err: String){
//        log.info("onConnectFailed code:\(code) err:\(err)")
//    }
//
//    /// The current user is kicked offline: the SDK notifies the user on the UI, and the user can choose to call the login() function of V2TIMManager to log in again.
//    func onKickedOffline(){
//        log.info("onKickedOffline")
//    }
//
//    /// The ticket expires when the user is online: the user needs to generate a new userSig and call the login() function of V2TIMManager to log in again.
//    func onUserSigExpired(){
//        log.info("onUserSigExpired")
//    }
//
//    /// The profile of the current user was updated
//    func onSelfInfoUpdated(info: ImSDK_Plus_Swift.V2TIMUserFullInfo){
//        log.info("onSelfInfoUpdated")
//    }
//
//    /**
//     * User status changed notification
//     *
//     * @note You will receive this callback in the following cases：
//     * 1. The status (including status and custom status) changed of the subscribed user.
//     * 2. The status (including status and custom status) changed of the friends. (Need to turn on the switch on console).
//     * 3. The custom status changed of yourself.
//     */
//    func onUserStatusChanged(userStatusList: [ImSDK_Plus_Swift.V2TIMUserStatus]){
//        log.info("onUserStatusChanged")
//    }
//
//}

//class TIMMsgListener : V2TIMAdvancedMsgListener{
//    /// Received a new message
//    func onRecvNewMessage(msg: ImSDK_Plus_Swift.V2TIMMessage){
//        log.info("onRecvNewMessage\(String(describing: msg.description))")
//    }
//
//    /// Message read receipt notification (if you send a message that supports read receipts, the message receiver calls the sendMessageReadReceipts interface, and you will receive the callback)
//    func onRecvMessageReadReceipts(receiptList: [ImSDK_Plus_Swift.V2TIMMessageReceipt]){
//        log.info("onRecvMessageReadReceipts\(receiptList[0].userID)")
//    }
//
//    /// C2C peer user conversation read notification（If the peer user calls the markC2CMessageAsRead interface, you will receive the callback, and the callback will only carry the peer userID and peer read timestamp information）
//    func onRecvC2CReadReceipt(receiptList: [ImSDK_Plus_Swift.V2TIMMessageReceipt]){
//        log.info("onRecvC2CReadReceipt\(receiptList[0].userID)")
//    }
//
//    /// Received a message recall notification
//    func onRecvMessageRevoked(msgID: String){
//        log.info("onRecvMessageRevoked\(msgID)")
//    }
//
//    /// Message content modified
//    func onRecvMessageModified(msg: ImSDK_Plus_Swift.V2TIMMessage){
//        log.info("onRecvMessageModified\(msg.textElem?.text)")
//    }
//
//    /// Message extension changed
//    func onRecvMessageExtensionsChanged(msgID: String, extensions: [ImSDK_Plus_Swift.V2TIMMessageExtension]){
//        log.info("onRecvMessageExtensionsChanged\(msgID)")
//    }
//
//    /// Message extension deleted
//    func onRecvMessageExtensionsDeleted(msgID: String, extensionKeys: [String]){
//        log.info("onRecvMessageExtensionsDeleted\(msgID)")
//    }
//}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
