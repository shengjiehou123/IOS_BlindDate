//
//  AddressView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/8.
//

import SwiftUI
import CoreAudio
import SDWebImageSwiftUI

struct AddressView: View {
    @Binding var show : Bool 
    @StateObject var addressModel : MyAddressModel = MyAddressModel()
    var addressArr : [AddressModel] = LocalData.shared.readProvinceAndCityData()
    @State var addressNameArr : [String] = []
    @State var cityNameArr : [String] = []
    @State var areaNameArr : [String] = []
    
    @State var cityArr : [CityModel] = []
    @State var areaArr : [AreaModel] = []
    @State var selectedIndex : Int = 0
   
    @State var showAddressList : Bool = false
    
    var completionHandle : (_ addressModel : MyAddressModel) ->Void
    
    var body: some View {
        if show {
            
            ZStack(alignment: .bottomLeading) {
                Color.black.opacity(0.3).frame(maxWidth:.infinity,maxHeight: .infinity).onTapGesture {
                    showAddressList = false
                    show = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.topViewController()?.dismiss(animated: true, completion: nil)
                    }
                }
                ScrollView(.horizontal,showsIndicators: false){
                    ScrollViewReader { reader in
                        LazyHStack(alignment: .top, spacing: 0){
                            AddressRow(titles:["选择省份/地区"],isFirstPage: true,addressArr: $addressNameArr) { selectedIndex in
                                let model = addressArr[selectedIndex]
                                addressModel.provinceId = model.id
                                addressModel.provinceName = model.name
                                cityArr = model.citys
                                areaArr.removeAll()
                                cityNameArr = getCityNameArr(cityArr: model.citys)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.linear(duration: 0.25)) {
                                        reader.scrollTo(101, anchor: .leading)
                                    }
                                }
                               
                                
                            }.frame(width:screenWidth).id(100)
                            
                            
                        if cityArr.count > 0 {
                            AddressRow(titles:[addressModel.provinceName],isFirstPage: false,addressArr: $cityNameArr) { selectedIndex in
                                let model = cityArr[selectedIndex]
                                addressModel.cityId = model.id
                                addressModel.cityName = model.name
                                areaArr = model.areas
                                areaNameArr = getAreaNameArr(areaArr:model.areas)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.linear(duration: 0.25)) {
                                        reader.scrollTo(102, anchor: .leading)
                                    }
                                }
                                
                            }.frame(width:screenWidth).id(101)
                        }
                            
                            
                        if areaArr.count > 0 {
                            AddressRow(titles:[addressModel.provinceName,addressModel.cityName],isFirstPage: false,addressArr: $areaNameArr) { selectedIndex in
                                let model = areaArr[selectedIndex]
                                addressModel.areaId = model.id
                                addressModel.areaName = model.name
                                completionHandle(addressModel)
                                show = false
                                showAddressList = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.topViewController()?.dismiss(animated: true, completion: nil)
                                }
                            }.frame(width:screenWidth).id(102)
                                
                        }
                            
                        }
                    }
                }.frame(width:screenWidth,height:350,alignment: .leading).background(RoundedCorner(corners:[.topLeft,.topRight],radius: 15).fill(Color.white)).offset(y:showAddressList ? 0 : 350).animation(.linear(duration: 0.25), value: showAddressList).onAppear(perform: {
                    showAddressList = true
                    addressNameArr = getAddressNameArr()
                }).introspectScrollView { sc in
                    sc.isPagingEnabled = true
                }
            }.edgesIgnoringSafeArea(.top)
        }else{
            EmptyView()
        }
    }
    
    func getAddressNameArr() -> [String]{
        var tempArr : [String] = []
        for model in addressArr {
            tempArr.append(model.name)
        }
        return tempArr
    }
    
    func getCityNameArr(cityArr:[CityModel]) -> [String]{
        var tempArr : [String] = []
        for model in cityArr {
            
            tempArr.append(model.name)
        }
        return tempArr
    }
    
    func getAreaNameArr(areaArr:[AreaModel]) -> [String]{
        var tempArr : [String] = []
        for model in areaArr {
            tempArr.append(model.name)
        }
        return tempArr
    }
}

struct RoundedCorner : Shape {
    var corners: UIRectCorner = .allCorners
    var radius: CGFloat = .infinity
    func path(in rect: CGRect) -> Path {
       let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
       return Path(path.cgPath)
   }
}

struct AddressRow:View{
    var titles : [String]
    var isFirstPage : Bool
    @Binding var addressArr : [String]
    @State var selectName : String = ""
    var selectedHandle:(_ selectedIndex : Int) ->Void
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            Spacer().frame(height:0)
            HStack(alignment: .top, spacing: 10){
                ForEach(titles,id:\.id){ title in
                    if isFirstPage {
                        Text(title)
                            .font(.system(size:20,weight:.medium))
                    }else{
                        Text(title).font(.system(size: 16)).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3")))
                    }
                }
               
            }.padding(.leading,20)
         
                                
            List{
                ForEach(0..<addressArr.count,id:\.self){ index in
                    let name = addressArr[index]
                    Text(name).font(.system(size:15)).foregroundColor(selectName == name ? .red : .black).frame(maxWidth:.infinity,maxHeight:40,alignment:.leading).listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)).contentShape(Rectangle()).onTapGesture {
                        selectName = name
                        selectedHandle(index)
//                        cityArr = model.citys
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            reader.scrollTo(1, anchor: .top)
//                        }
                        
                    }
                }
            }.listStyle(.plain).frame(width:screenWidth)
        }
        
    }
}


