//
//  ContentView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/14.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userCenter : UserCenter = UserCenter.shared
    var body: some View {
        if !userCenter.isLogin {
            LoginView()
        }else{
            TabView{
                RecommandList().tabItem {
                    Label {
                        Text("推荐")
                    } icon: {
                        Image(systemName: "arkit").foregroundColor(.red)
                    }
                }
                
                LikeMe().tabItem {
                    Label {
                        Text("喜欢")
                    } icon: {
                        Image(systemName: "arkit").foregroundColor(.red)
                    }
                }
                
                Text("消息").tabItem {
                    Label {
                        Text("消息")
                    } icon: {
                        Image(systemName: "arkit").foregroundColor(.red)
                    }
                }
                
                Me().tabItem {
                    Label {
                        Text("我的")
                    } icon: {
                        Image(systemName: "arkit").foregroundColor(.red)
                    }
                }
            }
        }
       
//        TabView{
//
//                .tabItem {
//                    Label{
//                        Text("首页")
//                    } icon: {
//                        Image("")
//                    }
//
//                }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
