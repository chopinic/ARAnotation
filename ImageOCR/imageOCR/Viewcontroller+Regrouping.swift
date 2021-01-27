//
//  Viewcontroller+Regrouping.swift
//  imageOCR
//
//  Created by 杨光 on 2020/12/5.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import ARKit
import UIKit
import RealityKit
extension ViewController{
    
    func getAttrName(kind: Int)->String{
        if isCoffee{
            if(kind == 1){return "Fragrance"}
            if(kind == 2){return "Body"}
            if(kind == 3){return "Score"}
            if(kind == 4){return "Balance"}
            else{return ""}
        }else{
            if(kind == 1){return "Publisher"}
            if(kind == 2){return "Author"}
            if(kind == 3){return "Score"}
            if(kind == 4){return "Related"}
            else{return ""}
        }
    }
    
    func getAttri(kind: Int, ele: Element) -> String {
        if let element = ele as? BookSt{
            if(kind == 1){return element.publisher}
            if(kind == 2){return element.author}
            if(kind == 3){return String(element.score)}
            if(kind == 4){return element.relatedBook}
            else{return ""}
        }else{
            let coffee = ele as! CoffeeSt
            if(kind == 1){return coffee.fragrance}
            if(kind == 2){return coffee.body}
            if(kind == 3){return String(coffee.score)}
            if(kind == 4){return coffee.balance}
            else{return ""}
        }
    }
    
    func compareAttri(kind: Int, ele1: Element, ele2: Element )->Bool{
        return getAttri(kind: kind, ele: ele1)==getAttri(kind: kind, ele: ele2)
    }
    
    func generateGroups(kind: Int) -> [[Int]] {
        var result = [[Int]]()
        if isCoffee{
            for s in stride(from: 0, to: coffees.count, by: 1){
                var isfind = false
                for i in stride(from: 0, to: result.count, by: 1){
                    let currentCoffee = coffees[s]
                    let coffee2 = coffees[result[i][0]]
                    if compareAttri(kind: kind, ele1: currentCoffee, ele2: coffee2){
                        result[i].append(s)
                        isfind = true
                        break
                    }
                }
                if isfind == false {
                    result.append([s])
                }
            }
        }
        else{
            for s in stride(from: 0, to: books.count, by: 1){
                var isfind = false
                for i in stride(from: 0, to: result.count, by: 1){
                    let currentBook = books[s]
                    let book2 = books[result[i][0]]
                    if compareAttri(kind: kind, ele1: currentBook, ele2: book2){
                        result[i].append(s)
                        isfind = true
                        break
                    }
                }
                if isfind == false {
                    result.append([s])
                }
            }
        }
        return result
    }
    
    func formHeadString(ori: String) -> String {
        var lineori = ori
        //英文 换行
        if(isCoffee){
            for i in stride(from: 12, to: ori.count, by: 12){
                if(lineori.count-i<4){break}
                lineori = lineori.prefix(i) + "\n" + lineori.suffix(lineori.count-i)
            }
        }else{//中文换行
            for i in stride(from: 6, to: ori.count, by: 6){
                if(lineori.count-i<2){break}
                lineori = lineori.prefix(i) + "\n" + lineori.suffix(lineori.count-i)
            }
        }
        return lineori
    }
    
