//
//  Base.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/30.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation


public struct Location{
    var width = Int();
    var height = Int();
    var top = Int();
    var left = Int();

}

public struct Book{
    var words = [String]()
    var locations = [Location]()
    var cros_pic: Int!=0
    var isDisplay: Bool!=false
}

