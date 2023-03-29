//
//  EnterInfoView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/4.
//

import SwiftUI
import simd
import SDWebImageSwiftUI
import PhotosUI
import Combine



struct EnterInfoView: View {
    @State var scrollIndex: Int = 0
    @State var nickName: String = ""
    @State var gender: Int = 3
    @State var birthDay: Double = 0
    @State var height: Int = 0
    @State var educationType : Int = 0
    @State var schoolName : String = ""
    @State var job : String = ""
    @State var yearIncome : Int = 0
    @State var workAddress : MyAddressModel = MyAddressModel()
    @State var homeTownAddress : MyAddressModel = MyAddressModel()
    @State var loveGoal : Int = 0
    @State var minAge : Int = 0
    @State var maxAge : Int = 0
    @State var aboutUsDesc :String = ""
    @State var tagArr : [String] = []
    @State var tagOtherArr : [String] = []
    
    @State var selectTagArr : [String] = []
    @State var selectTagOtherArr : [String] = []
    @StateObject var computedModel : MyComputedProperty = MyComputedProperty()
    @State var name : String = ""
    @State var id : String = ""
    
    var body: some View {
        
//        ScrollView(.horizontal, showsIndicators: false) {
//            ScrollViewReader { reader in
                LazyHStack(alignment: .top, spacing: 0) {
                    NickNameView(nickName: $nickName, scrollIndex: $scrollIndex).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(0)
                    GenderAgeHeightView(scrollIndex: $scrollIndex, gender: $gender, birthDay: $birthDay, height: $height).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(1)
                    EducationInfoView(scrollIndex: $scrollIndex, educationType: $educationType, schoolName: $schoolName).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(2)
                    MyJobView(scrollIndex: $scrollIndex, job: $job, yearIncome: $yearIncome).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(3)
                    MyCityAndHomeTownView(scrollIndex: $scrollIndex,workAddress:$workAddress,homeTownAddress: $homeTownAddress).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(4)
                    LoveGoalView(scrollIndex: $scrollIndex, loveGoal: $loveGoal, minAge: $minAge, maxAge: $maxAge).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(5)
                    MyAvatarView(scrollIndex: $scrollIndex).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(6).environmentObject(computedModel)
                    MyLifeView(scrollIndex: $scrollIndex).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(7).environmentObject(computedModel)
                    AboutUsDescView(scrollIndex: $scrollIndex, aboutUsDesc: $aboutUsDesc).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(8).ignoresSafeArea(.keyboard, edges: .bottom)
                    Group{
//                        ForEach(0..<tagTitleArr.count){ index in
//                            let title = tagTitleArr[index]
//
//                        }
                        PersonTagView(scrollIndex: $scrollIndex, index: 0,tagArr:$tagArr,selectTagArr:$selectTagArr,title: "选出最符合我的标签",nextHandle: {
                            
                        }).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(9)
                        PersonTagView(scrollIndex: $scrollIndex, index: 1,tagArr:$tagOtherArr,selectTagArr:$selectTagOtherArr,title: "我的理想中的他是？",nextHandle:{
                            log.info("nickName:\(nickName)")
                            log.info("gendar:\(gender)")
                            log.info("birthday:\(birthDay)")
                            log.info("height:\(height)")
                            log.info("educationType:\(educationType)")
                            log.info("schoolName:\(schoolName)")
                            log.info("job:\(job)")
                            log.info("yearIncome:\(yearIncome)")
                            log.info("provinceName: \(workAddress.provinceName) provinceId:\(workAddress.provinceId)")
                            log.info("cityName: \(workAddress.cityName) cityId:\(workAddress.cityId)")
                            log.info("areaName: \(workAddress.areaName) areaId:\(workAddress.areaId)")
                            log.info("HprovinceName: \(homeTownAddress.provinceName) HprovinceId:\(homeTownAddress.provinceId)")
                            log.info("HcityName: \(homeTownAddress.cityName) HcityId:\(workAddress.cityId)")
                            log.info("HareaName: \(homeTownAddress.areaName) HareaId:\(workAddress.areaId)")
                            log.info("loveGoal:\(loveGoal)")
                            log.info("minAge:\(minAge)")
                            log.info("maxAge:\(maxAge)")
                            log.info("aboutUsDesc:\(aboutUsDesc)")
                            log.info("myTag:\(selectTagArr)")
                            log.info("otherTag:\(selectTagOtherArr)")
                            requestSetUserInfo()
                        }).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(10)
                        RealNameVerifyView(name: $name, id: $id).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth).id(11)
                    }
                }.frame(width: screenWidth, alignment: .leading).offset(x:-screenWidth * CGFloat(scrollIndex))
            .animation(.linear(duration:0.25), value: scrollIndex).modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "")).onAppear {
                requestMyTagArr()
                requestLikePersonTagArr()
            }.modifier(LoadingView(isShowing: $computedModel.showLoading, bgColor: $computedModel.loadingBgColor))
                    
              
        }
        //.padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20))
    
    func requestMyTagArr(){
        NW.request(urlStr: "my/tag/list", method: .post, parameters: nil) { response in
            if let tags = response.data["tag"] as? [String]{
               tagArr = tags
            }
        } failedHandler: { response in
            
        }

    }
    
    func requestLikePersonTagArr(){
        NW.request(urlStr: "like/person/tag/list", method: .post, parameters: nil) { response in
            if let tags = response.data["tag"] as? [String]{
               tagOtherArr = tags
            }
        } failedHandler: { response in
            
        }

    }
    
    func requestSetUserInfo(){
        let mytag = selectTagArr.joined(separator: " ")
        let oterTag = selectTagOtherArr.joined(separator: ",")
        let param = ["nickName":nickName,
                     "gender":gender,
                     "birthday":birthDay,
                     "height":height,
                     "educationType":educationType,
                     "school":schoolName,
                     "job":job,
                     "yearIncome":yearIncome,
                     "workProvinceCode":workAddress.provinceId,
                     "workProvinceName":workAddress.provinceName,
                     "workCityCode":workAddress.cityId,
                     "workCityName":workAddress.cityName,
                     "workAreaCode":workAddress.areaId,
                     "workAreaName":workAddress.areaName,
                     "homeTownProvinceCode":homeTownAddress.provinceId,
                     "homeTownProvinceName":homeTownAddress.provinceName,
                     "homeTownCityCode":homeTownAddress.cityId,
                     "homeTownCityName":homeTownAddress.cityName,
                     "homeTownAreaCode":homeTownAddress.areaId,
                     "homeTownAreaName":homeTownAddress.areaName,
                     "loveGoals":loveGoal,
                     "acceptOtherPersonMinAge":minAge,
                     "acceptOtherPersonMaxAge":maxAge,
                     "aboutMeDesc":aboutUsDesc,
                     "myTag":mytag,
                     "likePersonTag":oterTag
        ] as [String : Any]
        computedModel.showLoading = true
        computedModel.loadingBgColor = .clear
        NW.request(urlStr: "set/user/info", method: .post, parameters: param) { response in
            computedModel.showLoading = false
            
            UserCenter.shared.requestUserInfo(needUserSig: true)
        } failedHandler: { response in
            computedModel.showLoading = false
            computedModel.showToast = true
            computedModel.toastMsg = response.message
        }
    }
       
    
}

