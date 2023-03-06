//
//  EnterInfoView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/4.
//

import SwiftUI
import simd

struct EnterInfoView: View {
    @State var nickName: String = ""
    @State var scrollIndex: Int = 0
    @State var gender: Int = 0
    @State var birthDay: Double = 0
    @State var height: Int = 0
    @State var educationType : Int = 0
    @State var schoolName : String = ""
    @State var job : String = ""
    @State var yearIncome : Int = 0
    @State var workCity : String = ""
    @State var workCityCode : Int = 0
    @State var homeTown : String = ""
    @State var homeTownCode : Int = 0
    @State var loveGoal : Int = 0
    @State var minAge : Int = 0
    @State var maxAge : Int = 0
    @State var aboutUsDesc :String = ""
    var tagTitleArr : [String] = ["选出最符合我的标签","我的理想中的他是？"]
    @State var tagArr : [String] = []
    @State var tagOtherArr : [String] = []
    @State var name : String = ""
    @State var id : String = ""
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                NickNameView(nickName: $nickName, scrollIndex: $scrollIndex).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                GenderAgeHeightView(scrollIndex: $scrollIndex, gender: $gender, birthDay: $birthDay, height: $height).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                EducationInfoView(scrollIndex: $scrollIndex, educationType: $educationType, schoolName: $schoolName).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                MyJobView(scrollIndex: $scrollIndex, job: $job, yearIncome: $yearIncome).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                MyCityAndHomeTownView(scrollIndex: $scrollIndex, workCity: $workCity, workCityCode: $workCityCode, homeTown: $homeTown, homeTownCode: $homeTownCode).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                LoveGoalView(scrollIndex: $scrollIndex, loveGoal: $loveGoal, minAge: $minAge, maxAge: $maxAge).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                MyAvatarView(scrollIndex: $scrollIndex).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                MyLifeView(scrollIndex: $scrollIndex).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                AboutUsDescView(scrollIndex: $scrollIndex, aboutUsDesc: $aboutUsDesc).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                Group{
                    ForEach(0..<tagTitleArr.count){ index in
                        let title = tagTitleArr[index]
                        PersonTagView(scrollIndex: $scrollIndex, tagArr: $tagArr,title: title).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                    }
                    RealNameVerifyView(name: $name, id: $id).padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 20)).frame(width:screenWidth)
                }
            }
        }.frame(maxWidth:.infinity,maxHeight: .infinity).introspectScrollView { scrollView in
            scrollView.isPagingEnabled = true
            scrollView.contentOffset = CGPoint(x: screenWidth * 11, y: 0)
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
        }
    }
}


//MARK: 选择标签
struct PersonTagView:View{
    @Binding var scrollIndex : Int
    @Binding var tagArr : [String]
    var title : String
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text(title)
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("最少3个，牵手会自动帮你生成自我介绍")
                .font(.system(size: 16))
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 9
            }, backSepHandle: {
                scrollIndex = 7
            })
            Spacer().frame(height:50)
        }
    }
}

struct AboutUsDescView:View{
    @Binding var scrollIndex : Int
    @Binding var aboutUsDesc : String
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("关于我")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("说说你是什么样的人?")
                .font(.system(size: 16, weight: .medium, design: .default))
            TextEditor(text: $aboutUsDesc).foregroundColor(.red).lineSpacing(5)
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).frame(height:200).introspectTextView { textView in
                    textView.backgroundColor = .colorWithHexString(hex: "#F3F3F3")
                }
            Text("示例：我是典型的白羊座，性格热情开朗喜欢认识新朋友，也比较喜欢小动物，偶尔多愁善感，容易对一些细节感动。")
                .font(.system(size: 14))
                .foregroundColor(.colorWithHexString(hex: "#918FC1"))
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F1F1FE")))
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 9
            }, backSepHandle: {
                scrollIndex = 7
            })
            Spacer().frame(height:50)
            
        }
    }
}

//MARK: 我的生活
struct MyLifeView:View{
    @Binding var scrollIndex : Int
    var  titles :[String] = ["生活照","兴趣照","旅行照","",""]
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我的生活")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("选几张照片来展示生活中的我，\n照片越丰富，就越容易收到喜欢～")
                .font(.system(size: 13))
            let items = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
            LazyVGrid(columns: items,spacing: 10) {
                ForEach(0..<titles.count){ index in
                    let title = titles[index]
                    Button {
                        
                    } label: {
                        VStack(alignment: .center, spacing: 10){
                            Image("add_photo").resizable().aspectRatio( contentMode: .fit)
                                .frame(width: 48, height: 48, alignment: .leading)
                            if title.count > 0 {
                                Text(title)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                            }
                        }
                    }.frame(maxWidth:.infinity,minHeight: 150, alignment: .center).background(RoundedRectangle(cornerRadius: 10).strokeBorder(.red,style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [4,4], dashPhase: 2)))
                        .background((Color.colorWithHexString(hex: "#FFF9F9"))).contentShape(Rectangle())
                }
            }
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 8
            }, backSepHandle: {
                scrollIndex = 6
            })
            Spacer().frame(height:50)

        }
    }
}

