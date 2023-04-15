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
    
    func setNavigation(color:UIColor){
        let navigationBar = UINavigationBar.appearance()

        if #available(iOS 15.0, *)  {
            let navibarAppearance = UINavigationBarAppearance()
//            navibarAppearance.configureWithOpaqueBackground()
            navibarAppearance.backgroundColor = color
            navibarAppearance.backgroundImage = UIImage.from(color: color)
            navibarAppearance.shadowImage = UIImage.from(color: .clear)

            navigationBar.standardAppearance = navibarAppearance
            navigationBar.scrollEdgeAppearance = navibarAppearance
        }else{
            navigationBar.setBackgroundImage(UIImage.from(color: color), for: .any, barMetrics: .default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    func setTabBar(color:UIColor){
        let tabBar = UITabBar.appearance()
        if #available(iOS 13.0, *) {
            let tabbarAppearance = UITabBarAppearance()
            tabbarAppearance.backgroundImage = UIImage.from(color: color)
            tabbarAppearance.shadowImage = UIImage.from(color: .clear)
           tabBar.standardAppearance = tabbarAppearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabbarAppearance
            }
        }else{
            tabBar.isTranslucent = false
            tabBar.backgroundImage = UIImage.from(color: color)
            tabBar.shadowImage = UIImage.from(color: .clear)
            tabBar.tintColor = UIColor.colorWithHexString(hex: "#326291")
        }
    }
}


struct ContentView: View {
    init(){
        UserCenter.shared.setDefaultData()
        JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroNetworkImageProvider.shared
        NavigationCenter.shared.setNavigation(color: UIColor.white)
        NavigationCenter.shared.setTabBar(color: UIColor.white)
        FaceVerifyService().initAliyunSDK()        

    }
    @StateObject var userCenter : UserCenter = UserCenter.shared
    @StateObject var naviCenter : NavigationCenter = NavigationCenter.shared
    @State var showVerifyView : Bool = false
    @State var pushVerify : Bool = false
    @State var certificateName : String = ""
    @State var certificateNumber : String = ""
    var body: some View {
        if !userCenter.isLogin {
            LoginView()
        }else{
            if (userCenter.userInfoModel?.nickName ?? "").isEmpty {
                EnterInfoView()
            }else{
                NavigationView{
                    VStack(alignment: .leading, spacing: 0){
                        NavigationLink(isActive: $pushVerify) {
                            RealNameVerifyView(name: $certificateName, id: $certificateNumber, isFirst: .constant(false)).modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "")).padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        } label: {
                            EmptyView()
                        }.frame(height:0)
                        
                  
                  
                TabView(selection: $naviCenter.tableSelectionType){
                    RecommandList().tabItem {
                        Label {
                            Text("推荐")
                        } icon: {
                            Image(uiImage: UIImage(named: "tabbar_recommend")!)
                        }
                    }.tag(TableSelectionTagType.recommandTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView,pushVerify: $pushVerify)
                    }
                    
                    LikeMe().tabItem {
                        Label {
                            Text("喜欢")
                        } icon: {
                            Image(uiImage: UIImage(named: "like")!)
                        }
                    }.tag(TableSelectionTagType.likeTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView,pushVerify: $pushVerify)
                    }
                    
                    DynamicCircleView().tabItem {
                        Label {
                            Text("广场")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.circleTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView,pushVerify: $pushVerify)
                    }
                    
                    MessageView().tabItem {
                        Label {
                            Text("消息")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.messageTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView,pushVerify: $pushVerify)
                    }
                    
                    Me().tabItem {
                        Label {
                            Text("我的")
                        } icon: {
                            Image(systemName: "arkit").foregroundColor(.red)
                        }
                    }.tag(TableSelectionTagType.meTagType).onAppear(perform: checkIdVerify).alertB(isPresented: $showVerifyView) {
                        VerifyIDAlterView(show: $showVerifyView,pushVerify: $pushVerify)
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
                       
                }.onChange(of: userCenter.idVerifyed) { newValue in
                    if newValue > 0{
                        pushVerify = false
                    }
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
