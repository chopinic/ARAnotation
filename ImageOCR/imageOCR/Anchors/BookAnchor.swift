//
//  BookAnchor.swift
//  imageOCR
//
//  Created by 杨光 on 2020/10/22.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
import ARKit

class BookAnchor: ARAnchor{
    open var id:Int?
    
    required init(anchor: ARAnchor) {
        super.init(anchor: anchor)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(id:Int,transform:simd_float4x4) {
        super.init(transform: transform)
        self.id = id
    }

    
}
