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
        

//    public func sh
    
    public func findString(lookFor: String){
        print("start find")
        var findResult = [Int]()
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
        if(findResult.count == 0){
            print("no such book")
            resetSearch()
            return;
        }
        nowGroup = findResult
        print("find \(findResult.count) book")
        setMessage("Find \(findResult.count) related books")
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
            if name.hasPrefix("book@") {
                let bookid = getIdFromName(name)
                if ids.firstIndex(of: bookid) != nil{
                    node.runAction(enhance)
                }
                else{node.runAction(disenhance)}
            }
        }
    }
    
    
    func showBookAbstract(id: Int){
        let currentBook = books[id]
        let nowBookNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false)!
        let pos = sceneView.projectPoint(currentBook.uiPosVec!+nowBookNode.position)
        var pos2d = CGPoint()
        pos2d.x = CGFloat(pos.x-Float(textWidth/2))
        pos2d.y = CGFloat(pos.y-Float(textHeight))
        let abstract = generateAbstract(currentBook: currentBook)
        DispatchQueue.main.async{
            self.bookAbstractUI.bookId = id
            self.bookAbstractUI.frame = CGRect(x: pos2d.x, y: pos2d.y, width: CGFloat(self.textWidth), height: CGFloat(self.textHeight))
            self.bookAbstractUI.text = abstract
            self.bookAbstractUI.isHidden = false
        }
    }
    
    func hideBookAbstract(){
        self.bookAbstractUI.isHidden = true
    }
    
    func generateAbstract(currentBook: BookSt)-> String{
        var abstractscore = ""
        for _ in stride(from: 0, to: currentBook.score ,by: 1){
            abstractscore+="⭐️"
        }
        var abstract = ""
        for bookStr in currentBook.words {
            abstract+=bookStr
            abstract+="\n"
        }
        abstract+="Rating: "+abstractscore+"\n\n"
        abstract+="Reviewer's words:\n  "+currentBook.remark
        return abstract
    }
    
    public func resetSearch(){
//        setMessage("")
        scaleNodes(ids: [])
        hideBookAbstract()
        nowGroup = [Int](repeating: 0, count:books.count )
        for i in stride(from: 0, to: nowGroup.count, by: 1){
            nowGroup[i] = i
        }
    }
    
    @objc func changeToSortDisplay(){
        
        scaleNodes(ids: [])
        hideBookAbstract()
        shouldBeInPlace = false

        let z = -1*PicMatrix.itemDis
        var y = -0.08
        let x =  0
        let nowTrans = sceneView.session.currentFrame!.camera.transform
        elementWeights.sort(by: {$0.weight > $1.weight})
        for i in stride(from: 0, to: elementWeights.count ,by: 1){
            let nowBookWeight = elementWeights[i]
            let nowBookNode = sceneView.scene.rootNode.childNode(withName: "book@\(nowBookWeight.id)", recursively: false)!
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(z)
            translation.columns.3.x = Float(x)
            translation.columns.3.y = Float(y)
            y += 0.03
            let bookSortNode = SCNNode()
            bookSortNode.transform = SCNMatrix4(nowTrans*translation)
            let nowPosVec = bookSortNode.position
            let trans = SCNAction.move(to: nowPosVec, duration: 0.4);
            SCNAction.customAction(duration: 0.4) { (node, elapsedTime) in
                nowBookNode.transform = SCNMatrix4(nowTrans*translation)
            }
            nowBookNode.runAction(trans)
        }
    }
    
    func calculateScreenDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
        return Double(pow(pow((pos1.x-pos2.x), 2)+pow((pos1.y-pos2.y), 2),0.5))
    }
    
    
    @objc func changeToAntEyeDisplay(){

        scaleNodes(ids: [], time: 0.0)
//        hideBookAbstract()

        
        isAntUpdate = !isAntUpdate
        
        /*
        var z = -0.8*PicMatrix.itemDis
        var absy = 0.0
        let nowTrans = sceneView.session.currentFrame!.camera.transform
        bookweights.sort(by: {$0.weight > $1.weight})
        for i in stride(from: 0, to: bookweights.count ,by: 1){
            let nowBookWeight = bookweights[i]
            let nowBookNode = sceneView.scene.rootNode.childNode(withName: "book@\(nowBookWeight.id)", recursively: false)!
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(z)
            translation.columns.3.x = 0
            if i%2==1{
                translation.columns.3.y = Float(absy)
            }
            else{
                translation.columns.3.y = Float(-1.0*absy)
            }
            let bookSortNode = SCNNode();
            bookSortNode.transform = SCNMatrix4(nowTrans*translation)
            let nowPosVec = bookSortNode.position
            let tans = SCNAction.move(to: nowPosVec, duration: 0.4);
            nowBookNode.runAction(tans)
            if(i==0){
                absy+=0.01
            }
            if(i==1){
                absy-=0.01
            }
            if i%2==1{
                absy+=0.02
            }
            z -= 0.1/pow(Double(i+4),1)
        }
 
 */
    }
    
    @objc func restoreDisplay(){
        shouldBeInPlace = true
        scaleNodes(ids: [])
        hideBookAbstract()

        let childNodes = sceneView.scene.rootNode.childNodes
        for node in childNodes {
            guard let name = node.name else {
                continue
            }
            if name.hasPrefix("book@") {
                let bookid = getIdFromName(name)
                let restore = SCNAction.customAction(duration: 0.4){(node,time) in
                    node.transform = self.books[bookid].oriTrans
                }
                restore.timingMode = .easeOut
                node.runAction(restore)
            }else{
                continue;
            }
        }
    }




}
