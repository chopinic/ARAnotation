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
            displayGroups(kind: nowSelection, finding: text)
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
                let translation = node.transformMatrix(relativeTo: rootnode)
                var trans = Transform(matrix: translation)
                trans.scale = SIMD3<Float>(x: 2, y: 2, z: 2)
//                translation.columns.3.w = 2
//                translation.columns.3.y = Float(x)
                
                node.move(to: trans, relativeTo: rootnode, duration: 0.4)
            }
            else{
                let translation = node.transformMatrix(relativeTo: rootnode)
                var trans = Transform(matrix: translation)
                trans.scale = SIMD3<Float>(x: 1, y: 1, z: 1)
                node.move(to: trans, relativeTo: rootnode, duration: 0.4)
            }
        }
    }
    
    
//    func
    
    func showAbstract(id: Int){
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
        shouldBeInPlace = false
        removeHeadAnchor()


        let z = -1*PicMatrix.showDis
        var absy =  0.0
        let x =  -0.1
        let nowTrans = arView.session.currentFrame!.camera.transform
        elementWeights.sort(by: {$0.weight > $1.weight})
        for i in stride(from: 0, to: elementWeights.count ,by: 1){
            let elementWeight = elementWeights[i]
            var nowNode : Entity
            if isCoffee{
                nowNode = arView.scene.findEntity(named: "coffee@\(elementWeight.id)")!
            }else{
                nowNode = arView.scene.findEntity(named: "book@\(elementWeight.id)")!
            }
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(z)
            translation.columns.3.y = Float(x)
            if(i%2 != 0){
                translation.columns.3.x = Float(absy)
            }
            else{
                translation.columns.3.x = Float(-1*absy)
                absy += 0.03
            }
//            let sortNode = SCNNode()
//            sortNode.transform = SCNMatrix4(nowTrans*translation)
//            let nowPosVec = sortNode.position
            nowNode.move(to: nowTrans*translation, relativeTo: rootnode, duration: 0.4)
//            let trans = SCNAction.move(to: nowPosVec, duration: 0.4)
//            SCNAction.customAction(duration: 0.4) { (node, elapsedTime) in
//                nowNode.transform = SCNMatrix4(nowTrans*translation)
//            }
//            nowNode.runAction(trans)
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
//        hideBookAbstract()
        isAntUpdate = !isAntUpdate
    }
    
    @objc func restoreDisplay(){
        shouldBeInPlace = true
        scaleNodes(ids: [])
        hideAbstract()
        removeHeadAnchor()

        let childNodes = getEntityList()
        for node in childNodes {
            let name = node.name
            guard isCoffee&&name.hasPrefix("coffee@") || isCoffee==false&&name.hasPrefix("book@") else {
                return
            }
            let id = getIdFromName(name)
            if self.isCoffee{
                node.move(to: self.coffees[id].oriTrans, relativeTo: rootnode, duration: 0.4)
// .transform =
            }else{
                node.move(to: self.books[id].oriTrans, relativeTo: rootnode, duration: 0.4)
            }

        }


    }

}
