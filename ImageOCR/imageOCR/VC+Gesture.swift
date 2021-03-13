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
        let  panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))
        arView.addGestureRecognizer(panGesture)
    }
    
    
    
    @objc func panPiece(_ sender : UIPanGestureRecognizer) {
        guard mode == 1 else {return}
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let touchLocation = sender.location(in: arView)
        let results = arView.entities(at: touchLocation)
        var hasResult = false
        var id = -1
        for result in results{
            let name = result.name
            if name.hasPrefix("group@"){
                id = getIdFromName(name)
                hasResult = true
                break
            }
            if let faname = result.parent?.name{
                if faname.hasPrefix("group@"){
                    id = getIdFromName(name)
                    hasResult = true
                    break
                }
            }
        }
        if hasResult == false{return}
        if sender.state == .began {
            swapGestureStart = touchLocation
        }
        // Update the position for the .began, .changed, and .ended states
        if sender.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            //          let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
//            print("x:\(touchLocation.x-swapGestureStart.x), y:\(touchLocation.y-swapGestureStart.y)")
            var dis = Float(touchLocation.y-swapGestureStart.y)/50000
//            print(dis)
            if coffeeOffset is BigOffset{
                dis *= 10
            }
            if id >= nowGroups.count {return}
            if groupPosCha[id] < 0 && dis < 0{return}
            if groupPosCha[id] > groupPosChaLimit[id] && dis > 0{return}

            groupPosCha[id] += Double(dis)
            moveGroup(id,dis)
        }
        else {
            // On cancellation, return the piece to its original location.
            print("canceled")
            //          piece.center = initialCenter
        }
    }
    
    func checkIfVisible(_ group: Int,_ y: Float)->Bool{
        
        let upLimit = Float(coffeeOffset.blockStarty[group]/coffeeOffset.boxrad)
        let downLimit = upLimit-Float(coffeeOffset.blockHeight[group]/coffeeOffset.boxrad)
        if y > upLimit || y < downLimit{ return false }
        return true
    }
    
    func moveGroup(_ id : Int, _ dis: Float){
        let upLimit = Float(coffeeOffset.blockStarty[id]/coffeeOffset.boxrad)
        let downLimit = upLimit-Float(coffeeOffset.blockHeight[id]/coffeeOffset.boxrad)

        for i in stride(from: 0, to: nowGroups[id].count, by: 1){
            let coffee = findById(id: nowGroups[id][i])!
            var pos = coffee.position
            pos.y -= dis
            if pos.y > upLimit || pos.y < downLimit{
//                if pos.z != -0.05{
                pos.z = -10.50
//                    groupVisCot[id] -= 1
            }else{
//                if pos.z != 0.005{
                    pos.z = 0.005
//                    groupVisCot[id] += 1
            }
            coffee.setPosition(pos, relativeTo: coffee.parent)
        }
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
            if name.hasPrefix("book@"){
                openBook(getIdFromName(name))
                hasResult = true
                break
            }else if name.hasPrefix("color@"){
                showAbstract(id: getIdFromName(name))
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
            if mode==1{
                hideAbstract()
            } else if mode==2 {
                hideAbstract()
            }else{
                openBook(-1)
            }
        }
    }
    
    func findById(id: Int)->Entity?{
        if(mode==1){
            return arView.scene.findEntity(named: "coffee@\(id)")
        }else{
            return arView.scene.findEntity(named: "book@\(id)")
        }
    }
    
    func getEntityList()->[Entity]{
        var list = [Entity]()
        if(mode==1){
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
    
    //    func getEntityPosList()->[CGPoint]{
    //
    //    }
    
}


