//
//  RecommandList.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI

struct RecommandList: View {
    init(){
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .white
//        UIScrollView.appearance().bounces = false
    }
    @State var showToast : Bool = false
    @State var toastMsg : String = ""
    var body: some View {
//        Text("Hello, World!").onAppear {
////            requestRecommandList(state: .normal)
//        }
    NavigationView{
        ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .top) {
                VStack{
                    CardView(bgColor: .orange)
                    HomePageAboutUsView().padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
                }
                
            }.navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Text("推荐").font(.system(size: 30, weight: .medium, design: .default)))
                
        }
    }.navigationViewStyle(StackNavigationViewStyle()).toast(isShow: $showToast, msg: toastMsg).onAppear {
        requestRecommandList(state: .normal)
    }
            
        
    }
    
    func requestRecommandList(state:RefreshState){
        let param = ["page":1,"pageLimit":2]
        NW.request(urlStr: "recommended/list", method: .post, parameters: param) { response in
            print(response.data)
            showToast = true
            toastMsg = "suc"
        } failedHandler: { response in
            showToast = true
            toastMsg = "failed"
        }

    }
}

struct HomePageAboutUsView:View{
    var body: some View{
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 0) {
                Text("关于我")
                    .foregroundColor(.gray)
                    .font(.system(size: 17, weight: .medium, design: .default))
                Spacer()
            }
            Text("不知道说些什么哈哈哈哈哈哈哈哈哈哈不知道说些什么哈哈哈哈哈哈哈哈哈哈不知道说些什么哈哈哈哈哈哈哈哈哈哈不知道说些什么哈哈哈哈哈哈哈哈哈哈不知道说些什么哈哈哈哈哈哈哈哈哈哈").lineSpacing(5)
        }
        
    }
}

struct CardView:View{
    var bgColor : Color
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
           CardHeaderView(bgColor: bgColor)
            Spacer()
        }
    }
}

struct CardHeaderView:View{
    @State var titles = ["163cm","电商","搞笑女孩","搞笑女孩2","搞笑女孩3"]
    @State var sumWidth : CGFloat = 0
    @State var overParentWidthDic :[Int:[String]] = [:]
    @State var rows :[Int] = []
    var bgColor : Color
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0, content: {
                Circle().fill(Color.red).frame(width: 80, height: 80, alignment: .leading)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("昵称")
                            .foregroundColor(.white)
                        Text("30")
                            .foregroundColor(.white)
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    HStack(alignment: .center, spacing: 10) {
                        Image("arkit").resizable().frame(width: 20, height: 20, alignment: .leading).background(Color.red).padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 4))
                        Text("实名 真实头像")
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 4))
                    }.background(RoundedRectangle(cornerRadius: 4).fill(Color.orange)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                   

                }
                Spacer()
            }).background(Color.blue).padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0))
            ForEach(rows,id:\.self){ row in
                let titleContents = overParentWidthDic[row] ?? []
                HStack(alignment: .top, spacing: 10) {
                    ForEach(titleContents,id:\.self){ title in
                        BackColorText(title: title)
                    }
                }.padding(EdgeInsets(top: 20, leading: 10, bottom:row == rows.count - 1 ? 20 : 0, trailing: 10))
            }
            
            
//            Spacer()
        }.background(RoundedRectangle(cornerRadius: 10).fill(bgColor)).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).onAppear {
            sortTitles()
        }
    }
    
    func sortTitles(){
        getNextRowTitles(row: 0, titles: titles)
        log.info("overParentWidthDic:\(overParentWidthDic)")
    }
    
    func getNextRowTitles(row:Int,titles:[String]){
        var normalRowTitles : [String] = []
        var nextRowTitles : [String] = []
        for (index,item) in titles.enumerated() {
            let tuple = calTextWidth(index: index, title: item, font: UIFont.systemFont(ofSize: 17))
            let textContent = tuple.1
            if !textContent.isEmpty {
                nextRowTitles.append(textContent)
            }else{
                normalRowTitles.append(item)
            }
        }
        overParentWidthDic[row] = normalRowTitles
        rows.append(row)
        if !nextRowTitles.isEmpty {
            getNextRowTitles(row: row + 1, titles: nextRowTitles)
        }
    }
    
    func calTextWidth(index:Int,title:String,font:UIFont) ->(index:Int,title:String){
        let width = title.size(withAttributes: [NSAttributedString.Key.font : font]).width + 7 + 7
        if index == 0 {
            sumWidth = 0
        }
        sumWidth += ((index == 0) ? 10 + width : width)
        if sumWidth > screenWidth - 40 {
            return (index,title)
        }
        return (index,"")
    }
}

struct BackColorText:View{
    var title:String = ""
    var body: some View{
        Text(title).lineLimit(1).padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)).background(Capsule().fill(Color.black.opacity(0.2)))
    }
}

struct RecommandList_Previews: PreviewProvider {
    static var previews: some View {
        RecommandList()
    }
}
