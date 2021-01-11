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
    var radio: Float = 1
    var elementPics = [UIImage]()
    var bookAbstractUI = UIBookAbstract()
    var nowEnhanceNodes = [SCNNode]()
    var textWidth = 300,textHeight = 200
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
                    if let pic = UIImage(data: dataDecoded){
                        if nowOrientation == UIInterfaceOrientation.portrait.rawValue{
                            let temppic = pic.rotate(radians: -.pi/2)
                            elementPics.append(temppic)
                        }else{
//                            let temppic = pic.rotate(radians: .pi/2)
                            elementPics.append(pic)
                        }
                    }else{
                        elementPics.append(UIImage(named: "coffee1.jpg")!.rotate(radians: -.pi/2))
                    }
                    
                    strBase64 = nowCoffeeDic["desbase64"] as! String
                    dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    if let despic = UIImage(data: dataDecoded){
                        elementPics.append(despic)
                    }else{
                        elementPics.append(UIImage(named: "component.jpg")!)
                    }
                }
                nowCoffee.picid = elementPics.count-2
                nowCoffee.desPicid = elementPics.count-1
                nowCoffee.matrixId = cot;
                coffees.append(nowCoffee);
                elementWeights.append(ElementWeight())
            }
        }
        self.resetAndAddAnchor()
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
//                        let resloc = wordlocs["location"] as! NSDictionary
                    nowbook.kinds.append(wordlocs["type"] as! String)
                    nowbook.words.append(wordlocs["words"] as! String)
                }
                nowbook.matrixId = cot;
                books.append(nowbook);
                elementWeights.append(ElementWeight())
            }
        }
//        self.resetAndAddAnchor()
    }
    
    public func removeHeadAnchor(){
//        if let anchorlist = sceneView.session.currentFrame?.anchors {
//            for anchor in anchorlist {
//                if let hanchor = anchor as? HeadAnchor{
//                    sceneView.session.remove(anchor: hanchor)
//                }
//            }
//        }
        
        let childNodes = arView.scene.anchors

        for node in childNodes {
            let name = node.name
            if name.hasPrefix("head@") {
                arView.scene.removeAnchor(node)
            }
        }
    }
    
    public func resetAndAddAnchor(isReset: Bool = false){
        if isReset{
            for i in stride(from: 0, to: books.count ,by: 1){
                books[i].isDisplay = false
            }
            
            for i in stride(from: 0, to: coffees.count ,by: 1){
                coffees[i].isDisplay = false
            }
            
//            if let anchorlist = sceneView.session.currentFrame?.anchors {
//                for anchor in anchorlist {
//                    if let imanchor = anchor as? BookAnchor{
//                        sceneView.session.remove(anchor: imanchor)
//                    }
//                    else if let imanchor = anchor as? CoffeeAnchor{
//                        sceneView.session.remove(anchor: imanchor)
//                    }
//                }
//            }
            let childNodes = getEntityList()
            for node in childNodes {
                let name = node.name
                if name.hasPrefix("book@") {
                    print("remove:\(name)")
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
            let size = CGSize(width: PicMatrix.getActualLen(oriLen:Double(rootLoc.width),isW: true), height: PicMatrix.getActualLen(oriLen:Double(rootLoc.height),isW: false))
            print("bookid: \(i)")
            var words = ""
            for str in currentBook.words {
                words+=str+" "
            }
            print(" words: \(words)")
            let book = AnchorEntity(world: trans)
            book.addChild(createPlane(id: i, size: size))
            book.name = "book@\(i)"
            arView.scene.addAnchor(book)
            
            var translation = matrix_identity_float4x4
            translation.columns.3.x = -Float(size.width)
            translation.columns.3.y = Float(size.height)/2
            let topPos = book.transform.matrix*translation
            let top = SCNNode();
            top.transform = SCNMatrix4(topPos)
            books[i].uiPosVec = top.position-SCNVector3(book.position)
        }
        
        for i in stride(from: 0, to: coffees.count ,by: 1){
            if coffees[i].isDisplay{
                continue;
            }
            let nowMatrix = coffees[i].matrixId!-1
            coffees[i].isDisplay = true;
            picMatrix[nowMatrix].addCoffeeAnchor(id:i,coffee:coffees[i])
        }
    }
    
    
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
        let anchor = anchors.first!;
        if let bookAnchor = anchor as? BookAnchor{
        }
//        }else if let coffeeAnchor = anchor as? CoffeeAnchor{
//            let id = coffeeAnchor.id!;
//            let currentCoffee = coffees[id]
//            let rootLoc = currentCoffee.loc
//            let picContents = elementPics[currentCoffee.picid]
//            let size = CGSize(width: PicMatrix.getActualLen(oriLen:Double(rootLoc.width),isW: true), height: PicMatrix.getActualLen(oriLen:Double(rootLoc.height),isW: false))
//            print("coffeeid: \(id) \(coffees[id].name)")
//            let coffee = createPlaneNode(size: size, rotation: 0, contents: picContents)
//            coffee.name = "coffee@\(id)"
//            coffee.transform = SCNMatrix4(anchor.transform)
//            coffees[id].oriTrans = coffee.transform
//            arView.scene.rootNode.addChildNode(coffee)
//
//            var translation = matrix_identity_float4x4
//            translation.columns.3.y = Float(size.height/2)
//            let topPos = anchor.transform*translation
//            let top = SCNNode();
//            top.transform = SCNMatrix4(topPos)
//            coffees[id].uiPosVec = top.position-coffee.position
//
            
//        }else if let headAnchor = anchor as? HeadAnchor{
//
//
//            let text = SCNText(string: headAnchor.text, extrusionDepth: 0.1)
//            text.font = UIFont.systemFont(ofSize: 1)
//            text.isWrapped = true
//            text.containerFrame = CGRect(x: 0, y: 0, width: 5, height: 7)
//
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
//            text.materials = [material]
//
//            let textNode = SCNNode(geometry: text)
//            textNode.name = "head@"
//            textNode.transform = SCNMatrix4(headAnchor.transform)
//            textNode.scale = SCNVector3(x: 0.02, y: 0.02, z: 0.02)
//            textNode.constraints = [SCNBillboardConstraint()]
//            sceneView.scene.rootNode.addChildNode(textNode)
//        }
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


