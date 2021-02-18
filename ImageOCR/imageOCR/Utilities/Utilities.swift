/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's reusable helper functions.
*/

import Foundation
import ARKit
import RealityKit
import CoreML
import UIKit
import VideoToolbox

public func loadBookModel(_ outsideColor: UIColor, _ size: CGSize) ->ModelEntity{
    let l_in = try! Entity.loadModel(named: "L_In")
    let l_out = try! Entity.loadModel(named: "L_Out")
    let r_in = try! Entity.loadModel(named: "R_In")
    let r_out = try! Entity.loadModel(named: "R_Out")
    var material1 = UnlitMaterial()
    material1.baseColor = MaterialColorParameter.color(outsideColor)
//    material1.tintColor = outsideColor
    l_out.model?.materials = [material1]
    r_out.model?.materials = [material1]
    l_in.scale = SIMD3<Float>(x: Float(size.width/0.02),y:Float(size.height/0.26),z:Float(size.height/0.26))
    r_in.scale = SIMD3<Float>(x: Float(size.width/0.02),y:Float(size.height/0.26),z:Float(size.height/0.26))
    l_out.scale = SIMD3<Float>(x: Float(size.width/0.02),y:Float(size.height/0.26),z:Float(size.height/0.26))
    r_out.scale = SIMD3<Float>(x: Float(size.width/0.02),y:Float(size.height/0.26),z:Float(size.height/0.26))

    let left = ModelEntity()
    let right = ModelEntity()
    left.name = "left"
    right.name = "right"
    left.addChild(l_out)
    right.addChild(r_out)
    left.addChild(l_in)
    right.addChild(r_in)

    let bookBox = ModelEntity()
    bookBox.addChild(left)
    bookBox.addChild(right)
    bookBox.position = SIMD3<Float>(x: 0, y: Float(-1*size.height/2), z: -0.001)
    bookBox.name = "bookBox"

    return bookBox
}

public func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
     return cgImage
    }
    return nil
}


public func getForwardTrans(ori: simd_float4x4,dis:Float)->simd_float4x4{
    var trans = matrix_identity_float4x4
    trans.columns.3.z = dis;
    return ori*trans
}

public func getDownTrans(ori: simd_float4x4,dis:Float)->simd_float4x4{
    var trans = matrix_identity_float4x4
    trans.columns.3.y = -1*dis;
    return ori*trans
}


public func calcuPointPos(trans:simd_float4x4)->SIMD3<Float>{
    var point1 = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
    point1 = trans*point1
    return SIMD3<Float>(x: point1.x, y: point1.y, z: point1.z)
}

public func calcuPointDis(trans1:simd_float4x4 , trans2:simd_float4x4)->Float{
    var point1 = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
    point1 = trans1*point1
    var point2 = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
    point2 = trans2*point2
    let dis = pow((point1.x-point2.x),2) + pow((point1.y-point2.y),2)  + pow((point1.z-point2.z),2)
    return sqrt(dis)
}

func makeRotationMatrix(x:Float = 0,y:Float = 0,z:Float = 0)->simd_float4x4{
    return makeRotationMatrixX(angle: x)*makeRotationMatrixY(angle: y)*makeRotationMatrixZ(angle: z);
}

func makeRotationMatrixX(angle: Float) -> simd_float4x4 {
    let rows = [
        simd_float4(1,    0,          0,           0),
        simd_float4(0,    cos(angle), -sin(angle), 0),
        simd_float4(0,    sin(angle), cos(angle),  0),
        simd_float4(0,    0,          0,           1)
    ]
    
    return float4x4(rows: rows)
}

func makeScaleMatrix(by: Float) -> simd_float4x4 {
    let rows = [
        simd_float4(1,    0, 0, 0),
        simd_float4(0,    1, 0, 0),
        simd_float4(0,    0, 1, 0),
        simd_float4(0,    0, 0, by)
    ]
    
    return float4x4(rows: rows)
}

func makeRotationMatrixY(angle: Float) -> simd_float4x4 {
    let rows = [
        simd_float4(cos(angle), 0,    sin(angle),  0),
        simd_float4(0,          1,    0,           0),
        simd_float4(-sin(angle),0,    cos(angle),  0),
        simd_float4(0,          0,    0,           1)
    ]
    
    return float4x4(rows: rows)
}

func makeRotationMatrixZ(angle: Float) -> simd_float4x4 {
    let rows = [
        simd_float4( cos(angle), -sin(angle), 0,0),
        simd_float4(sin(angle), cos(angle), 0,0),
        simd_float4( 0,          0,          1,0),
        simd_float4( 0,          0,          0,1)
    ]
    
    return float4x4(rows: rows)
}
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
        VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        
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

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

//func createTransPlaneNode(size: CGSize, geometry:SCNGeometry){
//    let plane = SCNPlane(width: size.width, height: size.height)
//    
//    return createPlaneNode(size: size, geometry)
//}

func createCoffeeFont(id: Int,coffeeName: String, size:CGSize)->ModelEntity{
    let lineHeight: CGFloat = 0.05
    let font = MeshResource.Font.systemFont(ofSize: lineHeight)
    let textMesh = MeshResource.generateText(coffeeName, extrusionDepth: Float(lineHeight * 0.1), font: font)
    let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
    let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
    textModel.name = "coffee@\(id)"
    let bound = textMesh.bounds
    let radius = Float(size.width)/(bound.boundingRadius*2)
    textModel.scale = SIMD3<Float>(x: radius, y: radius, z: radius)
    
    return textModel
}


func createPlane(id:Int,size: CGSize, isCoffee: Bool)->ModelEntity?{
    do{
        if(isCoffee){
            let resource = try TextureResource.load(contentsOf:getDocumentsDirectory().appendingPathComponent("coffee@\(id).png"))
    //        let coffeeDes = try? TextureResource.load(contentsOf:getDocumentsDirectory().appendingPathComponent("coffeedes@\(id).png"))
            var material = UnlitMaterial()
            material.baseColor = MaterialColorParameter.texture(resource)
            material.tintColor = UIColor.white.withAlphaComponent(0.99)

            let imagePlane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            imagePlane.name = "coffee@\(id)"
            return imagePlane

            
        }else{
            
            guard let resource = try? TextureResource.load(contentsOf:getDocumentsDirectory().appendingPathComponent("book@\(id).png"))else {return nil}
            var material = UnlitMaterial()
            material.baseColor = MaterialColorParameter.texture(resource)
            material.tintColor = UIColor.white.withAlphaComponent(0.99)

            let imagePlane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
            
    //        imagePlane.position.y = 0.1
            imagePlane.name = "book@\(id)"
    //        imagePlane.scale = SIMD3<Float>(2)
            return imagePlane
        }
    }
    catch  {
       return nil
   }
}


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
