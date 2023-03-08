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
    var body: some View {
       
        LazyHStack(alignment: .top, spacing: 0){
            List{
                ForEach(addressArr,id:\.id){ model in
                    Text(model.name).onTapGesture {
                       cityArr = model.citys
                       selectedIndex = 1
                    }
                }
            }.listStyle(.plain).frame(width:screenWidth).id(0)
            
            List{
                ForEach(cityArr,id:\.id){ model in
                    Text(model.name).onTapGesture {
                        areaArr = model.areas
                        selectedIndex = 2
                    }
                }
            }.listStyle(.plain).frame(width:screenWidth).id(1)
            
            List{
                ForEach(areaArr,id:\.id){ model in
                    Text(model.name).onTapGesture {

                    }
                }
            }.listStyle(.plain).frame(width:screenWidth).id(2)
            
        }.frame(width:screenWidth,height:350,alignment: .leading).offset(x: -screenWidth * CGFloat( selectedIndex))

        
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView()
    }
}
