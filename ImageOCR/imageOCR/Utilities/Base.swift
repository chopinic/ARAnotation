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
public class Element{
    var loc = Location()
    var oriTrans = SCNMatrix4()
    var matrixId: Int!=0
    var picid = -1
    var isDisplay: Bool!=false
    var uiPosVec: SCNVector3?
    public func generateAbstract()->String{
        return "Element abstract"
    }
}

// book struct
public class BookSt: Element{
//    var loc = Location()
//    var oriTrans = SCNMatrix4()
    var words = [String]()
    var locations = [Location]()
    var kinds = [String]()
//    var matrixId: Int!=0
//    var picid = -1
//    var isDisplay: Bool!=false
//    var uiPosVec: SCNVector3?
    var title = ""
    var author = ""
    var publisher = ""
    var relatedBook = ""
    var score: Int = 0
    var remark = ""
    
    public override func generateAbstract()->String{
        var abstractscore = ""
        for _ in stride(from: 0, to: score ,by: 1){
            abstractscore+="⭐️"
        }
        var abstract = ""
        for bookStr in words {
            abstract+=bookStr
            abstract+="\n"
        }
        abstract+="Rating: "+abstractscore+"\n\n"
        abstract+="Reviewer's words:\n  "+remark
        return abstract
    }
}


//coffee struct
public class CoffeeSt: Element{
//    var loc = Location()
//    var oriTrans = SCNMatrix4()
//    var matrixId: Int!=0
//    var picid = -1
    var desPicid = -1
    var name = ""
    var fragrance = ""
    var aroma = ""
    var acidity = ""
    var body = ""
    var aftertaste = ""
    var flavor = ""
    var balance = ""
    var score: Int = 0
    var remark = ""
    
    public override func generateAbstract()->String{
        var abs = name+"\n"
        for _ in stride(from: 0, to: score, by: 1){
            abs+="⭐️"
        }
        abs = abs + "fragrance: "+fragrance+"\n"
        abs = abs + "aroma: "+aroma+"\n"
        abs = abs + "acidity: "+acidity+"\n"
        abs = abs + "body: "+body+"\n"
        abs = abs + "aftertaste: "+aftertaste+"\n"
        abs = abs + "remark: "+remark

        return abs
    }
    
//    public func findRelated(str: String)->Double{
//        
//    }
}

public struct ElementWeight{
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