//MARK: 实名认证
struct RealNameVerifyView:View{
    @Binding var name : String
    @Binding var id : String
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("最后，实名认证")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("为了保障您的交友安全，请完成实名认证。\n认证后即可匹配其他实名认证用户 。")
                .font(.system(size: 14))
            TextField("请输入姓名", text: $name)
                .padding()
                .frame(height:45)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
            TextField("请输入身份证号", text: $id)
                .padding()
                .frame(height:45)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
            Spacer().frame(height:20)
            NextStepButton(title: "认证并完成注册") {
                
            }
            Spacer()
        }
    }
}


//MARK: 选择标签
struct PersonTagView:View{
    @Binding var scrollIndex : Int
    var index : Int
    @Binding var tagArr : [String]
    @Binding var selectTagArr : [String]
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var title : String
    var nextHandle : ()->Void
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text(title)
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("最少3个，牵手会自动帮你生成自我介绍")
                .font(.system(size: 16))
            ScrollView(.vertical,showsIndicators: false){
                VStack(alignment: .leading, spacing: 20){
                    ForEach(0..<tagArr.count,id:\.self){ index in
                        if index % 2 == 1{
                            EmptyView()
                        }else{
                            HStack(alignment: .top, spacing: 10){
                                ForEach(index...index+1,id:\.self){ tagIndex in
                                    if tagIndex < tagArr.count {
                                        let tag = tagArr[tagIndex]
                                        Text(tag).font(.system(size: 13)).foregroundColor(selectTagArr.contains(tag) ? Color.red:Color.black).lineLimit(1).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3"))).onTapGesture {
                                            if selectTagArr.contains(tag) {
                                                selectTagArr.removeAll(where: {$0 == tag})
                                            }else{
                                                selectTagArr.append(tag)
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
                
            BackBtnMergeNextBtnView(nextStepHandle: {
                if selectTagArr.count  < 3 {
                    showToast = true
                    toastMsg = "请选择至少3个标签"
                    return
                }
                nextHandle()
                if index == 1 {
                    return
                }
                scrollIndex = 10 + index
            }, backSepHandle: {
                scrollIndex = 8 + index
            })
            Spacer().frame(height:50)
        }.toast(isShow: $showToast, msg: toastMsg)
    }
    
}

struct AboutUsDescView:View{
    @Binding var scrollIndex : Int
    @Binding var aboutUsDesc : String
    @State var showPlaceHolder : Bool = true
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("关于我")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("说说你是什么样的人?")
                .font(.system(size: 16, weight: .medium, design: .default))
            ZStack(alignment:.topLeading){
                TextEditor(text: $aboutUsDesc).foregroundColor(.black).lineSpacing(5)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).frame(height:200).introspectTextView { textView in
                        textView.backgroundColor = .colorWithHexString(hex: "#F3F3F3")
                    }.onChange(of: aboutUsDesc) { newValue in
                        if newValue.count == 0 {
                            showPlaceHolder = true
                        }else{
                            showPlaceHolder = false
                        }
                    }
                if showPlaceHolder {
                    Text("请输入至少10字").font(.system(size:15)).foregroundColor(.colorWithHexString(hex: "#999999")).padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0))
                }
            }
            Text("示例：我是典型的白羊座，性格热情开朗喜欢认识新朋友，也比较喜欢小动物，偶尔多愁善感，容易对一些细节感动。")
                .font(.system(size: 14))
                .foregroundColor(.colorWithHexString(hex: "#918FC1"))
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F1F1FE")))
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                if aboutUsDesc.isEmpty{
                    showToast = true
                    toastMsg = "请输入关于我的描述"
                    return
                }
                if aboutUsDesc.count < 10 {
                    showToast = true
                    toastMsg = "最少10个字符"
                    return
                }
                scrollIndex = 9
            }, backSepHandle: {
                scrollIndex = 7
            })
            Spacer().frame(height:50)
            
        }.ignoresSafeArea(.keyboard, edges: .bottom).onTapGesture {
            hidenKeyBoard()
        }.toast(isShow: $showToast, msg: toastMsg)
    }
}

