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
        print("uploadTask")
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            print("received")
            //print(data)
            //print(response)
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
            let mydata = data!
            if String(data: mydata, encoding: .utf8) != nil {
            print ("got data")
            controller?.setResult(receive: String(data: mydata, encoding: .utf8) ?? "")
            }

            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let responseData = String(data: data, encoding: .utf8) {
                //                print ("got data: \(responseS)")
                print ("got data \(responseData)")
                controller?.setResult(receive: String(data: data, encoding: .utf8) ?? "")
                
            }
        }
        task.resume()
        return nil;
    }
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    static func visit(from url: URL, controller: ViewController?){
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
        return;
    }
    

    static func uploadImage(imageData: Data, controller: ViewController?){
//        let url = URL(string: "http://172.20.10.2:8080/uploadTest")!
        let url = URL(string: "http://buddyoj.com/VIS/AR/ARInterface.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if upload(request: request, data: imageData,isVisit: true, controller: controller) != nil{
            return
        }
        return;
    }
}
