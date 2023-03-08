//
//  AddressView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/8.
//

import SwiftUI

struct AddressView: View {
    var addressArr : [AddressModel] = LocalData.shared.readProvinceAndCityData()
    @State var cityArr : [CityModel] = []
    @State var areaArr : [AreaModel] = []
    @State var selectedIndex : Int = 0
    @State var provinceName : String = ""
    @State var cityName : String = ""
    @State var areaId : Int = 0
    var body: some View {
       
        ScrollView(.horizontal,showsIndicators: false){
            ScrollViewReader { reader in
                LazyHStack(alignment: .top, spacing: 0){
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height:20)
                        HStack{
                            Text("选择省份/地区")
                                .font(.system(size:20,weight:.medium))
                                
                        }.padding(.leading,20)
                     
                                            
                        List{
                            ForEach(addressArr,id:\.id){ model in
                                Text(model.name).font(.system(size:15)).foregroundColor(provinceName == model.name ? .red : .black).frame(maxWidth:.infinity,maxHeight:40,alignment:.leading).listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)).contentShape(Rectangle()).onTapGesture {
                                    provinceName = model.name
                                    cityArr = model.citys
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        reader.scrollTo(1, anchor: .top)
                                    }
                                    
                                }
                            }
                        }.listStyle(.plain).frame(width:screenWidth)
                    }.id(0)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height:20)
                        HStack{
                            Text(provinceName).font(.system(size:16)).padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3")))
                        }.padding(.leading,20)
                        List{
                            ForEach(cityArr,id:\.id){ model in
                                Text(model.name).font(.system(size:15)).foregroundColor(cityName == model.name ? .red : .black).frame(maxWidth:.infinity,maxHeight:40,alignment:.leading).listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)).contentShape(Rectangle()).onTapGesture {
                                    cityName = model.name
                                    areaArr = model.areas
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        reader.scrollTo(2, anchor: .top)
                                    }
                                    
                                }
                            }
                        }.listStyle(.plain).frame(width:screenWidth)
                    }.id(1)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height:20)
                        HStack(alignment:.top,spacing:10){
                            Text(provinceName).font(.system(size:16)).padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3")))
                            
                            Text(cityName).font(.system(size:16)).padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3")))
                        }.padding(.leading,20)
                        
                    List{
                        ForEach(areaArr,id:\.id){ model in
                            Text(model.name).font(.system(size:15)).foregroundColor(areaId == model.id ? .red : .black)
                                .frame(maxWidth:.infinity,maxHeight:40,alignment:.leading).listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)).contentShape(Rectangle()).onTapGesture {
                                areaId = model.id
                            }
                        }
                    }.listStyle(.plain).frame(width:screenWidth)
                }.id(2)
                    
                }
            }
        }.frame(width:screenWidth,height:350,alignment: .leading).background(RoundedRectangle(cornerRadius: 10).fill(Color.white)).introspectScrollView { sc in
            sc.isPagingEnabled = true
        }

        
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView()
    }
}
