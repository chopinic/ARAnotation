//
//  CoffeeMenuOffset.swift
//  imageOCR
//
//  Created by 杨光 on 2021/2/19.
//  Copyright © 2021 Ivan Nesterenko. All rights reserved.
//

import Foundation
protocol offset{
    static var xx : [Double] { get set }
    static var yy : [Double] { get set }
    static var step: Double { get }
}
struct BigOffset: offset {
    static var step: Double = 100
    
    static var xx = [Double]()
    
    static var yy = [Double]()
    
}

struct SmallOffset: offset {
    static var step: Double = 80
    
    static var xx: [Double] = [180,740,1300,1880,1880]
    
    static var yy: [Double] = [420,420,420,420,1160]
    
}
