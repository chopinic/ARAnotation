//
//  ViewController+Button.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/18.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//
import UIKit

extension ViewController{
    func createButton(title : String,negX: CGFloat = 0, negY : CGFloat, action: Selector?)->UIButton{
        let button = UIButton(frame: CGRect(x: sceneView.bounds.size.width/2-50+negX, y: sceneView.bounds.size.height-negY, width: 100, height: 50))
        button.backgroundColor = UIColor.gray
        button.setTitle(title, for: .normal)
        if action != nil{
            button.addTarget(self, action: action!, for: UIControlEvents.touchUpInside)
        }
        sceneView.addSubview(button)
        return button

    }

    func createDirectionButton(){
        let buttonL = UIButton(frame: CGRect(x: sceneView.bounds.size.width/2-50, y: sceneView.bounds.size.height-250, width: 25, height: 25))
        buttonL.backgroundColor = UIColor.gray
        buttonL.setTitle("L", for: .normal)
        buttonL.addTarget(self, action: #selector(ViewController.buttonTapdecx), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonL)
        
        let buttonR = UIButton(frame: CGRect(x: sceneView.bounds.size.width/2+25, y: sceneView.bounds.size.height-250, width: 25, height: 25))
        buttonR.backgroundColor = UIColor.gray
        buttonR.setTitle("R", for: .normal)
        buttonR.addTarget(self, action: #selector(ViewController.buttonTapaddx), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonR)
        
        let buttonU = UIButton(frame: CGRect(x: sceneView.bounds.size.width/2-12.5, y: sceneView.bounds.size.height-300, width: 25, height: 25))
        buttonU.backgroundColor = UIColor.gray
        buttonU.setTitle("U", for: .normal)
        buttonU.addTarget(self, action: #selector(ViewController.buttonTapdecy), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonU)
        
        let buttonD = UIButton(frame: CGRect(x: sceneView.bounds.size.width/2-12.5, y: sceneView.bounds.size.height-200, width: 25, height: 25))
        buttonD.backgroundColor = UIColor.gray
        buttonD.setTitle("D", for: .normal)
        buttonD.addTarget(self, action: #selector(ViewController.buttonTapaddy), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonD)
    }
}
