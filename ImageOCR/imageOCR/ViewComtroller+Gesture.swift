//
//  ViewComtroller+Gesture.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/30.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

extension ViewController{
    func arViewGestureSetup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnARView))
        arView.addGestureRecognizer(tapGesture)
        
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedDownOnARView))
//        swipeGesture.direction = .down
//        sceneView.addGestureRecognizer(swipeGesture)
    }
    
    
    @objc func tappedOnARView(_ sender: UITapGestureRecognizer) {
//        print("touch")
        let touchLocation = sender.location(in: arView)
        print(touchLocation)
//        let results = arView.hitTest(touchLocation)
        guard let result = arView.entity(at: touchLocation)else{
            return
        }
//        for result in results {
        let name = result.name
        print(name)
        if name.hasPrefix("book@")&&isCoffee==false {
            showAbstract(id: getIdFromName(name))
        }
        if name.hasPrefix("coffee@")&&isCoffee {
            showAbstract(id: getIdFromName(name))
        }
            
//        }

    }
    
    func findById(id: Int)->AnchorEntity?{
        if(isCoffee){
            return arView.scene.findEntity(named: "coffee@\(id)") as? AnchorEntity
        }else{
            return arView.scene.findEntity(named: "book@\(id)")as? AnchorEntity
        }
    }
    
    func getEntityList()->[AnchorEntity]{
        var list = [AnchorEntity]()
        if(isCoffee){
            for i in stride(from: 0, to: coffees.count, by: 1){
                list.append(findById(id: i)!)
            }
        }else{
            for i in stride(from: 0, to: books.count, by: 1){
                list.append(findById(id: i)!)
            }
        }
        return list
    }
    
}
