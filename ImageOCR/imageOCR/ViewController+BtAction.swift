//
//  ViewController+BtAction.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/18.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit
extension ViewController{
    @objc func buttonAddInfo(){
        //addBookInfo()
    }
    
    @objc func timerAction(){
        buttonTapUpload()
    }
    
    @objc func buttonTapTimer(){
        if let nowTimer = timer{
            if nowTimer.isValid{
                nowTimer.invalidate()
                return
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func resize(){
        var id = -1 as Int
        for i in stride(from: 0, to: books.count ,by: 1){
            let singlebook = books[i]
            for j in stride(from: 0, to: singlebook.kinds.count ,by: 1){
                if singlebook.kinds[j] == "author"{
                    if singlebook.words[j] == "Sam Harris"{
                        id = i
                        break;
                    }
                }
            }
            if(id != -1){break};
        }
        if(id == -1){
            print("no such book")
            return;
        }
        enhance(id: id)
        
    }
    
    
    @objc func buttonTapDebug(){
        let nowBookDeal = HandleBook()
        nowBookDeal.saveCurrentTrans(view: sceneView)
        DealBook.append(nowBookDeal)
        
        setResult(receive: DebugString.jsonString);
        return
    }
    
    @objc func buttonTapaddx(){
        HandleBook.addxOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapdecx(){
        HandleBook.decxOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapaddy(){
        HandleBook.addyOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapdecy(){
        HandleBook.decyOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    
    @objc func buttonTapUpload(){
        if let capturedImage = sceneView.session.currentFrame?.capturedImage{
            let nowBookDeal = HandleBook()
            nowBookDeal.saveCurrentTrans(view: sceneView)
            DealBook.append(nowBookDeal)
            
            imageW = CGFloat(CVPixelBufferGetWidth(capturedImage))
            imageH = CGFloat(CVPixelBufferGetHeight(capturedImage))
            let cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
            let tempUiImage = UIImage(ciImage: cI)

            //            let data = tempUiImage.pngData()
            if let data = UIImageJPEGRepresentation(tempUiImage, 0.3 ){
//            if let data = UIImagePNGRepresentation(tempUiImage){
                let _:NSURL = NSURL(string : "urlHere")!
                //Now use image to create into NSData format
                let imageData = data.base64EncodedString()
                print(imageData)
                print("Start uploading!")
                Internet.uploadImage(imageData: imageData.data(using: .utf8)!,controller:self);
            }
        }
    }
    
    @objc func buttonTapVisit(){
        let url = URL(string: "http://172.20.10.2:8080/ocrtest")!
        Internet.visit(from: url, controller: self)
    }
}

