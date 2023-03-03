//
//  UIImageExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/3.
//

import UIKit
import JFHeroBrowser
import SDWebImage

extension UIImage {
    static func from(color: UIColor) -> UIImage {
           let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
           UIGraphicsBeginImageContext(rect.size)
           let context = UIGraphicsGetCurrentContext()
           context!.setFillColor(color.cgColor)
           context!.fill(rect)
           let img = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return img!
       }
    
}

extension HeroNetworkImageProvider:NetworkImageProvider{
    func downloadImage(with imgUrl: String, complete: Complete<UIImage>?) {
        SDWebImageManager.shared.loadImage(with: URL(string: imgUrl), options: SDWebImageOptions.continueInBackground) { receivedSize, expectedSize, targetURL in
           guard expectedSize > 0 else { return }
           let progress:CGFloat = CGFloat(CGFloat(receivedSize) / CGFloat(expectedSize))
           complete?(.progress(progress))
        } completed: { image , data, err, casheType, finished, targetURL in
            if err != nil{
                complete?(.failed(err))
            }else{
                complete?(.success(image ?? UIImage()))
            }
        }

    }
}

class HeroNetworkImageProvider: NSObject {
    @objc static let shared = HeroNetworkImageProvider()
}