class LifeModel:Identifiable{
    var int : UUID = UUID()
    var title : String = ""
    var image : UIImage?
    init(title:String,image:UIImage? = nil){
        self.title = title
        self.image = image
    }
}

//MARK: 我的生活
struct MyLifeView:View{
    @Binding var scrollIndex : Int
    @EnvironmentObject var computedModel : MyComputedProperty
    @State var isPresentLife : Bool = false
    @State var pickerLifeResult : [UIImage] = []
    
    @State var isPresentInterest : Bool = false
    @State var pickerInterestResult : [UIImage] = []
    
    @State var isPresentTravel : Bool = false
    @State var pickerTravelResult : [UIImage] = []
    
    @State var isPresentOther : Bool = false
    @State var pickerOtherResult : [UIImage] = []
    
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var config : PHPickerConfiguration{
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 6
        return config
    }
    @State var  titles : [LifeModel] = [
        LifeModel.init(title: "生活照", image: nil),
        LifeModel.init(title: "兴趣照", image: nil),
        LifeModel.init(title: "旅行照", image: nil),
        LifeModel.init(title: "其他", image: nil),
    ]
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我的生活")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("选几张照片来展示生活中的我，\n照片越丰富，就越容易收到喜欢～")
                .font(.system(size: 13))
            ScrollView(.vertical,showsIndicators: false){
            let items = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
            
            LazyVGrid(columns: items,spacing: 10) {
                ForEach(titles,id:\.id){ model in
                    if model.image == nil {
                        Button {
                            if model.title == "生活照" {
                                isPresentLife = true
                            }else if model.title == "兴趣照" {
                                isPresentInterest = true
                            }else if model.title == "旅行照" {
                                isPresentTravel = true
                            }else if model.title == "其他"{
                                isPresentOther = true
                            }
                          
                        } label: {
                            VStack(alignment: .center, spacing: 10){
                                Image("add_photo").resizable().aspectRatio( contentMode: .fit)
                                    .frame(width: 48, height: 48, alignment: .leading)
                                if model.title.count > 0 {
                                    Text(model.title)
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                }
                            }
                        }.contentShape(Rectangle()).frame(maxWidth:.infinity,minHeight: 150,maxHeight: 150, alignment: .center).background(RoundedRectangle(cornerRadius: 10).strokeBorder(.red,style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [4,4], dashPhase: 2)))
                            .background((Color.colorWithHexString(hex: "#FFF9F9")))
                    }else{
                        Image(uiImage:  model.image! ).resizable().aspectRatio( contentMode: .fill)
                            .frame(maxWidth:.infinity,minHeight: 150, maxHeight: 150,alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                   
                    
                }
            }.sheet(isPresented:$isPresentLife) {
                CustomPhotoPicker(configuration: config, pickerResult: $pickerLifeResult, isPresented: $isPresentLife)
            }.sheet(isPresented:$isPresentInterest) {
                CustomPhotoPicker(configuration: config, pickerResult: $pickerInterestResult, isPresented: $isPresentInterest)
            }.sheet(isPresented:$isPresentTravel) {
                CustomPhotoPicker(configuration: config, pickerResult: $pickerTravelResult, isPresented: $isPresentTravel)
            }.sheet(isPresented:$isPresentOther) {
                CustomPhotoPicker(configuration: config, pickerResult: $pickerOtherResult, isPresented: $isPresentOther)
            }
                
        }
//            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                if pickerLifeResult.count == 0 && pickerInterestResult.count == 0 && pickerTravelResult.count == 0 && pickerOtherResult.count == 0 {
                    showToast = true
                    toastMsg = "请添加图片展示自己"
                    return
                }
                
