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
//    private var animationInfo: AnimationInfo?
    private var result: NSDictionary!
    var picMatrix = [PicMatrix]()
    var books = [BookSt]()
    var viewCenterPoint = CGPoint()
    var elementWeights = [ElementWeight]()
    var imageH = CGFloat()
    var imageW = CGFloat()
    var timer: Timer?
    var trackedImgW = 0.4
    var trackedImgH = 0.3
    //var ratio = [Float]()
    var elementPics = [UIImage]()
    var bookAbstractUI = UIBookAbstract()
    var nowEnhanceNodes = [SCNNode]()
    var textWidth = 300,textHeight = 250
    var rootnode = AnchorEntity()
    
    
    var isAntUpdate = false
    var isAntUpdateCot = 0
    var shouldBeInPlace = false
    
    
    var isCoffee = true
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
        message.text = "Start scanning a book by press \"start\"!"
        message.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
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
//        let scene = SCNScene()
//        sceneView.scene = scene
        arView.session.delegate = self
        arView.environment.sceneUnderstanding.options = []
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        arViewGestureSetup()
        wholeView.sendSubview(toBack: arView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        if nowOrientation != UIInterfaceOrientation.portrait.rawValue{
            if #available(iOS 13.4, *) {
                configuration.sceneReconstruction = .meshWithClassification
            }
        }
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
        //createButton(title: "background",negX: -100,negY: 250, action: #selector(ViewController.buttonTapCreateBigPlane))
        createButton(title: "switch",negX: 100, negY: 250, action: #selector(ViewController.switchToCoffee))

        createDirectionButton()
//        ButtonCreate.createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        
        // height 300
        createButton(title: "coffeedebug",negX: 100, negY: 300, action: #selector(ViewController.buttonShowCoffeeAbs))

        switchToCoffee()
        switchToCoffee()

        DispatchQueue.main.async{
            self.nowOrientation = UIApplication.shared.statusBarOrientation.rawValue
        }
//        createDirectionButton()
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
//            loc.left = Int(PicMatrix.imageW) - (locDic["left"] as! Int)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetAndAddAnchor()
        }
    }

    public func setForBooks(cot:Int, hasResult: NSDictionary, isDebug: Bool){
        if let resultbooks = hasResult["words_result"] {
            let bookarray = resultbooks as! NSArray
            print("Found \(bookarray.count) books")
            for nowforbook in bookarray{
                let nowtempbook = nowforbook as! NSDictionary
                let nowbook = BookSt()
                let bookloc = nowtempbook["location"] as! NSDictionary
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
                        let data = UIImagePNGRepresentation(temppic)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetAndAddAnchor()
        }

    }

    public func removeHeadAnchor(){
        let childNodes = arView.scene.anchors

        while(true){
            var hasHead = false
            for node in childNodes {
                let name = node.name
                print(name)
                if name.hasPrefix("head@") {
                    arView.scene.removeAnchor(node)
                    hasHead = true
                    break;
                }
            }
            if(hasHead==false){break}
        }
    }
    
    public func resetPicTracking(){
        if(isCoffee==false){return}
        let fileName = "MenuOri@.png"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        guard let oriMenu = UIImage(contentsOfFile: path)else{
            print("no original menu file")
            return
        }
        trackedImgW = Double(oriMenu.size.width * oriMenu.scale)
        trackedImgH = Double(oriMenu.size.height * oriMenu.scale)
//        guard let oriMenu = UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent("MenuOri@.png").absoluteString) else{
//            print("no original menu file")
//            return
//        }
        let oriMenuCIImage = CIImage(image: oriMenu)!
        let oriMenuCgImage = convertCIImageToCGImage(inputImage: oriMenuCIImage)!
        let arImage = ARReferenceImage(oriMenuCgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.2)
        arImage.name = "CGImage Test"

        let configuration = ARWorldTrackingConfiguration()
        if nowOrientation != UIInterfaceOrientation.portrait.rawValue{
            if #available(iOS 13.4, *) {
                configuration.sceneReconstruction = .meshWithClassification
            }
        }
        configuration.detectionImages = [arImage]
        arView.session.run(configuration)

    }
    
    public func resetAndAddAnchor(isReset: Bool = false){
        resetPicTracking()
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
                    arView.scene.removeAnchor(node)
                }else if name.hasPrefix("coffee@"){
                    arView.scene.removeAnchor(node)
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
//            print(" words: \(words)")
            let book = AnchorEntity(world: trans)
            book.addChild(createPlane(id: i, size: size, isCoffee: isCoffee))
            book.name = "book@\(i)"
            book.generateCollisionShapes(recursive: true)
            arView.scene.addAnchor(book)
        }
        
        for i in stride(from: 0, to: coffees.count ,by: 1){
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
//            print("coffeeid: \(i) \(currentCoffee.name)")
            let coffee = AnchorEntity(world: trans)
            coffee.name = "coffee@\(i)"
            coffee.addChild(createPlane(id: i, size: size, isCoffee: isCoffee))
            coffee.generateCollisionShapes(recursive: true)
            arView.scene.addAnchor(coffee)
        }
    }
    
    

    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
        guard let imageAnchor = anchors.first as? ARImageAnchor else{
            return
        }
        print("find img: \(imageAnchor.name)")

        let resource = try? TextureResource.load(contentsOf: getDocumentsDirectory().appendingPathComponent("MenuEmpty@.png"))
