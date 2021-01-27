//
//  ViewController+BtAction.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/18.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//
import Foundation
import ARKit
import RealityKit
import CoreML
import UIKit
import VideoToolbox

extension ViewController{
    
    @objc func switchToCoffee(){
        if isCoffee{
            isCoffee = false
            setMessage("Set to book")
        }
        else{
            isCoffee = true
            setMessage("Set to coffee")
        }
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
    
    @objc func buttonTapDebug(){
        resetPicTracking()
//        resetAndAddAnchor()
//        let nowBookDeal = PicMatrix()
//        nowBookDeal.saveCurrentTrans(view: sceneView)
//        picMatrix.append(nowBookDeal)
//
//        if isCoffee{
//            setResult(cot: picMatrix.count, receive: DebugString.jsonStringCoffee ,isDebug: true);
//        }else{
//            setResult(cot: picMatrix.count, receive: DebugString.jsonString ,isDebug: true);
//        }
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
    
    @objc func buttonTapData(){
        print(Internet.imgData)
    }
    
    @objc func buttonTapUpload(){
        
        if let capturedImage = arView.session.currentFrame?.capturedImage{
            guard let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any).first else{
                setMessage("no plane detected")
                return
            }
            let dis = calcuPointDis(trans1: result.worldTransform, trans2: (arView.session.currentFrame?.camera.transform)!)
            print(dis)
            let nowMatrix = PicMatrix()
            let rotationTrans = makeRotationMatrix(x: -.pi/2)
            nowMatrix.saveCurrentTrans(trans: result.worldTransform*rotationTrans)
            nowMatrix.itemDis = Double(dis)
            picMatrix.append(nowMatrix)
            imageW = CGFloat(CVPixelBufferGetWidth(capturedImage))
            imageH = CGFloat(CVPixelBufferGetHeight(capturedImage))
            var url = URL(string: "http://buddyoj.com/VIS/AR/ARInterface.php?en=0")!
            
            if isCoffee{
                print("Start uploading coffee!")
                url = URL(string: "http://buddyoj.com/VIS/AR/ARInterface.php?recognizeType=coffee")!
            }
            setMessage("waiting for \(picMatrix.count-receiveAnsCot) scan results")

            utiQueue.async {
                Internet.uploadImage(cot: self.picMatrix.count, url: url, capturedImage: capturedImage, controller:self);
            }
            /*
            let cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
            let tempUiImage = UIImage(ciImage: cI)

            if let data = UIImageJPEGRepresentation(tempUiImage, 0.3 ){
                let _:NSURL = NSURL(string : "urlHere")!
                let imageData = data.base64EncodedString()
//                print(imageData)
                print("Start uploading!")
                setMessage("Waiting for \(picMatrix.count-receiveAnsCot) scan results")
                let url = URL(string: "http://buddyoj.com/VIS/AR/ARInterface.php?en=0")!
                Internet.uploadImage(cot: picMatrix.count, url: url, imageData: imageData.data(using: .utf8)!,controller:self);
            }
 */
        }
    }
    
    
//    @objc func buttonTapUploadCoffee(){
//        if let capturedImage = sceneView.session.currentFrame?.capturedImage{
//            let nowMatrix = PicMatrix()
//            nowMatrix.saveCurrentTrans(view: sceneView)
//            picMatrix.append(nowMatrix)
//            imageW = CGFloat(CVPixelBufferGetWidth(capturedImage))
//            imageH = CGFloat(CVPixelBufferGetHeight(capturedImage))
//            let cI = CIImage(cvPixelBuffer: capturedImage).oriented(.right)
//            let tempUiImage = UIImage(ciImage: cI)
//
//            if let data = UIImageJPEGRepresentation(tempUiImage, 0.3 ){
//                let imageData = data.base64EncodedString()
//                print(imageData)
//                print("Start uploading coffee!")
//                let url = URL(string: "http://buddyoj.com/VIS/AR/ARInterface.php?recognizeType=coffee")!
//                Internet.uploadImage(cot: picMatrix.count, url: url, imageData: imageData.data(using: .utf8)!,controller:self);
//            }
// 
//        }
//        
//    }
    
    @objc func buttonShowCoffeeAbs(){

        if coffeeAbstractUI.getIsHidden(){
            coffeeAbstractUI.id = 0
            coffeeAbstractUI.setImage(elementPics[coffees[0].desPicid])
            coffeeAbstractUI.setText(coffees[0].generateAbstract())
            coffeeAbstractUI.setIsHidden(false)
        }
        else{
            coffeeAbstractUI.setIsHidden(false)
        }
    }
    
    @objc func buttonTapCreateBigPlane(){
        if let backnode = arView.scene.findEntity(named: "trans@1"){
            backnode.name = "trans@0"
            let size = CGSize(width: 5, height: 5)
            var material = UnlitMaterial()
            material.tintColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0)
            backnode.removeChild(backnode.findEntity(named: "plane")!)
            let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            plane.name = "plane"
            backnode.addChild(plane)
        }
        else if let backnode = arView.scene.findEntity(named: "trans@0"){
            backnode.name = "trans@1"
            let size = CGSize(width: 5, height: 5)
            var material = UnlitMaterial()
            material.tintColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
            backnode.removeChild(backnode.findEntity(named: "plane")!)
            let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            plane.name = "plane"
            backnode.addChild(plane)
        }
        else{
            let nowTrans = arView.session.currentFrame!.camera.transform
            let size = CGSize(width: 5, height: 5)
            var material = UnlitMaterial()
            
            material.tintColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
            let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            plane.name = "plane"
            let transTip = AnchorEntity()
            transTip.name = "trans@1"
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-2)
            transTip.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
            transTip.addChild(plane)
            arView.scene.addAnchor(transTip)
//            transTip.look(at: <#T##SIMD3<Float>#>, from: <#T##SIMD3<Float>#>, relativeTo: <#T##Entity?#>)
        }
    }
    
}

