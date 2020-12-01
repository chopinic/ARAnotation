//
//  ViewController+BtAction.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/18.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit
import ARKit
extension ViewController{

    
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
    
    
    
    @objc func buttonTapDebug(){
        let nowBookDeal = PicMatrix()
        nowBookDeal.saveCurrentTrans(view: sceneView)
        picMatrix.append(nowBookDeal)
        
        setResult(cot: picMatrix.count, receive: DebugString.jsonString ,isDebug: true);
        return
    }
    
    @objc func buttonTapaddx(){
        PicMatrix.addxOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapdecx(){
        PicMatrix.decxOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapaddy(){
        PicMatrix.addyOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapdecy(){
        PicMatrix.decyOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    
    @objc func buttonTapUpload(){
        if let capturedImage = sceneView.session.currentFrame?.capturedImage{
            let nowMatrix = PicMatrix()
            nowMatrix.saveCurrentTrans(view: sceneView)
            picMatrix.append(nowMatrix)
            
            imageW = CGFloat(CVPixelBufferGetWidth(capturedImage))
            imageH = CGFloat(CVPixelBufferGetHeight(capturedImage))
            let cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
            let tempUiImage = UIImage(ciImage: cI)

            if let data = UIImageJPEGRepresentation(tempUiImage, 0.3 ){
                let _:NSURL = NSURL(string : "urlHere")!
                let imageData = data.base64EncodedString()
                print("Start uploading!")
                let url = URL(string: "http://buddyoj.com/VIS/AR/ARInterface.php?en=0")!
                Internet.uploadImage(cot: picMatrix.count, url: url, imageData: imageData.data(using: .utf8)!,controller:self);
            }
            
            let size = CGSize(width: PicMatrix.getActualLen(oriLen:Double(5760),isW: true), height: PicMatrix.getActualLen(oriLen:Double(4320),isW: false))
            let transTip = createPlaneNode(size: size, rotation: 0, contents: UIColor(red: 1, green: 1, blue: 1, alpha: 0.75))
            transTip.name = "trans@"
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-1*PicMatrix.itemDis-0.01)
            transTip.transform = SCNMatrix4(nowMatrix.prevTrans!*translation)
            sceneView.scene.rootNode.addChildNode(transTip)
 
        }
        
    }
    
    
}

