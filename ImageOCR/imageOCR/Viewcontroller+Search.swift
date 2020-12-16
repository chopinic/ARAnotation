//
//  Viewcontroller+Search.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/19.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import ARKit
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
        let enhance = SCNAction.scale(to: CGFloat(2), duration: time)
        enhance.timingMode = .easeOut
        
        let disenhance = SCNAction.scale(to: 1, duration: time)
        disenhance.timingMode = .easeOut

        for node in sceneView.scene.rootNode.childNodes{
            guard let name = node.name else {
                continue
            }
            var elementId = -1
            if isCoffee{guard name.hasPrefix("coffee@") else {return}}
            else{guard name.hasPrefix("book@") else {return}}
            elementId = getIdFromName(name)

            if ids.firstIndex(of: elementId) != nil{
                node.runAction(enhance)
                let material = node.geometry!.firstMaterial!
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5

                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5

                    material.emission.contents = UIColor.black

                    SCNTransaction.commit()
                }

                material.emission.contents = UIColor.yellow

                SCNTransaction.commit()
            }
            else{node.runAction(disenhance)}
        }
    }
    
    
//    func
    
    func showAbstract(id: Int){
        if isCoffee{
            coffeeAbstractUI.coffeeId = id
            coffeeAbstractUI.setImage(elementPics[coffees[id].desPicid])
            coffeeAbstractUI.setText(coffees[id].generateText())
            coffeeAbstractUI.setIsHidden(false)
            nowShowAbsId = coffeeAbstractUI.coffeeId

        }else{
            let currentBook = books[id]
            let abstract = currentBook.generateAbstract()
            DispatchQueue.main.async{
                self.bookAbstractUI.bookId = id
                self.nowShowAbsId = id
//                self.bookAbstractUI.frame = CGRect(x: pos2d.x, y: pos2d.y, width: CGFloat(self.textWidth), height: CGFloat(self.textHeight))
                self.bookAbstractUI.text = abstract
                self.bookAbstractUI.isHidden = false
                self.isBookHidden = false
            }
        }
    }
    
    func hideAbstract(){
        if isCoffee{
            coffeeAbstractUI.setIsHidden(true)
        }else{
            DispatchQueue.main.async{
                self.bookAbstractUI.isHidden = true
                self.isBookHidden = true
            }
        }
    }
    
//    func generateAbstract(currentBook: BookSt)-> String{
//        var abstractscore = ""
//        for _ in stride(from: 0, to: currentBook.score ,by: 1){
//            abstractscore+="⭐️"
//        }
//        var abstract = ""
//        for bookStr in currentBook.words {
//            abstract+=bookStr
//            abstract+="\n"
//        }
//        abstract+="Rating: "+abstractscore+"\n\n"
//        abstract+="Reviewer's words:\n  "+currentBook.remark
//        return abstract
//    }
    
    public func resetSearch(){
        scaleNodes(ids: [])
        hideAbstract()
    }
    
    @objc func changeToSortDisplay(){
        
        scaleNodes(ids: [])
        hideAbstract()
        shouldBeInPlace = false
        removeHeadAnchor()


        let z = -1*PicMatrix.itemDis
        var absy =  0.0
        let x =  0.0
        let nowTrans = sceneView.session.currentFrame!.camera.transform
        elementWeights.sort(by: {$0.weight > $1.weight})
        for i in stride(from: 0, to: elementWeights.count ,by: 1){
            let elementWeight = elementWeights[i]
            var nowNode = SCNNode()
            if isCoffee{
                nowNode = sceneView.scene.rootNode.childNode(withName: "coffee@\(elementWeight.id)", recursively: false)!
            }else{
                nowNode = sceneView.scene.rootNode.childNode(withName: "book@\(elementWeight.id)", recursively: false)!
            }
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(z)
            translation.columns.3.x = Float(x)
            if(i%2 != 0){
                translation.columns.3.y = Float(absy)
            }
            else{
                translation.columns.3.y = Float(-1*absy)
                absy += 0.03
            }
            if isCoffee{
                let temp = translation.columns.3.x
                translation.columns.3.x = translation.columns.3.y*2
                translation.columns.3.y = temp
            }
            let sortNode = SCNNode()
            sortNode.transform = SCNMatrix4(nowTrans*translation)
            let nowPosVec = sortNode.position
            let trans = SCNAction.move(to: nowPosVec, duration: 0.4)
            SCNAction.customAction(duration: 0.4) { (node, elapsedTime) in
                nowNode.transform = SCNMatrix4(nowTrans*translation)
            }
            nowNode.runAction(trans)
        }
    }
    
    func calculateScreenDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
        return Double(pow(pow((pos1.x-pos2.x), 2)+pow((pos1.y-pos2.y), 2),0.5))
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

        let childNodes = sceneView.scene.rootNode.childNodes
        for node in childNodes {
            guard let name = node.name else {
                continue
            }
            guard isCoffee&&name.hasPrefix("coffee@") || isCoffee==false&&name.hasPrefix("book@") else {
                return
            }

            let id = getIdFromName(name)
            let restore = SCNAction.customAction(duration: 0.4){(node,time) in
                if self.isCoffee{
                    node.transform = self.coffees[id].oriTrans
                }else{
                    node.transform = self.books[id].oriTrans
                }
            }
            restore.timingMode = .easeOut
            node.runAction(restore)
        }


    }

}
