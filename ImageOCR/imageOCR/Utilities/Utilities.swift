/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's reusable helper functions.
*/

import Foundation
import ARKit
import CoreML
import VideoToolbox

extension CIImage {
    
    /// Returns a pixel buffer of the image's current contents.
    func toPixelBuffer(pixelFormat: OSType) -> CVPixelBuffer? {
        var buffer: CVPixelBuffer?
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
        ]
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(extent.size.width),
                                         Int(extent.size.height),
                                         pixelFormat,
                                         options as CFDictionary, &buffer)
        
        if status == kCVReturnSuccess, let device = MTLCreateSystemDefaultDevice(), let pixelBuffer = buffer {
            let ciContext = CIContext(mtlDevice: device)
            ciContext.render(self, to: pixelBuffer)
        } else {
            print("Error: Converting CIImage to CVPixelBuffer failed.")
        }
        return buffer
    }
    
    /// Returns a copy of this image scaled to the argument size.
    func resize(to size: CGSize) -> CIImage? {
        return self.transformed(by: CGAffineTransform(scaleX: size.width / extent.size.width,
                                                      y: size.height / extent.size.height))
    }
}

extension CVPixelBuffer {
    
    /// Returns a Core Graphics image from the pixel buffer's current contents.
    func toCGImage() -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(self, nil, &cgImage)
        
        if cgImage == nil { print("Error: Converting CVPixelBuffer to CGImage failed.") }
        return cgImage
    }
}

extension MLMultiArray {
    /// Zeros out all indexes in the array except for the argument index, which is set to one.
    func setOnlyThisIndexToOne(_ index: Int) {
        if index > self.count - 1 {
            print("Error: Invalid index #\(index)")
            return
        }
        for i in 0...self.count - 1 {
            self[i] = Double(0) as NSNumber
        }
        self[index] = Double(1) as NSNumber
    }
}


//func createTransPlaneNode(size: CGSize, geometry:SCNGeometry){
//    let plane = SCNPlane(width: size.width, height: size.height)
//    
//    return createPlaneNode(size: size, geometry)
//}

/// Creates a SceneKit node with plane geometry, to the argument size, rotation, and material contents.
func createPlaneNode(size: CGSize, rotation: Float, contents: Any?) -> SCNNode {
    let plane = SCNPlane(width: size.width, height: size.height)
    plane.cornerRadius = size.width/CGFloat(50)
//    plane.b
    plane.firstMaterial?.diffuse.contents = contents
    let planeNode = SCNNode(geometry: plane)
    
    planeNode.eulerAngles.x = rotation
    
    return planeNode
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
