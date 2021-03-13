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
    
    @objc func setHidden(_ show: Bool = false){
        let hideButton = uiButton[uiButton.count-1]
        var toHide = false
        if show == true{
            hideButton.setTitle("Hide Buttons",for: .normal)
        }else{
            if hideButton.title(for: .normal) == "Hide Buttons"{
                toHide = true
                hideButton.setTitle("Show Buttons",for: .normal)
            }else{
                toHide = false
                hideButton.setTitle("Hide Buttons",for: .normal)
            }
        }
        for i in stride(from: 0, to: uiButton.count-1, by: 1){
//            if uiBotton[i].
            if uiButton[i].title(for: .normal) == ""{
                uiButton[i].isHidden = true
            }else{
                uiButton[i].isHidden = toHide
            }
        }
    }
    
    @objc func adHoc(){
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
            var url = URL(string: "http://106.12.176.27/AR/ARInterface.php?en=1")!
            setMessage("waiting for \(picMatrix.count-receiveAnsCot) scan results")

            utiQueue.async {
                Internet.uploadImageTemp(cot: self.picMatrix.count, url: url, capturedImage: capturedImage, controller:self);
            }
           
        }
    }
    
    func setButtonText(){
        for i in stride(from: 0, to: uiButton.count, by: 1){
            uiButton[i].setTitle(bottonText[mode][i], for: .normal)
        }
    }
    
    @objc func switchMode(){
        if scanEntitys.count > 0{
            setMessage("Cannot switch mode now, you can reopen and then switch mode.")
            return
        }
        mode = (mode+1)%3
        setButtonText()
        setHidden(true)
        if mode==0{
            setMessage("Set to book")
            attrSelect.reloadAllComponents()
        }
        else if mode==2{
            setMessage("Set to eye shadow")
            attrSelect.reloadAllComponents()
        }else{
            setMessage("Set to coffee")
            attrSelect.reloadAllComponents()
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
    
    @objc func buttonTapFaceDebug(){
        guard mode == 2 else{
            print("Not in eye shadow mode")
            setMessage("Not in eye shadow mode")
            return
        }
        guard colorAbstractUI.getIsHidden() == false else{
            setMessage("Selet an eye shadow first")
            return
        }
        var shadowColor = UnlitMaterial()
        shadowColor.tintColor = colors[colorAbstractUI.id].color

        if let prevFace = arView.scene.findEntity(named: "face"){
            prevFace.removeFromParent()
//            let shadow = prevFace.findEntity(named: "shadow")! as! ModelEntity
//            shadow.model?.materials = [shadowColor]
            return
        }
        let face = try! Entity.loadModel(named: "face_part")
        let shadow = try! Entity.loadModel(named: "shadow")
        face.name = "face"
        shadow.name = "shadow"
//        face.generateCollisionShapes(recursive: true)
        shadow.model?.materials = [shadowColor]
        let faceAnchor = AnchorEntity()
        faceAnchor.name = "face"
        let nowTrans = arView.session.currentFrame!.camera.transform
        var translation = matrix_identity_float4x4
        translation.columns.3.z = Float(-0.35)
        translation.columns.3.y = Float(-0.05)
        translation.columns.3.x = Float(0.15)

        faceAnchor.transform = Transform(matrix: nowTrans*translation)
        faceAnchor.scale = SIMD3<Float>(x: 0.2, y: 0.2, z: 0.2)
        faceAnchor.addChild(face)
        faceAnchor.addChild(shadow)
        arView.scene.anchors.append(faceAnchor)
    }
    
    @objc func buttonTapDebug(){
        setCoffeeColor(2, false)
        setCoffeeColor(3, true)
        print(coffees[2].name)
        print(coffees[3].name)
    }

    
    @objc func buttonTapUploadDebug(){
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
            setMessage("waiting for \(picMatrix.count-receiveAnsCot) scan results")
            if(mode==1){
                setResult(cot: picMatrix.count, receive: DebugString.coffeeDebug, isDebug: true)
            }else if mode == 2{
                setResult(cot: picMatrix.count, receive: DebugString.coffeeDebug, isDebug: true)
            }else{
                setResult(cot: picMatrix.count, receive: DebugString.bookDebug, isDebug: true)
            }
        }
    }

    
    @objc func buttonTapDecRad(){
        coffeeOffset.rad = coffeeOffset.rad + 120
        coffeeOffset.boxrad = coffeeOffset.boxrad  + 120
        print("now rad:\(coffeeOffset.rad)")
        resetAndAddAnchor(isReset: true)
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
        if mode==1&&picMatrix.count>=1{
            setMessage("Cannot scan more than 1 coffee menu at the same time.")
            return
        }
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
            var url = URL(string: "http://106.12.176.27/AR/ARInterface.php?en=0")!
            if mode==1{
                url = URL(string: "http://106.12.176.27/AR/ARInterface.php?recognizeType=coffee")!
            }else if mode == 2{
                url = URL(string: "http://106.12.176.27/AR/ARInterface.php?recognizeType=color")!
            }
            setMessage("waiting for \(picMatrix.count-receiveAnsCot) scan results")

            utiQueue.async {
                Internet.uploadImage(cot: self.picMatrix.count, url: url, capturedImage: capturedImage, controller:self);
            }
           
        }
    }
    @objc func buttonTapUploadLarge(){
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
            var url = URL(string: "http://106.12.176.27/AR/ARInterface.php?en=1")!
            if mode==1{
                url = URL(string: "http://106.12.176.27/AR/ARInterface.php?recognizeType=coffee_large")!
            }else if mode == 2{
                url = URL(string: "http://106.12.176.27/AR/ARInterface.php?recognizeType=color_square")!
                isSquare = true
                print("isSquare:\(isSquare)")
            }
            setMessage("waiting for \(picMatrix.count-receiveAnsCot) scan results")

            utiQueue.async {
                Internet.uploadImage(cot: self.picMatrix.count, url: url, capturedImage: capturedImage, controller:self);
            }
           
        }
    }

    
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
            let size = CGSize(width: 50, height: 50)
            var material = UnlitMaterial()
            material.tintColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0)
            backnode.removeChild(backnode.findEntity(named: "plane")!)
            let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            plane.name = "plane"
            backnode.addChild(plane)
        }
        else if let backnode = arView.scene.findEntity(named: "trans@0"){
            backnode.name = "trans@1"
            let size = CGSize(width: 50, height: 50)
            var material = UnlitMaterial()
            material.tintColor = UIColor.init(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.9)
            backnode.removeChild(backnode.findEntity(named: "plane")!)
            let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            plane.name = "plane"
            backnode.addChild(plane)
        }
        else{
            let nowTrans = arView.session.currentFrame!.camera.transform
            let size = CGSize(width: 50, height: 50)
            var material = UnlitMaterial()
            
            material.tintColor = UIColor.init(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.9)
            let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            plane.name = "plane"
            let transTip = AnchorEntity()
            transTip.name = "trans@1"
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-2)
            transTip.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
            transTip.addChild(plane)
            arView.scene.addAnchor(transTip)
        }
    }
    
}

