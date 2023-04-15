//
//  AccountAndSafeView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/15.
//

import SwiftUI

class AccountSafeViewModel:BaseModel{
    
    //MARK: 注销账号
    func requestDeleteAccount(){
        self.showLoading = true
        NW.request(urlStr: "delete/account",method: .post) { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = "账号已注销"
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }

    }
}

struct AccountAndSafeView: View {
    @StateObject var viewModel : AccountSafeViewModel = AccountSafeViewModel()
    @State  var deleteAccount : Bool = false
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            NavigationLink(destination: ModifyPhoneNumberView()) {
                AccountAndSafeRow(title: "修改手机号", desc: UserCenter.shared.userInfoModel?.phoneNumber ?? "")
            }
            LineHorizontalView()
            AccountAndSafeRow(title: "账号注销", desc: "").onTapGesture {
               deleteAccount = true
            }
            Spacer()
        }.background(Color.colorWithHexString(hex: "F3F3F3")).modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "账号与安全"))
            .modifier(LoadingView(isShowing: $viewModel.showLoading, bgColor: $viewModel.loadingBgColor))
            .toast(isShow: $viewModel.showToast, msg: viewModel.toastMsg)
            .alert(isPresented: $deleteAccount) {
            Alert(title: Text("确定要注销账号么？"), message: nil,
                primaryButton: .default(
                    Text("取消"),
                    action: {
                        
                    }
                ),
                secondaryButton: .destructive(
                    Text("确定"),
                    action: {
                        viewModel.requestDeleteAccount()
                    }
                ))
        }
    }
}

struct AccountAndSafeRow:View{
    var title : String
    var desc : String
    var body: some View{
        HStack(alignment: .center, spacing: 10) {
            Text(title).foregroundColor(.black)
                .font(.system(size: 15)).padding(.leading,20)
            Spacer()
            if !desc.isEmpty{
             Text(desc).foregroundColor(.black)
                    .font(.system(size: 15))
            }
            Image("7x14right").resizable().aspectRatio( contentMode: .fill).frame(width: 7, height: 14, alignment: .leading).padding(.trailing,20)
        }.frame(maxWidth:.infinity,maxHeight: 55).background(Color.white)
    }
}

struct AccountAndSafeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            AccountAndSafeView()
        }
    }
}
