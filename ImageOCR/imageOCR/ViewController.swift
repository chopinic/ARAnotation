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
//import Base





class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var wholeView: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var inputText: UITextField!
    @IBOutlet var attrSelect: UIPickerView!
    @IBOutlet var message: UITextField!
    var nowSelection: Int = 0
    var bookAttr = [String]()
//    private var animationInfo: AnimationInfo?
    private var result: NSDictionary!
    var picMatrix = [PicMatrix]()
    var books = [BookSt]()
    var coffees = [CoffeeSt]()
    //var bookInfo = [BookInfo]()
    //var bookSCNNode = [SCNNode]()
    var viewCenterPoint = CGPoint()
    var elementWeights = [ElementWeight]()
    var imageH = CGFloat()
    var imageW = CGFloat()
    var timer: Timer?
    var radio: Float = 1
    var elementPics = [UIImage]()
    var bookAbstractUI = UIBookAbstract()
    var coffeeAbstractUI = UICoffeeAbstract()
//    @IBOutlet var coffeeDes: UIImageView!
    var nowEnhanceNodes = [SCNNode]()
    var nowGroup = [Int]()
    var textWidth = 300,textHeight = 200
    var isAntUpdate = false
    var isAntUpdateCot = 0
    var shouldBeInPlace = false
    
    // ui
    var isBookHidden = true
    var nowShowAbsId = -1

    
    
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
        bookAbstractUI = UIBookAbstract()
        bookAbstractUI.isHidden = true
        bookAbstractUI.isEditable = false
        bookAbstractUI.layer.cornerRadius = 15.0
        bookAbstractUI.layer.borderWidth = 2.0
        bookAbstractUI.layer.borderColor = UIColor.red.cgColor
        bookAbstractUI.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.sceneView.addSubview(bookAbstractUI)

        coffeeAbstractUI.setIsHidden(true)
        self.sceneView.addSubview(coffeeAbstractUI.ui)
        self.sceneView.addSubview(coffeeAbstractUI.textUI)


        sceneView.bounds.size.width = wholewidth
        sceneView.bounds.size.height = wholeHeight
        sceneView.center = wholeView.center
        
        viewCenterPoint = sceneView.center
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        
        arViewGestureSetup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        createButton( title: "book",negX: -100, negY: 100, action: #selector(ViewController.buttonTapUpload))
//        ButtonCreate.createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        
        
        createButton(title: "debug", negY: 150, action: #selector(ViewController.buttonTapDebug))
        
        createButton(title: "sort",negX: 100,  negY: 100, action: #selector(ViewController.changeToSortDisplay))
        
        createButton(title: "restore",negX: -100, negY: 150, action: #selector(ViewController.restoreDisplay))
        
        let antButton = createButton(title: "Ant",negX: 100, negY: 150, action: nil)
        
        antButton.addTarget(self, action: #selector(ViewController.startAntEyeDisplay), for: .touchDown)
        antButton.addTarget(self, action: #selector(ViewController.stopAntEyeDisplay), for: [.touchUpInside, .touchUpOutside])


        createDirectionButton()
        createButton(title: "coffee",negX: 100, negY: 250, action: #selector(ViewController.buttonTapUploadCoffee))
        createButton(title: "coffeedebug",negX: 100, negY: 300, action: #selector(ViewController.buttonShowCoffeeAbs))
//        createButton(title: "regrouping", negY: 200, action: #selector(ViewController.displayGroups))
        createButton(title: "back",negX: -100,negY: 250, action: #selector(ViewController.buttonTapCreateBigPlane))
    }

    
    func setLocation(locDic: NSDictionary, isBook: Bool = true)->Location{
        var loc = Location()
        if(isBook){
            loc.height = locDic["width"] as! Int
            loc.width = locDic["height"] as! Int
            loc.top = locDic["left"] as! Int
            loc.left = locDic["top"] as! Int
        }
        else{
            loc.height = locDic["height"] as! Int
            loc.width = locDic["width"] as! Int
            loc.top = locDic["top"] as! Int
            loc.left = locDic["left"] as! Int
        }
        return loc;
    }
    
    func setResult(cot:Int, receive: String, isDebug: Bool = false){
            result = Internet.getDictionaryFromJSONString(jsonString: receive)
            print("visit returns")
            if let hasResult = result {
                if let _ = hasResult["books_result_num"]{
                    setForBooks(cot:cot, hasResult: hasResult,isDebug: isDebug)
                }
                else{setForCoffee(cot:cot, hasResult: hasResult,isDebug: isDebug)}
        }
    }
    
    public func setForCoffee(cot:Int, hasResult: NSDictionary, isDebug: Bool){
        if let resultbooks = hasResult["words_result"] {
            let coffeeArray = resultbooks as! NSArray
            print("Found \(coffeeArray.count) coffees")
            for nowforCoffee in coffeeArray{
                let nowCoffeeDic = nowforCoffee as! NSDictionary
                var nowCoffee = CoffeeSt()
                let coffeeloc = nowCoffeeDic["location"] as! NSDictionary
                nowCoffee.loc = setLocation(locDic: coffeeloc ,isBook: false)
                nowCoffee.name = "no name"
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
                        let temppic = pic.rotate(radians: -.pi/2)
                        elementPics.append(temppic)
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
                var nowbook = BookSt()
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
                        elementPics.append(pic)
                    }else{
                        elementPics.append(UIImage(named: "test2.png")!)
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
        self.resetAndAddAnchor()
    }
    
    
    public func resetAndAddAnchor(isReset: Bool = false){
        if isReset{
            for i in stride(from: 0, to: books.count ,by: 1){
                books[i].isDisplay = false
            }
            
            for i in stride(from: 0, to: coffees.count ,by: 1){
                coffees[i].isDisplay = false
            }
            
            if let anchorlist = sceneView.session.currentFrame?.anchors {
                for anchor in anchorlist {
                    if let imanchor = anchor as? BookAnchor{
                        sceneView.session.remove(anchor: imanchor)
                    }
                    else if let imanchor = anchor as? CoffeeAnchor{
                        sceneView.session.remove(anchor: imanchor)
                    }
                }
            }
            let childNodes = sceneView.scene.rootNode.childNodes
            for node in childNodes {
                guard let name = node.name else {
                    continue
                }
                if name.hasPrefix("book@") {
                    node.removeFromParentNode()
                }else if name.hasPrefix("coffee@"){
                    node.removeFromParentNode()
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
            picMatrix[nowMatrix].addBookAnchor(view:sceneView, id:i,book:books[i])
        }
        
        for i in stride(from: 0, to: coffees.count ,by: 1){
            if coffees[i].isDisplay{
                continue;
            }
            let nowMatrix = coffees[i].matrixId!-1
            coffees[i].isDisplay = true;
            picMatrix[nowMatrix].addCoffeeAnchor(view:sceneView, id:i,coffee:coffees[i])
        }
    }
    
        
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let bookAnchor = anchor as? BookAnchor{
            let id = bookAnchor.id!;
            let currentBook = books[id]
            let rootLoc = currentBook.loc
            let picContents = elementPics[currentBook.picid]
            let size = CGSize(width: PicMatrix.getActualLen(oriLen:Double(rootLoc.height),isW: true), height: PicMatrix.getActualLen(oriLen:Double(rootLoc.width),isW: false))
            print("bookid: \(id)")
            for str in currentBook.words {
                print(" words: \(str)")
            }
            
            let book = createPlaneNode(size: size, rotation: 0, contents: picContents)
            book.name = "book@\(id)"
            book.transform = SCNMatrix4(anchor.transform)
            books[id].oriTrans = book.transform
            sceneView.scene.rootNode.addChildNode(book)
            print(book.position)
            
            var translation = matrix_identity_float4x4
            translation.columns.3.x = -Float(size.width)
            translation.columns.3.y = -Float(size.height)
            let topPos = anchor.transform*translation
            let top = SCNNode();
            top.transform = SCNMatrix4(topPos)
            books[id].uiPosVec = top.position-book.position
        }else if let coffeeAnchor = anchor as? CoffeeAnchor{
            let id = coffeeAnchor.id!;
            let currentCoffee = coffees[id]
            let rootLoc = currentCoffee.loc
            let picContents = elementPics[currentCoffee.picid]
            let size = CGSize(width: PicMatrix.getActualLen(oriLen:Double(rootLoc.height),isW: true), height: PicMatrix.getActualLen(oriLen:Double(rootLoc.width),isW: false))
            print("coffeeid: \(id)")
            
            let coffee = createPlaneNode(size: size, rotation: 0, contents: picContents)
            coffee.name = "coffee@\(id)"
            coffee.transform = SCNMatrix4(anchor.transform)
            coffees[id].oriTrans = coffee.transform
            sceneView.scene.rootNode.addChildNode(coffee)
            print(coffee.position)
            
            var translation = matrix_identity_float4x4
//            translation.columns.3.x = Float(size.width)
            translation.columns.3.y = Float(size.height/2)
            let topPos = anchor.transform*translation
            let top = SCNNode();
            top.transform = SCNMatrix4(topPos)
            coffees[id].uiPosVec = top.position-coffee.position
            
            
        }else if let headAnchor = anchor as? HeadAnchor{

            let nowtext = headAnchor.text
//            let scale = Float(100.0)
            let text = SCNText(string: nowtext, extrusionDepth: 0.1)
            text.font = UIFont.systemFont(ofSize:10)
            text.alignmentMode = kCAAlignmentLeft
            text.isWrapped = true
            text.containerFrame = CGRect(x: 0, y: 0, width: 100, height: 150)
                
            let min = text.boundingBox.min
            let max = text.boundingBox.max
            let width = max.x - min.x
            let height = max.y - min.y
            let length = max.z - min.z
            
            let displacex = -width/2.0 - min.x
            let displacey = -height/2.0 - min.y
            print("displacex:\(displacex),displacey:\(displacey)")

//            let position = SCNVector3Make(displacex/scale, displacey/scale, (-length/2.0 - min.z)/scale)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.init(red: 0.7, green: 0.2, blue: 0.5, alpha: 1)
            text.materials = [material]
            
            let headNode = SCNNode()
            headNode.name = "group@"
            headNode.scale = SCNVector3(x:10 , y:10, z:10)
            headNode.geometry = text
            headNode.transform = SCNMatrix4(headAnchor.transform)
//            headNode.position = position
            sceneView.scene.rootNode.addChildNode(headNode)
            print("headnode pos: \(headNode.position)")
        }
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
//        var centerPoint = CGPoint()

//        DispatchQueue.main.async{
//            centerPoint = self.sceneView.center
//            isBookHidden = self.bookAbstractUI.isHidden
//            nowShowAbsId = self.bookAbstractUI.bookId
//            isCoffeeHidden = self.coffeeDes.isHidden
//            nowShowCoffeeAbsId = self.coffeeAbstractUI.coffeeId
//        }

        
        if let backnode = sceneView.scene.rootNode.childNode(withName: "trans@1", recursively: false){
            let trans = sceneView.session.currentFrame!.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-10*PicMatrix.itemDis-0.01)
            backnode.transform = SCNMatrix4(trans*translation)

        }

        if(isBookHidden == false){
            guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(nowShowAbsId)", recursively: false) else{
                print("renderer: no such book \(nowShowAbsId)")
                return
            }
            let bookTopPos = childNode.position+books[nowShowAbsId].uiPosVec!
            let pos = sceneView.projectPoint(bookTopPos)
            var pos2d = CGPoint()
            pos2d.x = CGFloat(pos.x-Float(textWidth/2))
            pos2d.y = CGFloat(pos.y-Float(textHeight))
            
            DispatchQueue.main.async{
                self.bookAbstractUI.updatePosition(position: pos2d)
            }
        }
        
        if(coffeeAbstractUI.getIsHidden() == false){
            guard let childNode = sceneView.scene.rootNode.childNode(withName: "coffee@\(coffeeAbstractUI.coffeeId)", recursively: false) else{
                print("renderer: no such coffee \(coffeeAbstractUI.coffeeId)")
                return
            }
            let topPos = childNode.position+coffees[coffeeAbstractUI.coffeeId].uiPosVec!
            let pos = sceneView.projectPoint(topPos)
            var pos2d = CGPoint()
            pos2d.x = CGFloat(pos.x)
            pos2d.y = CGFloat(pos.y-Float(coffeeAbstractUI.imageW/2))
            DispatchQueue.main.async{
                self.coffeeAbstractUI.updatePosition(position: pos2d)
            }
        }
        
        if(isAntUpdate){
            isAntUpdateCot = (isAntUpdateCot+1)%5
            var mindis = 1000.0
            var minid = -1
            for node in sceneView.scene.rootNode.childNodes {
                guard let name = node.name else {
                    continue
                }
                if name.hasPrefix("book@") {
                    let bookid = getIdFromName(name)
                    let pos = sceneView.projectPoint(node.position)
                    let point = CGPoint(x:CGFloat(pos.x),y:CGFloat(pos.y))
                    let dis = calculateScreenDistance(viewCenterPoint,point)
                    if dis<800{
                        let ratio = CGFloat(min(2.5,(dis+25.0)/dis))
                        let scale = SCNAction.scale(to: ratio, duration: 0)
                        node.runAction(scale)
                        mindis = min(mindis,dis)
                        if mindis == dis{
                            if isAntUpdateCot==0
                            {minid = bookid}
                        }
                    }
                    else if shouldBeInPlace{
                        node.transform = books[bookid].oriTrans
                    }
                }
            }
            if minid != -1 && minid != nowShowAbsId{
                let node = sceneView.scene.rootNode.childNode(withName: "book@\(minid)", recursively: false)
                let prevNode = sceneView.scene.rootNode.childNode(withName: "book@\(nowShowAbsId)", recursively: false)
                node?.runAction(SCNAction.moveBy(x: 0, y: 0, z: 0.015, duration: 0))
                prevNode?.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.015, duration: 0))
                showBookAbstract(id: minid)
            }
        }
        
    }
    
    
    
    
}


