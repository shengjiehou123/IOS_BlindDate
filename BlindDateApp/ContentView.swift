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

open class NavigationCenter : ObservableObject{
    static let shared = NavigationCenter()
    @Published var tableSelectionType : TableSelectionTagType = .recommandTagType
    @Published var likeTitle : String = "喜欢我的人"
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
        
        FaceVerifyService.shared.initAliyunSDK()        


    }
    @StateObject var userCenter : UserCenter = UserCenter.shared
    @StateObject var naviCenter : NavigationCenter = NavigationCenter.shared
    @State var showVerifyView : Bool = false
    var body: some View {
        if !userCenter.isLogin {
            LoginView()
        }else{
            if (userCenter.userInfoModel?.nickName ?? "").isEmpty {
                EnterInfoView()
            }else{
                NavigationView{
                TabView(selection: $naviCenter.tableSelectionType){
                    RecommandList().tabItem {
                        Label {
                            Text("推荐")
                        } icon: {
                            Image(uiImage: UIImage(named: "tabbar_recommend")!)
                        }
                    }.tag(TableSelectionTagType.recommandTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView)
                    }
                    
                    LikeMe().tabItem {
                        Label {
                            Text("喜欢")
                        } icon: {
                            Image(uiImage: UIImage(named: "like")!)
                        }
                    }.tag(TableSelectionTagType.likeTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView)
                    }
                    
                    DynamicCircleView().tabItem {
                        Label {
                            Text("广场")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.circleTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView)
                    }
                    
                    MessageView().tabItem {
                        Label {
                            Text("消息")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.messageTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView)
                    }
                    
                    Me().tabItem {
                        Label {
                            Text("我的")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.meTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView)
                    }
                }.navigationBarTitleDisplayMode(.inline).navigationBarHidden(naviCenter.tableSelectionType == .meTagType ? true : false).toolbar(content: {
                    ToolbarItem(placement:.navigationBarLeading){
                        Text(returnNavigationLeftItemText(tabTagType: naviCenter.tableSelectionType)).font(.system(size: naviCenter.tableSelectionType == .likeTagType ? 25 : 30, weight: .medium, design: .default))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        returnNavigationRightItem(tabTagType: naviCenter.tableSelectionType)
                    }
                })
                       
                }
            }
        }
       
        
    }
    
    func checkIdVerify(){
        if UserCenter.shared.isLogin{
            if UserCenter.shared.userInfoModel?.idVerifyed == 0{
                showVerifyView = true
            }else{
                showVerifyView = false
            }
        }else{
            showVerifyView = false
        }
    }
    
    func returnNavigationRightItem(tabTagType:TableSelectionTagType) ->AnyView{
        if tabTagType == .circleTagType {
            return   AnyView(Button {
                NotificationCenter.default.post(name: .init(rawValue: kNotiCreateCircle), object: nil)
            } label: {
                HStack{
                    Text("发动态").font(.system(size: 15, weight: .medium, design: .default)).foregroundColor(.white)
                }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)).background(RoundedRectangle(cornerRadius: 5).fill(btnLRLineGradient))
            }.buttonStyle(PlainButtonStyle()))
        }
        return AnyView(EmptyView())
    }
    
    func returnNavigationLeftItemText(tabTagType:TableSelectionTagType) ->String{
        switch tabTagType {
        case .recommandTagType:
            return "推荐"
        case .likeTagType:
            return naviCenter.likeTitle
        case .circleTagType:
            return "广场"
        case .messageTagType:
            return "消息"
        case .meTagType:
            return ""
        }
    }
    
}

struct CaptionLabelStyle : LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.fixedSize().frame(width: 50, height: 50, alignment: .center)
            configuration.title
        }
    }
}

struct ScaledImage: View {
    let name: String
    let size: CGSize
    
    var body: Image {
        let uiImage = resizedImage(named: self.name, for: self.size) ?? UIImage()
        
        return Image(uiImage: uiImage.withRenderingMode(.alwaysOriginal))
    }
    
    func resizedImage(named: String, for size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named) else {
            return nil
        }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