                uploadPhotos()
               
            }, backSepHandle: {
                scrollIndex = 6
            })
            Spacer().frame(height:50)

        }.onAppear {
           
         
        }.onChange(of: pickerLifeResult) { newValue in
            changeTitles()
        }.onChange(of: pickerInterestResult) { newValue in
            changeTitles()
        }.onChange(of: pickerTravelResult) { newValue in
            changeTitles()
        }.onChange(of: pickerOtherResult) { newValue in
            changeTitles()
        }.toast(isShow: $showToast, msg: toastMsg)
    }
    
    func uploadPhotos(){
        var requestArr : [BaseRequest] = []
        if pickerLifeResult.count > 0 {
            let baseLife = BaseRequest()
            baseLife.url = "upload/photos"
            baseLife.uploadImageParams = ["scenes":"life"]
            baseLife.uploadImages = pickerLifeResult
            requestArr.append(baseLife)
        }
      
        if pickerInterestResult.count > 0 {
            let baseInterest = BaseRequest()
            baseInterest.url = "upload/photos"
            baseInterest.uploadImageParams = ["scenes":"interest"]
            baseInterest.uploadImages = pickerInterestResult
            requestArr.append(baseInterest)
        }
        
        if pickerTravelResult.count > 0 {
            let baseTravel = BaseRequest()
            baseTravel.url = "upload/photos"
            baseTravel.uploadImageParams = ["scenes":"travel"]
            baseTravel.uploadImages = pickerTravelResult
            requestArr.append(baseTravel)
        }
      
        if pickerOtherResult.count > 0 {
            let baseOther = BaseRequest()
            baseOther.url = "upload/photos"
            baseOther.uploadImageParams = ["scenes":"other"]
            baseOther.uploadImages = pickerOtherResult
            requestArr.append(baseOther)
        }
      
        let batchRequest = BatchRequest(requestArray: requestArr)
        computedModel.showLoading = true
        computedModel.loadingBgColor = .clear
        batchRequest.uploadingImage { response in
            computedModel.showLoading = false
            scrollIndex = 8
        } failedHandler: { response in
            computedModel.showLoading = false
            computedModel.showToast = true
            computedModel.toastMsg = response.message
        }

    }
    
    
    func changeTitles(){
        titles.removeAll()
        if pickerLifeResult.count > 0 {
            for item in pickerLifeResult {
                let model = LifeModel(title: "生活照", image: item)
                titles.append(model)
            }
        }else{
            let model = LifeModel(title: "生活照", image: nil)
            titles.append(model)
        }
        
        if pickerInterestResult.count > 0 {
            for item in pickerInterestResult {
                let model = LifeModel(title: "兴趣照", image: item)
                titles.append(model)
            }
        }else{
            let model = LifeModel(title: "兴趣照", image: nil)
            titles.append(model)
        }
        
        if pickerTravelResult.count > 0 {
            for item in pickerTravelResult {
                let model = LifeModel(title: "旅行照", image: item)
                titles.append(model)
            }
        }else{
            let model = LifeModel(title: "旅行照", image: nil)
            titles.append(model)
        }
        
        if pickerOtherResult.count > 0 {
            for item in pickerOtherResult {
                let model = LifeModel(title: "其他", image: item)
                titles.append(model)
            }
        }else{
            let model = LifeModel(title: "其他", image: nil)
            titles.append(model)
        }
    }
}

struct MyAvatarView:View{
    @Binding var scrollIndex : Int
    @EnvironmentObject var computedModel : MyComputedProperty
    @State var isPresentPhotoAlbum : Bool = false
    @State var pickerResult: [UIImage] = []
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var config: PHPickerConfiguration  {
       var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images //videos, livePhotos...
        config.selectionLimit = 1 //0 => any, set 1-2-3 for har limit
        return config
    }
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我的头像")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("选张好看的照片做头像，记得露脸哦～")
                .font(.system(size: 13))
           
