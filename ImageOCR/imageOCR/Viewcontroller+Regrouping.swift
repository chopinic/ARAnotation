//
//  Viewcontroller+Regrouping.swift
//  imageOCR
//
//  Created by 杨光 on 2020/12/5.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import ARKit
import UIKit
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
    
    func displayGroups(kind: Int = 1, finding: String = ""){
        shouldBeInPlace = false
        removeHeadAnchor()

        let nowTrans = sceneView.session.currentFrame!.camera.transform
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

            }
            else{
                setMessage("Find no group named \"\(finding)\" in all \(result.count) groups")
            }
        }else{
            setMessage("Find \(result.count) groups")
        }
        var absx = 0.0
        var y = -0.08
        let z = -1.5*PicMatrix.itemDis
        var maxy = -0.08;
        var groupStarty = -0.08
        for i in stride(from: 0, to: result.count, by: 1) {
            for j in stride(from: 0, to: result[i].count, by: 1){
                let id = result[i][j]
                var nowNode = Optional<SCNNode>(SCNNode())
                var nowElement = Element()
                if isCoffee{
                    nowElement = coffees[id]
                    nowNode = sceneView.scene.rootNode.childNode(withName: "coffee@\(id)", recursively: false)
                }else{
                    nowElement = books[id]
                    nowNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false)
                }
                
                var translation = matrix_identity_float4x4
                translation.columns.3.z = Float(z)
                if i % 2 == 0{translation.columns.3.x = Float(absx)}
                else{translation.columns.3.x = Float(-1*absx)}
                translation.columns.3.y = Float(y)
                y += 0.03
                maxy = max(maxy, y)
                let sortNode = SCNNode()
                sortNode.transform = SCNMatrix4(nowTrans*translation)
                let nowPosVec = sortNode.position
                if j==0{
                    translation.columns.3.y -= Float(PicMatrix.itemDis/4)
                    translation.columns.3.x += Float(PicMatrix.itemDis/4)
                    let headString = getAttrName(kind: kind)+": \n"+getAttri(kind: kind, ele: nowElement)
                    print(headString)
                    let headAnchor = HeadAnchor(text: headString, transform: nowTrans*translation)
                    self.sceneView.session.add(anchor:headAnchor)
                }
                let trans = SCNAction.move(to: nowPosVec, duration: 0.4);
                SCNAction.customAction(duration: 0.4) { (node, elapsedTime) in
                    nowNode!.transform = SCNMatrix4(nowTrans*translation)
                }
                nowNode!.runAction(trans)
            }
            if i % 3 == 2{
                groupStarty = maxy+0.16
                absx = 0
            }
            else if i % 3 == 0{
                absx = 0.2
            }

            y = groupStarty

        }
    }
}
