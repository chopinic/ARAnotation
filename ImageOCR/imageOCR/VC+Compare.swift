//
//  VC+Compare.swift
//  imageOCR
//
//  Created by 杨光 on 2021/3/2.
//  Copyright © 2021 Ivan Nesterenko. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import RealityKit
extension ViewController{
    
    @objc func buttonTapSelect(){
        if mode==1 && coffeeAbstractUI.getIsHidden()==false{
            guard let menu = arView.scene.findEntity(named: "menu@") else{
                setMessage("No menu found")
                return
            }
            let nowSelect = coffeeAbstractUI.id
            if cmpGroup.firstIndex(of: nowSelect) != nil{
                setMessage("This item is already selected")
                return
            }
            for i in stride(from: 0, to: nowGroups.count, by: 1){
                if let index = nowGroups[i].firstIndex(of: nowSelect){
                    nowGroups[i].remove(at: index)
                    break
                }
            }
            var xx = Float(0.18)
            var yy = Float(0.04)
            var radio = Float(0.18)
            var step = Float(0.01)
            if menu.findEntity(named: "big") != nil{
                step*=5
                xx = 0.48
                yy = 0.6
                radio = 0.7
            }
            let node = findById(id: nowSelect)!
            var trans = node.transform.matrix
            trans.columns.3.x = xx
            trans.columns.3.y = yy-Float(cmpGroup.count)*step
            trans.columns.3.z = 0.01
            node.move(to: trans, relativeTo: node.parent, duration: 0.4)
            cmpGroup.append(nowSelect)
            if cmpGroup.count==1{
                let lineHeight: CGFloat = 0.05
                let font = MeshResource.Font.boldSystemFont(ofSize: lineHeight)
                let textMesh = MeshResource.generateText("Selected:", extrusionDepth: Float(lineHeight * 0.1), font: font)
                let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                textModel.name = "head"
                trans.columns.3.x = xx
                trans.columns.3.y = yy+step
                trans.columns.3.z = 0.01
                menu.addChild(textModel)
                textModel.setTransformMatrix(trans, relativeTo: menu)
                textModel.scale = SIMD3<Float>(x: radio, y: radio, z: radio)
            }
        }else if mode == 0 && bookAbstractUI.getIsHidden()==false{
            guard let bookshelf = arView.scene.findEntity(named: "bookShelf") else{print("no shelf");return}
            let nowSelect = bookAbstractUI.id
//            for i in stride(from: 0, to: nowGroups.count, by: 1){
//                if let index = nowGroups[i].firstIndex(of: nowSelect){
//                    nowGroups[i].remove(at: index)
//                    break
//                }
//            }
            let node = findById(id: nowSelect)!
            var trans = matrix_identity_float4x4
            trans.columns.3.x = -0.1+Float(cmpGroup.count)*0.05
            trans.columns.3.y = 0.8
            trans.columns.3.z = 0
            node.move(to: trans, relativeTo: bookshelf, duration: 0.4)
            cmpGroup.append(nowSelect)
            
            if cmpGroup.count==1{
                let lineHeight: CGFloat = 0.05
                let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                let textMesh = MeshResource.generateText("Select: ", extrusionDepth: Float(lineHeight * 0.1), font: font)
                let textMaterial = SimpleMaterial(color: .red, isMetallic: false)
                let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                textModel.scale = SIMD3<Float>(x: 0.1, y: 0.1, z: 0.1)
                textModel.name = "head@"
                trans.columns.3.x = -0.4
                trans.columns.3.y = 0.8
                trans.columns.3.z = 0
                bookshelf.addChild(textModel)
                textModel.setTransformMatrix(trans, relativeTo: bookshelf)
            }

        }
        checkIfHidden()
    }
    
