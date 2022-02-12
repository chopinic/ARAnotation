//
//  DebugString.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/7.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import Foundation
import SceneKit



//获取缓存文件夹中所有文件的路径
//dirPath: 缓存问及那夹的位置
//返回值： filePaths: dirPath中所有文件的路径构成的数组
func getAllFilePath(dirPath: String) -> [String] {
    var filePaths = [String]()
    
    do {
        let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
        
        for fileName in array {
            var isDir: ObjCBool = true
            
            let fullPath = "\(dirPath)/\(fileName)"
            
            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                if !isDir.boolValue {
                    filePaths.append(fullPath)
                }
            }
        }
        
    } catch let error as NSError {
        print("get file path error: \(error)")
    }
    
    return filePaths;
}

//读取文本文件
//filename： 要读取的文件名
//返回值： 如果有文件返回文件文本构成的字符串，没有该文件报错，并返回“”
func getTextFileStr(filename: String) -> String {
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                return data
            } catch {
                print(error)
            }
        }
        return ""
}

//判断两点距离是否满足条件
//x1, y1, z1...：相互比较的两点坐标
//返回值： 满足条件就返回true，否则返回false
//ps:阈值要调试时更改，选取精度较高的取值
func getPossibility(x1: Float! , y1: Float!, z1: Float!, x2: Float!, y2: Float!, z2: Float!) -> Bool! {
    let dis = pow((x1-x2),2) + pow((y1-y2),2)  + pow((z1-z2),2)
    return sqrt(dis) < 100.0
}

//设置输出的字符串
//trans: 转化到世界空间的变换矩阵
//返回值： 返回缓存文件夹中第一个满足条件的json字符串，没有满足条件的字符串就返回nil
//ps: 该函数会同时设置DebugString.bookDebug字符串内容
func setBookStr(trans:simd_float4x4) -> String? {
    let p1 = calcuPointPos(trans: trans)
    let fs = getAllFilePath(dirPath: "这里要换成缓存存放的文件夹")
    for item in fs {
        let jsonStr = getTextFileStr(filename: item)
        let dictBook = Internet.getDictionaryFromJSONString(jsonString: jsonStr)
        let x1 = dictBook["x"] as! Float
        let y1 = dictBook["y"] as! Float
        let z1 = dictBook["z"] as! Float
        if getPossibility(x1: p1.x, y1: p1.y, z1: p1.z, x2: x1, y2: y1, z2: z1) {
            DebugString.bookDebug = jsonStr
            return jsonStr
        }
    }
    DebugString.bookDebug = ""
    return nil
}


// static func base64ToImg(base64str:String!) -> UIImage! {
//     let imageData = NSData(base64EncodedString: base64str, options: .allZeros)
//     let image = UIImage(data: imageData)
//     return image
// }



struct DebugString{
    
    static var bookDebug: String?

    static var coffeeDebug: String?
}

// MARK: 字典转字符串
func dicValueString(_ dic:[String : Any]) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
    if let Str = str{
        return Str
    }
    return nil
}

// MARK: 字符串转字典
func stringValueDic(_ str: String) -> [String : Any]{
    let data = str.data(using: String.Encoding.utf8)
    if let dict = try? JSONSerialization.jsonObject(with: data!,
                    options: .mutableContainers) as? [String : Any] {
        return dict
    }

    return ["":""]
}

//在Documents下创建一个新的文件夹的函数
public func createFolder(name:String,baseUrl:NSURL){
    let manager = FileManager.default
    let folder = baseUrl.appendingPathComponent(name, isDirectory: true)
    print("文件夹: \(folder)")
    let exist = manager.fileExists(atPath: folder!.path)
    if !exist {
        try! manager.createDirectory(at: folder!, withIntermediateDirectories: true,attributes: nil)
    }
}
//在Documents下创建一个新的文件的函数
public func createFile(name:String, fileBaseUrl:URL){
    let manager = FileManager.default
    let file = fileBaseUrl.appendingPathComponent(name)
    print("文件: \(file)")
    let exist = manager.fileExists(atPath: file.path)
    if !exist {
        let data = Data(base64Encoded:"aGVsbG8gd29ybGQ=" ,options:.ignoreUnknownCharacters)
        let createSuccess = manager.createFile(atPath: file.path,contents:data,attributes:nil)
        print("文件创建结果: \(createSuccess)")
 }
}
//缓存函数：其中参数json表示的是前端从后端获取的json数据
//参数tran表示的是BtAction文件中第340行中的result的属性result.worldTransform
public func Cachesavedata(json:String,tran:simd_float4x4){
    var dictBook=stringValueDic(json)
    var point1 = SIMD4<Float>(x: 0, y: 0, z: 0, w: 1)
    point1 = tran*point1
    let x0=point1.x
    let y0=point1.y
    let z0=point1.z
    dictBook["x"]=x0
    dictBook["y"]=y0
    dictBook["z"]=z0
    let newjson=dicValueString(dictBook)
    let manager = FileManager.default
    let urlForDocument = manager.urls(for: .documentDirectory, in: .userDomainMask)
    let url2 = urlForDocument[0] as NSURL
    let url = urlForDocument[0]
    createFolder(name: "CacheSave", baseUrl: url2)
    var numberofCachefile:Int=1//缓存文件的序号
    if numberofCachefile==1{
        numberofCachefile+=1
        //let manager = FileManager.default
        //let urlForDocument = manager.urls( for: .documentDirectory,in:.userDomainMask)
        //let url = urlForDocument[0]
        createFile(name:"CacheSave/001.txt", fileBaseUrl: url)
        let filePath:String = NSHomeDirectory() + "/Documents/CacheSave/001.txt"
        
        do{
            try newjson?.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch{
            print(error)
        }
    }
      if numberofCachefile==2{
        numberofCachefile+=1
        //let manager = FileManager.default
        //let urlForDocument = manager.urls( for: .documentDirectory,in:.userDomainMask)
        //let url = urlForDocument[0]
        createFile(name:"CacheSave/002.txt", fileBaseUrl: url)
        let filePath:String = NSHomeDirectory() + "/Documents/CacheSave/002.txt"
        do{
            try newjson?.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch{
            print(error)
        }
    }
      if numberofCachefile==3{
        numberofCachefile=1
        //let manager = FileManager.default
        //let urlForDocument = manager.urls( for: .documentDirectory,in:.userDomainMask)
        //let url = urlForDocument[0]
        createFile(name:"CacheSave/003.txt", fileBaseUrl: url)
        let filePath:String = NSHomeDirectory() + "/Documents/CacheSave/003.txt"
        do{
            try newjson?.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch{
            print(error)
        }
      }
}




