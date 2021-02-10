//
//  ViewController.swift
//  ARKitImageDetectionTutorial
//
//  Created by Ivan Nesterenko on 28/5/18.
//  Copyright © 2018 Ivan Nesterenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import RealityKit

//import Base





class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var wholeView: UIView!
    @IBOutlet var arView: ARView!
    @IBOutlet var inputText: UITextField!
    @IBOutlet var attrSelect: UIPickerView!
    @IBOutlet var message: UITextField!
    var nowSelection: Int = 0
    var bookAttr = [String]()
    private var result: NSDictionary!
    var picMatrix = [PicMatrix]()
    var books = [BookSt]()
    var viewCenterPoint = CGPoint()
    var elementWeights = [ElementWeight]()
    var imageH = CGFloat()
    var imageW = CGFloat()
    var timer: Timer?
    var elementPics = [UIImage]()
    var bookAbstractUI = UIBookAbstract()
    var nowEnhanceNodes = [SCNNode]()
    var textWidth = 300,textHeight = 250
    var rootnode = AnchorEntity()
    
    
    var isAntUpdate = false
    var isAntUpdateCot = 0
    var shouldBeInPlace = false
    
    
    var isCoffee = false
    var coffees = [CoffeeSt]()
    var coffeeAbstractUI = UICoffeeAbstract()

    // ui
    var receiveAnsCot = 0
    var nowOrientation = 0
    
    var utiQueue = DispatchQueue(label:"uploadImage", qos: .utility)


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wholewidth = wholeView.bounds.size.width
        let wholeHeight = wholeView.bounds.size.height
//        inputText.ret
        inputText.addDismissButton()
        inputText.delegate = self
        inputText.bounds.size.width = wholewidth-130
        inputText.center.x = wholeView.center.x+50
        inputText.text = ""
        
        message.bounds.size.width = wholewidth-100
        message.center.x = wholeView.center.x
        message.text = "Start scanning a book by press \"scan\"!"
        message.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        message.delegate = self

        attrSelect.delegate = self
        attrSelect.bounds.size.width = 120
        attrSelect.center.x = 55
        attrSelect.center.y = inputText.center.y
        attrSelect.dataSource = self
        bookAttr = ["Title", "Publisher", "Author", "Score", "Relate"]
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.findString), name: NSNotification.Name.UITextFieldTextDidChange, object:nil)
        
        self.arView.addSubview(bookAbstractUI.ui)

        coffeeAbstractUI.setIsHidden(true)
        self.arView.addSubview(coffeeAbstractUI.ui)
        self.arView.addSubview(coffeeAbstractUI.textUI)


        arView.bounds.size.width = wholewidth
        arView.bounds.size.height = wholeHeight
        arView.center = wholeView.center
        
        viewCenterPoint = arView.center
        arView.session.delegate = self
        arView.environment.sceneUnderstanding.options = []
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        arViewGestureSetup()
        wholeView.sendSubviewToBack(arView)
        
        let emptyMenu = UIImage(named: "big_empty.png")!
        let data = emptyMenu.pngData()
        let filename = getDocumentsDirectory().appendingPathComponent("big_empty.jpg")
        try! data!.write(to: filename)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