    func createComparePanel()->AnchorEntity{
        hideAbstract()
        if let cmpPlane = arView.scene.findEntity(named: "cmp@1"){
            print("already have compare panel!")
            return cmpPlane as! AnchorEntity
        }
        let nowTrans = arView.session.currentFrame!.camera.transform
        let size = CGSize(width: 0.25, height: 0.15)
        let sizeback = CGSize(width: 5, height: 5)
        var material = UnlitMaterial()
        material.tintColor = UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 0.85)
        var materialback = UnlitMaterial()
        materialback.tintColor = UIColor.init(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.9)

        let frontPlane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height),cornerRadius: 0.02), materials: [material])
        let backPlane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(sizeback.width), height: Float(sizeback.height)), materials: [materialback])
        backPlane.position.z = -0.1
        let transTip = AnchorEntity()
        transTip.name = "cmp@1"
        var translation = matrix_identity_float4x4
        translation.columns.3.z = Float(-0.25)
        translation.columns.3.y = Float(-0.02)
        transTip.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
        transTip.addChild(frontPlane)
        transTip.addChild(backPlane)
        return transTip
    }
    
    func addTitleReturn(_ title: String, _ length: Int = 15,_ hasLimit:Int = 100)->String{
        var name = ""
//        for i in stride(from: 0, to: title.count, by: 1){
//            if(lineori.index(after: String.Index(encodedOffset: i)) != " "){continue}
//            lineori = lineori.prefix(i) + "\n" + lineori.suffix(lineori.count-i)
//            print("add return")
//        }
        var tail = title
        var head = ""
//        var cot = 0
        var nowLineLength = 0
        var linecot = 0
        while(true){
            var firstSpace = tail.firstIndex(of: " ") ?? tail.endIndex
            if firstSpace == tail.endIndex{
                name = name + tail
                break
            }
            head = String(tail[..<firstSpace])
            nowLineLength += head.count
//            if head.count>3{
            if nowLineLength>length{
                if linecot >= hasLimit{
                    return name+" ..."
                }
                if(head.count>length){
                    name = name + head.prefix(head.count - nowLineLength + length) + "-"
                    name = name + "\n" + head.suffix(nowLineLength-length)
                }else{
                    name = name + "\n" + head
                    nowLineLength = head.count
                    linecot+=1
                }
                
            }else{
                name = name + " " + head
            }
            firstSpace = tail.index(after: firstSpace)
            tail = String(tail[firstSpace...])
        }
        return name
    }
    
    
    @objc func buttonTapCmp(){
        if let cmpPlane = arView.scene.findEntity(named: "cmp@1"){
            cmpPlane.removeFromParent()
        }
        else{
            guard cmpGroup.count > 0 else {
                setMessage("Please select items first")
                return
            }
            let transTip = createComparePanel()
            let dic = NSMutableDictionary()
            var info = [NSMutableDictionary]()

            if mode == 0{
//                generateTitleText("Rating and Prices",transTip)
                dic["title"] = "Rating and Prices"
                for id in cmpGroup {
                    let bookInfo = NSMutableDictionary()
                    bookInfo["title"] = addTitleReturn(books[id].title, 60/cmpGroup.count)
                    bookInfo["price"] = books[id].price
                    bookInfo["score"] = books[id].score
                    info.append(bookInfo)
                }
                dic["data"] = info
                let json = Internet.convertDictionaryToJSONString(dict: dic)
                let jsonData = json.data(using: .utf8)!
                var request = URLRequest(url: URL(string: "http://180.76.187.112:8888/score")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                var receive = Internet.uploadBookIsbns(request: request, data: jsonData)
                var picDic = Internet.getDictionaryFromJSONString(jsonString: receive)
                var pibBase64 = picDic["base64"] as! String
                var dataDecoded : Data = Data(base64Encoded: pibBase64, options: .ignoreUnknownCharacters)!
                let filename = getDocumentsDirectory().appendingPathComponent("cmpScoreChart.png")
                try! dataDecoded.write(to: filename)
                
                request = URLRequest(url: URL(string: "http://180.76.187.112:8888/price")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                receive = Internet.uploadBookIsbns(request: request, data: jsonData)
                picDic = Internet.getDictionaryFromJSONString(jsonString: receive)
                pibBase64 = picDic["base64"] as! String
                dataDecoded = Data(base64Encoded: pibBase64, options: .ignoreUnknownCharacters)!
                let filenamePrice = getDocumentsDirectory().appendingPathComponent("cmpPriceChart.png")
                try! dataDecoded.write(to: filenamePrice)

                Thread.sleep(forTimeInterval: 0.5)
                
                let cellSize = CGSize(width: 0.10, height: 0.10)
                let priceCell = createImagePlane(url: filename, size: cellSize)!
                priceCell.position = SIMD3<Float>(x: -0.06, y: -0.008, z: 0.016)
                let lineHeight: CGFloat = 0.05
                let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                var textMesh = MeshResource.generateText("Rating", extrusionDepth: Float(lineHeight * 0.1), font: font)
                var bound = textMesh.bounds
                let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                let ratio = Float(0.2)
                var titleText = ModelEntity(mesh: textMesh, materials: [textMaterial])
                titleText.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
                titleText.position = SIMD3<Float>(x: -ratio*bound.boundingRadius, y: 0.065, z: 0)
                priceCell.addChild(titleText)
                
                
                
                let scoreCell = createImagePlane(url: filenamePrice, size: cellSize)!
                scoreCell.position = SIMD3<Float>(x: 0.06, y: -0.008, z: 0.0155)
                textMesh = MeshResource.generateText("Price", extrusionDepth: Float(lineHeight * 0.1), font: font)
                bound = textMesh.bounds
                titleText = ModelEntity(mesh: textMesh, materials: [textMaterial])
                titleText.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
                titleText.position = SIMD3<Float>(x: -ratio*bound.boundingRadius, y: 0.065, z: 0)
                scoreCell.addChild(titleText)
                
                transTip.addChild(priceCell)
                transTip.addChild(scoreCell)

            }else if mode == 1{
                generateTitleText("Ingredients",transTip)
                for i in stride(from: 0, to: cmpGroup.count, by: 1){
                    let cellSize = CGSize(width: 0.05, height: 0.05)
                    let filename = getDocumentsDirectory().appendingPathComponent("coffeedespercent@\(cmpGroup[i]).png")
                    let cell = createImagePlane(url: filename, size: cellSize)!
                    cell.position = SIMD3<Float>(x: -0.09+0.06*Float(i), y: 0.020, z: 0.006)
                    transTip.addChild(cell)
                    
                    let lineHeight: CGFloat = 0.05
                    let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                    let textMesh = MeshResource.generateText(coffees[cmpGroup[i]].name, extrusionDepth: Float(lineHeight * 0.1), font: font)
                    let boundBox = textMesh.bounds
                    let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                    let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = Float(-0.25)
                    textModel.transform = Transform(matrix: translation)
                    let ratio = Float(0.07)
                    textModel.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
                    textModel.position = SIMD3<Float>(x: -1*ratio*boundBox.boundingRadius, y: -0.032, z: 0)
                    cell.addChild(textModel)
                }
            }
            arView.scene.addAnchor(transTip)
        }

    }

    @objc func buttonTapPicCmp(){
        if let cmpPlane = arView.scene.findEntity(named: "cmp@1"){
            cmpPlane.removeFromParent()
        }
        else{
            guard cmpGroup.count > 0 else {
                setMessage("Please select items first")
                return
            }
            let transTip = createComparePanel()
            if mode == 0{
                let dic = NSMutableDictionary()
                var isbns = [String]()
                for i in stride(from: 0, to: cmpGroup.count, by: 1) {
                    isbns.append(books[cmpGroup[i]].isbn)
                }
                dic["isbns"] = isbns
                let jsonData = Internet.convertDictionaryToJSONString(dict: dic).data(using: .utf8)!
                var request = URLRequest(url: URL(string: "http://180.76.187.112/AR/BookDataInterface.php")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let receive = Internet.uploadBookIsbns(request: request, data: jsonData)
                let picBase64 = Internet.getArrayFromJSONString(jsonString: receive)
                for i in stride(from: 0, to: picBase64.count, by: 1){
                    let nowBook = picBase64[i] as! NSDictionary
                    let summaryWordCloudStr = nowBook["summary_base64"] as! String
                    let dataDecoded : Data = Data(base64Encoded: summaryWordCloudStr, options: .ignoreUnknownCharacters)!
                    let filename = getDocumentsDirectory().appendingPathComponent("bookWordCloud@\(cmpGroup[i]).png")
                    try! dataDecoded.write(to: filename)
                }
                Thread.sleep(forTimeInterval: 0.5)
                
                generateTitleText("Word Cloud",transTip)
                for i in stride(from: 0, to: cmpGroup.count, by: 1){
                    let cellSize = CGSize(width: 0.04, height: 0.04)
                    let filename = getDocumentsDirectory().appendingPathComponent("bookWordCloud@\(cmpGroup[i]).png")
                    let cell = createImagePlane(url: filename, size: cellSize)!
                    cell.position = SIMD3<Float>(x: -0.075+0.05*Float(i), y: 0.03, z: 0.016)
                    transTip.addChild(cell)
                    
                    let lineHeight: CGFloat = 0.05
                    let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                    let textMesh = MeshResource.generateText(addTitleReturn(books[cmpGroup[i]].title,15,3), extrusionDepth: Float(lineHeight * 0.1), font: font)
                    let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                    let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = Float(-0.25)
                    textModel.transform = Transform(matrix: translation)
                    let boundBox = textMesh.bounds
                    let ratio = Float(0.07)
                    textModel.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
                    textModel.position = SIMD3<Float>(x: -1*ratio*boundBox.boundingRadius, y: -0.027-0.4*ratio*boundBox.boundingRadius, z: 0)
                    cell.addChild(textModel)
                }
            }
            else{
                generateTitleText("Word Cloud",transTip)
                for i in stride(from: 0, to: cmpGroup.count, by: 1){
                    let cellSize = CGSize(width: 0.07, height: 0.07)
                    let filename = getDocumentsDirectory().appendingPathComponent("coffeeRemark@\(cmpGroup[i]).png")
                    guard let cell = createImagePlane(url: filename, size: cellSize) else{
                        setMessage("Please select coffee. There's drinks or tea in the selected list.")
                        return
                    }
//                    for j in stride(from: 0, to: cmpGroup.count, by: 1){
//                        for h in stride(from: 0, to: 2, by: 1){
                    cell.position = SIMD3<Float>(x: -0.04+0.08*Float(i%2), y: 0.04-0.070*Float(i/2), z: 0.006)
//                        }
//                    }

                    transTip.addChild(cell)
                    
                    let lineHeight: CGFloat = 0.05
                    let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                    let textMesh = MeshResource.generateText(coffees[cmpGroup[i]].name, extrusionDepth: Float(lineHeight * 0.1), font: font)
                    let boundBox = textMesh.bounds
                    let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                    let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = Float(-0.25)
                    textModel.transform = Transform(matrix: translation)
                    let ratio = Float(0.08)
                    textModel.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
                    textModel.position = SIMD3<Float>(x: -1*ratio*boundBox.boundingRadius, y: -0.035, z: 0)
                    cell.addChild(textModel)
                    
                
                }
            }
            arView.scene.addAnchor(transTip)
        }
    }
    
    
    func generateTitleText(_ text: String, _ transTip:Entity){
        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(text, extrusionDepth: Float(lineHeight * 0.1), font: font)
        let bound = textMesh.bounds
        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
        let ratio = Float(0.3)
        let titleText = ModelEntity(mesh: textMesh, materials: [textMaterial])
        titleText.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
        titleText.position = SIMD3<Float>(x: -1*ratio*bound.boundingRadius, y: 0.055, z: 0)
        transTip.addChild(titleText)
    }
}
