//
//  DynamicCircle.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/15.
//

import SwiftUI
import SDWebImageSwiftUI
import HandyJSON
import JFHeroBrowser
import Combine

class CircleModel:HandyJSON,ObservableObject{
    var id : Int = 0
    var uid : Int = 0
    var content : String = ""
    var images : String = ""
    var userInfo : CircleUserInfo = CircleUserInfo()
    required init() {
        
    }
}

class CircleUserInfo:HandyJSON{
    var avatar : String = ""
    var nickName : String = ""
    var birthday : Double = 0
    var workCityName : String = ""
    var job : String = ""
    required init() {
        
    }
}

struct DynamicCircleView: View {
    @State var listData : [CircleModel] = []
    var body: some View {
     NavigationView{
        ScrollView(.vertical,showsIndicators: false){
            LazyVStack(alignment:.leading,spacing:30){
                ForEach(listData,id:\.uid){ model in
                    CircleRow(model:model)
                }
            }
        }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "")).navigationBarTitleDisplayMode(.inline).toolbar(content:{
            ToolbarItem(placement:.navigationBarLeading){
                Text("广场").font(.system(size:25,weight:.medium))
            }
        }).onAppear {
            requestCircleList()
        }
    }
  }
    
    func requestCircleList(){
        NW.request(urlStr: "circle/list", method: .post, parameters: nil) { response in
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            listData.removeAll()
            for item in list {
                guard let model = CircleModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                listData.append(model)
            }
            
        } failedHandler: { response in
            
        }

    }
}

struct CircleRow:View{
    @StateObject var model : CircleModel
    @State var showComment : Bool = false
    @State var images: [String] = []
    var body: some View{
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL(string:model.userInfo.avatar)).resizable().aspectRatio( contentMode: .fill).frame(width: 40, height: 40, alignment: .center).background(Color.red).clipShape(Circle())
                VStack(alignment: .leading, spacing: 5){
                    Text(model.userInfo.nickName).font(.system(size: 13,weight:.medium))
                    HStack(alignment: .center, spacing: 3){
                        Text("\(Date.init(timeIntervalSince1970: model.userInfo.birthday).getAge())岁").font(.system(size: 13)).foregroundColor(.gray)
                        Text(model.userInfo.workCityName).font(.system(size: 13)).foregroundColor(.gray)
                        Text(model.userInfo.job).font(.system(size: 13)).foregroundColor(.gray)
                    }
                }
                Spacer()
            }.frame(maxWidth:.infinity).padding(.leading,15)
            
            HStack(alignment: .center, spacing: 0){
                Spacer().frame(width:50)
                Text(model.content).lineSpacing(10)
                Spacer()
            }.frame(maxWidth:.infinity).padding(.leading,15)
            VStack(alignment: .leading, spacing: 10){
                ForEach(0..<getRow(total: images.count)){ i in
                    HStack(alignment: .center,spacing: 5){
                        ForEach(0..<3){ j in
                            let index = getIndex(i: i, j: j)
                            if index < images.count {
                                WebImage(url:URL(string:"\(images[index])")).resizable().renderingMode(.original).aspectRatio(contentMode: .fill)
                                    .frame(width:100,height:100,alignment: .center).background(Color.red).clipShape(RoundedRectangle(cornerRadius: 10)).contentShape(Rectangle()).onTapGesture {
                                        var list: [HeroBrowserViewModule] = []
                                        for imageUrlStr in images {
                                            list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: imageUrlStr, originImgUrl: imageUrlStr))
                                        }
                                        myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                                    }
                            }else{
                                EmptyView().frame(width: 0, height: 0, alignment: .leading)
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }.padding(EdgeInsets(top: 0, leading: 65, bottom: 0, trailing: 10))
            HStack(alignment:.center,spacing:50){
                Spacer()
                Text("点赞")
                Text("评论").onTapGesture {
                    showComment = true
                }
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            
        }.onAppear {
            images = model.images.components(separatedBy: ",")
        }.alertB(isPresented: $showComment) {
            CommentListView(show:$showComment,circleId: $model.id)
        }
    }
    
    func getRow(total:Int) ->Int{
        return (total-1) / 3 + 1
    }
    
    func getIndex(i:Int,j:Int) ->Int{
        let index = i*3 + j
        return index
    }
}

class ObserVedCommentModel:ObservableObject,Identifiable{
    @Published var titles : [CommentModel] = []
}

