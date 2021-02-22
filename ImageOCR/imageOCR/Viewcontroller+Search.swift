//
//  Viewcontroller+Search.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/19.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import ARKit
import RealityKit
import UIKit

extension ViewController: UITextFieldDelegate{
    
    
    public func setMessage(_ text: String){
        DispatchQueue.main.async{
            self.message.text = text
        }
    }

    
    func getIdFromName(_ name: String) -> Int {
        let i = name.index(after: name.firstIndex(of: "@")!)
        return Int(name.suffix(from: i))!
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print(textField.text)
        if(textField == message) {return false}
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
//        if(textField.na == message) {return false}
        let text = textField.text ?? ""
        if(nowSelection == 0)
        {
            if(text != "")
            {findString(lookFor:text)}
        }
        else{
            displayGroups(nowSelection, text)
        }
        textField.resignFirstResponder()
        return true
    }
        
    
    public func findString(lookFor: String){
        print("start find")
        var findResult = [Int]()
        if isCoffee{
            for i in stride(from: 0, to: coffees.count ,by: 1){
                let element = coffees[i]
                elementWeights[i].id = i;
                if element.name.contains(lookFor)
                {
                    elementWeights[i].weight = (Double(lookFor.count)/Double(element.name.count))
                    findResult.append(i)
                }
                else{
                    elementWeights[i].weight = 0
                }
            }
        }else{
            for i in stride(from: 0, to: books.count ,by: 1){
                let singlebook = books[i]
                elementWeights[i].id = i;
                elementWeights[i].weight = 0;

                for j in stride(from: 0, to: singlebook.words.count ,by: 1){
                    if singlebook.words[j].contains(lookFor){
                        findResult.append(i)
                        elementWeights[i].update(w: Double(lookFor.count)/Double(singlebook.words[j].count));
                        break
                    }else{
                        elementWeights[i].update(w: 0);
                    }
                }
            }
        }
        if(findResult.count == 0){
            print("no result")
            setMessage("Find no related result")
            resetSearch()
            return;
        }
        print("find \(findResult.count) results")
        setMessage("Find \(findResult.count) related results")
        scaleNodes(ids: findResult)
        //showBookAbstract(id: focusId)
    }
    
    public func scaleNodes(ids: [Int], time: Double = 0.4){
        isAntUpdate = false
//        let closer = SCNAction.moveBy(x: 0, y: 0, z: 0.01, duration: 0.4)
        

        for node in getEntityList(){
            let name = node.name
            var elementId = -1
            if isCoffee{guard name.hasPrefix("coffee@") else {return}}
            else{guard name.hasPrefix("book@") else {return}}
            elementId = getIdFromName(name)

            if ids.firstIndex(of: elementId) != nil{
//                var enhance =
//                enhance.scale = SIMD3<Float>(x: 2, y: 2, z: 1)
//                node.move(to: enhance, relativeTo: node.parent, duration: 0.2)
                let dis = 0.001*Float(elementId%13)
                let translation = getForwardTrans(ori: node.transformMatrix(relativeTo: rootnode), dis: dis)
                var trans = Transform(matrix: translation)
                trans.scale = SIMD3<Float>(x: 2, y: 2, z: 2)
//                translation.columns.3.w = 2
//                translation.columns.3.y = Float(x)
                
                node.move(to: trans, relativeTo: rootnode, duration: 0.4)
            }
            else{
                let translation = getForwardTrans(ori: node.transformMatrix(relativeTo: rootnode), dis: -0.005)
                var trans = Transform(matrix: translation)
                trans.scale = SIMD3<Float>(x: 1, y: 1, z: 1)
                node.move(to: trans, relativeTo: rootnode, duration: 0.4)
            }
        }
    }
    
    
//    func
    
    func openBook(_ id: Int){
        for i in stride(from: 0, to: books.count, by: 1){
            let book = findById(id: i) as! AnchorEntity

            if books[i].isOpen == false{
                books[i].tempTrans = book.transformMatrix(relativeTo: book.parent)
            }
            if id == i {
                if books[i].isOpen == true{
                    continue
                }
                
                let bookBox = book.findEntity(named: "bookBox") as! ModelEntity
                let left = bookBox.findEntity(named: "left")!
                let right = bookBox.findEntity(named: "right")!
                
                var trans = arView.session.currentFrame!.camera.transform
                var translation = matrix_identity_float4x4
                translation.columns.3.z = Float(-0.34)

                trans = trans * translation * makeRotationMatrixY(angle: .pi)
                book.move(to: trans, relativeTo: book.parent, duration: 0.4)
                
                var rotation = left.transform.matrix * makeRotationMatrix(x: 0, y: -.pi/2, z: 0)
                left.move(to: rotation, relativeTo: bookBox, duration: 0.8)
                rotation = right.transform.matrix * makeRotationMatrix(x: 0, y: .pi/2, z: 0)
                right.move(to: rotation, relativeTo: bookBox, duration: 0.8)
                books[i].isOpen = true
                continue
            }

            else if books[i].isOpen == true{
                let bookBox = book.findEntity(named: "bookBox") as! ModelEntity
                let left = bookBox.findEntity(named: "left")!
                let right = bookBox.findEntity(named: "right")!
                book.move(to: books[i].tempTrans, relativeTo: book.parent, duration: 0.4)

                var rotation = left.transform.matrix * makeRotationMatrix(x: 0, y: .pi/2, z: 0)
                left.move(to: rotation, relativeTo: bookBox, duration: 0.4)
                rotation = right.transform.matrix * makeRotationMatrix(x: 0, y: -.pi/2, z: 0)
                right.move(to: rotation, relativeTo: bookBox, duration: 0.4)
                books[i].isOpen = false
            }
        }
    }
    
