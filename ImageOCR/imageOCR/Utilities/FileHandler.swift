//
//  FileHandle.swift
//  imageOCR
//
//  Created by chopinic on 2022/1/26.
//  Copyright © 2022 Ivan Nesterenko. All rights reserved.
//

import Foundation
import Metal
import ARKit
import UIKit
import RealityKit

class FileHandler{
    
    static var savedResultCot = 0;
    
    static var savedResultCotFile = "ResultCot.txt";

    static var fileSubFix = ".txt";

    static var coodRef = "coodRef"
    
    static var bookResultFile = "result";
    
    static var picMatrixFile = "matrix";
    
    static public func writeResultCot(){
        NSLog("write result cot: \(savedResultCot)")
        writeFile(text: String(savedResultCot), url: savedResultCotFile);
    }
    
    static public func readResultCot() -> Int{
        if let cotStr = readFile(url: savedResultCotFile){
            savedResultCot = Int(cotStr)!;
            NSLog("read result cot: \(savedResultCot)")
        }else{
            NSLog("fail to read result cot, set to 0");
            savedResultCot = 0;
            writeResultCot()
        }
        return savedResultCot;
    }
    
    static public func readCoodRef()->simd_float4x4?{
        var matrix = matrix_identity_float4x4
        let matrixStr = readFile(url: "\(coodRef)\(fileSubFix)");
        if let allNumbers = matrixStr?.components(separatedBy: " "){
            if(allNumbers.count == 17){
                matrix.columns.0.x = Float(allNumbers[1])!;
                matrix.columns.0.y = Float(allNumbers[2])!;
                matrix.columns.0.z = Float(allNumbers[3])!;
                matrix.columns.0.w = Float(allNumbers[4])!;
                matrix.columns.1.x = Float(allNumbers[5])!;
                matrix.columns.1.y = Float(allNumbers[6])!;
                matrix.columns.1.z = Float(allNumbers[7])!;
                matrix.columns.1.w = Float(allNumbers[8])!;
                matrix.columns.2.x = Float(allNumbers[9])!;
                matrix.columns.2.y = Float(allNumbers[10])!;
                matrix.columns.2.z = Float(allNumbers[11])!;
                matrix.columns.2.w = Float(allNumbers[12])!;
                matrix.columns.3.x = Float(allNumbers[13])!;
                matrix.columns.3.y = Float(allNumbers[14])!;
                matrix.columns.3.z = Float(allNumbers[15])!;
                matrix.columns.3.w = Float(allNumbers[16])!;
                return matrix;
            }
        }
        return nil;
    }
    
    static public func writeCoodRef(matrix: simd_float4x4){
        let matrixStr = NSMutableString("");
        matrixStr.append(String(matrix.columns.0.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.0.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.0.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.0.w))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.1.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.1.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.1.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.1.w))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.2.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.2.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.2.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.2.w))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.3.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.3.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.3.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.columns.3.w))
        
        writeFile(text: matrixStr as String, url: "\(coodRef)\(fileSubFix)");
    }
    
    static public func clearAllSavedData() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first;
        readResultCot();
        do{
            for i in stride(from: 0, to: savedResultCot ,by: 1){
                let nowFileURL = "\(bookResultFile)\(i)\(fileSubFix)"
                let fullFileURL = dir!.appendingPathComponent(nowFileURL)
                if( FileManager().fileExists(atPath: fullFileURL.absoluteString) ){
                    try FileManager().removeItem(atPath: fullFileURL.absoluteString)
                    NSLog("removed \(nowFileURL)");
                }
                let nowMatrixURL = "\(picMatrixFile)\(i)\(fileSubFix)"
                let fullMatrixURL = dir!.appendingPathComponent(nowMatrixURL)
                if( FileManager().fileExists(atPath: fullMatrixURL.absoluteString) ){
                    try FileManager().removeItem(atPath: fullMatrixURL.absoluteString)
                    NSLog("removed \(nowMatrixURL)");
                }
            }
            writeResultCot();
        }catch {
            NSLog("error clear data:  \(error)");
        }
        savedResultCot = 0;
        writeResultCot();
    }
    
    static public func decodeMatrixToFile(cot:Int) ->PicMatrix?{
        var matrix = PicMatrix();
        let matrixStr = readFile(url: "\(picMatrixFile)\(cot)\(fileSubFix)");
        if let allNumbers = matrixStr?.components(separatedBy: " "){
            if(allNumbers.count == 17){
                matrix.itemDis = Double(allNumbers[0])!;
                matrix.prevTrans = matrix_identity_float4x4
                matrix.prevTrans!.columns.0.x = Float(allNumbers[1])!;
                matrix.prevTrans!.columns.0.y = Float(allNumbers[2])!;
                matrix.prevTrans!.columns.0.z = Float(allNumbers[3])!;
                matrix.prevTrans!.columns.0.w = Float(allNumbers[4])!;
                matrix.prevTrans!.columns.1.x = Float(allNumbers[5])!;
                matrix.prevTrans!.columns.1.y = Float(allNumbers[6])!;
                matrix.prevTrans!.columns.1.z = Float(allNumbers[7])!;
                matrix.prevTrans!.columns.1.w = Float(allNumbers[8])!;
                matrix.prevTrans!.columns.2.x = Float(allNumbers[9])!;
                matrix.prevTrans!.columns.2.y = Float(allNumbers[10])!;
                matrix.prevTrans!.columns.2.z = Float(allNumbers[11])!;
                matrix.prevTrans!.columns.2.w = Float(allNumbers[12])!;
                matrix.prevTrans!.columns.3.x = Float(allNumbers[13])!;
                matrix.prevTrans!.columns.3.y = Float(allNumbers[14])!;
                matrix.prevTrans!.columns.3.z = Float(allNumbers[15])!;
                matrix.prevTrans!.columns.3.w = Float(allNumbers[16])!;
                return matrix;
            }
        }
        return nil;
    }
    
    static public func encodeMatrixToFile(matrix: PicMatrix){
        readResultCot()
        let matrixStr = NSMutableString("");
        matrixStr.append(String(matrix.itemDis))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.0.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.0.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.0.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.0.w))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.1.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.1.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.1.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.1.w))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.2.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.2.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.2.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.2.w))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.3.x))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.3.y))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.3.z))
        matrixStr.append(" ");
        matrixStr.append(String(matrix.prevTrans!.columns.3.w))
        
        writeFile(text: matrixStr as String, url: "\(picMatrixFile)\(savedResultCot)\(fileSubFix)");
    }
    
    static public func readResultFromFile(cot:Int) -> String?{
        readResultCot();
        if(cot >= savedResultCot) {
            NSLog("out of range file cot: \(cot)");
        }
        return readFile(url: "\(bookResultFile)\(cot)\(fileSubFix)")
    }
    
    static public func addResultToFile(text:String) -> Int?{
        readResultCot();
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("\(bookResultFile)\(savedResultCot)\(fileSubFix)");
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                NSLog("error writing file");
                return nil;
            }
        }
        savedResultCot+=1
        writeResultCot()
        readResultCot(); // double check
        return savedResultCot;
    }
    
    static public func writeFile(text:String, url: String){
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(url)

            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                NSLog("error writing file: \(url)");
            }
        }

    }
    
    static public func readFile(url: String) -> String? {
        var text = "";
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(url)

            //reading
            do {
                text = try String(contentsOf: fileURL, encoding: .utf8)
                return text;
            }
            catch {
                NSLog("error reading file: \(url), reason: \(error)");
                return nil;
            }
        }
        return nil;
    }
}
