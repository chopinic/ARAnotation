//
//  CoffeeMenuOffset.swift
//  imageOCR
//
//  Created by 杨光 on 2021/2/19.
//  Copyright © 2021 Ivan Nesterenko. All rights reserved.
//

import Foundation
protocol Offset{
    var rad : Double { get set}
    var boxrad : Double { get set}
    var blockStartx :  [Double] { get  }
    var blockStarty :  [Double] { get  }
    var blockWidth :  [Double] { get  }
    var blockHeight :  [Double] { get  }

    var xx : [Double] { get  }
    var yy : [Double] { get }
    var step: Double { get }
}
struct BigOffset: Offset {
    var boxrad: Double = 3000
    
    var rad: Double = 3000
    
    var blockStartx: [Double]
    
    var blockStarty: [Double]
    
    var blockWidth: [Double]
    
    var blockHeight: [Double]
    
    var xx: [Double]
    
    var yy: [Double]
    
    var picW = 5998.0
    var picH = 3820.0

    var step: Double = 170
    
    init() {
        xx=[1880-picW/2,3290-picW/2,1880-picW/2,3290-picW/2,3290-picW/2]
        yy = [picH/2+130,picH/2+130,picH/2-2250,picH/2-2250,picH/2-3650]
        blockStartx = [1630-picW/2,3140-picW/2,1630-picW/2,3140-picW/2,3140-picW/2]
        blockStarty = [picH/2+80,picH/2+80,picH/2-2300,picH/2-2300,picH/2-3700]
        blockWidth = [1070,1070,1070,1070,1070]
        blockHeight = [1490,1490,1160,1160,550]
    }
//    var xx//: [Double] = [720-picW/2,2210-picW/2,720-picW/2,2210-picW/2,2210-picW/2]
//
//    var yy: [Double] = [picH/2-1020,picH/2-1020,picH/2-3250,picH/2-3270,picH/2-4680]
//
//    var blockStartx: [Double] = [1630-picW/2,3140-picW/2,1630-picW/2,3140-picW/2,3140-picW/2]
//
//    var blockStarty: [Double]  =
//
//    var blockWidth: [Double] = [1070,1070,1070,1070,1070]
//
//    var blockHeight: [Double] = [1490,1490,1160,1160,550]
//
}

struct SmallOffset: Offset {
    var rad: Double = 6000.0
    
    var boxrad: Double = 6100.0
    
    var blockStartx: [Double]
    
    var blockStarty: [Double]
    
    var blockWidth: [Double]
    
    var blockHeight: [Double]
    
    var xx: [Double]
    
    var yy: [Double]
    
    var picW = 2480.0
    var picH = 1755.0

    var step: Double = 75
    
    init() {
        xx=[250-picW/2,810-picW/2,1360-picW/2,1950-picW/2,1950-picW/2]
        yy = [picH/2-520,picH/2-520,picH/2-520,picH/2-520,picH/2-1311]
        blockStartx = [142-picW/2,690-picW/2,1250-picW/2,1830-picW/2,1850-picW/2]
        blockStarty = [picH/2-615,picH/2-615,picH/2-615,picH/2-615,picH/2-1405]
        blockWidth = [520,520,520,520,512]
        blockHeight = [790,790,630,630,320]
    }

//    var xx: [Double] = [250-picW/2,810-picW/2,1360-picW/2,1930-picW/2,1930-picW/2]
//
////    var yy: [Double] = [picH/2-370,picH/2-370,picH/2-370,picH/2-370,picH/2-1200]
//    var yy: [Double] = [picH/2-520,picH/2-520,picH/2-520,picH/2-520,picH/2-1331]
//
//    var blockStartx: [Double] = [142-picW/2,690-picW/2,1250-picW/2,1830-picW/2,1830-picW/2]
//
////    var blockStarty: [Double]  = [picH/2-465,picH/2-465,picH/2-465,picH/2-465,picH/2-1295]
//    var blockStarty: [Double]  = [picH/2-615,picH/2-615,picH/2-615,picH/2-615,picH/2-1455]
//
//    var blockWidth: [Double] = [520,520,520,520,512]
//
//    var blockHeight: [Double] = [790,790,630,630,320]
    
}


//big ori:
//var xx: [Double] = [720-picW/2,2210-picW/2,720-picW/2,2210-picW/2,2210-picW/2]
//
//var yy: [Double] = [picH/2-1020,picH/2-1020,picH/2-3250,picH/2-3270,picH/2-4680]
//
//var blockStartx: [Double] = [530-picW/2,2040-picW/2,530-picW/2,2040-picW/2,2040-picW/2]
//
//var blockStarty: [Double]  = [picH/2-1020,picH/2-1020,picH/2-3400,picH/2-3400,picH/2-4800]
//
//var blockWidth: [Double] = [1070,1070,1070,1070,1070]
//
//var blockHeight: [Double] = [1490,1490,1160,1160,550]