    func displayGroups(kind: Int = 1, finding: String = ""){
        shouldBeInPlace = false
        removeHeadAnchor()

        let nowTrans = arView.session.currentFrame!.camera.transform
        var result = generateGroups(kind: kind)
        var groupName = ""
        if(finding != ""){
            var isFind = false
            for i in stride(from: 0, to: result.count, by: 1) {
                var nowEle = Element()
                if isCoffee {
                    nowEle = coffees[result[i][0]]
                }else{
                    nowEle = books[result[i][0]]
                }
                if(getAttri(kind: kind, ele: nowEle).contains(finding) ){
                    groupName = getAttri(kind: kind, ele: nowEle)
                    if i != 0 {result.swapAt(0, i)}
                    isFind = true
                    break
                }
            }
            if(isFind){
                setMessage("Find group \(groupName) in all \(result.count) groups")
            }else{
                setMessage("Find no group named \"\(finding)\" in all \(result.count) groups")
            }
        }else{
            setMessage("Find \(result.count) groups")
        }
        if(isCoffee == false){
            var absy = Float(0)
            var x = Float(-0.08)
            let z = Float(-1.5*PicMatrix.showDis)
            var maxx = Float(-0.08)
            var groupStartx = Float(-0.08)
            for i in stride(from: 0, to: result.count, by: 1) {
                for j in stride(from: 0, to: result[i].count, by: 1){
                    let id = result[i][j]
                    let nowNode = arView.scene.findEntity(named: "book@\(id)")!
                    let nowElement = books[id]
                    var translation = matrix_identity_float4x4
                    // set z
                    translation.columns.3.z = z-(0.0001*Float(j%5+i%3))
                    //set y
                    if i % 2 == 0{translation.columns.3.y = absy}
                    else{translation.columns.3.y = -1*absy}
                    //set x
                    translation.columns.3.x = x
                    x += 0.03
                    maxx = max(maxx, x)
                    if j==0{
                        let headString = getAttrName(kind: kind)+":\n"+formHeadString(ori: getAttri(kind: kind, ele: nowElement))
                        print(headString)
                        let lineHeight: CGFloat = 0.05
                        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                        let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
                        let textMaterial = SimpleMaterial(color: .red, isMetallic: false)
                        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                        textModel.scale = SIMD3<Float>(x: 0.4, y: 0.4, z: 0.4)
                        let textAnchor = AnchorEntity(world: nowTrans*translation)
                        textAnchor.name = "head@"
                        textAnchor.addChild(textModel)
                        self.arView.scene.addAnchor(textAnchor)
                        x+=0.13
                        translation.columns.3.x = x
                        x+=0.03
                    }
                    nowNode.move(to: nowTrans*translation, relativeTo: rootnode, duration: 0.4)
                }
                if i % 3 == 2{
                    groupStartx = maxx+0.16
                    absy = 0
                }
                else if i % 3 == 0{
                    absy = 0.2
                }

                x = groupStartx

            }
        }else{
            if(picMatrix.count<=0){return}
            guard let menu = arView.scene.findEntity(named: "menu@")else{return}
//            nowTrans = menu.transformMatrix(relativeTo: rootnode)
            var y = Float(0.05)
            var absx = Float(0)
            let z = Float(0.01)
            for i in stride(from: 0, to: result.count, by: 1) {
                for j in stride(from: 0, to: result[i].count, by: 1){
                    let id = result[i][j]
                    let nowNode = arView.scene.findEntity(named: "coffee@\(id)")!
                    let nowElement = coffees[id]
                    var translation = matrix_identity_float4x4
                    // set z
                    translation.columns.3.z = z-(0.0001*Float(j%5+i%3))
                    // set y
                    translation.columns.3.y = y
                    // set x
                    if(i%2==0){
                        translation.columns.3.x = absx
                    }else{
                        translation.columns.3.x = -1*absx
                    }
                    y -= 0.01
                    if j==0{
                        translation.columns.3.x -= 0.02
                        let headString = getAttrName(kind: kind)+":\n"+formHeadString(ori: getAttri(kind: kind, ele: nowElement))
                        print(headString)
                        let lineHeight: CGFloat = 0.05
                        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                        let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
                        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                        textModel.name = "head@"
                        textModel.transform = Transform(matrix: translation)
                        textModel.scale = SIMD3<Float>(x: 0.2, y: 0.2, z: 0.2)
//                        let textAnchor = AnchorEntity(world: nowTrans*translation)
//                        textAnchor.name = "head@\(i)"
                        menu.addChild(textModel)
//                        self.arView.scene.addAnchor(textAnchor)
                        y-=0.01
                        translation.columns.3.y = y
                        y-=0.01
                    }
                    nowNode.move(to: translation, relativeTo: nowNode.parent, duration: 0.4)
                }
                if(i%2==0){absx+=0.08}
                y = Float(0.05)
            }
        }
    }
}
