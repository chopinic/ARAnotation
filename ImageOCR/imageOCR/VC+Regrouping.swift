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
        if mode==1{
            if(kind == 1){return ""}
            if(kind == 2){return "Rating"}
            if(kind == 3){return "Milk"}
            if(kind == 4){return "Caffeine"}
            if(kind == 5){return "Sugar"}
            if(kind == 6){return "Calories"}
            if(kind == 7){return "Protein"}
            if(kind == 8){return "Fat"}
            else{return ""}
        } else if mode == 2 {
            if(kind == 0){return "Shadowtype"}
            if(kind == 1){return "Eyetype"}
            if(kind == 2){return "Scheme"}
            else{return ""}
        }else{
            if(kind == 1){return "Publisher"}
            if(kind == 2){return "Author"}
            if(kind == 3){return "Rating"}
            if(kind == 4){return "Price"}
            else{return ""}
        }
    }
    
    func getAttrValue(kind: Int, ele: Element) -> Double? {
        if let element = ele as? BookSt{
            if(kind == 3){return element.score}
            if(kind == 4){return element.price}
        }else if let coffee = ele as? CoffeeSt{
            if(kind == 2){return coffee.score}
            if(kind == 3){return coffee.milk}
            if(kind == 4){return coffee.caffeine}
            if(kind == 5){return coffee.sugar}
            if(kind == 6){return coffee.calories}
            if(kind == 7){return coffee.protein}
            if(kind == 8){return coffee.fat}
        }
        
        return nil

    }
    
    func getAttri(kind: Int, ele: Element) -> String {
        if let element = ele as? BookSt{
            if(kind == 1){return element.publisher}
            if(kind == 2){return element.author}
            if(kind == 3){return String(element.score)}
            if(kind == 4){return String(element.price)}
            else{return ""}
        }else if let coffee = ele as? CoffeeSt{
            if(kind == 1){return coffee.belong}
            if(kind == 2){return String(coffee.score)}
            if(kind == 3){return String(coffee.milk)}
            if(kind == 4){return String(coffee.caffeine)}
            if(kind == 5){return String(coffee.sugar)}
            if(kind == 6){return String(coffee.calories)}
            if(kind == 7){return String(coffee.protein)}
            if(kind == 8){return String(coffee.fat)}
            else{return ""}
        }else{
            let color = ele as! ColorSt
            if(kind == 0){return color.shadowtype}
            if(kind == 1){return color.eyetype}
            if(kind == 2){return String(color.scheme)}
            else{return ""}
        }
    }
    
    func evenValue(_ kind: Int, _ value: String) -> String{
        let a = Double(value) ?? 0
        if mode == 0{
            if kind == 3{
                if a <= 2{return "<= 2"}
                else if a<=3{return "2 ~ 3"}
                else if a<=4{return "3 ~ 4"}
                else {return "4 ~ 5"}
            }
            if kind == 4{
                if a <= 10{return "<= 10¥"}
                else if a <= 30{return "10¥ ~ 30¥"}
                else if a <= 50{return "30¥ ~ 50¥"}
                else{return "> 50¥"}
            }
        }
        if mode == 1{
            if kind == 2{
                return String(Int(a))
            }
            if kind == 3 || kind == 4{
                if a <= 0.05{return "< 5%"}
                else if a <= 0.15{return "5% ~ 15%"}
                else if a <= 0.25{return "15% ~ 25%"}
                else{return "> 25%"}
            }else if kind == 5{
                if a <= 0.05{return "Sugar Free"}
                else if a <= 0.15{return "Slightly Sweet"}
                else if a <= 0.25{return "Medium Sweet"}
                else{return "Sweet"}
            }else if kind == 6{
                if a <= 10{return "<= 10cal"}
                else if a <= 40{return "10cal ~ 40cal"}
                else if a <= 120{return "40cal ~ 120cal"}
                else{return "> 120cal"}
            }else if kind == 7 || kind == 8{
                if a <= 5{return "<= 5g"}
                else if a <= 10{return "5g ~ 10g"}
                else if a <= 30{return "10g ~ 30g"}
                else{return "> 30g"}
            }
        }
        if mode == 2{
//            if kind == 2{
//                return "Scheme"
//            }
        }
        return value
    }
    
    
    func generateGroupValue(id: Int, kind: Int, element: Element){
        if let v = getAttrValue(kind: kind, ele: element){
            elementWeights[id].weight = v
            elementWeights[id].id = id
        }
    }
    
    func compareAttri(kind: Int, ele1: Element, ele2: Element )->Bool{
        return evenValue(kind,getAttri(kind: kind, ele: ele1))==evenValue(kind,getAttri(kind: kind, ele: ele2))
    }
    
    func transferOrderToId(result: [[Int]] )->[[Int]]{
        guard mode == 1 else {
            setMessage("Not in coffee mode!")
            return [[Int]]()
        }
        let group = ["Hot Coffees","Cold Coffees","Hot Teas","Iced Teas","Drinks"]
        var ans = [[Int]]()
        for i in stride(from: 0, to: result.count, by: 1){
            ans.append([Int]())
            for j in stride(from: 0, to: result[i].count, by: 1){
                for k in stride(from: 0, to: coffees.count, by: 1){
                    if coffees[k].order == result[i][j] && coffees[k].belong == group[i]{
                        ans[i].append(k)
                        break
                    }
                }
            }
        }
        return ans
    }
    
    func generateGroups(kind: Int) -> [[Int]] {
        var result = [[Int]]()
        if mode==1{
            if kind == 1 {
                result = [[1,2,3,4,5,6,7,8,9,10],[1,2,3,4,5,6,7,8,9,10],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4]]
                
                nowGroups = transferOrderToId(result: result)
                return nowGroups
            }
            for s in stride(from: 0, to: coffees.count, by: 1){
                var isfind = false
                generateGroupValue(id: s, kind: kind, element: coffees[s])
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
        } else if mode == 2 {
            for s in stride(from: 0, to: colors.count, by: 1){
                var isfind = false
                for i in stride(from: 0, to: result.count, by: 1){
                    let currentColor = colors[s]
                    let color2 = colors[result[i][0]]
                    if compareAttri(kind: kind, ele1: currentColor, ele2: color2){
                        result[i].append(s)
                        isfind = true
                        break
                    }
                }
                if isfind == false {
                    result.append([s])
                }
            }

        }else{
            for s in stride(from: 0, to: books.count, by: 1){
//                if books[s].entityId == -1{continue}
                var isfind = false
                generateGroupValue(id: s, kind: kind, element: books[s])
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
        nowGroups = result
        return result
    }
    
    func getPrefixHead(_ kind: Int)->String{
        if mode == 0{
            return getAttrName(kind: kind)+": "
        }

        if mode == 1{
            if(kind == 1){return ""}
            else if (kind == 5){return ""}
            else{
                return getAttrName(kind: kind)+": "
            }
        }
        else{
            if(kind == 1){return "Eyetype"}
            if(kind == 2){return "Scheme"}
        }
        return ""
    }
    
    func getSubfixHead(_ kind: Int)->String{
        if mode == 0{
            if(kind == 1){return ""}
            if(kind == 2){return ""}
            if(kind == 3){return " / 5"}
//            if(kind == 4){return " ¥ "}
        }
        if mode == 1{
            if(kind == 1){return ""}
            if(kind == 2){return " / 5"}
//            if(kind == 3){return " % "}
//            if(kind == 4){return " % "}
//            if(kind == 5){return " cal "}
//            if(kind == 6){return " g "}
//            if(kind == 7){return " g "}
        }
        return ""
    }

    func formHeadString(ori: String) -> String {
        var lineori = ori
        if(mode==1){
            
            
        } else if mode==2 {
            for i in stride(from: 18, to: ori.count, by: 18){
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
    
    func displayGroups(_ kind: Int = 1,_ finding: String = "",_ enableHighlight: Bool = true){
//        shouldBeInPlace = false
        removeHeadAnchor()
        cmpGroup = [Int]()
        isInRegroupView = true

        let nowTrans = arView.session.currentFrame!.camera.transform

        var result = generateGroups(kind: kind)
        var groupName = ""
        if(finding != ""){
            var isFind = false
            for i in stride(from: 0, to: result.count, by: 1) {
                var nowEle = Element()
                if mode==1 {
                    nowEle = coffees[result[i][0]]
                } else if mode==2 {
                    nowEle = colors[result[i][0]]
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
                if enableHighlight{highlightNodes(result[0])}
            }else{
                setMessage("Find no group named \"\(finding)\" in all \(result.count) groups")
                highlightNodes([Int]())
            }
        }else{
            setMessage("Find \(result.count) groups")
        }
        if(mode == 0){
            
            var absy = Float(0)
            var x = Float(-0.4)
            let z = Float(-1*PicMatrix.showDis)
            var maxx = x
            var groupStartx = x
            
            var translation = matrix_identity_float4x4
            translation.columns.3.z = z
            translation.columns.3.y = -1.8
            translation.columns.3.x = 0
            loadBookShelf(nowTrans*translation)
            for i in stride(from: 0, to: result.count, by: 1) {
                var jj = -1
                for j in stride(from: 0, to: result[i].count, by: 1){
                    let id = result[i][j]
                    let nowNode = scanEntitys[id]
                    if getIdFromName(nowNode.name) == -1{continue}
                    jj+=1
                    let nowElement = books[id]
                    // set z
                    translation.columns.3.z = z-(0.0001*Float(j%5+i%3))
                    // set y
                    if i % 2 == 0{translation.columns.3.y = absy}
                    else{translation.columns.3.y = -1*absy}
                    // set x
                    translation.columns.3.x = x
                    x += 0.05
                    maxx = max(maxx, x)
                    if jj==0{
                        let headString = getPrefixHead(kind)+"\n"+addTitleReturn(getAttri(kind: kind, ele: nowElement)) + getSubfixHead(kind)
                        print(headString)
                        let lineHeight: CGFloat = 0.05
                        let font = MeshResource.Font.boldSystemFont(ofSize: lineHeight)
                        let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
                        let textMaterial = SimpleMaterial(color: .red, isMetallic: false)
                        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                        textModel.scale = SIMD3<Float>(x: 0.5, y: 0.5, z: 0.5)
                        let textAnchor = AnchorEntity(world: nowTrans*translation)
                        textAnchor.name = "head@"
                        textAnchor.addChild(textModel)
                        self.arView.scene.addAnchor(textAnchor)
                        x+=0.13
                        translation.columns.3.x = x
                        x+=0.05
                    }
                    nowNode.move(to: nowTrans*translation, relativeTo: rootnode, duration: 0.4)
                    books[id].tempTrans = nowTrans*translation
                }
                if i % 3 == 2{
                    groupStartx = maxx+0.16
                    if i/3 == 1{groupStartx-=0.06}
                    absy = 0
                }
                else if i % 3 == 0{
                    absy = 0.5
                }

                x = groupStartx

            }
        }else if mode == 2 {
            var y = Float(0.15)
            var absx = Float(0)
            var z = Float(-0.3)
            var translation = matrix_identity_float4x4

            var cot = 0
            for i in stride(from: 0, to: result.count, by: 1) {
                for j in stride(from: 0, to: result[i].count, by: 1){
                    let id = result[i][j]
                    let nowNode = scanEntitys[id]
                    let nowElement = colors[id]
                    // set z
                    translation.columns.3.z = z-(0.0001*Float(j%5+i%3))
                    // set x
                    if i % 2 == 0{translation.columns.3.x = absx}
                    else{translation.columns.3.x = -1*absx}
                    // set y
                    translation.columns.3.y = y
                    if j==0{
                        var headString = getPrefixHead(kind) + "\n" + evenValue(kind, getAttri(kind: kind, ele: nowElement) ) + getSubfixHead(kind) + "\n"
                        if kind == 2
                        {headString = headString + eyeshadowscheme[i]}
                        print(headString)
                        let lineHeight: CGFloat = 0.05
                        let font = MeshResource.Font.boldSystemFont(ofSize: lineHeight)
                        let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
                        let textMaterial = SimpleMaterial(color: .red, isMetallic: false)
                        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                        textModel.scale = SIMD3<Float>(x: 0.2, y: 0.2, z: 0.2)
                        textModel.position = SIMD3<Float>(x: -1*textMesh.bounds.boundingRadius*0.2, y: 0, z: 0)
                        let textAnchor = AnchorEntity(world: nowTrans*translation)
                        textAnchor.name = "head@"
                        textAnchor.addChild(textModel)
                        self.arView.scene.addAnchor(textAnchor)
                        y -= 0.024
                        translation.columns.3.y = y
                    }
                    if j > 5 && kind == 2{
                        translation.columns.3.z += 10
                    }
                    var trans = Transform(matrix: nowTrans*translation)
                    let radio = Float(0.015/colors[id].size.width)
                    trans.scale = SIMD3<Float>(x: radio, y: radio, z: radio)
                    nowNode.move(to: trans, relativeTo: rootnode, duration: 0.4)
        //            let picContents = elementPics[currentBook.picid]
                    colors[id].tempTrans = nowTrans*translation
                    y -= 0.025
                }
                y = 0.15-0.01*Float(cot)
                if(i%2==0){absx += 0.08; z -= 0.06; cot+=1}
            }
        }else if coffeeAdhoc{
            if(picMatrix.count<=0){return}
            guard let menu = arView.scene.findEntity(named: "menu@")else{return}
            groupPosCha = [Double]()
            groupPosChaLimit = [Double]()
            for i in stride(from: 0, to: result.count, by: 1) {
                let ystep = Float(coffeeOffset.step/coffeeOffset.rad)
                let x = Float(coffeeOffset.xx[i]/coffeeOffset.rad)-0.015
                var y = Float(coffeeOffset.yy[i]/coffeeOffset.rad)
                groupPosCha.append(Double(result[i].count-1)*Double(ystep))
                groupPosChaLimit.append(Double(result[i].count-1)*Double(ystep))
                for j in stride(from: 0, to: result[i].count, by: 1){
                    let id = result[i][j]
                    let nowNode = arView.scene.findEntity(named: "coffee@\(id)")!
                    let nowElement = coffees[id]
                    var translation = matrix_identity_float4x4
                    // set y
                    translation.columns.3.y = y
                    // set x
                    translation.columns.3.x = x
                    y -= ystep
                    if j==0{
                        translation.columns.3.x -= 0.01
                        let headString = getPrefixHead(kind) + evenValue(kind, getAttri(kind: kind, ele: nowElement)) + getSubfixHead(kind)
                        print(headString)
                        let lineHeight: CGFloat = 0.05
                        let font = MeshResource.Font.boldSystemFont(ofSize: lineHeight)
                        let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
                        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                        textModel.name = "head@"
                        textModel.transform = Transform(matrix: translation)
                        textModel.scale = SIMD3<Float>(x: 0.18, y: 0.18, z: 0.18)
                        if menu.findEntity(named: "big") != nil{
                            textModel.scale = SIMD3<Float>(x: 0.84, y: 0.84, z: 0.84)
                        }
                        menu.addChild(textModel)
                        y -= ystep
                        translation.columns.3.y = y
                        y -= ystep
                        translation.columns.3.x = x
                    }
                    if checkIfVisible(i,translation.columns.3.y)==false{
                        translation.columns.3.z = -10.50
                    }else{
                        translation.columns.3.z = 0.010
                    }
                    nowNode.move(to: translation, relativeTo: nowNode.parent, duration: 0.4)
                }
            }
            
            
        }
        else{
            if(picMatrix.count<=0){return}
            guard let menu = arView.scene.findEntity(named: "menu@")else{return}
            cmpGroup = [Int]()
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
                        menu.addChild(textModel)
                        y-=0.01
                        translation.columns.3.y = y
                        y-=0.01
                        translation.columns.3.x += 0.02

                    }
                    nowNode.move(to: translation, relativeTo: nowNode.parent, duration: 0.4)
                }
                if(i%2==0){absx+=0.08}
                y = Float(0.05)
            }
        }
        checkIfHidden()
    }
}