//        if nowOrientation != UIInterfaceOrientation.portrait.rawValue{
//            if #available(iOS 13.4, *) {
//                configuration.sceneReconstruction = .meshWithClassification
//            }
//        }
        arView.session.run(configuration)
        // height 100
        createButton( title: "scan",negX: -100, negY: 100, action: #selector(ViewController.buttonTapUpload))
        createButton(title: "sort",negX: 100,  negY: 100, action: #selector(ViewController.changeToSortDisplay))
        // height 150
        createButton(title: "restore",negX: -100, negY: 150, action: #selector(ViewController.restoreDisplay))
        createButton(title: "debug", negY: 150, action: #selector(ViewController.buttonTapDebug))
        let antButton = createButton(title: "Ant",negX: 100, negY: 150, action: nil)
        antButton.addTarget(self, action: #selector(ViewController.startAntEyeDisplay), for: .touchDown)
        antButton.addTarget(self, action: #selector(ViewController.stopAntEyeDisplay), for: [.touchUpInside, .touchUpOutside])

        createButton(title: "data",negY: 200, action: #selector(ViewController.buttonTapData))

        
        // height 250
        createButton(title: "background",negX: -100,negY: 250, action: #selector(ViewController.buttonTapCreateBigPlane))
        createButton(title: "switch",negX: 100, negY: 250, action: #selector(ViewController.switchToCoffee))

//        createDirectionButton()
//        ButtonCreate.createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        
        // height 300
//        createButton(title: "coffeedebug",negX: 100, negY: 300, action: #selector(ViewController.buttonShowCoffeeAbs))

//        switchToCoffee()
//        switchToCoffee()

        DispatchQueue.main.async{
            self.nowOrientation = UIApplication.shared.statusBarOrientation.rawValue
        }
        let rootNode = AnchorEntity(world: matrix_identity_float4x4)
        rootNode.name = "rootnode@"
        arView.scene.addAnchor(rootNode)
        rootnode = rootNode
    }
    
    func setLocation(locDic: NSDictionary)->Location{
        var loc = Location()
        if(isCoffee){
            loc.height = locDic["height"] as! Int
            loc.width = locDic["width"] as! Int
            loc.top = locDic["top"] as! Int
            loc.left = locDic["left"] as! Int
        }
        else{
            loc.height = locDic["width"] as! Int
            loc.width = locDic["height"] as! Int
            loc.left = Int(PicMatrix.imageW) - (locDic["top"] as! Int) - loc.width
            loc.top = (locDic["left"] as! Int)
        }
        return loc;
    }
    
    func setResult(cot:Int, receive: String, isDebug: Bool = false){
        result = Internet.getDictionaryFromJSONString(jsonString: receive)
        print("visit returns")
        print("setResult function is on \(Thread.current)" )
        receiveAnsCot+=1
        if let hasResult = result {
            if isCoffee == false{
                setForBooks(cot:cot, hasResult: hasResult,isDebug: isDebug)
            }
            else{setForCoffee(cot:cot, hasResult: hasResult,isDebug: isDebug)}
        }
        if(receiveAnsCot != picMatrix.count){
            setMessage("waiting for \(picMatrix.count-receiveAnsCot) scan results")
        }else{
            setMessage("Receive all scan results")
        }

    }
    
    public func setForCoffee(cot:Int, hasResult: NSDictionary, isDebug: Bool){
        let menuPic : Data = Data(base64Encoded: hasResult["menubase64"] as! String, options: .ignoreUnknownCharacters)!
        let oriFilename = getDocumentsDirectory().appendingPathComponent("MenuOri@.png")
        try! menuPic.write(to: oriFilename)
        let emptyMenu : Data = Data(base64Encoded: hasResult["menubase64_nowords"] as! String, options: .ignoreUnknownCharacters)!
        let emptyFileName = getDocumentsDirectory().appendingPathComponent("MenuEmpty@.png")
        try! emptyMenu.write(to: emptyFileName)
        if let resultbooks = hasResult["words_result"] {
            let coffeeArray = resultbooks as! NSArray
            print("Found \(coffeeArray.count) coffees")
            for nowforCoffee in coffeeArray{
                let nowCoffeeDic = nowforCoffee as! NSDictionary
                let nowCoffee = CoffeeSt()
                let coffeeloc = nowCoffeeDic["location"] as! NSDictionary
                nowCoffee.loc = setLocation(locDic: coffeeloc)
                nowCoffee.name = nowCoffeeDic["words"] as! String
                nowCoffee.fragrance = nowCoffeeDic["fragrance"] as! String
                nowCoffee.aroma = nowCoffeeDic["aroma"] as! String
                nowCoffee.acidity = nowCoffeeDic["acidity"] as! String
                nowCoffee.body = nowCoffeeDic["body"] as! String
                nowCoffee.aftertaste = nowCoffeeDic["aftertaste"] as! String
                nowCoffee.flavor = nowCoffeeDic["flavor"] as! String
                nowCoffee.balance = nowCoffeeDic["balance"] as! String
                nowCoffee.score = Int((nowCoffeeDic["score"] as! Double)*5)
                nowCoffee.remark = nowCoffeeDic["remark"] as! String
                if(isDebug){
                    elementPics.append(UIImage(named: "coffee1.jpg")!)
                    elementPics.append(UIImage(named: "component.jpg")!)
                }else{
                    var strBase64 = nowCoffeeDic["base64"] as! String
                    var dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    let filename = getDocumentsDirectory().appendingPathComponent("coffee@\(coffees.count).png")
                    try! dataDecoded.write(to: filename)
                    strBase64 = nowCoffeeDic["desbase64"] as! String
                    dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    nowCoffee.desPicid = elementPics.count
                    if let pic = UIImage(data: dataDecoded){
                        elementPics.append(pic)
                    }else{
                        elementPics.append(UIImage(named: "component.png")!)
                    }
                }
                nowCoffee.picid = elementPics.count-2
                nowCoffee.desPicid = elementPics.count-1
                nowCoffee.matrixId = cot;
                coffees.append(nowCoffee);
                elementWeights.append(ElementWeight())
            }
        }
        var ready = false
        while(ready==false){
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Thread.sleep(forTimeInterval: 0.5)
            ready = resetPicTracking()
            print(ready)
//            }
        }
//        print("after async: \(ready)")
    }

    public func setForBooks(cot:Int, hasResult: NSDictionary, isDebug: Bool){
        if let resultbooks = hasResult["words_result"] {
            let bookarray = resultbooks as! NSArray
            print("Found \(bookarray.count) books")
            for nowforbook in bookarray{
                let nowtempbook = nowforbook as! NSDictionary
                let nowbook = BookSt()
                let bookloc = nowtempbook["location"] as! NSDictionary
                nowbook.color = UIColor(red: (nowtempbook["r"] as! CGFloat)/255.0, green: (nowtempbook["g"] as! CGFloat)/255.0, blue: (nowtempbook["b"] as! CGFloat)/255.0, alpha: 1)
                nowbook.loc = setLocation(locDic: bookloc)
                nowbook.title = nowtempbook["title"] as! String
                nowbook.author = nowtempbook["author"] as! String
                nowbook.publisher = nowtempbook["publisher"] as! String
                nowbook.relatedBook = nowtempbook["relatebooks"] as! String
                nowbook.score = Int((nowtempbook["score"] as! Double)*5)
                nowbook.remark = nowtempbook["remark"] as! String
                if(isDebug){
                    elementPics.append(UIImage(named: "test2.png")!)
                }else{
                    let strBase64 = nowtempbook["base64"] as! String
                    let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    if let pic = UIImage(data: dataDecoded){
                        let temppic = pic.rotate(radians: .pi/2)
                        let data = temppic.pngData()
                        let filename = getDocumentsDirectory().appendingPathComponent("book@\(books.count).png")
                        try! data!.write(to: filename)
                    }
                }
                nowbook.picid = elementPics.count-1
                let parts = nowtempbook["part"] as! NSArray
                for wordforlocs in parts {
                    let wordlocs = wordforlocs as! NSDictionary
                    nowbook.kinds.append(wordlocs["type"] as! String)
                    nowbook.words.append(wordlocs["words"] as! String)
                }
                nowbook.matrixId = cot;
                books.append(nowbook);
                elementWeights.append(ElementWeight())
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetAndAddAnchor()
        }

    }

    public func removeHeadAnchor(){
//        let childNodes = arView.scene.anchors
        while(true){
            guard let headNode = arView.scene.findEntity(named: "head@")else{break}
            headNode.removeFromParent()
        }
    }
    
    public func resetPicTracking() -> Bool{
        if(isCoffee==false){return false}
        let fileName = "MenuOri@.png"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        guard var oriMenu = UIImage(contentsOfFile: path)else{
            print("no original menu file")
            return false
        }
        PicMatrix.imageW = Double(oriMenu.size.width * oriMenu.scale)
        PicMatrix.imageH = Double(oriMenu.size.height * oriMenu.scale)
        oriMenu = UIImage(named: "big.jpg")!

        let physicalWidth = picMatrix[0].getActualLen(oriLen: PicMatrix.imageW, isW: true)
        let oriMenuCIImage = CIImage(image: oriMenu)!
        let oriMenuCgImage = convertCIImageToCGImage(inputImage: oriMenuCIImage)!
        let arImage = ARReferenceImage(oriMenuCgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(physicalWidth))
        arImage.name = "Coffee Menu"

        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = [arImage]
        arView.session.run(configuration)
        return true
    }
    
    public func resetAndAddAnchor(isReset: Bool = false) -> Bool{
        if isReset{
            for i in stride(from: 0, to: books.count ,by: 1){
                books[i].isDisplay = false
            }
            
            for i in stride(from: 0, to: coffees.count ,by: 1){
                coffees[i].isDisplay = false
            }
            
            let childNodes = getEntityList()
            for node in childNodes {
                let name = node.name
                if name.hasPrefix("book@") {
                    arView.scene.removeAnchor(node as! HasAnchoring)
                }else if name.hasPrefix("coffee@"){
                    node.removeFromParent()
                }else{
                    continue;
                }
            }
        }
        
        for i in stride(from: 0, to: books.count ,by: 1){
            if books[i].isDisplay{
                continue;
            }
            let nowMatrix = books[i].matrixId!-1
            books[i].isDisplay = true;
            let trans = picMatrix[nowMatrix].addBookAnchor(id:i,book:books[i])
            books[i].oriTrans = trans
            let currentBook = books[i]
            let rootLoc = currentBook.loc
//            let picContents = elementPics[currentBook.picid]
            let size = CGSize(width: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.width),isW: true), height: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.height),isW: false))
            books[i].size = size
            print("bookid: \(i),size \(size)")
            var words = ""
            for str in currentBook.words {
                words+=str+" "
            }
            let book = AnchorEntity(world: trans)
            guard let plane = createPlane(id: i, size: size, isCoffee: isCoffee) else{
                return false
            }
            book.addChild(plane)
            
            let booksur = try! Entity.loadModel(named: "sur")
            let bookpage = try! Entity.loadModel(named: "page")
            var material1 = UnlitMaterial()
            var material2 = UnlitMaterial()
            material1.tintColor = books[i].color
            material2.tintColor = UIColor.white
            booksur.model?.materials = [material1]
            bookpage.model?.materials = [material2]
            
            let bookBox = ModelEntity()
            bookBox.addChild(booksur)
            bookBox.addChild(bookpage)
            bookBox.scale = SIMD3<Float>(x: Float(size.width/0.02),y:Float(size.height/0.26),z:0.7)
            bookBox.position = SIMD3<Float>(x: 0, y: Float(-1*size.height/2), z: -0.001)
            
            book.addChild(bookBox)
            book.name = "book@\(i)"
            book.generateCollisionShapes(recursive: true)
            arView.scene.addAnchor(book)
        }
        
        for i in stride(from: 0, to: coffees.count ,by: 1){
            guard let menu = arView.scene.findEntity(named: "menu@") else{
                return false
            }

            if coffees[i].isDisplay{
                continue;
            }
            let nowMatrix = coffees[i].matrixId!-1
            coffees[i].isDisplay = true;
            let trans = picMatrix[nowMatrix].addCoffeeAnchor(id:i,coffee:coffees[i])
            coffees[i].oriTrans = trans
            let currentCoffee = coffees[i]
            let rootLoc = currentCoffee.loc
            let size = CGSize(width: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.width),isW: true), height: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.height),isW: false))
            coffees[i].size = size
//            let coffee = createCoffeeFont(id: i,coffeeName:coffees[i].name, size: size)
            let coffee = ModelEntity()
            let lineHeight: CGFloat = 0.05
            let font = MeshResource.Font.systemFont(ofSize: lineHeight, weight: .bold)
            let textMesh = MeshResource.generateText(coffees[i].name, extrusionDepth: Float(lineHeight * 0.1), font: font)
            var textMaterial = UnlitMaterial()
//            material.baseColor = MaterialColorParameter.texture(resource!)
            textMaterial.tintColor = UIColor(red: 108.0/255, green: 71.0/255, blue: 45.0/255, alpha: 0.8)

//            let textMaterial = SimpleMaterial(color: UIColor(red: 108.0/255, green: 71.0/255, blue: 45.0/255, alpha: 0.8), isMetallic: false)
            let coffeeFont = ModelEntity(mesh: textMesh, materials: [textMaterial])
//            let bound = textMesh.bounds
            let radius = Float(0.2) //Float(size.width)/(bound.boundingRadius*2)
            
            coffee.transform = Transform(matrix: trans)
            coffee.name = "coffee@\(i)"
            coffee.addChild(coffeeFont)
            coffeeFont.scale = SIMD3<Float>(x: radius, y: radius, z: radius)
            coffee.generateCollisionShapes(recursive: true)
            menu.addChild(coffee)

        }
        return true
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
        guard let imageAnchor = anchors.first as? ARImageAnchor else{
            return
        }
        //        let resource = try? TextureResource.load(contentsOf: getDocumentsDirectory().appendingPathComponent("MenuEmpty@.png"))
        let resource = try? TextureResource.load(contentsOf: getDocumentsDirectory().appendingPathComponent("big_empty.jpg"))
        let nowW = Float(picMatrix.last!.getActualLen(oriLen: PicMatrix.imageW, isW: true))
        let nowH = Float(picMatrix.last!.getActualLen(oriLen: PicMatrix.imageH, isW: false))
        print("menu width: \(nowW), height:\(nowH)")
        let rotationTrans = imageAnchor.transform*makeRotationMatrix(x: -.pi/2, y: 0, z: 0)
        let trans = getForwardTrans(ori: rotationTrans, dis: 0.1) //开始时是悬浮在上方10cm， update时向下移动到原位
        let anchor = AnchorEntity(world:trans)
        picMatrix[0].prevTrans = trans
        var material = UnlitMaterial()
        material.baseColor = MaterialColorParameter.texture(resource!)
        material.tintColor = UIColor.white.withAlphaComponent(0.99)
        let imagePlane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(nowW), height: Float(nowH)), materials: [material])
        anchor.addChild(imagePlane)
        anchor.name = "menu@"
        arView.scene.anchors.append(anchor)
        resetAndAddAnchor()
    }
    
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        for anchor in anchors{
            if let imgAnchor = anchor as? ARImageAnchor{
                if let childNode = arView.scene.findEntity(named: "menu@"){
                    let rotationTrans = imgAnchor.transform*makeRotationMatrix(x: -.pi/2, y: 0, z: 0)
                    childNode.move(to: rotationTrans, relativeTo: rootnode, duration: 0.4)
                }
            }
        }
    }

    
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        if(bookAbstractUI.getIsHidden() == false){
            guard let childNode = arView.scene.findEntity(named: "book@\(bookAbstractUI.id)")  else{
                print("renderer: no such book \(bookAbstractUI.id)")
                return
            }
            if let pos = arView.project(books[bookAbstractUI.id].uiPos(childNode.transformMatrix(relativeTo: rootnode))){
//                print(pos)
                var pos2d = CGPoint()
                pos2d.x = pos.x-CGFloat(textWidth/2)
                pos2d.y = pos.y-CGFloat(textHeight)
                self.bookAbstractUI.updatePosition(position: pos2d)
            }
        }

        if(coffeeAbstractUI.getIsHidden() == false){
            guard let childNode = arView.scene.findEntity(named:  "coffee@\(coffeeAbstractUI.id)") else{
                print("renderer: no such coffee \(coffeeAbstractUI.id)")
                return
            }
            if let pos = arView.project(coffees[coffeeAbstractUI.id].uiPos(childNode.transformMatrix(relativeTo: rootnode))){
                var pos2d = CGPoint()
                pos2d.x = pos.x//+CGFloat(coffeeAbstractUI.imageW/2)
                pos2d.y = pos.y-125//-CGFloat(coffeeAbstractUI.imageW/2)
                coffeeAbstractUI.updatePosition(position: pos2d)
            }
        }

        if(isAntUpdate){
            viewCenterPoint = arView.center
            isAntUpdateCot = (isAntUpdateCot+1)%5
            var mindis = 100000.0
            var minid = -1
            for node in getEntityList() {
                let name = node.name
                guard isCoffee&&name.hasPrefix("coffee@") || isCoffee==false&&name.hasPrefix("book@") else {
                    return
                }
                let elementId = getIdFromName(name)
                guard let pos = arView.project(calcuPointPos(trans: node.transformMatrix(relativeTo: rootnode))) else{continue}
                let point = CGPoint(x:pos.x,y:pos.y)
                var screenCenter = arView.center
                if(isCoffee){screenCenter.x-=150}
                let dis = calculateScreenDistance(screenCenter,point)
                if dis<800{
                    let ratio = Float(min(2.3,(dis+28.0)/dis))
                    node.setScale(SIMD3<Float>(x:ratio,y:ratio,z:ratio), relativeTo: rootnode)
                    mindis = min(mindis,dis)
                    if mindis == dis{
                        if isAntUpdateCot==0
                        {minid = elementId}
                    }
                }
                else if shouldBeInPlace{
                    if isCoffee{
                        node.transform = Transform(matrix: coffees[elementId].oriTrans)
                    }else{
                        node.transform = Transform(matrix: books[elementId].oriTrans)
                    }
                }
            }
            let prevId = isCoffee ? coffeeAbstractUI.id : bookAbstractUI.id
            if minid != -1 && minid != prevId{
                showAbstract(id: minid)
            }
        }
        if let backnode = arView.scene.findEntity(named: "trans@1"){
            let nowTrans = arView.session.currentFrame!.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-2)
            backnode.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
            if let anno = arView.scene.findEntity(named: "cannon"){
                anno.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
                print("find cannon")
            }
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        result = nil
//        picMatrix
    }
    
    
}