            if pickerResult.count > 0 {
                let uiImage = pickerResult.last!
                Image(uiImage: uiImage).resizable().aspectRatio( contentMode: .fill).background(Color.colorWithHexString(hex: "#FFF9F9"))
                    .frame(width: screenWidth - 40, height: screenWidth - 40, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)).onTapGesture {
                        isPresentPhotoAlbum = true
                    }
            }else{
                Button {
                    isPresentPhotoAlbum.toggle()
                } label: {
                    VStack(alignment: .center, spacing: 10){
                        Image("add_photo").resizable().aspectRatio( contentMode: .fit)
                            .frame(width: 48, height: 48, alignment: .leading)
                        Text("上传形象照")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                }.frame(width: screenWidth - 40, height: screenWidth - 40, alignment: .center).background(RoundedRectangle(cornerRadius: 10).strokeBorder(.red,style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [4,4], dashPhase: 2)))
                    .background((Color.colorWithHexString(hex: "#FFF9F9"))).contentShape(Rectangle())
            }

            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                if pickerResult.count == 0 {
                    showToast = true
                    toastMsg = "请添加头像图片"
                    return
                }
                upLoadAvatar()
              
            }, backSepHandle: {
                scrollIndex = 5
            })
            Spacer().frame(height:50)
        }.sheet(isPresented: $isPresentPhotoAlbum) {
            
        } content: {
            CustomPhotoPicker(configuration: config, pickerResult: $pickerResult, isPresented: $isPresentPhotoAlbum)
        }.toast(isShow: $showToast, msg: toastMsg)
    }
    
    func upLoadAvatar(){
        computedModel.showLoading = true
        computedModel.loadingBgColor = .clear
        NW.uploadingImage(urlStr: "upload/photos", params: ["scenes":"avatar"], images:[pickerResult.last!]) { response in
            computedModel.showLoading = false
            scrollIndex = 7
        } failedHandler: { response in
            computedModel.showLoading = false
            computedModel.showToast = true
            computedModel.toastMsg = response.message
        }

    }
}

struct LoveGoalView:View{
    @Binding var scrollIndex : Int
    @Binding var loveGoal : Int
    @Binding var minAge : Int
    @Binding var maxAge : Int
    @State var minAgeStr : String = "最小年龄"
    @State var maxAgeStr : String = "最大年龄"
    @State var selectedIndex : Int = 0
    @State var showMinAgePicker : Bool = false
    @State var showMaxAgePicker : Bool = false
    var titles : [String] = ["短期内想结婚","认真谈场恋爱，合适就考虑结婚","先认真谈场恋爱再说","没考虑清楚"]
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("关于恋爱")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("我的恋爱目标")
                .font(.system(size: 16, weight: .medium, design: .default))
            ForEach(0..<titles.count,id:\.self){ index in
                let title = titles[index]
                Text(title)
                    .font(selectedIndex == index + 1 ? .system(size: 15, weight: .medium, design: .default):.system(size: 15)).frame(width:screenWidth - 40,height:45,alignment:.leading).padding(.leading,15)
                    .foregroundColor(selectedIndex == index + 1 ? .red : .black)
                    .background(RoundedRectangle(cornerRadius: 5).strokeBorder(selectedIndex == index + 1 ? .red : .gray,style: .init(lineWidth: selectedIndex == index + 1 ? 2 : 1, lineCap: .round, lineJoin: .round))).contentShape(Rectangle()).onTapGesture {
                        selectedIndex = index + 1
                        loveGoal = selectedIndex - 1
                    }
            }
            
            Text("接受对方的年龄")
                .font(.system(size: 16, weight: .medium, design: .default))
            HStack(alignment: .center, spacing: 10){
                PullDownButton(title:$minAgeStr) { chose in
                    showMinAgePicker = true
                }
                Text("—")
                    .foregroundColor(.gray)
                PullDownButton(title:$maxAgeStr) { chose in
                    showMaxAgePicker = true
                }
            }
            
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                if selectedIndex == 0 {
                    showToast = true
                    toastMsg = "请选择我的恋爱目标"
                    return
                }
                if minAgeStr == "最小年龄"{
                    showToast = true
                    toastMsg = "请选择最小年龄"
                    return
                }
                
                if maxAgeStr == "最大年龄"{
                    showToast = true
                    toastMsg = "请选择最大年龄"
                    return
                }
                
                if minAge > maxAge{
                    showToast = true
                    toastMsg = "最小年龄不应大于最大年龄，请重新选择"
                    return
                }
                
                
                scrollIndex = 6
            }, backSepHandle: {
                scrollIndex = 4
            })
            Spacer().frame(height:50)
        }.alertB(isPresented: $showMinAgePicker) {
            CustomPicker(show: $showMinAgePicker, selection: $minAge, contentArr: ageArr()) { selectedIndex in
                let ageArr = ageArr()
                minAgeStr = ageArr[selectedIndex]
                let str = minAgeStr.replacingOccurrences(of: "岁", with: "")
                minAge = Int(str) ?? 0
            }
        }.alertB(isPresented: $showMaxAgePicker) {
            CustomPicker(show: $showMaxAgePicker, selection: $maxAge, contentArr: ageArr()) { selectedIndex in
                let ageArr = ageArr()
                maxAgeStr = ageArr[selectedIndex]
                let str = maxAgeStr.replacingOccurrences(of: "岁", with: "")
                maxAge = Int(str) ?? 0
            }
        }.toast(isShow: $showToast, msg: toastMsg)
    }
    
    func ageArr() -> [String]{
        var tempArr : [String] = []
        for index in 18...70{
            tempArr.append("\(index)岁")
        }
        return tempArr
    }
}

