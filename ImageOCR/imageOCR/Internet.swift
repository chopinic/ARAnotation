//
//  Internet.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/19.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
struct Internet {
    static var responseBuffer: String = "";
    
    static func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
         
     
    }
    
    static func upload(request :URLRequest, data: Data, isVisit: Bool, controller: ViewController?) -> String? {
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                if isVisit{
                    controller?.buttonTapVisit()
                }

                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let responseData = String(data: data, encoding: .utf8) {
                //                print ("got data: \(responseS)")
                print ("got data")
                if isVisit{
                    controller?.buttonTapVisit()
                }

            }
        }
        task.resume()
        return nil;
    }
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    static func visit(from url: URL, controller: ViewController?) -> String?{
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Visited Finished")
            responseBuffer = String(data: data, encoding: .utf8) ?? ""
            DispatchQueue.main.async() { 
                if let con = controller{
                    con.setResult(receive: responseBuffer)
                    
                }
            }
        }
        return responseBuffer;
    }
    

    static func uploadImage(imageData: Data, controller: ViewController?)-> String?{
        let url = URL(string: "http://172.20.10.2:8080/uploadTest")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let response = upload(request: request, data: imageData,isVisit: true, controller: controller){
            return response
        }
        return nil;
    }
}
