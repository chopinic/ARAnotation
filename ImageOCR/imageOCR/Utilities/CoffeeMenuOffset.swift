//
//  CoffeeMenuOffset.swift
//  imageOCR
//
//  Created by 杨光 on 2021/2/19.
//  Copyright © 2021 Ivan Nesterenko. All rights reserved.
//

import Foundation
protocol offset{
    static var blockStartx :  [Double] { get set }
    static var blockStarty :  [Double] { get set }
    static var blockWidth :  [Double] { get set }
    static var blockHeight :  [Double] { get set }

    static var xx : [Double] { get set }
    static var yy : [Double] { get set }
    static var step: Double { get }
}
struct BigOffset: offset {
    static var blockStartx = [Double]()
    
    static var blockStarty = [Double]()
    
    static var blockWidth = [Double]()
    
    static var blockHeight = [Double]()
    
    static var step: Double = 100
    
    static var xx = [Double]()
    
    static var yy = [Double]()
    
}

struct SmallOffset: offset {
    static var picW = 2480.0
    static var picH = 1755.0

    static var step: Double = 80
    
    static var xx: [Double] = [180-picW/2,740-picW/2,1300-picW/2,1880-picW/2,1880-picW/2]
    
    static var yy: [Double] = [picH/2-390,picH/2-390,picH/2-390,picH/2-390,picH/2-1230]
    
    static var blockStartx: [Double] = [142-picW/2,690-picW/2,1250-picW/2,1830-picW/2,1830-picW/2]
    
    static var blockStarty: [Double]  = [picH/2-452,picH/2-452,picH/2-452,picH/2-452,picH/2-1290]
    
    static var blockWidth: [Double] = [520,520,520,520,512]
    
    static var blockHeight: [Double] = [790,790,630,630,320]
    
}
