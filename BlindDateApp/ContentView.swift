//
//  ContentView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            LoginView()
                .tabItem {
                    Label{
                        Text("首页")
                    } icon: {
                        Image("")
                    }

                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
