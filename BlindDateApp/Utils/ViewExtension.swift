//
//  ViewExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController)

    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}


extension View{
    
    func toast(isShow:Binding<Bool>,msg:String) -> some View{
        ZStack(alignment: .center) {
            self
            Toast(isShow: isShow,msg: msg,duration: 2)
        }
    }
    
    
    func delaysTouches(for duration: TimeInterval = 0.25, onTap action: @escaping () -> Void = {}) -> some View {
           modifier(DelaysTouches(duration: duration, action: action))
       }
    func hidenKeyBoard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func alertB<Content:View>(isPresented: Binding<Bool>, @ViewBuilder builder: () -> Content) -> some View {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = .overFullScreen
        toPresent.modalTransitionStyle = .crossDissolve
//        toPresent.rootView = AnyView(
//            builder()
//                .environment(\.viewController, toPresent)
//        )
        toPresent.view.backgroundColor = .clear
       
       
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { [weak toPresent] _ in
            toPresent?.dismiss(animated: true, completion: nil)
        }
        if isPresented.wrappedValue {
            toPresent.rootView = AnyView(builder())
            let topVc = topViewController()
            topVc?.present(toPresent, animated: false, completion: nil)
        } else {
            toPresent.dismiss(animated: true, completion: nil)
        }
       
        return self
    }
    
     func topViewController(baseVC: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        
        if let nav = baseVC as? UINavigationController {
            return topViewController(baseVC: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(baseVC: selected)
            }
        }
        if let presented = baseVC?.presentedViewController {
            return topViewController(baseVC: presented)
        }
        return baseVC
    }
}

fileprivate struct DelaysTouches: ViewModifier {
    @State private var disabled = false
    @State private var touchDownDate: Date? = nil

    var duration: TimeInterval
    var action: () -> Void

    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
        .buttonStyle(DelaysTouchesButtonStyle(disabled: $disabled, duration: duration, touchDownDate: $touchDownDate))
        .disabled(disabled)
    }
}

fileprivate struct DelaysTouchesButtonStyle: ButtonStyle {
    @Binding var disabled: Bool
    var duration: TimeInterval
    @Binding var touchDownDate: Date?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed, perform: handleIsPressed)
    }

    private func handleIsPressed(isPressed: Bool) {
        if isPressed {
            let date = Date()
            touchDownDate = date

            DispatchQueue.main.asyncAfter(deadline: .now() + max(duration, 0)) {
                if date == touchDownDate {
                    disabled = true

                    DispatchQueue.main.async {
                        disabled = false
                    }
                }
            }
        } else {
            touchDownDate = nil
            disabled = false
        }
    }
}


//struct ToastModifier:ViewModifier{
//    @Binding var isShow: Bool
//    var msg : String
//    func body(content: Content) -> some View {
//        ZStack(alignment: .center) {
//            content
//            Toast(isShow: $isShow,msg: msg,duration: 0.3)
//        }
//    }
//}

struct Toast:View{
    @Binding var isShow : Bool
    var msg : String
    var duration:Double
    var body: some View{
        if isShow && !msg.isEmpty{
            HStack(alignment: .center, spacing: 0) {
                Text(msg).foregroundColor(.white).padding()
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.black.withAlphaComponent(0.9)))).frame(maxWidth:screenWidth - 60).onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isShow = false
                }
            }
            
        }
        
    }
}

struct Toast_Previews:PreviewProvider{
    static var previews: some View{
        Toast(isShow: .constant(true), msg: "12345dfsfgsdggfs", duration: 3)

    }
}


