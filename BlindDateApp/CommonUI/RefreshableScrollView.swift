// Authoer: The SwiftUI Lab
// Full article: https://swiftui-lab.com/scrollview-pull-to-refresh/

import SwiftUI

struct RefreshableScrollView<Content: View>: View{
//    @State private var previousScrollOffset: CGFloat = 0
//    @State private var startScrollOffset: CGFloat = 0
//    @State private var scrollOffset: CGFloat = 0
//    @State private var started: Bool = false
//    @State private var frozen: Bool = false
//    @State private var rotation: Angle = .degrees(0)
//
//
//
//    var threshold: CGFloat = 80
//    @Binding var refreshing: Bool
//    var pullDown : (()->Void)?
//    private var footerRefreshing: Binding<Bool>?
//    @State var myFooterRefreshing: Bool = true
//
//
//    @State var footerLoading : Bool = false
//    let content: Content
//
//    var onFooterRefreshing : (()->Void)?
    
    let ableSrollView : _RefreshableScrollView<Content>
    
    init(height: CGFloat = 80,refreshing: Binding<Bool>,pullDown:(()->Void)? = nil,@ViewBuilder content: () -> Content) {
//        self.threshold = height
//        self._refreshing = refreshing
//        self.content = content()
//        self.pullDown = pullDown
//        self.footerRefreshing = nil
//        self.onFooterRefreshing = nil
//        self.init(privateHeight: height, refreshing: refreshing, pullDown: pullDown, footerRefreshing: nil, onFooterRefreshing: nil,content: content)
        ableSrollView = _RefreshableScrollView(privateHeight: height, refreshing: refreshing, pullDown: pullDown, footerRefreshing: nil,loadMore: nil, onFooterRefreshing: nil, content: content)
    }
    
    init(height: CGFloat = 80,refreshing: Binding<Bool>,pullDown:(()->Void)? = nil, footerRefreshing: Binding<Bool>,loadMore:Binding<Bool>,onFooterRefreshing: (()->Void)? = nil,@ViewBuilder content: () -> Content) {
//        self.threshold = height
//        self._refreshing = refreshing
//        self.footerRefreshing = footerRefreshing
//        self.content = content()
//        self.pullDown = pullDown
//        self.onFooterRefreshing = onFooterRefreshing
//        self.init(privateHeight: height, refreshing: refreshing, pullDown: pullDown, footerRefreshing: footerRefreshing, onFooterRefreshing: onFooterRefreshing, content: content)
        ableSrollView = _RefreshableScrollView(privateHeight: height, refreshing: refreshing, pullDown: pullDown, footerRefreshing: footerRefreshing, loadMore: loadMore,onFooterRefreshing: onFooterRefreshing, content: content)
    }
    
    var body: some View{
        ableSrollView
    }
}

struct _RefreshableScrollView<Content: View>: View {
    @State private var previousScrollOffset: CGFloat = 0
    @State private var startScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var started: Bool = false
    @State private var frozen: Bool = false
    @State private var rotation: Angle = .degrees(0)
    
   
    
    var threshold: CGFloat = 80
    @Binding var refreshing: Bool
    @Binding var footerRefreshing: Bool
    @Binding var loadMore : Bool
    var pullDown : (()->Void)?
    
    
    @State var footerLoading : Bool = false
    let content: Content
    
    var onFooterRefreshing : (()->Void)?
    
    

    
    
    init(privateHeight: CGFloat,refreshing: Binding<Bool>,pullDown:(()->Void)? = nil, footerRefreshing: Binding<Bool>?,loadMore:Binding<Bool>?,onFooterRefreshing: (()->Void)? = nil,@ViewBuilder content: () -> Content) {
        self.threshold = privateHeight
        self._refreshing = refreshing
        self._footerRefreshing = footerRefreshing ?? .constant(false)
        self.content = content()
        self.pullDown = pullDown
        self.onFooterRefreshing = onFooterRefreshing
        self._loadMore = loadMore ?? .constant(false)
    }
    
    
    
