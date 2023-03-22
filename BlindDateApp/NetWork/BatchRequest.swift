//
//  BatchRequest.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/22.
//

import UIKit
import Alamofire

class BatchRequest: NSObject {
    
    var _requestArray : [BaseRequest] = []
    var finishedCount : Int = 0
    
    public  init(requestArray:[BaseRequest]) {
        _requestArray = requestArray
        self.finishedCount = 0
    }
    
    
    func request(completionHandler: @escaping (_ response: BatchRequest) -> Void, failedHandler: @escaping (_ response: ResponseData) -> Void){
        if self.finishedCount > 0 {
            log.info("Error! Batch request has already started.")
            return
        }
        for baseReq in self._requestArray {
            baseReq.request(urlStr: baseReq.url, method: baseReq.method, parameters: baseReq.params, encoding: baseReq.encoding) { _ in
                self.finishedCount += 1
                if self.finishedCount == self._requestArray.count {
                    completionHandler(self)
                }
            } failedHandler: { response in
                failedHandler(response)
                for baseReq in self._requestArray {
                    baseReq.cancel()
                }
            }

          }
        }
    
    //MARK: 上传图片
    func uploadingImage(completionHandler:@escaping (_ response: BatchRequest) -> Void,failedHandler: @escaping (_ response: ResponseData) -> Void){
        if self.finishedCount > 0 {
            log.info("Error! Batch upload request has already started.")
            return
        }
        for baseReq in self._requestArray {
            baseReq.uploadingImage(urlStr: baseReq.url, params: baseReq.uploadImageParams ?? ["":""], image: baseReq.uploadImage ?? UIImage()) { _ in
                self.finishedCount += 1
                if self.finishedCount == self._requestArray.count {
                    completionHandler(self)
                }
            } failedHandler: { response in
                failedHandler(response)
                for baseReq in self._requestArray {
                    baseReq.cancel()
                }
            }
        }
    }

}
