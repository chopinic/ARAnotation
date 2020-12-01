//
//  ViewComtroller+Gesture.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/30.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit
import ARKit

extension ViewController{
    func arViewGestureSetup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnARView))
        sceneView.addGestureRecognizer(tapGesture)
        
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedDownOnARView))
//        swipeGesture.direction = .down
//        sceneView.addGestureRecognizer(swipeGesture)
    }
    
    
    @objc func tappedOnARView(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation)
        for result in results {
            if let name = result.node.name{
                if name.hasPrefix("book@") {
                    let bookid = getIdFromName(name)
                    focus(nowBookNode: result.node, currentBook: books[bookid])
                }
            }
        }

//        if let object = sceneView.virtualObject(at: touchLocation) {
//            return object
//        }


    }
    
}
