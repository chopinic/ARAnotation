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
