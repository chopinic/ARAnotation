//
//  MySceneView.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/20.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class PicMatrix{
    
//    public var prevFrame : ARFrame?
    var prevTrans: simd_float4x4?
    
    static var itemDis: Double = 0.3
    
//    var camWAngle: Double = 32.71/2
//    var camWAngle: Double = 36.71/2 // cal
    static var camWAngle: Double = 48.71/2

    static var camHAngle: Double = 61.15/2
//    var camHAngle: Double = 65.15/2

    static var actualPicW: Double = 0.29
    
    static var actualPicH: Double = 0.26
    
    static var imageW: Double = 4320
    
    static var imageH: Double  = 5760
    
    static var xOffset: Float = -0.03
    
    static var yOffset: Float = 0.00
    
    static var xCoffeeOffset: Float = 0.002
    
    static var yCoffeeOffset: Float = 0.002

    public static func findMax(x:Double,y:Double)->Double{
        if x>y{
            return x;
        }
        return y;
    }
    
    public static func findMin(x:Double,y:Double)->Double{
        if x>y{
            return y;
        }
        return x;
    }

    
    public static func addxOffSet(){
        xOffset += 0.002;
        print("now xOffset:\(xOffset)")
    }
    
    public static func decxOffSet(){
        xOffset -= 0.002;
        print("now xOffset:\(xOffset)")
    }
    
    public static func addyOffSet(){
        yOffset += 0.002;
        print("now yOffset:\(yOffset)")
    }
    
    public static func decyOffSet(){
        yOffset -= 0.002;
        print("now yOffset:\(yOffset)")
    }
    
    public func saveCurrentTrans(view: ARSCNView){
        prevTrans = view.session.currentFrame?.camera.transform
        return
    }
    
    public static func getActualLen(oriLen: Double, isW: Bool) -> Double{
        actualPicW = 2*itemDis*tan(camWAngle * Double.pi / 180)
        actualPicH = 2*itemDis*tan(camHAngle * Double.pi / 180)
        if(isW){
            return oriLen*(actualPicW/imageW)
        }else{
            return oriLen*(actualPicH/imageH)
        }
    }
    
    public static func getActualOffset(offset: Double , isW: Bool) -> Double {
        
        actualPicW = 2*itemDis*tan(camWAngle * Double.pi / 180)
        actualPicH = 2*itemDis*tan(camHAngle * Double.pi / 180)

        if(isW){
            let midOffset = -offset+imageW/2
            return actualPicW*(midOffset/imageW)
        }
        else{
            let midOffset = offset-imageH/2
            return actualPicH*(midOffset/imageH)
        }
    }
        
    public func addCoffeeAnchor(view: ARSCNView,id:Int,coffee:CoffeeSt){
        guard let trans = prevTrans
        else { return }
        let picW : Double = PicMatrix.imageW - Double(coffee.loc.left);
        let picH : Double = Double(coffee.loc.top);
        let width = Double(coffee.loc.width);
        let height = Double(coffee.loc.height);
        var x = Float(PicMatrix.getActualOffset(offset: picW,isW: true))
        var y = Float(PicMatrix.getActualOffset(offset: picH,isW: false))
        let z  = Float(-1*PicMatrix.itemDis)
        let w = PicMatrix.getActualLen(oriLen: width, isW: true)
        let h = PicMatrix.getActualLen(oriLen:height, isW: false)
        x += Float(w/2)+PicMatrix.xCoffeeOffset //-:left
        y += Float(h/2)+PicMatrix.yCoffeeOffset //+:ri
        var zz = z
        if(id%3==0){
            zz+=0.005
        }else if(id%3==1){
            zz+=0.003
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = zz
        translation.columns.3.x = y
        translation.columns.3.y = x
        let transform = trans * translation
        let anchor = CoffeeAnchor(id:id, transform: transform)
        view.session.add(anchor: anchor)
        
    }
    public func addBookAnchor(view: ARSCNView,id:Int,book:BookSt){
        guard let trans = prevTrans
        else { return }
        let picW : Double = Double(book.loc.left);
        let picH : Double = Double(book.loc.top);
        let width = Double(book.loc.width);
        let height = Double(book.loc.height);
        var x = Float(PicMatrix.getActualOffset(offset: picW,isW: true))
        var y = Float(PicMatrix.getActualOffset(offset: picH,isW: false))
        let z  = Float(-1*PicMatrix.itemDis)
        let w = PicMatrix.getActualLen(oriLen: width, isW: true)
        let h = PicMatrix.getActualLen(oriLen:height, isW: false)
        x += Float(w/2)+PicMatrix.xOffset //-:left
        y += Float(h/2)+PicMatrix.yOffset //+:ri
        
        var zz = z
        if(id%3==0){
            zz+=0.005
        }else if(id%3==1){
            zz+=0.003
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = zz
        translation.columns.3.x = y
        translation.columns.3.y = x
        let transform = trans * translation
        let anchor = BookAnchor(id:id, transform: transform)
        view.session.add(anchor: anchor)
    }
}
