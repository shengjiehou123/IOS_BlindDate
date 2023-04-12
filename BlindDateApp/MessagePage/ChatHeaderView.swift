//
//  ChatHeaderView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/4.
//

import SwiftUI
import SDWebImageSwiftUI
import JFHeroBrowser

struct ChatHeaderView:View{
    @EnvironmentObject  var chatModel : ChatModel
    var body: some View{
        VStack(alignment: .leading,spacing: 20){
            HStack(alignment: .center,spacing: 15) {
                NavigationLink(destination: UserIntroduceView(uid:chatModel.toUserInfo.id)) {
                    WebImage(url: URL(string: chatModel.toUserInfo._avatar)).resizable().aspectRatio(contentMode: .fill).frame(width: 60,height: 60,alignment: .center).background(Color.gray).clipShape(Circle())
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
                        let index = chatModel.toUserInfo.userPhotos.firstIndex(of: model) ?? 0
                        ChartHeaderImageItem(photoModel: model).onTapGesture {
                            var list: [HeroBrowserViewModule] = []
                            for i in 0..<chatModel.toUserInfo.userPhotos.count {
                                let photoModel = chatModel.toUserInfo.userPhotos[i]
                                list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: photoModel._photo, originImgUrl: photoModel._photo))
                            }
                            myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                        }
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
            WebImage(url: URL(string: photoModel._photo)).resizable().aspectRatio(contentMode: .fill).frame(width: 100,height: 100,alignment: .center).background(Color.gray).clipShape(RoundedRectangle(cornerRadius: 5)).contentShape(Rectangle())
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


struct ChatHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHeaderView()
    }
}
