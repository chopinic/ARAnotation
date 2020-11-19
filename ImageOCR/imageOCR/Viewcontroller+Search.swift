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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        let text = textField.text ?? ""
        if text != ""{
            findString(lookFor:text)
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
            for j in stride(from: 0, to: singlebook.kinds.count ,by: 1){
//                if singlebook.kinds[j] == "author"{
                if singlebook.words[j].contains(lookFor){
                    focusId = i
                    findResult.append(i)
                    continue;
                }
            }
        }
        if(findResult.count == 0){
            print("no such book")
            enhance(ids: findResult)
            resetSearch()
            return;
        }
        print("find \(findResult.count) book")
        enhance(ids: findResult)
        showBookInfo(id: focusId)
    }
    
    public func enhance(ids: [Int]){
        let disscale = SCNAction.scale(by: 0.5, duration: 0.04)

        let closer = SCNAction.moveBy(x: 0, y: 0, z: 0.01, duration: 0.4)
        let scale = SCNAction.scale(to: CGFloat(2), duration: 0.4)
        let enhance = SCNAction.group([closer,scale])
        enhance.timingMode = .easeOut

        for prevNode in nowEnhanceNodes {
            let name = prevNode.name!
            let i = name.index(after: name.firstIndex(of: "@")!)
            let bookid = Int(name.suffix(from: i))!
            if ids.firstIndex(of: bookid) != nil{
                continue
            }
            let further = SCNAction.move(to: books[bookid].bookOriVec, duration: 0.4)
            let disenhance = SCNAction.group([disscale,further])
            disenhance.timingMode = .easeOut
            prevNode.runAction(disenhance)
        }
        nowEnhanceNodes.removeAll()
        
        for id in ids {
            guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false) else{
                print("no such node \(id)")
                continue;
            }
            
            childNode.runAction(enhance)
            nowEnhanceNodes.append(childNode)

        }
    }
    
    func showBookInfo(id: Int){
        let currentBook = books[id]
        let pos = sceneView.projectPoint(currentBook.bookTopPos!.position)
        var pos2d = CGPoint()
        pos2d.x = CGFloat(pos.x-Float(textWidth/2))
        pos2d.y = CGFloat(pos.y-Float(textHeight))
        DispatchQueue.main.async{
            self.bookInfo.frame = CGRect(x: pos2d.x, y: pos2d.y, width: CGFloat(self.textWidth), height: CGFloat(self.textHeight))
            self.bookInfo.text = "info\(id)"
            self.bookInfo.isHidden = false
        }
    }
    
    public func resetSearch(){
        focusId = -1
        nowEnhanceNodes.removeAll()
        self.bookInfo.isHidden = true
    }
}
