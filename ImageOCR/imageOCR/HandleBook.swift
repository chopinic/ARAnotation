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
//import Math

//{
//    dis=0.6
//    xoff = -0.075
//    yoff = 0.08
//}
//
//{
//    dis = 0.4
//    xoff = -0.055
//    yoff = 0.06
//}





open class HandleBook{
    
//    public var prevFrame : ARFrame?
    var prevTrans: simd_float4x4?
    
    static var itemDis: Double = 0.4
    
//    var camWAngle: Double = 32.71/2
//    var camWAngle: Double = 36.71/2 // cal
    static var camWAngle: Double = 48.71/2

    static var camHAngle: Double = 61.15/2
//    var camHAngle: Double = 65.15/2

    static var actualPicW: Double = 0.29
    
    static var actualPicH: Double = 0.26
    
    static var imageW: Double = 4320
    
    static var imageH: Double  = 5760
    
    static var xOffset: Float = -0.005
    
    static var yOffset: Float = 0.00
    
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
        xOffset += 0.01;
        print("now xOffset:\(xOffset)")
    }
    
    public static func decxOffSet(){
        xOffset -= 0.01;
        print("now xOffset:\(xOffset)")
    }
    
    public static func addyOffSet(){
        yOffset += 0.01;
        print("now yOffset:\(yOffset)")
    }
    
    public static func decyOffSet(){
        yOffset -= 0.01;
        print("now yOffset:\(yOffset)")
    }
    
    public func saveCurrentTrans(view: ARSCNView) -> simd_float4x4?{
        prevTrans = view.session.currentFrame?.camera.transform
        return prevTrans
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
            let midOffset = offset-imageW/2
            return actualPicW*(midOffset/imageW)
        }
        else{
            let midOffset = offset-imageH/2
            return actualPicH*(midOffset/imageH)
        }
    }
    
    public func debug(view:ARSCNView){
        guard let trans = view.session.currentFrame?.camera.transform
        else { return }

        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.4
        translation.columns.3.x = -0.027525755
        translation.columns.3.y = -0.03317832
        let transform = trans * translation
//        let anchor = BookAnchor(bookId: 0,w:0.03,h:0.06, transform: transform)
//        view.session.add(anchor: anchor)
    }
    
    public func addBookAnchor(view: ARSCNView,id:Int,book:Book){
        guard let trans = prevTrans
        else { return }
        var picW : Double = 1e10;
        var picH : Double = 1e10;
        var picWm : Double = 0;
        var picHm : Double = 0;
        for loc in book.locations{
            picW = HandleBook.findMin(x: picW, y: Double(loc.left))
            picH = HandleBook.findMin(x: picH, y: Double(loc.top))
            picWm = HandleBook.findMax(x: picWm, y: Double(loc.left)+Double(loc.width))
            picHm = HandleBook.findMax(x: picHm, y: Double(loc.height)+Double(loc.top))
        }
        let width = picWm-picW;
        let height = picHm-picH;
        print("picw:\(picW),picH:\(picH)")
        var x = Float(HandleBook.getActualOffset(offset: picW,isW: true))
        var y = Float(HandleBook.getActualOffset(offset: picH,isW: false))
        let z  = Float(-1*HandleBook.itemDis)
        let w = HandleBook.getActualLen(oriLen: width, isW: true)
        let h = HandleBook.getActualLen(oriLen:height, isW: false)
        x += Float(w/2)+HandleBook.xOffset //-:left
        y += Float(h/2)+HandleBook.yOffset //+:ri
        var translation = matrix_identity_float4x4
        translation.columns.3.z = z
        translation.columns.3.x = y
        translation.columns.3.y = x
        print("x:\(x),y:\(y),z:\(z),w:\(w),h\(h)")
        print()
        let transform = trans * translation
        var rootLoc = Location()
        rootLoc.height = Int(height)
        rootLoc.width = Int(width)
        rootLoc.left = Int(picW)
        rootLoc.top = Int(picH)
        let anchor = BookAnchor(bookId:id, loc:rootLoc, transform: transform)
        view.session.add(anchor: anchor)
    }
}
