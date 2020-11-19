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
    var bookOriVec = SCNVector3()
    var words = [String]()
    var locations = [Location]()
    var kinds = [String]()
    var cros_pic: Int!=0
    var isDisplay: Bool!=false
    var bookTopPos: SCNNode?
}

