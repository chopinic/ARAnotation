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





class HandleBook{
    
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
    
    public func debug(view:ARSCNView){
        guard let trans = view.session.currentFrame?.camera.transform
        else { return }

        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.4
        translation.columns.3.x = -0.027525755
        translation.columns.3.y = -0.03317832
        _ = trans * translation
//        let anchor = BookAnch123or(bookId: 0,w:0.03,h:0.06, transform: transform)
//        view.session.add(anchor: anchor)
    }
    
    public func addBookAnchor(view: ARSCNView,id:Int,book:BookSt){
        guard let trans = prevTrans
        else { return }
        let picW : Double = Double(book.bookLoc.left);
        let picH : Double = Double(book.bookLoc.top);
        let width = Double(book.bookLoc.width);
        let height = Double(book.bookLoc.height);
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
        print("book: x:\(x),y:\(y),z:\(z),w:\(w),h\(h)")
        print()
        let transform = trans * translation
        let anchor = BookAnchor(bookId:id, transform: transform)
        view.session.add(anchor: anchor)
    }
}