class MyAddressModel:ObservableObject{
   @Published  var provinceId : Int = 0
   @Published  var provinceName : String = ""
   @Published  var cityId : Int = 0
   @Published  var cityName : String = ""
   @Published  var areaId : Int = 0
   @Published  var areaName : String = ""
}

//MARK: 工作居住地 我的家乡
struct MyCityAndHomeTownView:View{
    @Binding var scrollIndex : Int
    @Binding var workAddress : MyAddressModel
    @Binding var homeTownAddress : MyAddressModel
    @State var isShowWorkCity : Bool = false
    @State var isShowHomeTown : Bool = false
    @State var workAddressStr : String = "请选择"
    @State var homeTownAddressStr : String = "请选择"
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我在哪里")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("工作居住地")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton(title:$workAddressStr,choseHandle: { chose in
                isShowWorkCity = true
            }).frame(height:45)
            
            Text("我的家乡")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton(title:$homeTownAddressStr,choseHandle: { chose in
                isShowHomeTown = true
            }).frame(height:45)
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                if workAddressStr == "请选择" {
                    showToast = true
                    toastMsg = "请选择工作居住地"
                    return
                }
                if homeTownAddressStr == "请选择" {
                    showToast = true
                    toastMsg = "请选择家乡地址"
                    return
                }
                scrollIndex = 5
            }, backSepHandle: {
                scrollIndex = 3
            })
            Spacer().frame(height:50)
            
        }.alertB(isPresented: $isShowWorkCity) {
            AddressView(show: $isShowWorkCity) { addressModel in
                workAddress = addressModel
                workAddressStr = addressModel.provinceName + " " + addressModel.cityName
            }

        }
            .alertB(isPresented: $isShowHomeTown) {
                AddressView(show: $isShowHomeTown) { addressModel in
                    homeTownAddress = addressModel
                    homeTownAddressStr = addressModel.provinceName + " " + addressModel.cityName
                }
            }.toast(isShow: $showToast, msg: toastMsg)
    }
        
}

struct MyJobView:View{
    @Binding var scrollIndex : Int
    @Binding var job : String
    @Binding var yearIncome : Int
    @State var showJobList : Bool = false
    @State var showYearIncomePicker : Bool = false
    @State var yearIncomeStr : String = "请选择"
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
        
            VStack(alignment: .leading, spacing: 20) {
                HStack{
                    Text("我的工作")
                        .font(.system(size: 22, weight: .medium, design: .default))
                    Spacer()
                }
                Text("职业")
                    .font(.system(size: 16, weight: .medium, design: .default))
                
                TextField("请输入职业", text: $job,onEditingChanged: { focuse in
                    showJobList = focuse
                    if !focuse {
                        hidenKeyBoard()
                    }
                }).font(.system(size: 15, weight: .medium, design: .default)).frame(height:45).padding(.leading,10).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).accentColor(textFieldAccentColor)
                if showJobList {
                    ScrollView(.vertical, showsIndicators: false) {
                        let jobs = LocalData.shared.searchProfessionName(name: job)
                        VStack(alignment: .leading, spacing: 0){
                            ForEach(jobs,id:\.self){ profession in
                                HStack{
                                    Text(profession).font(.system(size: 15)).padding().frame(height:40)
                                    Spacer()
                                }.contentShape(Rectangle()).onTapGesture {
                                    showJobList = false
                                    job = profession
                                    hidenKeyBoard()
                                }
                            }
                        }.background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
                    }.frame(maxWidth:.infinity,maxHeight: .infinity).background(Color.white)
                }
                
                
                Text("年收入")
                    .font(.system(size: 16, weight: .medium, design: .default))
                PullDownButton(title:$yearIncomeStr,choseHandle: { chose in
                    showYearIncomePicker = true
                }).frame(height:45)
                Spacer()
                BackBtnMergeNextBtnView(nextStepHandle: {
                    if job.isEmpty {
                        showToast = true
                        toastMsg = "请输入职业"
                        return
                    }
                    if yearIncomeStr == "请选择"{
                        showToast = true
                        toastMsg = "请选择年收入"
                        return
                    }
                    scrollIndex = 4
                }, backSepHandle: {
                    scrollIndex = 2
                })
                Spacer().frame(height:50)
                
            }.ignoresSafeArea(.keyboard, edges: .bottom).onTapGesture {
                hidenKeyBoard()
            }.alertB(isPresented: $showYearIncomePicker) {
                CustomPicker(show: $showYearIncomePicker, selection: $yearIncome, contentArr:getYearIncomeArr() ) { selectedIndex in
                    let incomeArr = getYearIncomeArr()
                    yearIncomeStr = incomeArr[selectedIndex]
                }
            }.toast(isShow: $showToast, msg: toastMsg)
            
        
    }
    
    func getYearIncomeArr() -> [String]{
        return ["100万以上","60-100万","30-60万","20-30万","10-20万","5-10万","5万以下"].reversed()
      
    }
}

