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
        let results = arView.entities(at: touchLocation)
        var hasResult = false
        for result in results{
//        for result in results {
            let name = result.name
            print(name)
            if name.hasPrefix("book@")||name.hasPrefix("coffee@") {
                openBook(getIdFromName(name))
                hasResult = true
//                showAbstract(id: getIdFromName(name))
                break
            }
            if let faname = result.parent?.name{
                if faname.hasPrefix("coffee@"){
                    showAbstract(id: getIdFromName(faname))
                    hasResult = true
                    break
                }
            }
        }

        if hasResult == false{
            print("no result at touch location")
            if isCoffee{
                hideAbstract()
            }else{
                openBook(-1)
            }
        }
    }
    
    func findById(id: Int)->Entity?{
        if(isCoffee){
            return arView.scene.findEntity(named: "coffee@\(id)")
        }else{
            return arView.scene.findEntity(named: "book@\(id)")
        }
    }
    
    func getEntityList()->[Entity]{
        var list = [Entity]()
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
