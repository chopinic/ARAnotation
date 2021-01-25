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
import RealityKit

class PicMatrix{
    
    
//    static
////  iphone X:
//    static var camWAngle: Double = 48.71/2
//    static var camHAngle: Double = 61.15/2
//    static var imageW: Double = 4320
//    static var imageH: Double  = 5760
    
// ipad 6 horizontal:
//    static var camWAngle: Double = 22.3
//    static var camHAngle: Double = 26.5
//    static var imageW: Double = 2880
//    static var imageH: Double  = 2000

// ipad pro horizontal:
    static var camWAngle: Double = 30.55
    static var camHAngle: Double = 24
    static var imageW: Double = 3840
    static var imageH: Double  = 2880
    static var xOffset: Float = 0
    static var yOffset: Float = 0

    var prevTrans: simd_float4x4?
    
    public var itemDis: Double = 0.4
    
    static var actualPicW: Double = 0.29
    
    static var actualPicH: Double = 0.26
    
    static public var showDis: Double = 0.4
    
    //static var xCoffeeOffset: Float = 0
    
    //static var yCoffeeOffset: Float = 0

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

    public static func addCamAngle(){
        camWAngle += 0.1;
        print("now cam:\(camWAngle)")
    }
    
    public static func decCamAngle(){
        camWAngle -= 0.1;
        print("now cam:\(camWAngle)")
    }

    
    public static func addxOffSet(){
        xOffset += 0.002;
        //xCoffeeOffset += 0.002;
        print("now xOffset:\(xOffset)")
    }
    
    public static func decxOffSet(){
        xOffset -= 0.002;
        //xCoffeeOffset -= 0.002;
        print("now xOffset:\(xOffset)")
    }
    
    public static func addyOffSet(){
        yOffset += 0.002;
        //yCoffeeOffset += 0.002;

        print("now yOffset:\(yOffset)")
    }
    
    public static func decyOffSet(){
        yOffset -= 0.002;
        //yCoffeeOffset -= 0.002;
        print("now yOffset:\(yOffset)")
    }
    
    public func saveCurrentTrans(trans:simd_float4x4){
        prevTrans = trans
        return
    }
    
    public func getActualLen(oriLen: Double, isW: Bool) -> Double{
        PicMatrix.actualPicW = 2*itemDis*tan(PicMatrix.camWAngle * Double.pi / 180)
        PicMatrix.actualPicH = 2*itemDis*tan(PicMatrix.camHAngle * Double.pi / 180)
        if(isW){
            return oriLen*(PicMatrix.actualPicW/PicMatrix.imageW)
        }else{
            return oriLen*(PicMatrix.actualPicH/PicMatrix.imageH)
        }
    }
    
    public func getActualOffset(offset: Double , isW: Bool) -> Double {
        
        PicMatrix.actualPicW = 2*itemDis*tan(PicMatrix.camWAngle * Double.pi / 180)
        PicMatrix.actualPicH = 2*itemDis*tan(PicMatrix.camHAngle * Double.pi / 180)

        if(isW){
            let midOffset = offset-PicMatrix.imageW/2
            return PicMatrix.actualPicW*(midOffset/PicMatrix.imageW)
        }
        else{
            let midOffset = -offset+PicMatrix.imageH/2
            return PicMatrix.actualPicH*(midOffset/PicMatrix.imageH)
        }
    }
        
    public func addCoffeeAnchor(id:Int,coffee:CoffeeSt)->simd_float4x4{
        guard let trans = prevTrans
        else { return matrix_identity_float4x4}
        let width = Double(coffee.loc.width);
        let height = Double(coffee.loc.height);
        let picW : Double = Double(coffee.loc.left)+width/2;
        let picH : Double = Double(coffee.loc.top)+height/2;
        var x = Float(getActualOffset(offset: picW,isW: true))
        var y = Float(getActualOffset(offset: picH,isW: false))
        let z  = Float(-1*itemDis)
        x += PicMatrix.xOffset //-:left
        y += PicMatrix.yOffset //+:ri
        var zz = z
        if(id%4==0){
            zz+=0.005
        }else if(id%4==1){
            zz+=0.003
        }else if(id%4==2){
            zz+=0.001
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = 0
        translation.columns.3.x = x
        translation.columns.3.y = y
        let transform = trans * translation
        return transform
        
    }
    
    public func addBookAnchor(id:Int,book:BookSt)->simd_float4x4{
//        print("addBookAnchor function is on \(Thread.current)" )
        guard let trans = prevTrans
        else { return matrix_identity_float4x4}
        let width = Double(book.loc.width)
        let height = Double(book.loc.height)
        let picW : Double = Double(book.loc.left)+width/2
        let picH : Double = Double(book.loc.top)+height/2
        var x = Float(getActualOffset(offset: picW,isW: true))
        var y = Float(getActualOffset(offset: picH,isW: false))
        x += PicMatrix.xOffset //-:left
        y += PicMatrix.yOffset //+:ri
        
        var zz = 0.0
        if(id%3==0){
            zz+=0.005
        }else if(id%3==1){
            zz+=0.003
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = Float(zz)
        translation.columns.3.x = x
        translation.columns.3.y = y
//        print("x:\(x), y:\(y), h:\(h), w:\(w)")
        let transform = trans * translation
        return transform
    }
}
//x:-0.106536895, y:-0.24927528, h:0.19478754982248456, w:0.11486377820200745

