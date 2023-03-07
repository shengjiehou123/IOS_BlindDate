//
//  NavigationViewExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/7.
//

import SwiftUI

extension NavigationView{
    
}

struct NavigationViewModifer: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    @Binding var hiddenNavigation : Bool
    var title : String
    func body(content: Content) -> some View {
//        NavigationView{
            content
                .navigationBarHidden(hiddenNavigation)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(title)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("back_btn").resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30, alignment: .leading)
                        }

                    }
                }
//        }
    }
}


