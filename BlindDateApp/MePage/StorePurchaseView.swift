//
//  StorePurchaseView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/13.
//

import SwiftUI

import StoreKit

class PurchaseModel:NSObject,SKPaymentTransactionObserver,SKProductsRequestDelegate{
   
    
    func startPurchase(){
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = Set.init(["normal_vip"]) //产品ID
            let request = SKProductsRequest.init(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        }else {
            print("用户禁止购买")
        }
       
    }
    
    func addObserverPurchaseResult(){
        SKPaymentQueue.default().add(self)
    }
    
    //MARK: SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState{
            case .purchased://购买成功
                dl_completeTransaction(transaction: transaction)
                break
            case .failed://购买失败
                dl_failedTransaction(transaction: transaction)
                break
            case .restored://恢复购买
                dl_restoreTransaction(transaction: transaction)
                break
            case .purchasing://正在处理
                break
            default:
                break
            }
        }
    }
    
    func dl_completeTransaction(transaction:SKPaymentTransaction) {
        let productIdentifier = transaction.payment.productIdentifier
        let receiptData = NSData.init(contentsOf: Bundle.main.appStoreReceiptURL!)
//        NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        let receipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        if !(receipt?.isEmpty ?? true) && productIdentifier.count > 0 {
//            [SVProgressHUD showSuccessWithStatus:@"支付成功"];
            /**
             可以将receipt发给服务器进行购买验证
             */
            log.info("支付成功")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func dl_failedTransaction(transaction:SKPaymentTransaction) {
//        [SVProgressHUD showErrorWithStatus:@"支付失败"];
        log.info("支付失败")
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func dl_restoreTransaction(transaction:SKPaymentTransaction){
        log.info("恢复购买")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    //MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.invalidProductIdentifiers.count > 0{
            //无效的产品ID
            log.info("无效的产品ID")
        }else{
            if response.products.count > 0{
                let payment = SKMutablePayment(product: response.products.first!)
                SKPaymentQueue.default().add(payment)
            }
        }
    }
    
    
}

struct StorePurchaseView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct StorePurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        StorePurchaseView()
    }
}
