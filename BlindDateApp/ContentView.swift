//
//  ContentView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/14.
//

import SwiftUI
import JFHeroBrowser

enum TableSelectionTagType:Hashable{
    case recommandTagType
    case likeTagType
    case circleTagType
    case messageTagType
    case meTagType
}

struct ContentView: View {
    init(){
        UserCenter.shared.setDefaultData()
        JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroNetworkImageProvider.shared
        let navigationBar = UINavigationBar.appearance()

        if #available(iOS 15.0, *)  {
            let navibarAppearance = UINavigationBarAppearance()
            navibarAppearance.backgroundColor = .white
            navibarAppearance.backgroundImage = UIImage.from(color: .white)
            navibarAppearance.shadowImage = UIImage.from(color: .clear)

            navigationBar.standardAppearance = navibarAppearance
            navigationBar.scrollEdgeAppearance = navibarAppearance
        }else{
            navigationBar.setBackgroundImage(UIImage.from(color: .white), for: .any, barMetrics: .default)
            navigationBar.shadowImage = UIImage()
        }
        let tabBar = UITabBar.appearance()
        if #available(iOS 13.0, *) {
            let tabbarAppearance = UITabBarAppearance()
            tabbarAppearance.backgroundImage = UIImage.from(color: .white)
            tabbarAppearance.shadowImage = UIImage.from(color: .clear)
           tabBar.standardAppearance = tabbarAppearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabbarAppearance
            }
        }else{
            tabBar.isTranslucent = false
            tabBar.backgroundImage = UIImage.from(color: .white)
            tabBar.shadowImage = UIImage.from(color: .clear)
            tabBar.tintColor = UIColor.colorWithHexString(hex: "#326291")
        }
        


    }
    @ObservedObject var userCenter : UserCenter = UserCenter.shared
    @State var tabSelection : TableSelectionTagType = .recommandTagType
    var body: some View {
        if !userCenter.isLogin {
            LoginView()
        }else{
            if (userCenter.userInfoModel?.nickName ?? "").isEmpty {
                EnterInfoView()
            }else{
                TabView(selection: $tabSelection){
                    RecommandList().tabItem {
                        Label {
                            Text("推荐")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.recommandTagType)
                    
                    LikeMe().tabItem {
                        Label {
                            Text("喜欢")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.likeTagType)
                    
                    DynamicCircleView().tabItem {
                        Label {
                            Text("广场")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.circleTagType)
                    
                    MessageView().tabItem {
                        Label {
                            Text("消息")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.messageTagType)
                    
                    Me().tabItem {
                        Label {
                            Text("我的")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.meTagType)
                }
            }
        }
       
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
