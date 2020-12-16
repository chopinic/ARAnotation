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
    
    func getAttri(kind: Int, book: BookSt) -> String {
        if(kind == 1){return book.publisher}
        if(kind == 2){return book.author}
        if(kind == 3){return String(book.score)}
        if(kind == 4){return book.relatedBook}
        else{return ""}
    }
    
    
    
    func getAttri(kind: Int, coffee: CoffeeSt) -> String {
        if(kind == 1){return coffee.fragrance}
        if(kind == 2){return coffee.body}
        if(kind == 3){return String(coffee.score)}
        if(kind == 4){return coffee.balance}
        else{return ""}
    }

    
    func compareAttri(kind: Int, book1: BookSt, book2: BookSt )->Bool{
        return getAttri(kind: kind, book: book1)==getAttri(kind: kind, book: book2)
    }
    
    func generateGroups(kind: Int) -> [[Int]] {
        var result = [[Int]]()
        for s in stride(from: 0, to: books.count, by: 1){
            var isfind = false
            for i in stride(from: 0, to: result.count, by: 1){
                let currentBook = books[s]
                let book2 = books[result[i][0]]
                if compareAttri(kind: kind, book1: currentBook, book2: book2){
                    result[i].append(s)
                    isfind = true
                    break
                }
            }
            if isfind == false {
                result.append([s])
            }
        }
        return result
    }
    
    func displayGroups(kind: Int = 1, finding: String = ""){
        shouldBeInPlace = false
        removeHeadAnchor()

        let nowTrans = sceneView.session.currentFrame!.camera.transform
        var result = generateGroups(kind: kind)
        if(finding != ""){
            var isFind = false
            for i in stride(from: 0, to: result.count, by: 1) {
                if(getAttri(kind: kind, book: books[result[i][0]]).contains(finding) ){
                    if i != 0 {result.swapAt(0, i)}
                    isFind = true
                    print("find group kind: \(kind)!")
                    break
                }
            }
            if(isFind){
                setMessage("Find group \"\(getAttri(kind: kind, book: books[result[0][0]]))\" in all \(result.count) groups")

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
                let nowBookNode = sceneView.scene.rootNode.childNode(withName: "book@\(result[i][j])", recursively: false)!
                var translation = matrix_identity_float4x4
                translation.columns.3.z = Float(z)
                if i % 2 == 0{translation.columns.3.x = Float(absx)}
                else{translation.columns.3.x = Float(-1*absx)}
                translation.columns.3.y = Float(y)
                y += 0.03
                maxy = max(maxy, y)
                let bookSortNode = SCNNode()
                bookSortNode.transform = SCNMatrix4(nowTrans*translation)
                if j==0{
                    print(getAttri(kind: kind, book:books[id]))
                    translation.columns.3.y -= 0.1
                    translation.columns.3.x += 0.1
                    var headString = getAttrName(kind: kind)+": \n"+getAttri(kind: kind, book:books[id])
                    let headAnchor = HeadAnchor(text: headString, transform: nowTrans*translation)
                    self.sceneView.session.add(anchor:headAnchor)
                }
                let nowPosVec = bookSortNode.position
                let trans = SCNAction.move(to: nowPosVec, duration: 0.4);
                SCNAction.customAction(duration: 0.4) { (node, elapsedTime) in
                    nowBookNode.transform = SCNMatrix4(nowTrans*translation)
                }
                nowBookNode.runAction(trans)
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