//MARK: 教育信息
struct EducationInfoView:View{
    @Binding var scrollIndex : Int
    @Binding var educationType : Int
    @Binding var schoolName : String
    @State var showPicker : Bool = false
    let educationArr : [String] = ["博士","硕士","本科"," 专科","专科以下"].reversed()
    @State var educationStr : String = "请选择"
    @State var showSchoolNameList : Bool = false
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
        
            VStack(alignment: .leading, spacing: 20) {
                HStack{
                    Text("教育信息")
                        .font(.system(size: 22, weight: .medium, design: .default))
                    Spacer()
                }
                Text("学历")
                    .font(.system(size: 16, weight: .medium, design: .default))
                PullDownButton(title:$educationStr,choseHandle: { chose in
                    showPicker = true
                }).frame(height:45)
                
                Text("学校")
                    .font(.system(size: 16, weight: .medium, design: .default))
                TextField("请输入学校名称", text: $schoolName,onEditingChanged: { focuse in
                    showSchoolNameList = focuse
                    if !focuse {
                        hidenKeyBoard()
                    }
                }).font(.system(size: 15, weight: .medium, design: .default)).frame(height:45).padding(.leading,10).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).accentColor(textFieldAccentColor)
                if showSchoolNameList {
                    ScrollView(.vertical, showsIndicators: false) {
                        let schoolNames = LocalData.shared.searchSchooName(name: schoolName)
                        VStack(alignment: .leading, spacing: 0){
                            ForEach(schoolNames,id:\.self){ school in
                                HStack{
                                    Text(school).font(.system(size: 15)).padding().frame(height:40)
                                  Spacer()
                                }.contentShape(Rectangle()).onTapGesture {
                                    showSchoolNameList = false
                                    schoolName = school
                                    hidenKeyBoard()
                                }
                            }
                        }.background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
                    }.frame(maxWidth:.infinity)
                }
                Spacer()
                BackBtnMergeNextBtnView(nextStepHandle: {
                    if educationStr == "请选择" {
                        showToast = true
                        toastMsg = "请选择学历"
                        return
                    }
                    if educationType > 0 && schoolName.count == 0 {
                        showToast = true
                        toastMsg = "请输入学校名称"
                        return
                    }
                    scrollIndex = 3
                }, backSepHandle: {
                    scrollIndex = 1
                })
                Spacer().frame(height:50)
            }.ignoresSafeArea(.keyboard, edges: .bottom).onTapGesture {
            hidenKeyBoard()
            }.alertB(isPresented:$showPicker) {
                CustomPicker(show: $showPicker, selection: $educationType, contentArr: educationArr) { selectedIndex in
                    educationStr = educationArr[selectedIndex]
                }
            }.toast(isShow: $showToast, msg: toastMsg)
    }
}

struct PullDownButton:View{
    @Binding var title : String
    var choseHandle : (_ chose:String) ->Void
    var body: some View{
        Button {
            choseHandle(title)
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.gray).padding(.leading,10)
            Spacer()
            Image("pull_down_indicator").resizable().aspectRatio( contentMode: .fit).frame(width: 20, height: 20, alignment: .leading)
            Spacer().frame(width:10)
        }.frame(height:45).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))

    }
}

//MARK: 昵称UI
struct NickNameView:View{
    @Binding var nickName : String
    @Binding var scrollIndex : Int
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
//        ScrollView(.vertical,showsIndicators: false){
       
            VStack(alignment: .leading, spacing: 20) {
                Text("首先，给自己起个好听的名字吧")
                    .font(.system(size: 22, weight: .medium, design: .default))
                TextField.init("输入昵称", text: $nickName).padding().background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).accentColor(textFieldAccentColor).onChange(of: nickName) { newValue in
                    nickName = newValue.trimmingCharacters(in: .whitespaces)
                }
                Spacer()
                NextStepButton(title: "下一步", completion: {
                    if nickName.count  == 0 {
                        showToast = true
                        toastMsg = "请输入昵称"
                        return
                    }
                    scrollIndex = 1
                }).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                Spacer().frame(height:50)

            }.contentShape(Rectangle()).toast(isShow: $showToast, msg: toastMsg).onTapGesture {
                hidenKeyBoard()
            }
           
        
        
        
    }
}

