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
    
    func checkIfHidden(){
        (uiButton["scan"] as! UIButton).isHidden = false
        (uiButton["switch"] as! UIButton).isHidden = true
        (uiButton["background"] as! UIButton).isHidden = true

        if scanEntitys.count > 0 || isInRegroupView{
            (uiButton["reranking"] as! UIButton).isHidden = false
            (uiButton["fisheye"] as! UIButton).isHidden = false
            (uiButton["restore"] as! UIButton).isHidden = false
        }else{
            (uiButton["fisheye"] as! UIButton).isHidden = true
            (uiButton["restore"] as! UIButton).isHidden = true
            (uiButton["reranking"] as! UIButton).isHidden = true
        }
        
        if mode == 0{
            (uiButton["clearStore"] as! UIButton).isHidden = false
            (uiButton["store"] as! UIButton).isHidden = false
            (uiButton["background"] as! UIButton).isHidden = false
            if isFiltered{
                (uiButton["model"] as! UIButton).isHidden = true
            }else{
                (uiButton["model"] as! UIButton).isHidden = false
            }
            if isInRegroupView{
                (uiButton["select"] as! UIButton).isHidden = false
                (uiButton["reranking"] as! UIButton).isHidden = false

            }else{
                (uiButton["select"] as! UIButton).isHidden = true
                (uiButton["reranking"] as! UIButton).isHidden = true
            }
                        
            if cmpGroup.count > 0{
                (uiButton["chart"] as! UIButton).isHidden = false
                (uiButton["compare"] as! UIButton).isHidden = false
            }else{
                (uiButton["chart"] as! UIButton).isHidden = true
                (uiButton["compare"] as! UIButton).isHidden = true
            }
        }

        if mode == 1{
            (uiButton["select"] as! UIButton).isHidden = false
            (uiButton["sscan"] as! UIButton).isHidden = false
            (uiButton["sscan"] as! UIButton).isHidden = true
            (uiButton["reranking"] as! UIButton).isHidden = false

            if cmpGroup.count > 0{
                (uiButton["chart"] as! UIButton).isHidden = false
                (uiButton["compare"] as! UIButton).isHidden = false
            }else{
                (uiButton["chart"] as! UIButton).isHidden = true
                (uiButton["compare"] as! UIButton).isHidden = true

            }

        }
        if mode == 2{
            (uiButton["select"] as! UIButton).isHidden = false
            (uiButton["sscan"] as! UIButton).isHidden = false
            (uiButton["scan"] as! UIButton).isHidden = true
            (uiButton["reranking"] as! UIButton).isHidden = true
            (uiButton["background"] as! UIButton).isHidden = false
            (uiButton["select"] as! UIButton).isHidden = true
        }
    }
    
    

    
    func setInitHidden(){
        for i in stride(from: 0, to: uiButton.count, by: 1){
            if(uiKeys[i] == "hide"){continue}
            (uiButton[uiKeys[i]] as! UIButton).isHidden = true
        }
        (uiButton["scan"] as! UIButton).isHidden = true
    }
    
    
    @objc func setHiddenAfterSwitch(_ show: Bool = false){
        let hideButton = uiButton["hide"] as! UIButton
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
        for i in stride(from: 0, to: uiButton.count, by: 1){
//            if uiBotton[i].
            if (uiButton[uiKeys[i]] as! UIButton).title(for: .normal) == ""{
                (uiButton[uiKeys[i]] as! UIButton).isHidden = true
            }else{
                if(uiKeys[i] == "hide"){continue}
                (uiButton[uiKeys[i]] as! UIButton).isHidden = toHide
                if(toHide==false){
                    checkIfHidden()
                }
            }
        }
        toggleFlash(mode)
    }
        
    func setButtonText(){
        for i in stride(from: 0, to: uiButton.count, by: 1){
            (uiButton[uiKeys[i]] as! UIButton).setTitle(bottonText[mode][i], for: .normal)
        }
    }
    
    @objc func switchMode(){
        if scanEntitys.count > 0{
            setMessage("Cannot switch mode now, you can reopen and then switch mode.")
            return
        }
        mode = (mode+1)%3
        setButtonText()
        setHiddenAfterSwitch(true)
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
        if mode != 0{
        // 大菜单、小菜单。硬编码
//            buttonTapUploadLarge()
            buttonTapUpload()
            return
        }
        if let nowTimer = timer{
            if nowTimer.isValid{
                nowTimer.invalidate()
                (uiButton["scan"] as! UIButton).backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha:0.5)
                return
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        (uiButton["scan"] as! UIButton).backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)

    }
    
    @objc func buttonTapLoadModel(){
        if mode == 0{
            isFiltered = true
            resetAndAddAnchor()
            return
        }
        guard mode == 2 else{
            print("Not in eye shadow mode")
            setMessage("Not in eye shadow mode")
            return
        }
        guard colorAbstractUI.getIsHidden() == false else{
            setMessage("Selet an eye shadow first")
            return
        }
//        let resource = try? TextureResource.load(contentsOf:getDocumentsDirectory().appendingPathComponent("color@\(colorAbstractUI.id).png"))
        var shadowColor = UnlitMaterial()
//        shadowColor.baseColor = MaterialColorParameter.texture(resource!)
//        shadowColor.tintColor = UIColor.white.withAlphaComponent(0.99)

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
    
    @objc func buttonTabClearPrev(){
        FileHandler.clearAllSavedData()
    }
    
    @objc func buttonTabLoadPrev(){
        let resultCot = FileHandler.readResultCot();
        NSLog("find \(resultCot) previous result");
        for i in stride(from: 0, to: resultCot ,by: 1){
            let nowMatrix = FileHandler.readMatrixFromFile(cot: i)
            if (nowMatrix == nil){
                NSLog("error reading nowmatrix: \(i)");
                continue
            }
            while(picMatrix.count <= i){
                picMatrix.append(PicMatrix())
            }
            picMatrix[i] = nowMatrix!
            let nowResult = FileHandler.readResultFromFile(cot: i)
            if (nowResult == nil){
                NSLog("error reading nowResult: \(i)");
                return;
            }
            let staticRefCoodPrev = FileHandler.readCoodRef(cot: i) ?? matrix_identity_float4x4;
            if (staticRefCoodPrev == matrix_identity_float4x4) {
                NSLog("fail to load previous coordinate referrence, locations may be inaccurate")
            }
            if (staticRefCood == matrix_identity_float4x4) {
                NSLog("fail to load coordinate referrence, locations may be inaccurate")
            }
            picMatrix[i].refImgOffset = staticRefCood * simd_inverse(staticRefCoodPrev)
            NSLog("trans \(i) from prev to current success")
            setResult(cot: i+1, receive: nowResult!, false);
        }
    }
    
    @objc func buttonTapUpload(){
        if mode==1&&picMatrix.count>=1{
            setMessage("Cannot scan more than 1 coffee menu at the same time.")
            return
        }
        if picMatrix.count%2 == 0{
            setMessage("Scanning"+getSubfix()+".")
        }else{
            setMessage("Recognize \(increaseCot())"+getSubfix()+".")
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
            var url = URL(string: "http://180.76.187.112/AR/ARInterface.php?id=\(picMatrix.count+1)&en=1")!
            if mode == 0{
                FileHandler.writeMatrixToFile(matrix: nowMatrix, cot: picMatrix.count-1);
                FileHandler.writeCoodRef(matrix: staticRefCood, cot: picMatrix.count-1)
            }
            else if mode==1{
                url = URL(string: "http://180.76.187.112/AR/ARInterface.php?recognizeType=coffee")!
            }else if mode == 2{
                url = URL(string: "http://180.76.187.112/AR/ARInterface.php?recognizeType=color")!
            }
            utiQueue.async {
                Internet.uploadImage(cot: self.picMatrix.count, url: url, capturedImage: capturedImage, controller:self);
            }
                       
        }
            //        setMessage("Recognize \(increaseCot())"+getSubfix())

    }
    
    public func getSubfix()->String{
        if mode == 0{
            return " books"
        }else if mode == 1{
            return " coffees"
        }else{
            return " eyeshadows"
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
            var url = URL(string: "http://180.76.187.112/AR/ARInterface.php?id=\(picMatrix.count+1)")!
            if mode==1{
                url = URL(string: "http://180.76.187.112/AR/ARInterface.php?recognizeType=coffee")!
            }else if mode == 2{
                if isFirstPic{
                    url = URL(string: "http://180.76.187.112/AR/ARInterface.php?recognizeType=color")!
                    isFirstPic = false
                }else{
                    url = URL(string: "http://180.76.187.112/AR/ARInterface.php?recognizeType=color_square")!
                    isSquare = true
                }
                print("isSquare:\(isSquare)")
            }
            var subfix = " scan result"
            if picMatrix.count-receiveAnsCot>1{subfix+="s"}
            setMessage("waiting for \(picMatrix.count-receiveAnsCot)"+subfix)

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

