//
//  CreateDynamicCircleView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/23.
//

import SwiftUI
import PhotosUI
import JFHeroBrowser

struct CreateDynamicCircleView: View {
    @Binding var show : Bool
    @State var showAnimation : Bool = false
    @State var comment : String = ""
    @State var showPlacHolder : Bool = true
    @State var isPresentPhotoAlbum : Bool = false
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    @State var pickerResult : [UIImage] = []
    @State var config: PHPickerConfiguration =  PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    @State var deletePhoto : Bool = false
   
    @StateObject var computedModel : MyComputedProperty = MyComputedProperty()
    var body: some View {
     if show {
        
        ScrollView(.vertical,showsIndicators: false){
        LazyVStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 0) {
                Button {
                    showAnimation = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        show = false
                        self.topViewController()?.dismiss(animated: false, completion: nil)
                    }
                } label: {
                    HStack{
                        Text("取消")
                            .font(.system(size: 15))
                            .foregroundColor(.colorWithHexString(hex: "#999999")).padding(10)
                    }.padding(.leading,10)
                }.buttonStyle(PlainButtonStyle()).foregroundColor(.red)
                
                Spacer()
                
                Button {
                    comment = comment.trimmingCharacters(in: .whitespaces)
                    if comment.isEmpty {
                        computedModel.showToast = true
                        computedModel.toastMsg = "请输入文字"
                        return
                    }
                    requestCreateCircle()
                } label: {
                    HStack{
                        Text("发表")
                            .font(.system(size: 15,weight: .medium))
                            .foregroundColor( .white).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)).background(Capsule().fill(comment.isEmpty ? Color.colorWithHexString(hex: "#999999") : Color.green))
                    }.padding(.trailing,20)
                }.buttonStyle(PlainButtonStyle()).foregroundColor(.red)

            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $comment).frame(maxWidth:.infinity,minHeight: 100,maxHeight: 200).background(Color.red).lineSpacing(5).onChange(of: comment) { newValue in
                    showPlacHolder = newValue.isEmpty
                }
                if showPlacHolder {
                    Text("这一刻的想法...")
                        .font(.system(size: 15))
                        .foregroundColor(.colorWithHexString(hex: "#999999")).padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 10))
                }
               
            }.padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: (screenWidth - 40 - 10) / 3,maximum: (screenWidth - 40 - 10) / 3),spacing:5)],alignment: .leading,spacing: 5) {
                ForEach(0..<pickerResult.count,id:\.self){ index in
                    let image = pickerResult[index]
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio( contentMode: .fill)
                            .frame(width: (screenWidth - 40 - 10) / 3, height: (screenWidth - 40 - 10) / 3, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 10)).onTapGesture {
                                var list: [HeroBrowserLocalImageViewModule] = []
                                for i in 0..<pickerResult.count {
                                    let pickerImage = pickerResult[i]
                                    list.append(HeroBrowserLocalImageViewModule(image: pickerImage))
                                }
                                self.topViewController()?.hero.browserPhoto(viewModules: list, initIndex: index)
                            }
                        Button {
                            pickerResult.remove(at: index)
                        } label: {
                            Image("delete")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25, alignment: .center).padding(EdgeInsets(top: 2, leading: 5, bottom: 5, trailing: 2))
                        }
                       
                    }
                }
                
                if pickerResult.count < 9{
                    Button {
                        config.filter = .images //videos, livePhotos...
                        config.selectionLimit = 9 -  pickerResult.count
                        isPresentPhotoAlbum = true
                    } label: {
                        Image("add_photo")
                            .resizable()
                            .aspectRatio( contentMode: .fit)
                            .frame(width: 48, height: 48, alignment: .center)
                    }.frame(width: (screenWidth - 40 - 10) / 3, height: (screenWidth - 40 - 10) / 3, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(.red,style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [4,4], dashPhase: 2)))
                        .background((Color.colorWithHexString(hex: "#FFF9F9")))
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                }
                
            }.frame(maxWidth:.infinity).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
           
            
            Spacer()

        }.sheet(isPresented:$isPresentPhotoAlbum) {
            
        } content: {
           
            CustomPhotoPicker(configuration: config, pickerResult: $pickerResult, isPresented: $isPresentPhotoAlbum)
        }.toast(isShow: $showToast, msg: toastMsg)
                

               
        }.offset(y:showAnimation ? 0 : screenHeight).animation(.linear(duration: 0.25), value: showAnimation).onAppear {
            showAnimation = true
        }.background(Color.white)
             .modifier(LoadingView(isShowing: $computedModel.showLoading, bgColor: $computedModel.loadingBgColor))
             .toast(isShow: $computedModel.showToast, msg: computedModel.toastMsg)
         
     }
    }
    
    func requestCreateCircle(){
        var params   = ["content":comment]
        if pickerResult.count > 0 {
            params["scenes"] = "circle"
            var reqSucCount : Int = 0
            computedModel.showLoading = true
            var circleId : Int = 0
            for image in pickerResult{
                if circleId > 0{
                    params["circleId"] = "\(circleId)"
                }
                NW.uploadingImage(urlStr: "create/circle", params: params, image: image) { response in
                    reqSucCount += 1
                    circleId = response.data["circleId"] as? Int ?? 0
                    if reqSucCount == pickerResult.count {
                        computedModel.showLoading = false
                        showAnimation = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            show = false
                            self.topViewController()?.dismiss(animated: false, completion: nil)
                        }
                    }
                } failedHandler: { response in
                    computedModel.showLoading = false
                    computedModel.showToast = true
                    computedModel.toastMsg = response.message
                }

            }
        }else{
            NW.request(urlStr: "create/circle", method: .post, parameters: params) { response in
                computedModel.showLoading = false
                showAnimation = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    show = false
                    self.topViewController()?.dismiss(animated: false, completion: nil)
                }
            } failedHandler: { response in
                computedModel.showLoading = false
                computedModel.showToast = true
                computedModel.toastMsg = response.message
            }

        }
       

    }
}

//struct CreateDynamicCircleView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateDynamicCircleView()
//    }
//}
