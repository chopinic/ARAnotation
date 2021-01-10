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
//        print("touch")
        let touchLocation = sender.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation)
        for result in results {
            if let name = result.node.name{
                if name.hasPrefix("book@")&&isCoffee==false {
                    showAbstract(id: getIdFromName(name))
                }
                if name.hasPrefix("coffee@")&&isCoffee {
                    showAbstract(id: getIdFromName(name))
                }
            }
        }

    }
    
}
