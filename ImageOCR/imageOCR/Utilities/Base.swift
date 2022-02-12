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
    var oriTrans = simd_float4x4()
    var tempTrans = simd_float4x4()
    var matrixId: Int!=0
    var picid = -1
    var isDisplay: Bool!=false
    var size = CGSize()
    var remark = ""
    var score: Double = 0

//    var uiPos: SIMD3<Float>?
    public func uiPos(_ trans: simd_float4x4 = matrix_identity_float4x4)->SIMD3<Float>{
        return SIMD3<Float>(x: 0, y: 0, z: 0)
    }
    public func generateAbstract()->String{
        return "Element abstract"
    }
}

// book struct
public class BookSt: Element{
//    var shouldDisplay = true
    var entityId = -1
    var words = [String]()
    var locations = [Location]()
    var kinds = [String]()
    var color = UIColor.gray
    var isbn = ""
    var title = ""
    var author = ""
    var publisher = ""
    var isOpen = false
    var price = 160.0
    
    
    public override func uiPos(_ trans: simd_float4x4 = matrix_identity_float4x4)->SIMD3<Float>{
        var translation = matrix_identity_float4x4
        translation.columns.3.y = Float(size.height)/2
        translation.columns.3.x = -Float(size.width)
        translation = trans*translation
        let rootpos = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
        let bookToppos4 = translation*rootpos
        let bookToppos = SIMD3<Float>(x:bookToppos4.x,y:bookToppos4.y,z:bookToppos4.z)

        return bookToppos
    }
    
    
    public override func generateAbstract()->String{
        var abstractscore = ""
        for _ in stride(from: 0, to: score ,by: 1){
            abstractscore+="⭐️"
        }
        var abstract = title+"\n"
        abstract += "Rating: "+abstractscore+"\n"
        abstract += "Publisher: "+publisher+"\n"
        abstract += "isbn: "+isbn+"\n"
//        for bookStr in words {
//            abstract+=bookStr
//            abstract+="\n"
//        }
//        abstract
//        abstract+="Rating: "+abstractscore+"\n"
        abstract+="Price: \(price)\n\n"
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
    var desPerPicid = -1
    var name = ""
    var belong = ""
    var calories = 30.0
    var fat = 0.0
    var protein = 0.0
    var milk = 0.2
    var price = 0.0
    var caffeine = 0.2
    var sugar = 0.2
    var water = 0.2
    var freshness = ""
    var sweet = ""
    var rich = ""
    var sour = ""
    var order = -1
    
    public override func uiPos(_ trans: simd_float4x4 = matrix_identity_float4x4)->SIMD3<Float>{
        var translation = matrix_identity_float4x4
        translation.columns.3.y = -Float(size.height)
//        translation.columns.3.x = Float(size.width/2)
        translation = trans*translation
//        let rootpos = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
//        let toppos4 = translation*rootpos
//        let toppos = SIMD3<Float>(x:toppos4.x,y:toppos4.y,z:toppos4.z)
        return calcuPointPos(trans: translation)
    }

    
    public override func generateAbstract()->String{
        var abs = name+"\n"
        for _ in stride(from: 0, to: score, by: 1){
            abs+="⭐️"
        }
        abs+="\n"
        abs+="Price: "+String(price)+"\n"
        abs+="Protein: "+String(protein)+" g\n"
        abs+="Fat: "+String(fat)+" g\n"
        abs+="Calories: "+String(calories)+" cal\n"
//        abs+=abs+"Protein: "+protein+"g"
//        abs+=abs+"Protein: "+protein+"g"
//        abs = abs+ "rich: "+rich+"\n"
        abs = abs + "Remark: "+remark

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

public class ColorSt: Element{
    var shadowtype = ""
    var eyetype = ""
    var scheme = 0
    var locations = [Location]()
    var recommandplace = ""
    var benifits = ""
    var feature = ""
    var tips = ""
    var tPicId = -1
    var color = UIColor()

    public override func uiPos(_ trans: simd_float4x4 = matrix_identity_float4x4)->SIMD3<Float>{
        var translation = matrix_identity_float4x4
//        translation.columns.3.y = Float(size.height)/2
        translation.columns.3.x = Float(size.width)/2
        translation = trans*translation
        let rootpos = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
        let bookToppos4 = translation*rootpos
        let bookToppos = SIMD3<Float>(x:bookToppos4.x,y:bookToppos4.y,z:bookToppos4.z)

        return bookToppos
    }
    
    
    public override func generateAbstract()->String{
        var abstract = shadowtype+"\n"
        abstract+="Recommand Place: "+recommandplace+"\n"
//        abstract+="benifits: "+benifits+"\n"
//        abstract+="Feature: "+feature+"\n"
        abstract+="Remark:\n  "+remark
        return abstract
    }
}