//        let rotationTrans =  imageAnchor.transform * Transform.init( rotation: simd_quaternion(0, .pi, 0, 1),translation: SIMD3(0,0,0.2)).matrix
        let nowW = Float(picMatrix.last!.getActualLen(oriLen: trackedImgW, isW: true))
        let nowH = Float(picMatrix.last!.getActualLen(oriLen: trackedImgH, isW: false))

        let rotationTrans = imageAnchor.transform*makeRotationMatrix(x: -.pi/2, y: 0, z: 0)
        let anchor = AnchorEntity(world:getForwardTrans(ori: rotationTrans, dis: -1*nowH/2)
)
        var material = UnlitMaterial()
        material.baseColor = MaterialColorParameter.texture(resource!)
        material.tintColor = UIColor.white.withAlphaComponent(0.99)
        let imagePlane = ModelEntity(mesh: MeshResource.generatePlane(width: nowW, height: nowH), materials: [material])
        anchor.addChild(imagePlane)
        anchor.name = "menu@"
        arView.scene.anchors.append(anchor)
    }
    
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        for anchor in anchors{
            if let imgAnchor = anchor as? ARImageAnchor{
                if let childNode = arView.scene.findEntity(named: "menu@"){
                    let nowH = Float(picMatrix.last!.getActualLen(oriLen: trackedImgH, isW: false))+0.05

                    var rotationTrans = imgAnchor.transform*makeRotationMatrix(x: -.pi/2, y: 0, z: 0)
                    rotationTrans = getForwardTrans(ori: rotationTrans, dis: -1*nowH/2)

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
                pos2d.y = pos.y-500//-CGFloat(coffeeAbstractUI.imageW/2)
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
//                let centerP = CGPoint(x: 590, y: 400)
                let dis = calculateScreenDistance(arView.center,point)
                if(elementId == 0){
                    print("dis: \(dis)")}

                if dis<800{
                    let ratio = Float(min(2.3,(dis+28.0)/dis))
//                    node.transform
                    node.setScale(SIMD3<Float>(x:ratio,y:ratio,z:ratio), relativeTo: rootnode) //scale =
//                    node.setTransformMatrix(getForwardTrans(ori:node.transformMatrix(relativeTo: rootnode),dis:ratio[elementId]/20), relativeTo: rootnode)
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
//                var node = Optional<AnchorEntity>(AnchorEntity())
//                var prevNode = Optional<AnchorEntity>(AnchorEntity())
//
//                if isCoffee{
//                    node = arView.scene.findEntity(named: "coffee@\(minid)") as? AnchorEntity
//                    prevNode = arView.scene.findEntity(named: "coffee@\(prevId)") as? AnchorEntity
//                }else{
//                    node = arView.scene.findEntity(named: "book@\(minid)") as? AnchorEntity
//                    prevNode = arView.scene.findEntity(named: "book@\(prevId)") as? AnchorEntity
//                }
//                var transForm = matrix_identity_float4x4
//                transForm.columns.3.z = -0.02
//                node?.move(to: (node?.transform.matrix)!*transForm, relativeTo: node, duration: 0.01)
//                transForm.columns.3.z = 0.02
//                prevNode?.move(to: (prevNode?.transform.matrix)!*transForm, relativeTo: prevNode, duration: 0.01)
                showAbstract(id: minid)
            }
        }

    }


    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//        if let backnode = sceneView.scene.rootNode.childNode(withName: "trans@1", recursively: false){
//            let trans = arView.session.currentFrame!.camera.transform
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = Float(-5)
//            backnode.transform = SCNMatrix4(trans*translation)
//
//        }
//
//        if(bookAbstractUI.getIsHidden() == false){
//            guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(bookAbstractUI.id)", recursively: false) else{
//                print("renderer: no such book \(bookAbstractUI.id)")
//                return
//            }
//            let bookTopPos = childNode.position+books[bookAbstractUI.id].uiPosVec!
//            let pos = sceneView.projectPoint(bookTopPos)
//            var pos2d = CGPoint()
//            pos2d.x = CGFloat(pos.x-Float(textWidth/2))
//            pos2d.y = CGFloat(pos.y-Float(textHeight))
//            DispatchQueue.main.async{
//                self.bookAbstractUI.updatePosition(position: pos2d)
//            }
//        }
//
//        if(coffeeAbstractUI.getIsHidden() == false){
//            guard let childNode = sceneView.scene.rootNode.childNode(withName: "coffee@\(coffeeAbstractUI.id)", recursively: false) else{
//                print("renderer: no such coffee \(coffeeAbstractUI.id)")
//                return
//            }
//            let topPos = childNode.position+coffees[coffeeAbstractUI.id].uiPosVec!
//            let pos = sceneView.projectPoint(topPos)
//            var pos2d = CGPoint()
//            pos2d.x = CGFloat(pos.x)
//            pos2d.y = CGFloat(pos.y-Float(coffeeAbstractUI.imageW/2))
//            coffeeAbstractUI.updatePosition(position: pos2d)
//        }
//
//        if(isAntUpdate){
//            isAntUpdateCot = (isAntUpdateCot+1)%5
//            var mindis = 1000.0
//            var minid = -1
//            for node in sceneView.scene.rootNode.childNodes {
//                guard let name = node.name else {
//                    continue
//                }
////                print(name)
//                guard isCoffee&&name.hasPrefix("coffee@") || isCoffee==false&&name.hasPrefix("book@") else {
//                    return
//                }
//                let elementId = getIdFromName(name)
////                print(elementId)
//                let pos = sceneView.projectPoint(node.position)
//                let point = CGPoint(x:CGFloat(pos.x),y:CGFloat(pos.y))
//                let dis = calculateScreenDistance(viewCenterPoint,point)
//                if dis<800{
//                    let ratio = CGFloat(min(2.5,(dis+25.0)/dis))
//                    let scale = SCNAction.scale(to: ratio, duration: 0)
//                    node.runAction(scale)
//                    mindis = min(mindis,dis)
//                    if mindis == dis{
//                        if isAntUpdateCot==0
//                        {minid = elementId}
//                    }
//                }
//                else if shouldBeInPlace{
//                    if isCoffee{
//                        node.transform = coffees[elementId].oriTrans
//                    }else{
//                        node.transform = books[elementId].oriTrans
//                    }
//                }
//            }
//            let prevId = isCoffee ? coffeeAbstractUI.id : bookAbstractUI.id
//            if minid != -1 && minid != prevId{
//                var node = Optional<SCNNode>(SCNNode())
//                var prevNode = Optional<SCNNode>(SCNNode())
//
//                if isCoffee{
//                    node = sceneView.scene.rootNode.childNode(withName: "coffee@\(minid)", recursively: false)
//                    prevNode = sceneView.scene.rootNode.childNode(withName: "coffee@\(prevId)", recursively: false)
//                }else{
//                    node = sceneView.scene.rootNode.childNode(withName: "book@\(minid)", recursively: false)
//                    prevNode = sceneView.scene.rootNode.childNode(withName: "book@\(prevId)", recursively: false)
//                }
//
//                node?.runAction(SCNAction.moveBy(x: 0, y: 0, z: 0.015, duration: 0))
//                prevNode?.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.015, duration: 0))
//                showAbstract(id: minid)
//            }
//        }
//
//    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        result = nil
//        picMatrix
    }
    
    
}