struct MyAvatarView:View{
    @Binding var scrollIndex : Int
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我的头像")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("选张好看的照片做头像，记得露脸哦～")
                .font(.system(size: 13))
            Button {
                
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
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 7
            }, backSepHandle: {
                scrollIndex = 5
            })
            Spacer().frame(height:50)

        }
    }
}

struct LoveGoalView:View{
    @Binding var scrollIndex : Int
    @Binding var loveGoal : Int
    @Binding var minAge : Int
    @Binding var maxAge : Int
    @State var selectedIndex : Int = 0
    var titles : [String] = ["短期内想结婚","认真谈场恋爱，合适就考虑结婚","先认真谈场恋爱再说","没考虑清楚"]
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
                    }
            }
            
            Text("接受对方的年龄")
                .font(.system(size: 16, weight: .medium, design: .default))
            HStack(alignment: .center, spacing: 10){
                PullDownButton(title:"最小年龄")
                Text("—")
                    .foregroundColor(.gray)
                PullDownButton(title:"最大年龄")
            }
            
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 6
            }, backSepHandle: {
                scrollIndex = 4
            })
            Spacer().frame(height:50)
        }
    }
}

//MARK: 工作居住地 我的家乡
struct MyCityAndHomeTownView:View{
    @Binding var scrollIndex : Int
    @Binding var workCity : String
    @Binding var workCityCode : Int
    @Binding var homeTown : String
    @Binding var homeTownCode : Int
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我在哪里")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("工作居住地")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton().frame(height:45)
            
            Text("我的家乡")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton().frame(height:45)
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 5
            }, backSepHandle: {
                scrollIndex = 3
            })
            Spacer().frame(height:50)
            
        }
    }
}

struct MyJobView:View{
    @Binding var scrollIndex : Int
    @Binding var job : String
    @Binding var yearIncome : Int
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("我的工作")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("职业")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton().frame(height:45)
            
            Text("年收入")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton().frame(height:45)
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 4
            }, backSepHandle: {
                scrollIndex = 2
            })
            Spacer().frame(height:50)
            
        }
    }
}

//MARK: 教育信息
struct EducationInfoView:View{
    @Binding var scrollIndex : Int
    @Binding var educationType : Int
    @Binding var schoolName : String
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("教育信息")
                    .font(.system(size: 22, weight: .medium, design: .default))
                Spacer()
            }
            Text("学历")
                .font(.system(size: 16, weight: .medium, design: .default))
            PullDownButton().frame(height:45)
            
            Text("学校")
                .font(.system(size: 16, weight: .medium, design: .default))
            TextField("请输入学校名称", text: $schoolName).font(.system(size: 15, weight: .medium, design: .default)).frame(height:45).padding(.leading,10).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
            Spacer()
            BackBtnMergeNextBtnView(nextStepHandle: {
                scrollIndex = 3
            }, backSepHandle: {
                scrollIndex = 1
            })
            Spacer().frame(height:50)

        }
    }
}

struct PullDownButton:View{
    var title : String = "请选择"
    var body: some View{
        Button {
            
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
    var body: some View{
        VStack(alignment: .leading, spacing: 20) {
            Text("首先，给自己起个好听的名字吧")
                .font(.system(size: 22, weight: .medium, design: .default))
            TextField.init("输入昵称", text: $nickName).padding().background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
            Spacer()
            NextStepButton(title: "下一步", completion: {
                scrollIndex = 1
            }).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            Spacer().frame(height:50)
        }
    }
}

// MARK: 性别 生日 身高 UI
struct GenderAgeHeightView:View{
    @Binding var scrollIndex: Int
    @Binding var gender: Int
    @Binding var birthDay: Double
    @Binding var height: Int
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
           GenderView()
           
           BirthdayOrHeightView(title: "生日", content: "请选择出生时间")
            BirthdayOrHeightView(title: "身高", content: "请选择身高")

            Spacer()
            BackBtnMergeNextBtnView {
                scrollIndex = 0
            } backSepHandle: {
                scrollIndex = 2
            }
           
            Spacer().frame(height:50)
        }
    }
}

struct BackBtnMergeNextBtnView:View{
    var nextStepHandle : (() -> Void)
    var backSepHandle  : (() -> Void)
    var body: some View{
        HStack(alignment: .center, spacing: 10){
            Button {
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
    var content:String
    var body: some View{
        HStack{
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.black)
            Button {
                
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
    var genders : [String] = ["男","女"]
    @State var isSelectIndex : Int = 0
    var body: some View{
        GeometryReader { reader in
            let width = reader.size.width
            HStack(alignment: .top, spacing: 10) {
                ForEach(0..<2){ index in
                    let gender = genders[index]
                    ZStack(alignment: .leading) {
                        Image("").resizable().frame(width:(width - 10) / 2.0,height:70).background(RoundedRectangle(cornerRadius: 5).fill(isSelectIndex == index + 1 ? Color.red : Color.colorWithHexString(hex: "#F3F3F3")))
                        HStack{
                            Text(gender)
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(isSelectIndex == index + 1 ? Color.white : Color.gray)
                            Spacer()
                        }.padding(.leading,20)
                    }.onTapGesture {
                        isSelectIndex = index + 1
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
            completion()
        } label: {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium, design: .default))
        }.frame(maxWidth:.infinity,maxHeight: 45).background(Capsule().fill(Color.red))

    }
}

struct EnterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EnterInfoView()
    }
}
