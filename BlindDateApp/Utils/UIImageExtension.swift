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
    
    //二分压缩法
    func compressImageMid(maxLength: Int) -> Data? {
       var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: 1) else { return nil }
        log.info("message: 压缩前kb: \( Double((data.count)/1024))")
        
       if data.count < maxLength {
           return data
       }
        log.info("压缩前kb, \(data.count / 1024)KB")
       var max: CGFloat = 1
       var min: CGFloat = 0
//       for _ in 0..<10 {
//           compression = (max + min) / 2
//           data = self.jpegData(compressionQuality:compression)!
//           if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
//               min = compression
//           } else if data.count > maxLength {
//               max = compression
//           } else {
//               break
//           }
//       }
        
        while data.count > maxLength{
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality:compression)!
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
       }
//       var resultImage: UIImage = UIImage(data: data)!
        log.info("压缩后kb, \(data.count / 1024)KB")
       if data.count < maxLength {
           return data
       }
        
        return data
    }
    
    func resize(withPercentage percentage: CGFloat) -> UIImage? {
        let newRect = CGRect(origin: .zero, size: CGSize(width: size.width*percentage, height: size.height*percentage))
        UIGraphicsBeginImageContextWithOptions(newRect.size, true, 1)
        self.draw(in: newRect)
        defer {UIGraphicsEndImageContext()}
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resizedMB(maxLenth:Int) -> UIImage? {
        guard let imageData = self.jpegData(compressionQuality: 1) else { return nil }
        var resizingImage = self
        var imageSizeMB = imageData.count / 1024 / 1024 // ! Or devide for 1024 if you need KB but not kB
        while imageSizeMB > maxLenth { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resize(withPercentage: 0.9),
                let imageData = resizedImage.jpegData(compressionQuality: 1)
                else { return nil }

            resizingImage = resizedImage
            imageSizeMB = imageData.count / 1024 / 1024
        }

        return resizingImage
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
