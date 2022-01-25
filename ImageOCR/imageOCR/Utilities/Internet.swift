//
//  Internet.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/19.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
import ARKit
public struct Internet {
    static var responseBuffer: String = "";
    
    static public var imgData: String = "";
        
    static func convertDictionaryToJSONString(dict:NSDictionary?)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }

    static func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
         
     
    }
    
    static func getArrayFromJSONString(jsonString:String) ->NSArray{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSArray
        }
        return NSArray()
         
     
    }
    
    static func uploadAndSetResultTemp(request :URLRequest, data: Data, cot:Int, controller: ViewController?) -> String? {
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            print("received")
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                print(String(data: data ?? Data(), encoding: .utf8))
                return
            }
            let mydata = data!
            if String(data: mydata, encoding: .utf8) != nil {
                print ("got data")
                controller?.setResult(cot: cot,receive: String(data: mydata, encoding: .utf8) ?? "", true)
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let responseData = String(data: data, encoding: .utf8) {
                controller?.setResult(cot: cot, receive: String(data: data, encoding: .utf8) ?? "",true)
            }
        }
        task.resume()
        return nil;
    }
    
    static func uploadAndSetResult(request :URLRequest, data: Data, cot:Int, controller: ViewController?) -> String? {
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            print("received")
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                print(String(data: data ?? Data(), encoding: .utf8))
                return
            }
            let mydata = data!
            if String(data: mydata, encoding: .utf8) != nil {
                print ("got data")
                controller?.setResult(cot: cot,receive: String(data: mydata, encoding: .utf8) ?? "")
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let responseData = String(data: data, encoding: .utf8) {
                controller?.setResult(cot: cot, receive: String(data: data, encoding: .utf8) ?? "")
            }
        }
        task.resume()
        return nil;
    }
    
    static func uploadBookIsbns(request :URLRequest, data: Data, _ type: Bool = false) -> String {
        var receiveStr = ""
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            print("received")
            if let error = error {
                print ("error: \(error)")
                receiveStr = "error"
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                receiveStr = "error"
                return
            }
            let mydata = data!
            if let str = String(data: mydata, encoding: .utf8){
                print ("got data")
                receiveStr = str
            }
        }
        task.resume()
        while(receiveStr==""){
            Thread.sleep(forTimeInterval: 0.5)
        }
        return receiveStr
    }

//    static func requestForChart(request :URLRequest, data: Data) -> String {
//        var receiveStr = ""
//        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
//            print("received")
//            if let error = error {
//                print ("error: \(error)")
//                receiveStr = "error"
//                return
//            }
//            guard let response = response as? HTTPURLResponse,
//                (200...299).contains(response.statusCode) else {
//                print ("server error")
//                receiveStr = "error"
//                return
//            }
//            let mydata = data!
//            if let str = String(data: mydata, encoding: .utf8){
//                print ("got data")
//                receiveStr = str
//            }
//        }
//        task.resume()
//        while(receiveStr==""){
//            Thread.sleep(forTimeInterval: 0.5)
//        }
//        return receiveStr
//    }

    
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    

    static func uploadImage(cot:Int, url: URL, imageData: Data, controller: ViewController?){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(cot, forHTTPHeaderField: "")
        
        if uploadAndSetResult(request: request, data: imageData, cot: cot, controller: controller) != nil{
            return
        }
        return;
    }
    
    static func uploadImage(cot:Int, url: URL, capturedImage: CVPixelBuffer, controller: ViewController?){
        var cI = CIImage()

//        print(controller?.nowOrientation)
        if(controller?.mode == 1){
//            if controller?.nowOrientation == UIInterfaceOrientation.portrait.rawValue{
//                cI = CIImage(cvPixelBuffer: capturedImage).oriented(.right)
//            }
//            else{
//                cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
//            }
            cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
        }
        else{ cI = CIImage(cvPixelBuffer: capturedImage).oriented(.left )}
        let tempUiImage = UIImage(ciImage: cI)

        if let data = tempUiImage.jpegData(compressionQuality: 0.3 ){
            let imageData = data.base64EncodedString()
            print(imageData)
            var request = URLRequest(url: url)
            imgData = imageData
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if uploadAndSetResult(request: request, data: imageData.data(using: .utf8)!, cot: cot, controller: controller) != nil{
                return
            }
        }

        return;

    }
    
    static func uploadImageTemp(cot:Int, url: URL, capturedImage: CVPixelBuffer, controller: ViewController?){
        var cI = CIImage()

//        print(controller?.nowOrientation)
        if(controller?.mode == 1){
//            if controller?.nowOrientation == UIInterfaceOrientation.portrait.rawValue{
//                cI = CIImage(cvPixelBuffer: capturedImage).oriented(.right)
//            }
//            else{
//                cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
//            }
            cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
        }
        else{ cI = CIImage(cvPixelBuffer: capturedImage).oriented(.left )}
        let tempUiImage = UIImage(ciImage: cI)

        if let data = tempUiImage.jpegData(compressionQuality: 0.3 ){
            let imageData = data.base64EncodedString()
            var request = URLRequest(url: url)
            imgData = imageData
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if uploadAndSetResultTemp(request: request, data: imageData.data(using: .utf8)!, cot: cot, controller: controller) != nil{
                return
            }
        }

        return;

    }
    
}