struct CommentListView:View{
    @Binding var show : Bool
    @Binding var circleId : Int
//    @StateObject var obModel : ObserVedCommentModel = ObserVedCommentModel()
    @State var titles : [CommentModel] = []
    @State var showSecondaryList : Bool = false
    @State var showAnimation : Bool = false
    @State var comment : String = ""
    var body: some View{
        if show{
    ZStack(alignment: .bottomLeading){
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(Color.black.opacity(0.3))
        VStack(alignment: .leading, spacing: 0){
            HStack(alignment: .center, spacing: 0){
                Text(titles.count > 0 ? "评论\(titles.count)" : "评论").font(.system(size: 18, weight: .medium, design: .default))
                Spacer()
                Button {
                    showAnimation = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.topViewController()?.dismiss(animated: false, completion: nil)
                        show = false
                    }
                } label: {
                    HStack{
                        Image("close").resizable().renderingMode(.original).aspectRatio( contentMode: .fill).frame(width: 24, height: 24, alignment: .center)
                    }.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                }

                
            }.padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 0)).frame(height:50)
        ScrollView(.vertical,showsIndicators: false){
            ScrollViewReader { reader in
                LazyVStack(alignment: .leading, spacing: 10){
                
                ForEach(titles,id:\.id){ model in
                    Section(header: CommentSection(model:model)) {
                        SecondaryRowList(model: model)
                    }
                    
                }
                    
                }.onChange(of: titles) { _ in
                 reader.scrollTo(titles[0].id, anchor: .center)
             }
            }
                
        }.padding(.bottom,65 + kSafeBottom)
        
           
        }.background((RoundedCorner(corners: [.topLeft,.topRight], radius: 10).fill(Color.white))).frame(maxWidth:.infinity,maxHeight: 600).offset(y:showAnimation ? 0: 620).animation(.linear(duration: 0.25), value: showAnimation).onAppear {
            showAnimation = true
         }
            
        }.edgesIgnoringSafeArea(.all).onAppear {
            requestCommentList(state: .normal)
       }
            
        CommentSendMsgView(circleId: $circleId,sendCommentSucHandle: {
            requestCommentList(state: .normal)
        })
    }.ignoresSafeArea(edges: .bottom)
     }
    }
    func requestCommentList(state:RefreshState){
        let params = ["circleId":circleId,"page":1,"pageLimit":10]
        NW.request(urlStr: "comment/list",method: .post,parameters: params) { response in
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            if state == .normal || state == .pullDown {
                titles.removeAll()
            }
            for item in list {
                guard let model = CommentModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                titles.append(model)
            }
        } failedHandler: { response in
            
        }
    }
    
    
    
    
}

//MARK: 发送评论
struct CommentSendMsgView:View{
    @Binding var circleId : Int
    @State var comment : String = ""
    var sendCommentSucHandle : () ->Void
    @State var keyBoardShow : Bool = false
    var body: some View{
        HStack(alignment: .center, spacing: 0) {
            TextField("评论...", text: $comment,onCommit: {
                if !comment.isEmpty {
                    requestCreateComment()
                }
            }).frame(maxWidth:.infinity,maxHeight:50).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3"))).onChange(of: comment) { newValue in
                comment = comment.trimmingCharacters(in: .whitespaces)
            }.onReceive(Publishers.keyboardHeight) {
                let keyboardHeight = $0
                keyBoardShow  = keyboardHeight > 0 ? true : false
            }
        }.padding(EdgeInsets(top: 10, leading: 20, bottom: keyBoardShow ? 5 : kSafeBottom, trailing: 20)).introspectTextField { textfield in
            textfield.returnKeyType = .send
        }.background(Color.white).keyboardAdaptive()
    }
    func requestCreateComment(){
        let params = ["circleId":circleId,"comment":comment] as [String : Any]
        NW.request(urlStr: "create/comment", method: .post, parameters: params) { response in
            comment = ""
            sendCommentSucHandle()
        } failedHandler: { response in
            
        }

    }
}

