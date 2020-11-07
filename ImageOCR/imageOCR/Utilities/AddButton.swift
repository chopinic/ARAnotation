//
//  AddButton.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/7.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit


struct ButtonCreate{
    static func createButton(control: ViewController, title : String, negY : CGFloat, action: Selector){
        let button = UIButton(frame: CGRect(x: control.sceneView.bounds.size.width/2-50, y: control.sceneView.bounds.size.height-negY, width: 100, height: 50))
        button.backgroundColor = UIColor.gray
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        control.sceneView.addSubview(button)
    }
    
    static func createDirectionButton(control: ViewController){
        let buttonL = UIButton(frame: CGRect(x: control.sceneView.bounds.size.width/2-50, y: control.sceneView.bounds.size.height-250, width: 25, height: 25))
        buttonL.backgroundColor = UIColor.gray
        buttonL.setTitle("L", for: .normal)
        buttonL.addTarget(self, action: #selector(ViewController.buttonTapdecx), for: UIControlEvents.touchUpInside)
        control.sceneView.addSubview(buttonL)
        
        let buttonR = UIButton(frame: CGRect(x: control.sceneView.bounds.size.width/2+25, y: control.sceneView.bounds.size.height-250, width: 25, height: 25))
        buttonR.backgroundColor = UIColor.gray
        buttonR.setTitle("R", for: .normal)
        buttonR.addTarget(self, action: #selector(ViewController.buttonTapaddx), for: UIControlEvents.touchUpInside)
        control.sceneView.addSubview(buttonR)
        
        let buttonU = UIButton(frame: CGRect(x: control.sceneView.bounds.size.width/2-12.5, y: control.sceneView.bounds.size.height-300, width: 25, height: 25))
        buttonU.backgroundColor = UIColor.gray
        buttonU.setTitle("U", for: .normal)
        buttonU.addTarget(self, action: #selector(ViewController.buttonTapdecy), for: UIControlEvents.touchUpInside)
        control.sceneView.addSubview(buttonU)
        
        let buttonD = UIButton(frame: CGRect(x: control.sceneView.bounds.size.width/2-12.5, y: control.sceneView.bounds.size.height-200, width: 25, height: 25))
        buttonD.backgroundColor = UIColor.gray
        buttonD.setTitle("D", for: .normal)
        buttonD.addTarget(self, action: #selector(ViewController.buttonTapaddy), for: UIControlEvents.touchUpInside)
        control.sceneView.addSubview(buttonD)
    }
}