    var body: some View {
        return VStack {
            
                ScrollView {
                    
                    ZStack(alignment: .top) {
                        MovingView()
                        
                        LazyVStack(alignment: .center, spacing: 0) {
                            self.content
                            if footerRefreshing {
                                PullUpView {
                                    
                                }
                            }
                        }.background(ContentFixedView()).alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen) ? -self.threshold : 0.0 })
                        
                        if pullDown != nil {
                            SymbolView(height: self.threshold, loading: self.refreshing, frozen: self.frozen, rotation: self.rotation)
                        }
                    }
                    
                }.background(FixedView())
                    .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                        self.refreshLogic(values: values)
                    }
                    
        
            
        }
    }
    
    func impact() {
        if #available(iOS 10.0, *) {
            let impacter = UIImpactFeedbackGenerator()
            impacter.impactOccurred()
        }
    }
    
     func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            let contentFixedBounds = values.first { $0.vType == .contentFixedView}?.bounds ?? .zero
            
            if self.startScrollOffset == 0 {
                self.startScrollOffset = 30
            }
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.rotation = self.symbolRotation(self.scrollOffset)
            
            // Crossing the threshold on the way down, we start the refresh process
            if !self.refreshing &&  (self.scrollOffset >= self.threshold) && pullDown != nil{
                //&& self.previousScrollOffset <= self.threshold
                self.refreshing = true
                self.started = false
                impact()
            }
            
            if !self.started && (self.scrollOffset <= self.startScrollOffset) && self.refreshing {
                self.started = true
                updateData()
            }
            
            
            
            if self.refreshing {
                // Crossing the threshold on the way up, we add a space at the top of the scrollview
                self.frozen = true
//                if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold {
//                    self.frozen = true
//
//                }
            } else {
                // remove the sapce at the top of the scroll view
                self.frozen = false
            }
            
            // Update last scroll offset
            self.previousScrollOffset = self.scrollOffset
            
            let contentHeight = max(fixedBounds.size.height,contentFixedBounds.size.height) + 5
            
            if(fixedBounds.size.height - scrollOffset  > contentHeight && !footerLoading && self.onFooterRefreshing != nil && loadMore){
                footerLoading = true
            }
            if footerLoading && fixedBounds.size.height - scrollOffset >= contentHeight && !footerRefreshing && loadMore{
//                if footerRefreshing != nil {
//                    footerRefreshing = $myFooterRefreshing
//                }
                footerRefreshing = true
                if let onFooterRefresh = onFooterRefreshing{
                     onFooterRefresh()
                 }
            }
           
        }
    }
    
    func updateData(){
        if let pull = pullDown {
            pull()
        }
    }
    
    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        
        // We will begin rotation, only after we have passed
        // 60% of the way of reaching the threshold.
        if scrollOffset < self.threshold * 0.60 {
            return .degrees(0)
        } else {
            // Calculate rotation, based on the amount of scroll offset
            let h = Double(self.threshold)
            let d = Double(scrollOffset)
            let v = max(min(d - (h * 0.6), h * 0.4), 0)
            return .degrees(180 * v / (h * 0.4))
        }
    }
    
    struct SymbolView: View {
        var height: CGFloat
        var loading: Bool
        var frozen: Bool
        var rotation: Angle
        
        
        var body: some View {
            Group {
                if self.loading { // If loading, show the activity control
                    VStack {
                        Spacer()
                        ActivityRep()
                        Spacer()
                    }.frame(height: height).fixedSize()
                        .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
                } else {
                    Image(systemName: "arrow.down") // If not loading, show the arrow
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: height * 0.25, height: height * 0.25).fixedSize()
                        .padding(height * 0.375)
                        .rotationEffect(rotation)
                        .offset(y: -height + (loading && frozen ? +height : 0.0))
                }
            }
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
    
    struct ContentFixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .contentFixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}



struct PullUpView:View{
    var dragupRefresh : () -> Void
     var body: some View{
         HStack{
             ActivityRep()
             Text("加载中...").font(.system(size: 14)).foregroundColor(Color(UIColor.gray.withAlphaComponent(0.8)))
         }.onAppear {
             dragupRefresh()
         }
     }
 }

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
        case contentFixedView
        case bottomView
    }

    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }

        typealias Value = [PrefData]
    }
}

struct ActivityRep: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
        uiView.startAnimating()
    }
}
