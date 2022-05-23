//
//  Viewcontroller+Search.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/19.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import ARKit
import RealityKit
import UIKit

extension ViewController: UITextFieldDelegate{
    
    public func setMessage(_ text: String){
        DispatchQueue.main.async{
            self.message.text = text
        }
    }

    
    func getIdFromName(_ name: String) -> Int {
        let i = name.index(after: name.firstIndex(of: "@")!)
        return Int(name.suffix(from: i))!
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print(textField.text)
        if(textField == message) {return false}
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if mode == 0{
            let text = textField.text ?? ""
            let command = text.components(separatedBy: " ")
            if(command.count == 2 && command[0] == "d"){
                FileHandler.removeResult(Int(command[1])!)
                return true
            }
            if(command.count == 2 && command[0] == "setres"){
                FileHandler.savedResultCot = Int(command[1])!
                FileHandler.writeResultCot()
                return true
            }
            if(command.count == 3 && command[0] == "change"){
                FileHandler.swapResult(from: Int(command[1])!, to: Int(command[2])!)
                return true
            }
            if(command.count == 2 && command[0] == "clear" && command[1] == "_all"){
                FileHandler.clearAllSavedData()
                return true
            }
            if(command.count == 2 && command[0] == "setnum" ){
                Show_Entity_Limit = Int(command[1])!
                return true
            }
            if(command.count == 1 && command[0] == "getres" ){
                setMessage("\(FileHandler.savedResultCot)")
                return true
            }
            if(command.count == 1 && command[0] == "changeshow" ){
                Simple_Filter_Nearby = !Simple_Filter_Nearby
                setMessage("\(Simple_Filter_Nearby)")
                return true
            }
            if(command.count == 2 && command[0] == "bookname" ){
                books[Int(command[1])!].title = "ecnomic studys"
                setMessage("\(books[Int(command[1])!].title)")
                return true
            }

            if(isFiltered == false){
                let remainedCot = filterBooks(textField.text ?? "")
                setMessage("After fuzzy search and filtering: \(remainedCot) books remain.")
                print("After filtering: \(remainedCot) books remain.")
                return true
            }
        }
        let text = textField.text ?? ""
        findResult = [Int]()
        if(nowSelection == 0 && mode != 2)
        {
            if(text != "")
            {
                findString(lookFor:text)
                updateShouldShowEntities()
                highlightNodes(findResult)
            }
        }
        else{
            if(text != ""&&mode == 2&&nowSelection == 2){
                findEyeshadows(text)
            }else{
                prevSearch = text
                previousKind = nowSelection
                displayGroups(nowSelection, text)
                updateShouldShowEntities()
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    public func findEyeshadows(_ str: String){
        guard let g = Int(str)else{
            setMessage("please input a valid scheme")
            return
        }
        var isfind = false
        for i in stride(from: 0, to: colors.count, by: 1){
            if colors[i].scheme == g{
                highlightColorAnimate(arEntitys[i])
                isfind = true
            }
        }
        if isfind{
            setMessage("Highlighting scheme \(g).")
        }else{
            setMessage("Scheme \(g) not found.")
        }
    }
    
    public func filterBooks(_ str:String)->Int{
        var cot = 0
        for i in stride(from: 0, to: books.count, by: 1){
            if i%17 <= 3 || i%10 > 7  {
                books[i].isDisplay = false
                cot+=1
            }
//            else{
//                books[i].isDisplay = true
//            }
        }
        return Int(Double(increaseCot()) * 0.7)
    }
    
    
    public func highlightNodes(_ ids: [Int]){
        for id in stride(from: 0, to: arEntitys.count, by: 1){
            setCoffeeColor(id, true)
            if ids.count == 0 {
                continue
            }
            if ids.firstIndex(of: id) != nil{
                var trans = Transform(matrix: arEntitys[id].transformMatrix(relativeTo: arEntitys[id].parent))
                var ratio = Float(1.4)
                if mode == 2{ratio = 1.2}
                trans.scale = SIMD3<Float>(x: ratio, y: ratio, z: ratio)
                arEntitys[id].move(to: trans, relativeTo: arEntitys[id].parent, duration: 1)
                highlightColorAnimate(arEntitys[id])
            }
            else{
                var trans = Transform(matrix: arEntitys[id].transformMatrix(relativeTo: arEntitys[id].parent))
//                if(trans.scale.x != 1){
//                    print("set coffee vague:\(id)")
//                }
                trans.scale = SIMD3<Float>(x: 1, y: 1, z: 1)
                arEntitys[id].move(to: trans, relativeTo: arEntitys[id].parent, duration: 0.4)
                setCoffeeColor(id, false)
            }
        }
    }
    
    func setCoffeeColor(_ id: Int, _ isHighlighted: Bool){
        guard mode==1 else {
            return
        }
        let font = arEntitys[id].findEntity(named: "font")! as! ModelEntity
        if isHighlighted{
            font.model!.materials = [coffeeNormalMaterial]
        }else{
//            (font.model!.materials[0] as! UnlitMaterial).tintColor  = UIColor(red: 130.0/255, green: 90.0/255, blue: 55.0/255, alpha: 0.6)
            font.model!.materials[0] = coffeeVagueMaterial
        }
    }
        
    public func findString(lookFor: String){
        print("start find")
        findResult = [Int]()
        if mode==1{
//            restoreDisplay()
            for i in stride(from: 0, to: coffees.count ,by: 1){
                let element = coffees[i]
                elementWeights[i].id = i;
                if transToSmallCase(element.name).contains(lookFor)
                {
                    elementWeights[i].weight = (Double(lookFor.count)/Double(element.name.count))
                    findResult.append(i)
                }
                else{
                    elementWeights[i].weight = 0
                }
            }
        } else if mode == 2 {
            for i in stride(from: 0, to: colors.count ,by: 1){
                let element = colors[i]
                elementWeights[i].id = i;
                if transToSmallCase(element.shadowtype).contains(lookFor)
                {
                    elementWeights[i].weight = (Double(lookFor.count)/Double(element.shadowtype.count))
                    findResult.append(i)
                }
                else{
                    elementWeights[i].weight = 0
                }
            }
        }else{
            if checkBookShelf() == false{
                restoreDisplay()
            }
            for i in stride(from: 0, to: books.count ,by: 1){
                let singlebook = books[i]
                elementWeights[i].id = i;
                elementWeights[i].weight = 0;

                if transToSmallCase(singlebook.title).contains(transToSmallCase(lookFor)){
                    findResult.append(i)
                    elementWeights[i].update(w: Double(lookFor.count)/Double(singlebook.title.count))
                }
                else{
                    // move unrelated books away.  (disabled
                    if false && mode == 0 && arView.scene.findEntity(named: "trans@1") == nil{
                        var translation = matrix_identity_float4x4
                        translation.columns.3.z = 100
                        translation.columns.3.y = 0
                        translation.columns.3.x = 0
                        let nowtrans = arView.session.currentFrame!.camera.transform
                        arEntitys[i].setTransformMatrix(nowtrans*translation, relativeTo: rootnode)
                    }
                }
//                for j in stride(from: 0, to: singlebook.words.count ,by: 1){
//                    if singlebook.words[j].contains(lookFor){
//                        findResult.append(i)
//                        elementWeights[i].update(w: Double(lookFor.count)/Double(singlebook.words[j].count));
//                        break
//                    }else{
//                        elementWeights[i].update(w: 0);
//                    }
            }
        }
        if(findResult.count == 0){
            print("no result")
            setMessage("Find no related result")
            resetSearch()
            return;
        }
        print("find \(findResult.count) results")
        setMessage("Find \(findResult.count) related results")
    }
    
    public func scaleNodes(ids: [Int], time: Double = 0.4){
        isAntUpdate = false
//        let closer = SCNAction.moveBy(x: 0, y: 0, z: 0.01, duration: 0.4)
        for node in arEntitys{
            let name = node.name
            var elementId = -1
            elementId = getIdFromName(name)
            if elementId == -1{continue}

            if ids.firstIndex(of: elementId) != nil{
//                var enhance =
//                enhance.scale = SIMD3<Float>(x: 2, y: 2, z: 1)
//                node.move(to: enhance, relativeTo: node.parent, duration: 0.2)
                
                var dis = 0.0001*Float(elementId%13)
                let translation = getForwardTrans(ori: node.transformMatrix(relativeTo: rootnode), dis: dis)
                var trans = Transform(matrix: translation)
                if mode == 1{trans = Transform(matrix:node.transformMatrix(relativeTo: rootnode))}
                trans.scale = SIMD3<Float>(x: 1.5, y: 1.5, z: 1.5)
                node.move(to: trans, relativeTo: rootnode, duration: 0.4)
            }
            else{
//                let translation = getForwardTrans(ori: node.transformMatrix(relativeTo: rootnode), dis: 0.005)
                var trans = Transform(matrix: node.transformMatrix(relativeTo: rootnode))
                trans.scale = SIMD3<Float>(x: 1, y: 1, z: 1)
                node.move(to: trans, relativeTo: rootnode, duration: 0.4)
                if mode == 1{
                    setCoffeeColor(elementId, true)
                }
            }
        }
    }
    
    
//    func
    
    func openBook(_ id: Int){
        return
        if mode==1{return}
        for i in stride(from: 0, to: books.count, by: 1){
            let book = findById(id: i) as! AnchorEntity

            if books[i].isOpen == false{
                books[i].tempTrans = book.transformMatrix(relativeTo: book.parent)
            }
            if id == i {
                if books[i].isOpen == true{
                    continue
                }
                let bookBox = book.findEntity(named: "bookBox") as! ModelEntity
                let left = bookBox.findEntity(named: "left")!
                let right = bookBox.findEntity(named: "right")!
                
                var trans = arView.session.currentFrame!.camera.transform
                var translation = matrix_identity_float4x4
                translation.columns.3.z = Float(-0.34)

                trans = trans * translation * makeRotationMatrixY(angle: .pi)
                book.move(to: trans, relativeTo: book.parent, duration: 0.4)
                
                var rotation = left.transform.matrix * makeRotationMatrix(x: 0, y: -.pi/2, z: 0)
                left.move(to: rotation, relativeTo: bookBox, duration: 0.8)
                rotation = right.transform.matrix * makeRotationMatrix(x: 0, y: .pi/2, z: 0)
                right.move(to: rotation, relativeTo: bookBox, duration: 0.8)
                books[i].isOpen = true
                continue
            }

            else if books[i].isOpen == true{
                let bookBox = book.findEntity(named: "bookBox") as! ModelEntity
                let left = bookBox.findEntity(named: "left")!
                let right = bookBox.findEntity(named: "right")!
                book.move(to: books[i].tempTrans, relativeTo: book.parent, duration: 0.4)

                var rotation = left.transform.matrix * makeRotationMatrix(x: 0, y: .pi/2, z: 0)
                left.move(to: rotation, relativeTo: bookBox, duration: 0.4)
                rotation = right.transform.matrix * makeRotationMatrix(x: 0, y: -.pi/2, z: 0)
                right.move(to: rotation, relativeTo: bookBox, duration: 0.4)
                books[i].isOpen = false
            }
        }
    }
    
    func showAbstract(id: Int){
        if id < 0{
            hideAbstract()
        }
        if mode==1{
            guard arEntitys[id].position.z >= 0 else{return}
            coffeeAbstractUI.id = id
            coffeeAbstractUI.setImage(elementPics[coffees[id].desPicid])
            coffeeAbstractUI.setText(coffees[id].generateAbstract())
            coffeeAbstractUI.setIsHidden(false)
            if let prevFace = arView.scene.findEntity(named: "face"){
                var shadowColor = UnlitMaterial()
                shadowColor.tintColor = colors[colorAbstractUI.id].color
                let shadow = prevFace.findEntity(named: "shadow")! as! ModelEntity
                shadow.model?.materials = [shadowColor]
            }
        } else if mode == 2 {
            colorAbstractUI.id = id
            colorAbstractUI.setImage(elementPics[colors[id].tPicId])
            colorAbstractUI.setText(colors[id].generateAbstract())
            colorAbstractUI.setIsHidden(false)
        }else{
            bookAbstractUI.id = id
            bookAbstractUI.setText(books[id].generateAbstract())
            bookAbstractUI.setIsHidden(false)
        }
    }
    
    func hideAbstract(){
        coffeeAbstractUI.setIsHidden(true)
        bookAbstractUI.setIsHidden(true)
        colorAbstractUI.setIsHidden(true)
    }
        
    public func resetSearch(){
        scaleNodes(ids: [])
        hideAbstract()
    }
    
    @objc func changeToSortDisplay(){
        
        scaleNodes(ids: [])
        hideAbstract()
//        shouldBeInPlace = false
        removeHeadAnchor()
        elementWeights.sort(by: {$0.weight > $1.weight})
        isInRegroupView = true
        if(mode==0){

            let z = -1*PicMatrix.showDis
            var xx =  -0.4
            let y =  0
            let nowTrans = arView.session.currentFrame!.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(z)
            translation.columns.3.y = -1.8
            translation.columns.3.x = 0
            loadBookShelf(nowTrans*translation)
            
            let headString = "Sort by " + getAttrName(kind: nowSelection)
            let lineHeight: CGFloat = 0.05
            let font = MeshResource.Font.boldSystemFont(ofSize: lineHeight)
            let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
            let textMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
            textModel.scale = SIMD3<Float>(x: 0.4, y: 0.4, z: 0.4)
            translation.columns.3.z = Float(z)
            translation.columns.3.y = 0.14
            translation.columns.3.x = 0
            let textAnchor = AnchorEntity(world: nowTrans*translation)
            textAnchor.name = "head@"
            textAnchor.addChild(textModel)
            self.arView.scene.addAnchor(textAnchor)
            for i in stride(from: 0, to: elementWeights.count ,by: 1){
                let elementWeight = elementWeights[i]
                let nowNode = arEntitys[elementWeight.id]
                if getIdFromName(nowNode.name) == -1{continue}
                translation.columns.3.z = Float(z)-(0.0001*Float(i%5))

                translation.columns.3.y = Float(y)
                translation.columns.3.x = Float(xx)
                xx += 0.055
                nowNode.move(to: nowTrans*translation, relativeTo: rootnode, duration: 0.4)
                books[elementWeight.id].tempTrans = nowTrans*translation
            }
        }else if mode == 1{
            if(picMatrix.count<=0){return}
            guard let menu = arView.scene.findEntity(named: "menu@")else{return}
            groupPosCha = [Double]()
            groupPosChaLimit = [Double]()
            var result = [[Int]]()
            result.append([Int]())
            var i = 0
            var cot = 0
            for ele in elementWeights{
                if result[i].count >= 10 && i <= 3 {i+=1;result.append([Int]())}
                result[i].append(ele.id)
                cot+=1
            }
            nowGroups = result
            for i in stride(from: 0, to: result.count, by: 1) {
                print("i:\(i),result:\(result.count)")
                let x = Float(coffeeOffset.xx[i]/coffeeOffset.rad)-0.015
                var y = Float(coffeeOffset.yy[i]/coffeeOffset.rad)
                let ystep = Float(coffeeOffset.step/coffeeOffset.rad)
                let z = Float(0.01)
                groupPosCha.append(Double(result[i].count-1)*Double(ystep))
                groupPosChaLimit.append(Double(result[i].count-1)*Double(ystep))
                for j in stride(from: 0, to: result[i].count, by: 1){
                    print("now moving: \(j)")
                    if coffees[result[i][j]].name.contains("oast") {
                        print("now trans")
                    }

                    let id = result[i][j]
                    let nowNode = arView.scene.findEntity(named: "coffee@\(id)")!
                    var translation = matrix_identity_float4x4
                    // set y
                    translation.columns.3.y = y
                    // set x
                    translation.columns.3.x = x
                    y -= ystep
                    if j == 0 && i == 1{
                        let filenamearrar = getDocumentsDirectory().appendingPathComponent("arror.png")
                        translation.columns.3.x += 0.055
                        translation.columns.3.z = 0.15
                        translation.columns.3.y -= 0.035
                        let cellSize = CGSize(width: 0.18, height: 0.02)
                        let arror = createImagePlane(url: filenamearrar, size: cellSize)!
                        arror.transform = Transform(matrix: translation)
                        arror.name = "head@"
                        menu.addChild(arror)
                        translation.columns.3.y = y
                        // set x
                        translation.columns.3.x = x
                        y -= ystep
                    }
                    if j==0 && (i==0||i==result.count-1){
                        translation.columns.3.x -= 0.01
                        if i == 0{
                            translation.columns.3.x -= 0.02
                        }
                        var headString = getAttrName(kind: nowSelection)
                        if i==0 {headString+=" (most)"}
                        else{headString+=" (least)"}
                        let lineHeight: CGFloat = 0.05
                        let font = MeshResource.Font.boldSystemFont(ofSize: lineHeight)
                        let textMesh = MeshResource.generateText(headString, extrusionDepth: Float(lineHeight * 0.1), font: font)
                        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
                        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
                        textModel.name = "head@"
                        textModel.transform = Transform(matrix: translation)
                        textModel.scale = SIMD3<Float>(x: 0.18, y: 0.18, z: 0.18)
                        if menu.findEntity(named: "big") != nil{
                            textModel.scale = SIMD3<Float>(x: 0.84, y: 0.84, z: 0.84)
                        }
                        menu.addChild(textModel)
                        translation.columns.3.y = y
                        y -= ystep
                        translation.columns.3.x = x
                    }
                    if checkIfVisible(i,translation.columns.3.y)==false{
                        translation.columns.3.z = -10
                    }else{
                        translation.columns.3.z = z
                    }
                    nowNode.move(to: translation, relativeTo: nowNode.parent, duration: 0.4)
                }
            }
        }
        checkIfHidden()
    }
    
    func calculateXDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
//        return Double(pow(pow((pos1.x-pos2.x), 2)+pow((pos1.y-pos2.y), 2),0.5))
        
        return Double(sqrt(pow( pos1.x-pos2.x,2)))
    }
    func calculateScreenDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
        return Double(pow(pow((pos1.x-pos2.x), 2)+pow((pos1.y-pos2.y), 2),0.5))
    }
    func calculateYDistance(_ pos1: CGPoint,_ pos2: CGPoint)->Double{
        return Double(pow(pow(pos1.y-pos2.y, 2),0.5))
    }
    
    
    @objc func stopAntEyeDisplay(){
        isAntUpdate = false
    }
    
    
    @objc func startAntEyeDisplay(){
        scaleNodes(ids: [], time: 0.0)
        //        hideBookAbstract()
        isAntUpdate = true
    }
    
    @objc func restoreDisplay(){
//        shouldBeInPlace = true
        
        scaleNodes(ids: [])
        hideAbstract()
        removeHeadAnchor()
        removeBookShelf()
        openBook(-1)
        cmpGroup = [Int]()
        isInRegroupView = false
        
//        if arView.scene.findEntity(named: "trans@1") != nil{
//            buttonTapCreateBigPlane()
//        }

        if self.mode==1{
            displayGroups()
            //resetAndAddAnchor(isReset: true)
            return
        }
        for i in stride(from: 0, to: arEntitys.count ,by: 1){
            let node = arEntitys[i]
            let name = node.name
            let id = getIdFromName(name)
            if mode == 2 {
                if id == -1{continue}
                var trans = Transform(matrix: self.colors[id].oriTrans)
                trans.scale = SIMD3<Float>(x: 1, y: 1, z: 1)
                node.move(to: trans, relativeTo: node.parent, duration: 0.4)
                colors[id].tempTrans = colors[id].oriTrans
            }else{
                if id != -1{
                    node.move(to: self.books[id].oriTrans, relativeTo: node.parent, duration: 0.4)
                }
                books[i].tempTrans = books[i].oriTrans
            }
        }
        checkIfHidden()
    }

    func checkBookShelf()->Bool{
        if let _ = arView.scene.findEntity(named: "bookShelf"){
            return true
        }
        return false
    }
    
    func loadBookShelf(_ trans:simd_float4x4){
        if arView.scene.findEntity(named: "trans@1") == nil{
            buttonTapCreateBigPlane()
        }
        removeBookShelf()
        let bookShelf = try! Entity.loadModel(named: "bookShelf")
//        let bookShelf1 = bookShelf.clone(recursive: true)
//        bookShelf1.position = SIMD3<Float>(x: -1.22, y: 0, z: 0)
        let bookShelf2 = bookShelf.clone(recursive: true)
        bookShelf2.position = SIMD3<Float>(x: 1.22, y: 0, z: 0)
        let bookShelf3 = bookShelf.clone(recursive: true)
        bookShelf3.position = SIMD3<Float>(x: 2.44, y: 0, z: 0)
        let bookShelf4 = bookShelf.clone(recursive: true)
        bookShelf4.position = SIMD3<Float>(x: 3.66, y: 0, z: 0)

        print("loading entity")
        let anchor = AnchorEntity(world: trans )
        anchor.addChild(bookShelf)
//        anchor.addChild(bookShelf1)
        anchor.addChild(bookShelf2)
        anchor.addChild(bookShelf3)
        anchor.addChild(bookShelf4)
//        bookShelf.scale = SIMD3<Float>(x: 0.1, y: 0.1, z: 0.1)
        anchor.name = "bookShelf"
        arView.scene.anchors.append(anchor)
        return
    }
    
    func removeBookShelf(){
        if let anchor = arView.scene.findEntity(named: "bookShelf"){
            anchor.removeFromParent()
        }
    }
    
    
}
