//
//  Base.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/30.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
import ARKit


public struct Location{
    var width = Int();
    var height = Int();
    var top = Int();
    var left = Int();

}
// book struct
public struct BookSt{
    var bookLoc = Location()
    var bookOriTrans = SCNMatrix4()
    var words = [String]()
    var locations = [Location]()
    var kinds = [String]()
    var matrixId: Int!=0
    var isDisplay: Bool!=false
    var bookTopVec: SCNVector3?
    var nowScale: Double = 1
    var title = ""
    var author = ""
    var publisher = ""
    var relatedBook = ""
    var score: Int = 0
    var remark = ""
}

public struct BookWeight{
    var id : Int = 0
    var weight : Double = 0
    init(){
        
    }
    init(i:Int,w:Double) {
        id = i;
        weight = w;
    }
    public mutating func update(w:Double){
        if(w > weight){weight = w;}
    }
}


extension SCNVector3 {
    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x+right.x,left.y+right.y,left.z+right.z)
    }
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x-right.x,left.y-right.y,left.z-right.z)
    }

}


extension SCNMatrix4{
//    static func -(left: SCNMatrix4, right: SCNMatrix4) -> SCNMatrix4 {
//        return SCNMatrix4(m11: right.m11-left.m11, m12: right.m12-left.m12, m13: right.m13-left.m13, m14: right.m14-left.m14, m21: right.m15-left.m15, m22: right.m16-left.m16, m23: right.m17-left.m17, m24: right.m11-left.m11, m31: right.m11-left.m11, m32: right.m11-left.m11, m33: right.m11-left.m11, m34: right.m11-left.m11, m41: right.m11-left.m11, m42: right.m11-left.m11, m43: right.m11-left.m11, m44: right.m11-left.m11)
//    }
//    
}