struct SecondaryRowList:View{
    @State var page : Int = 1
    @StateObject var model : CommentModel
    @State var show:Bool = true
    var body: some View{
        
        if show {
            ForEach(model.list,id:\.id){ secondaryCommentModel in
                SecondaryCommentRow(model: secondaryCommentModel)
            }
        }
        
        if model.secondaryCount > 0{
            if model.list.count < model.secondaryCount || !show{
                HStack(alignment: .center, spacing: 0) {
                    Spacer().frame(width:60)
                    Text("–– 展开\(!show ? model.list.count : model.secondaryCount-model.list.count)条回复").font(.system(size: 13, weight: .medium, design: .default))
                    Image("pull_down_indicator").resizable().renderingMode(.template).foregroundColor(.black).aspectRatio(contentMode: .fill)
                        .frame(width: 14, height: 14, alignment: .center)
                }.onTapGesture {
                    if(model.secondaryCount > 0 && model.secondaryCount == model.list.count){
                        show = true
                        return
                    }
                    requestSecondaryCommentList(model: model,state: .pullUp)
                }
            }else{
                HStack(alignment: .center, spacing: 0) {
                    Spacer().frame(width:60)
                    Text("–– 收起").font(.system(size: 13, weight: .medium, design: .default))
                    Image("pull_down_indicator").resizable().renderingMode(.template).foregroundColor(.black).aspectRatio(contentMode: .fill)
                        .frame(width: 14, height: 14, alignment: .center)
                }.onTapGesture {
                    show = false
                }
            }
        }
    }
    
    func requestSecondaryCommentList(model:CommentModel,state:RefreshState){
        if state != .pullUp {
            self.page = 1
        }
        let params = ["commentId":model.id,"page":self.page,"pageLimit":1]
        NW.request(urlStr: "secondary/comment/list", method: .post, parameters: params) { response in
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            self.page += 1
            for item in list {
                guard let secondaryCommentModel = SecondaryCommentModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                model.list.append(secondaryCommentModel)
            }
        } failedHandler: { response in
            
        }

    }
}

struct CommentSection:View{
    var model : CommentModel
    var body: some View{
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top, spacing: 5){
                Spacer().frame(width:20)
                WebImage(url: URL(string: model.userInfo.avatar)).resizable().aspectRatio(contentMode: .fill).background(Color.gray).clipShape(Circle()).frame(width: 30, height: 30, alignment: .center)
                VStack(alignment: .leading, spacing: 3){
                    Text(model.userInfo.nickName).font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Text(model.comment).font(.system(size: 15)).lineSpacing(5)
                }
                Spacer()
            }
                HStack(alignment: .center, spacing: 5){
                    Spacer().frame(width:55)
                    Text(model.createAt).font(.system(size: 12)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Text("回复").font(.system(size: 12, weight: .medium, design: .default)).foregroundColor(.colorWithHexString(hex: "#999999"))
                }
        }
    }
}

struct SecondaryCommentRow:View{
    var model : SecondaryCommentModel
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 5){
                Spacer().frame(width:55)
                WebImage(url: URL(string: model.uidInfo.avatar)).resizable().aspectRatio(contentMode: .fill).background(Color.gray).clipShape(Circle()).frame(width: 20, height: 20, alignment: .center)
                Text(model.atUid > 0 ? "\(model.uidInfo.nickName)►\(model.atUidInfo.nickName)" : "\(model.uidInfo.nickName)").font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "#999999"))
                Spacer()
            }
            Spacer().frame(height:3)
            HStack(alignment: .center, spacing: 0) {
                Spacer().frame(width:85)
                Text(model.comment).font(.system(size: 15)).lineSpacing(5)
            }
            Spacer().frame(height:5)
            HStack(alignment: .center, spacing: 5){
                Spacer().frame(width:80)
                Text(model.createAt).font(.system(size: 12)).foregroundColor(.gray)
                Text("回复").font(.system(size: 12, weight: .medium, design: .default)).foregroundColor(.colorWithHexString(hex: "#999999"))
            }
        }
    }
}

class CommentModel:HandyJSON,ObservableObject,Identifiable,Equatable{
    static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id : Int = 0
    var circleId : Int = 0
    var uid : Int = 0
    var comment: String = ""
    var createAt : String = ""
    var secondaryCount :Int = 0
    var userInfo : CircleUserInfo = CircleUserInfo()
    @Published var list : [SecondaryCommentModel] = []
    required init() {
        
    }
}

class SecondaryCommentModel:HandyJSON,Identifiable{
    var id :Int = 0
    var commentId :Int = 0
    var uid : Int = 0
    var atUid : Int = 0
    var comment : String = ""
    var createAt : String = ""
    var updateAt : String = ""
    var uidInfo:CircleUserInfo = CircleUserInfo()
    var atUidInfo:CircleUserInfo = CircleUserInfo()
    required init() {
        
    }
}

//struct CommentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentListView(show: .constant(true),circleId: 1)
//
//    }
//}

//struct DynamicCircle_Previews: PreviewProvider {
//    static var previews: some View {
//        DynamicCircleView()
//    }
//}