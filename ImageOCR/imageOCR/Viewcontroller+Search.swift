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
        focusId = -1
        var findResult = [Int]()
        for i in stride(from: 0, to: books.count ,by: 1){
            let singlebook = books[i]
            bookweights[i].id = i;
            bookweights[i].weight = 0;

            for j in stride(from: 0, to: singlebook.words.count ,by: 1){
                if singlebook.words[j].contains(lookFor){
                    focusId = i
                    findResult.append(i)
                    bookweights[i].update(w: Double(lookFor.count)/Double(singlebook.words[j].count));
                    break
                }else{
                    bookweights[i].update(w: 0);
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
    
    public func scaleNodes(ids: [Int]){
        let closer = SCNAction.moveBy(x: 0, y: 0, z: 0.01, duration: 0.4)
        let scale = SCNAction.scale(to: CGFloat(2), duration: 0.4)
        let enhance = SCNAction.group([closer,scale])
        enhance.timingMode = .easeOut

        for prevNode in nowEnhanceNodes {
            let bookid = getIdFromName(prevNode.name!)
            if ids.firstIndex(of: bookid) != nil{
                continue
            }
//            let further = SCNAction.move(to: books[bookid].bookOriTrans, duration: 0.4)
            let disenhance = SCNAction.scale(to: 1, duration: 0.4)
            disenhance.timingMode = .easeOut
            prevNode.runAction(disenhance)
        }
        nowEnhanceNodes.removeAll()
        
        for id in ids {
            guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false) else{
                print("search: no such node \(id)")
                continue;
            }
            childNode.runAction(enhance)
            nowEnhanceNodes.append(childNode)

        }
    }
    
    
    func showBookAbstract(id: Int){
//        for sb in sceneView.scene.rootNode.childNodes {
//            print(sb.name)
//        }
        let currentBook = books[id]
        let nowBookNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false)!
        focus(nowBookNode: nowBookNode, currentBook: currentBook)
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
    
    func focus(nowBookNode: SCNNode, currentBook: BookSt) {
        focusId = getIdFromName(nowBookNode.name!)
        let pos = sceneView.projectPoint(currentBook.bookTopVec!+nowBookNode.position)
        var pos2d = CGPoint()
        pos2d.x = CGFloat(pos.x-Float(textWidth/2))
        pos2d.y = CGFloat(pos.y-Float(textHeight))
        let abstract = generateAbstract(currentBook: currentBook)
        DispatchQueue.main.async{
            self.bookAbstractUI.frame = CGRect(x: pos2d.x, y: pos2d.y, width: CGFloat(self.textWidth), height: CGFloat(self.textHeight))
            self.bookAbstractUI.text = abstract
            self.bookAbstractUI.isHidden = false
        }
    }
        
    public func resetSearch(){
        setMessage("")
        focusId = -1
        scaleNodes(ids: [])
        nowGroup = [Int](repeating: 0, count:books.count )
        for i in stride(from: 0, to: nowGroup.count, by: 1){
            nowGroup[i] = i
        }
        self.bookAbstractUI.isHidden = true
    }
    
    @objc func changeToSortDisplay(){
        if(nowGroup.count==books.count)
        {scaleNodes(ids: [])}
        else{
            scaleNodes(ids: nowGroup)
        }
        focusId = -1
        self.bookAbstractUI.isHidden = true
        let z = -1*PicMatrix.itemDis
        var y = -0.08
        let x =  0
        let nowTrans = sceneView.session.currentFrame!.camera.transform
        bookweights.sort(by: {$0.weight > $1.weight})
        for i in stride(from: 0, to: bookweights.count ,by: 1){
            let nowBookWeight = bookweights[i]
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
//                let dist = nowBookNode.transform - SCNMatrix4(self.nowTrans!*translation)
                nowBookNode.transform = SCNMatrix4(nowTrans*translation)
            }
            nowBookNode.runAction(trans)
        }
    }
    
    @objc func changeToAntEyeDisplay(){
        resetSearch()
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
    }
    
    @objc func restoreDisplay(){
        resetSearch()
        let childNodes = sceneView.scene.rootNode.childNodes
        for node in childNodes {
            guard let name = node.name else {
                continue
            }
            if name.hasPrefix("book@") {
                let bookid = getIdFromName(name)
                let restore = SCNAction.customAction(duration: 0.4){(node,time) in
                    node.transform = self.books[bookid].bookOriTrans
                }
                restore.timingMode = .easeOut
                node.runAction(restore)
            }else{
                continue;
            }
        }
    }




}