    func showAbstract(id: Int){
        if id < 0{
            hideAbstract()
        }
        if isCoffee{
            coffeeAbstractUI.id = id
            coffeeAbstractUI.setImage(elementPics[coffees[id].desPicid])
            coffeeAbstractUI.setText(coffees[id].generateAbstract())
            coffeeAbstractUI.setIsHidden(false)
        }else{
            bookAbstractUI.id = id
            bookAbstractUI.setText(books[id].generateAbstract())
            bookAbstractUI.setIsHidden(false)
        }
    }
    
    func hideAbstract(){
        if isCoffee{
            coffeeAbstractUI.setIsHidden(true)
        }else{
            bookAbstractUI.setIsHidden(true)
        }
    }
        
    public func resetSearch(){
        scaleNodes(ids: [])
        hideAbstract()
    }
    
    @objc func changeToSortDisplay(){
        
        scaleNodes(ids: [])
        hideAbstract()
//        shouldBeInPlace = false
        removeHeadAnchor()


        let z = -1*PicMatrix.showDis
        var absy =  0.0
        let x =  0
        let nowTrans = arView.session.currentFrame!.camera.transform
        elementWeights.sort(by: {$0.weight > $1.weight})
        var translation = matrix_identity_float4x4
        if(isCoffee==false){
            translation.columns.3.z = Float(z)
            translation.columns.3.y = -1.8
            translation.columns.3.x = 0
            loadBookShelf(nowTrans*translation)
        }
        for i in stride(from: 0, to: elementWeights.count ,by: 1){
            let elementWeight = elementWeights[i]
            var nowNode : Entity
            if isCoffee{
                nowNode = arView.scene.findEntity(named: "coffee@\(elementWeight.id)")!
            }else{
                nowNode = arView.scene.findEntity(named: "book@\(elementWeight.id)")!
            }
            translation.columns.3.z = Float(z)-(0.0001*Float(i%5))

            translation.columns.3.y = Float(x)
            if(i%2 != 0){
                translation.columns.3.x = Float(absy)
            }
            else{
                translation.columns.3.x = Float(-1*absy)
                absy += 0.055
            }
            nowNode.move(to: nowTrans*translation, relativeTo: rootnode, duration: 0.4)
            books[i].tempTrans = nowTrans*translation
        }
    }
    
    func calculateXDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
//        return Double(pow(pow((pos1.x-pos2.x), 2)+pow((pos1.y-pos2.y), 2),0.5))
        
        return Double(sqrt(pow( pos1.x-pos2.x,2)))
    }
    func calculateScreenDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
        return Double(pow(pow((pos1.x-pos2.x), 2)+pow((pos1.y-pos2.y), 2),0.5))
    }
    func calculateYDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
        return Double(pow(pow(pos1.y-pos2.y, 2),0.5))
    }
    @objc func stopAntEyeDisplay(){
        isAntUpdate = !isAntUpdate
    }
    
    
    @objc func startAntEyeDisplay(){
        scaleNodes(ids: [], time: 0.0)
        recStart = 0
//        hideBookAbstract()
        isAntUpdate = !isAntUpdate
    }
    
    @objc func restoreDisplay(){
//        shouldBeInPlace = true
        scaleNodes(ids: [])
        hideAbstract()
        removeHeadAnchor()
        removeBookShelf()
        openBook(-1)
        let childNodes = getEntityList()
        for node in childNodes {
            let name = node.name
            guard isCoffee&&name.hasPrefix("coffee@") || isCoffee==false&&name.hasPrefix("book@") else {
                return
            }
            let id = getIdFromName(name)
            if self.isCoffee{
                node.move(to: self.coffees[id].oriTrans, relativeTo: node.parent, duration: 0.4)
// .transform =
            }else{
                node.move(to: self.books[id].oriTrans, relativeTo: node.parent, duration: 0.4)
                books[id].tempTrans = books[id].oriTrans
            }

        }


    }

    func checkBookShelf()->Bool{
        if let _ = arView.scene.findEntity(named: "bookShelf"){
            return true
        }
        return false
    }
    func loadBookShelf(_ trans:simd_float4x4){
        removeBookShelf()
        let bookShelf = try! Entity.loadModel(named: "bookShelf")
        let bookShelf1 = bookShelf.clone(recursive: true)
        bookShelf1.position = SIMD3<Float>(x: -1.22, y: 0, z: 0)
        let bookShelf2 = bookShelf.clone(recursive: true)
        bookShelf2.position = SIMD3<Float>(x: 1.22, y: 0, z: 0)

        print("loading entity")
        let anchor = AnchorEntity(world: trans )
        anchor.addChild(bookShelf)
        anchor.addChild(bookShelf1)
        anchor.addChild(bookShelf2)
//        bookShelf.scale = SIMD3<Float>(x: 0.1, y: 0.1, z: 0.1)
        anchor.name = "bookShelf"
        arView.scene.anchors.append(anchor)
        return
    }
    func removeBookShelf(){
        if let anchor = arView.scene.findEntity(named: "bookShelf"){
            anchor.removeFromParent()
        }
    }
}
