//
//  MessageView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/11.
//

import SwiftUI
import ImSDK_Plus_Swift

struct MessageView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    func initTIMSDK(){
        let config = V2TIMSDKConfig.init()
        config.logLevel = .V2TIM_LOG_INFO
        V2TIMManager.shared.addIMSDKListener(listener: TIMListener())
        _ = V2TIMManager.shared.initSDK(sdkAppID: 1234, config: config)
    }
}

class TIMListener : V2TIMSDKListener{
    
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