// MARK: 性别 生日 身高 UI
struct GenderAgeHeightView:View{
    @Binding var scrollIndex: Int
    @Binding var gender: Int
    @Binding var birthDay: Double
    @Binding var height: Int
    @State var isShowDatePicker : Bool = false
    @State var isShowHeightPicker : Bool = false
    @State var birthDayDate : Date? = nil
    @State var birthDayStr : String = "请选择出生时间"
    @State var heightStr : String = "请选择身高"
    @State var heightSelection : Int = 0
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View{
        
            VStack(alignment: .leading, spacing: 20) {
                HStack{
                    Text("基本信息")
                        .font(.system(size: 22, weight: .medium, design: .default))
                    Text("*性别、生日完成注册后不可修改")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
                
                Text("性别")
                    .font(.system(size: 16, weight: .medium, design: .default))
                GenderView(gender: $gender)
                
                BirthdayOrHeightView(title: "生日", content: $birthDayStr) { choseStr in
                    isShowDatePicker = true
                }
                BirthdayOrHeightView(title: "身高", content: $heightStr) { choseStr in
                    isShowHeightPicker = true
                }
                
                Spacer()
                BackBtnMergeNextBtnView {
                    if gender > 1 {
                        showToast = true
                        toastMsg = "请选择性别"
                        return
                    }
                    if birthDayDate == nil {
                        showToast = true
                        toastMsg = "请选择出生时间"
                        return
                    }
                    
                    if heightStr == "请选择身高" {
                        showToast = true
                        toastMsg = "请选择身高"
                        return
                    }
                    
                    scrollIndex = 2
                } backSepHandle: {
                    scrollIndex = 0
                }
                
                Spacer().frame(height:50)
            }.alertB(isPresented:$isShowDatePicker , builder: {
                let minDate = Date().addYear(year: -70)
                let maxDate = Date().addYear(year: -18)
                CustomDatePicker(show:$isShowDatePicker,date: maxDate, selectionDate: $birthDayDate, minDate: minDate, maxDate: maxDate, displayedComponents: [.date]) { seletedDate in
                    birthDay = seletedDate.timeIntervalSince1970
                    birthDayStr = birthDayDate?.stringFormat(format: "yyyy年M月d日") ?? ""
                }
            })
            .alertB(isPresented: $isShowHeightPicker) {
                CustomPicker(show: $isShowHeightPicker, selection: $heightSelection, contentArr: getHeightArr()) { selectedIndex in
                    let tempArr = getHeightArr()
                    heightStr = tempArr[selectedIndex]
                    let str = heightStr.replacingOccurrences(of: "cm", with: "")
                    height = Int(str) ?? 0
                }
            }.toast(isShow: $showToast, msg: toastMsg)
            

        
    }
    
    func getHeightArr() -> [String]{
        var tempArr : [String] = []
        for height in 140...210 {
            let str = "\(height)cm"
            tempArr.append(str)
        }
        return tempArr
    }
}

struct BackBtnMergeNextBtnView:View{
    var nextStepHandle : (() -> Void)
    var backSepHandle  : (() -> Void)
    var body: some View{
        HStack(alignment: .center, spacing: 10){
            Button {
                hidenKeyBoard()
                backSepHandle()
            } label: {
                Image("back_btn").resizable().aspectRatio( contentMode: .fill).frame(width: 30, height: 30, alignment: .leading)
            }.frame(width: 40, height: 40, alignment: .center).background(Circle().stroke(.gray,lineWidth: 1))

            NextStepButton(title: "下一步", completion: {
                nextStepHandle()
            })
        }
    }
}

//MARK: 生日、 身高UI
struct BirthdayOrHeightView:View{
    var title : String
    @Binding var content:String
    var choseHandle : (_ choseStr:String) ->Void
    var body: some View{
        HStack(alignment: .center, spacing: 40){
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.black)
            Button {
                choseHandle(title)
            } label: {
                HStack(alignment: .center, spacing: 10){
                    Spacer()
                    Text(content)
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.gray)
                    Image("7x14right").resizable().aspectRatio( contentMode: .fill)
                        .frame(width: 7, height: 14, alignment: .leading)
//                        Spacer()
                }
        }.padding()
        }.padding(.leading,20).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
    }
}

struct GenderView:View{
    @Binding var gender : Int
    @State   var selectedIndex : Int = 0
    var genders : [String] = ["男","女"]
    var body: some View{
        GeometryReader { reader in
            let width = reader.size.width
            HStack(alignment: .top, spacing: 10) {
                ForEach(0..<2){ index in
                    let genderStr = genders[index]
                    ZStack(alignment: .leading) {
                        Image("").resizable().frame(width:(width - 10) / 2.0,height:70).background(RoundedRectangle(cornerRadius: 5).fill(selectedIndex == index + 1 ? btnLRLineGradient : LinearGradient(colors: [Color.colorWithHexString(hex: "#F3F3F3")], startPoint: .leading, endPoint: .trailing)))
                        HStack{
                            Text(genderStr)
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(selectedIndex == index + 1 ? Color.white : Color.gray)
                            Spacer()
                        }.padding(.leading,20)
                    }.onTapGesture {
                        selectedIndex = index + 1
                        gender = (selectedIndex - 1 == 0) ? 1 : 0
                    }
                }
            }
        }.frame(height:70)
    }
}

struct NextStepButton:View{
    var title : String
    var completion : (() -> Void)
    var body: some View{
        Button {
            hidenKeyBoard()
            completion()
        } label: {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium, design: .default)).frame(maxWidth:.infinity,minHeight: 45).background(Capsule().fill(btnLRLineGradient))
        }.buttonStyle(PlainButtonStyle())

    }
}

struct EnterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EnterInfoView()
    }
}
