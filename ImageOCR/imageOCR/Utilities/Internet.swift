//
//  Internet.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/19.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
public struct Internet {
    static var responseBuffer: String = "";
    
    static func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
         
     
    }
    
    static func upload(request :URLRequest, data: Data, cot:Int, controller: ViewController?) -> String? {
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            print("received")
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
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
                print ("got data \(responseData)")
                controller?.setResult(cot: cot, receive: String(data: data, encoding: .utf8) ?? "")
            }
        }
        task.resume()
        return nil;
    }
    
    
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    

    static func uploadImage(cot:Int, url: URL, imageData: Data, controller: ViewController?){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(cot, forHTTPHeaderField: "")
        
        if upload(request: request, data: imageData, cot: cot, controller: controller) != nil{
            return
        }
        return;
    }
}
