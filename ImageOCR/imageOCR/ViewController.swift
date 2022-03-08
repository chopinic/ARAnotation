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


var Ant_Eye_Update_Interval = 50
var Nearby_Anchor_Update_Interval = 500
var Show_Entity_Limit = 150
var Simple_Show_Entity_Filter = 5


class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var wholeView: UIView!
    @IBOutlet var arView: ARView!
    @IBOutlet var inputText: UITextField!
    @IBOutlet var attrSelect: UIPickerView!
    @IBOutlet var message: UITextField!
    var nowSelection: Int = 0
    var bookAttr = [String]()
    var coffAttr = [String]()
    var colorAttr = [String]()
    private var result: NSDictionary!
    var picMatrix = [PicMatrix]()
    var books = [BookSt]()
    var colors = [ColorSt]()
    var coffees = [CoffeeSt]()
    var viewCenterPoint = CGPoint()
    var elementWeights = [ElementWeight]()
    var imageH = CGFloat()
    var imageW = CGFloat()
    var timer: Timer?
    var elementPics = [UIImage]()
    var bookAbstractUI = UIBookAbstract()
//    var nowEnhanceNodes = [SCNNode]()
    var textWidth = 300,textHeight = 250
    var rootnode = AnchorEntity()
    var coffeeAdhoc = true
    var nowGroups = [[Int]]()
    var groupPosCha = [Double]()
    var groupPosChaLimit = [Double]()
    var isInRegroupView = false
    var isRegrouped = false
    var isAntUpdate = false
    var isAntUpdateCot = 0
    var updateShouldShowCot = 0
    var cmpGroup = [Int]()
    
    var mode = 0
    var coffeeAbstractUI = UICoffeeAbstract()
    var colorAbstractUI = UIColorAbstract()
    var coffeeNormalMaterial = UnlitMaterial()
    var coffeeVagueMaterial = UnlitMaterial()
    var isSquare = false
//    var rad = 6000.0
//    var boxrad = 6160.0
    var coffeeOffset : Offset = SmallOffset()
    // ui
    var receiveAnsCot = 0
    var swapGestureStart = CGPoint()
    var uiButton = NSMutableDictionary()
    var uiKeys = [String]()
    var bottonText = [[String]]()
    var prevSearch = ""
    var previousKind = 1
    
    var utiQueue = DispatchQueue(label:"uploadImage", qos: .utility)
    var bookAnchorQueue = DispatchQueue(label:"addBookAnchors", qos: .utility)

    var nowScaleNodes = [Int]()
    var arEntitys = [Entity]()
    var isFiltered = false
    
    var isFirstPic = true  // in mode 1 / 2, only one pic is allowed
    var eyeshadowscheme = ["Brown and Gold Soft","The Simple Day-Look","Soft Smokey","Defined-Crease Smokey","Rose Gold","Deep Blue","The Simple Day-Look","Soft Smokey","Defined-Crease Smokey", "Brown and Gold Soft","Defined-Crease Smokey","Rose Gold","Rose Gold","Deep Blue","The Simple Day-Look"]

    var staticRefCood = matrix_identity_float4x4

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
        inputText.font = UIFont.preferredFont(forTextStyle: .headline)
        inputText.textColor = UIColor.black
        inputText.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        message.font = UIFont.preferredFont(forTextStyle: .headline)
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
        attrSelect.tintColor = UIColor.black
//        attrSelect.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)

        bookAttr = ["Title", "Publisher", "Author", "Rating", "Price"]
        coffAttr = ["Name", "Group","Rating", "Milk", "Caffeine", "Sugar", "Calories", "Protein","Fat"]
        colorAttr = ["Color", "Eyetype", "Scheme"]
        
        bottonText = [
            ["Switch Mode", "Reranking", "Pan to Scale", "Restore",  "Scan","", "Load Books", "Background", "Select Target","Compare Chart","Word Cloud","Hide Buttons","Stored","ClearStored"],
        ["Switch Mode", "Reranking", "Pan to Scale", "Restore", "Scan Menu", "Scan Menu", "", "", "Select Target","Components","Word Cloud","Hide Buttons","",""],
        ["Switch Mode", "", "Pan to Scale", "Restore", "Scan (Circle)", "Scan", "Virtual Preview", "Background","","","","Hide Buttons","",""]]

        uiKeys = ["switch","reranking","fisheye","restore","scan","sscan","model","background","select","chart","compare","hide","store","clearStore"]
        self.arView.addSubview(bookAbstractUI.ui)

        coffeeAbstractUI.setIsHidden(true)
        self.arView.addSubview(coffeeAbstractUI.ui)
        self.arView.addSubview(coffeeAbstractUI.textUI)

        colorAbstractUI.setIsHidden(true)
        self.arView.addSubview(colorAbstractUI.ui)
        self.arView.addSubview(colorAbstractUI.textUI)

        message.textColor = UIColor.black
        message.textAlignment = .center

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
        
        let emptyMenu = UIImage(named: "small_empty.png")!
        let data = emptyMenu.pngData()
        let filename = getDocumentsDirectory().appendingPathComponent("small_empty.jpg")
        try! data!.write(to: filename)
        
        let emptyMenuBig = UIImage(named: "big_empty.png")!
        let dataBig = emptyMenuBig.pngData()
        let filenameBig = getDocumentsDirectory().appendingPathComponent("big_empty.jpg")
        try! dataBig!.write(to: filenameBig)


        let arrarpic = UIImage(named: "arror.png")!
        let dataArrar = arrarpic.pngData()
        let filenamearrar = getDocumentsDirectory().appendingPathComponent("arror.png")
        try! dataArrar!.write(to: filenamearrar)
        
        
        coffeeNormalMaterial.tintColor = UIColor(red: 108.0/255, green: 71.0/255, blue: 45.0/255, alpha: 0.99)
        coffeeVagueMaterial.tintColor = UIColor(red: 130.0/255, green: 90.0/255, blue: 55.0/255, alpha: 0.6)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (mode == 0){
            resetRefImageTracking()
        }else{
            let configuration = ARWorldTrackingConfiguration()
            arView.session.run(configuration)
        }

        uiButton["switch"] = createButton(title: "Switch",negX: -500, negY: 450, action: #selector(ViewController.switchMode))
        uiButton["reranking"] = createButton(title: "Reranking",negX: -500,negY: 380, action: #selector(ViewController.changeToSortDisplay))
        let antButton = createButton(title: "Scale",negX: -500, negY: 310, action: nil)
        antButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        antButton.addTarget(self, action: #selector(ViewController.startAntEyeDisplay), for: .touchDown)
        antButton.addTarget(self, action: #selector(ViewController.stopAntEyeDisplay), for: [.touchUpInside, .touchUpOutside])

        uiButton["fisheye"] = antButton
        uiButton["restore"] = createButton(title: "Restore",negX: -500, negY: 240, action: #selector(ViewController.restoreDisplay))
        uiButton["scan"] = createButton( title: "Scan",negX: -500, negY: 100, action: #selector(ViewController.buttonTapUpload))
        uiButton["sscan"] = createButton( title: "Sscan",negX: -500, negY: 100, action: #selector(ViewController.buttonTapUploadLarge))
        uiButton["model"] = createButton(title: "Model",negX: 450,negY: 450, action: #selector(ViewController.buttonTapLoadModel))
        uiButton["background"] = createButton(title: "BackGround",negX: 450,negY: 370, action: #selector(ViewController.buttonTapCreateBigPlane))
        let selectButton = createButton(title: "Select",negX: 450,negY: 310, action: #selector(ViewController.buttonTapSelect))
        selectButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        uiButton["select"] = selectButton
        uiButton["chart"] = createButton(title: "Chart",negX: 450,  negY: 240, action: #selector(ViewController.buttonTapCmp))
        uiButton["compare"] = createButton(title: "Compare",negX: 450,negY: 170, action: #selector(ViewController.buttonTapPicCmp))
        uiButton["hide"] = createButton(title: "Hide",negX: 450, negY: 100, action: #selector(ViewController.setHiddenAfterSwitch))
        uiButton["store"] = createButton(title: "GetStored",negX: -500, negY: 170, action: #selector(ViewController.buttonTabLoadPrev))
        uiButton["clearStore"] = createButton(title: "ClearStored",negX: -500, negY: 520, action: #selector(ViewController.buttonTabClearPrev))


        setButtonText()
        setHiddenAfterSwitch(true)
        setInitHidden()
        
        let rootNode = AnchorEntity(world: matrix_identity_float4x4)
        rootNode.name = "rootnode@"
        arView.scene.addAnchor(rootNode)
        rootnode = rootNode
        // 修改场景，硬编码
        //switchMode()
        //switchMode()

    }
    
    func setLocation(locDic: NSDictionary)->Location{
        var loc = Location()
        if(mode==1){
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
    
    func setResult(cot:Int, receive: String, isDebug: Bool = false, _ isNew:Bool = true, _ refImgOffset: simd_float4x4 = matrix_identity_float4x4){
        result = Internet.getDictionaryFromJSONString(jsonString: receive)
        receiveAnsCot+=1
        if let hasResult = result {
            if mode == 0{
                setMessage("Set for Books")
                setForBooks(cot:cot, hasResult: hasResult)
                setMessage("Set for Books OK")
                if (isNew || receiveAnsCot == picMatrix.count){
                    if isNew {
                        FileHandler.writeResultToFile(text: receive)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.resetAndAddAnchor()
                    }
                }
            }else if mode == 2{
                setForColor(cot:cot, hasResult: hasResult,isDebug: isDebug)
            }else{setForCoffee(cot:cot, hasResult: hasResult,isDebug: isDebug)}
        }
        if(receiveAnsCot != picMatrix.count){
            setMessage("Recognize \(increaseCot())"+getSubfix())

        }else{
            setMessage("Receive all scan results: \(increaseCot())" + getSubfix()+" recognized.")
        }

    }
    public func setForColor(cot:Int, hasResult: NSDictionary, isDebug: Bool){
        if let colorResult = hasResult["result"] {
            let colorArray = colorResult as! NSArray
            print("Found \(colorArray.count) colors")
            for nowforbook in colorArray{
                let nowTempColor = nowforbook as! NSDictionary
                let nowColor = ColorSt()
                let loc = nowTempColor["location"] as! NSDictionary
                nowColor.loc = setLocation(locDic: loc)
                nowColor.remark = nowTempColor["remark"] as! String
                nowColor.eyetype = nowTempColor["eyetype"] as! String
                nowColor.shadowtype = nowTempColor["shadowtype"] as! String
                print(nowColor.shadowtype)
                nowColor.recommandplace = nowTempColor["recommandplace"] as! String
                nowColor.benifits = nowTempColor["benifits"] as! String
                nowColor.feature = nowTempColor["feature"] as! String
                nowColor.tips = nowTempColor["tips"] as! String
                nowColor.scheme = nowTempColor["match"] as! Int + 1
                let r = nowTempColor["r"] as! Double// NSString).doubleValue
                let g = nowTempColor["g"] as! Double// NSString).doubleValue
                let b = nowTempColor["b"] as! Double// NSString).doubleValue
                nowColor.color = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 0.8)
                var strBase64 = nowTempColor["base64"] as! String
                var dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
//                        let temppic = pic.rotate(radians: .pi/2)
                var filename = getDocumentsDirectory().appendingPathComponent("color@\(colors.count).png")
                try! dataDecoded.write(to: filename)

                strBase64 = nowTempColor["tipsbase64"] as! String
                dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
//                        let temppic = pic.rotate(radians: .pi/2)
//                    filename = getDocumentsDirectory().appendingPathComponent("colorTips@\(colors.count).png")
//                    try! dataDecoded.write(to: filename)
                elementPics.append(UIImage(data: dataDecoded)!)
                
                nowColor.tPicId = elementPics.count-1
                nowColor.matrixId = cot
                colors.append(nowColor)
                elementWeights.append(ElementWeight())
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetAndAddAnchor()
        }


    }
    
    public func setForCoffee(cot:Int, hasResult: NSDictionary, isDebug: Bool){
        if isDebug{
            let menuPic = UIImage(named: "menuDebug.jpg")!.pngData()!
            let oriFilename = getDocumentsDirectory().appendingPathComponent("MenuOri@.png")
            try! menuPic.write(to: oriFilename)
            
//            let emptyMenu = UIImage(named: "menu_nowords.jpg")!.pngData()!
//            let emptyFileName = getDocumentsDirectory().appendingPathComponent("MenuEmpty@.png")
//            try! emptyMenu.write(to: emptyFileName)
        }else{
            let menuPic : Data = Data(base64Encoded: hasResult["menubase64"] as! String, options: .ignoreUnknownCharacters)!
            let oriFilename = getDocumentsDirectory().appendingPathComponent("MenuOri@.png")
            try! menuPic.write(to: oriFilename)
        }
            
        if let resultbooks = hasResult["words_result"] {
            let coffeeArray = resultbooks as! NSArray
            print("Found \(coffeeArray.count) coffees")
            for nowforCoffee in coffeeArray{
                let nowCoffeeDic = nowforCoffee as! NSDictionary
                let nowCoffee = CoffeeSt()
//                let coffeeloc = nowCoffeeDic["location"] as! NSDictionary
//                nowCoffee.loc = setLocation(locDic: coffeeloc)
                nowCoffee.name = nowCoffeeDic["words"] as! String
                nowCoffee.milk = nowCoffeeDic["milk"] as! Double
                nowCoffee.caffeine = nowCoffeeDic["caffine"] as! Double
                nowCoffee.water = nowCoffeeDic["water"] as! Double
                nowCoffee.belong = nowCoffeeDic["belong"] as! String
                nowCoffee.sugar = nowCoffeeDic["sugar"] as! Double
                nowCoffee.calories = nowCoffeeDic["calories"] as! Double
                nowCoffee.fat = nowCoffeeDic["fat"] as! Double
                nowCoffee.protein = nowCoffeeDic["protein"] as! Double
                nowCoffee.score = nowCoffeeDic["score"] as! Double
                nowCoffee.remark = nowCoffeeDic["remark"] as! String
                nowCoffee.order = nowCoffeeDic["order"] as! Int
                nowCoffee.price = nowCoffeeDic["price"] as! Double

                
                if(isDebug){
                    let dataDecoded = UIImage(named: "component.png")!.pngData()!
                    let filename = getDocumentsDirectory().appendingPathComponent("coffeedes@\(coffees.count).png")
                    try! dataDecoded.write(to: filename)
                    nowCoffee.desPicid = elementPics.count
                    elementPics.append(UIImage(named: "component.png")!)
                }else{
                    var strBase64 = nowCoffeeDic["desbase64"] as! String
                    var dataDecoded : Data
                    if Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters) != nil{
                        dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    }else{
                        strBase64 = nowCoffeeDic["previewbase64"] as! String
                        dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    }

                    var filename = getDocumentsDirectory().appendingPathComponent("coffeedes@\(coffees.count).png")
//                    if nowCoffee.belong.contains("coffees")==false{
//                        strBase64 = nowCoffeeDic["previewbase64"] as! String
//                    }
                    try! dataDecoded.write(to: filename)
                    nowCoffee.desPicid = elementPics.count
                    
                    strBase64 = nowCoffeeDic["desbase64percent"] as! String
                    dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    filename = getDocumentsDirectory().appendingPathComponent("coffeedespercent@\(coffees.count).png")
                    try! dataDecoded.write(to: filename)

//                    nowCoffee.desPerPicid = elementPics.count
                    
                    
                    if let pic = UIImage(data: dataDecoded){
                        elementPics.append(pic)
                    }else{
                        elementPics.append(UIImage(named: "component.png")!)
                    }
                    
                    strBase64 = nowCoffeeDic["remarkbase64"] as! String
                    filename = getDocumentsDirectory().appendingPathComponent("coffeeRemark@\(coffees.count).png")
                    dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    try! dataDecoded.write(to: filename)
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
            Thread.sleep(forTimeInterval: 0.5)
            ready = resetCoffeePicTracking()
            print(ready)
        }
    }

    public func setForBooks(cot:Int, hasResult: NSDictionary){
        if let resultbooks = hasResult["words_result"] {
            let bookarray = resultbooks as! NSArray
            print("Found \(bookarray.count) books")
            for nowforbook in bookarray{
                let nowtempbook = nowforbook as! NSDictionary
                let nowbook = BookSt()
                let bookloc = nowtempbook["location"] as! NSDictionary
                nowbook.color = UIColor(red: (nowtempbook["r"] as! CGFloat)/255.0, green: (nowtempbook["g"] as! CGFloat)/255.0, blue: (nowtempbook["b"] as! CGFloat)/255.0, alpha: 1)
                nowbook.loc = setLocation(locDic: bookloc)
                nowbook.title = nowtempbook["titleocr"] as? String ?? ""
                if nowbook.title == ""{
                    nowbook.title = nowtempbook["title"] as! String
                }
                NSLog("book title: \(nowbook.title)")
                nowbook.isbn = nowtempbook["isbn"] as! String
                nowbook.author = nowtempbook["author"] as! String
                nowbook.publisher = nowtempbook["publisher"] as! String
                nowbook.price = (nowtempbook["pages"] as? Double ?? Double(books.count) )/5
                nowbook.score = Double(nowtempbook["average"] as? Int ?? books.count%6)
                if (nowbook.score < 1)
                {
                    nowbook.score = 2.0
                }
                nowbook.remark = nowtempbook["summary"] as! String
                let strBase64 = nowtempbook["base64"] as! String
                let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                if let pic = UIImage(data: dataDecoded){
                    let temppic = pic.rotate(radians: .pi/2)
                    let data = temppic.pngData()
                    let filename = getDocumentsDirectory().appendingPathComponent("book@\(books.count).png")
                    try! data!.write(to: filename)
                }
                nowbook.picid = elementPics.count-1
                nowbook.words.append("wors");
                nowbook.matrixId = cot;
                books.append(nowbook);
                elementWeights.append(ElementWeight())
            }
        }
        setMessage("Recognize \(increaseCot())" + getSubfix())
    }
    
    // 虚报图书数量
    public func increaseCot() -> Int{
        let cot = books.count
        if mode == 1{
            return coffees.count
        }else if mode == 2{
            return colors.count
        }
        let c = Double(cot)*2.33 + Double(cot%10)
        return Int(c)
    }

    public func removeHeadAnchor(){
        while(true){
            guard let headNode = arView.scene.findEntity(named: "head@")else{break}
            headNode.removeFromParent()
        }
    }
    
    public func resetRefImageTracking() -> Bool{
        if(mode == 0) {
            let refImg = UIImage(named: "refImg.jpeg")!
            let refImgCIImage = CIImage(image: refImg)!
            let refImgCgImage = convertCIImageToCGImage(inputImage: refImgCIImage)!
            let arImage = ARReferenceImage(refImgCgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(0.1))
            arImage.name = "ref_img"
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = [arImage]
            arView.session.run(configuration)
            return true;
        }
        return false
    }
    
    public func resetCoffeePicTracking() -> Bool{
        if(mode == 1) {

            let oriMenuBig = UIImage(named: "bigPic.jpeg")!.cgImage!
    //        let oriMenuCIImageBig = CIImage(image: oriMenuBig)!
    //        let oriMenuCgImageBig = convertCIImageToCGImage(inputImage: oriMenuCIImageBig)!
            let arImageBig = ARReferenceImage(oriMenuBig, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(1.2))
            arImageBig.name = "big"
            
            let oriMenu = UIImage(named: "small.jpg")!
            let oriMenuCIImage = CIImage(image: oriMenu)!
            let oriMenuCgImage = convertCIImageToCGImage(inputImage: oriMenuCIImage)!
            let arImage = ARReferenceImage(oriMenuCgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(0.5))
            arImage.name = "small"

            
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = [arImage,arImageBig]
            arView.session.run(configuration)
            return true
        }
        return false;
    }
    
    public func resetAndAddAnchor(isReset: Bool = false) -> Bool{
        if isReset{
            arEntitys = [Entity]()
            for i in stride(from: 0, to: books.count ,by: 1){
                books[i].isDisplay = false
            }
            
            for i in stride(from: 0, to: coffees.count ,by: 1){
                coffees[i].isDisplay = false
                print("reset for \(i)")
            }
            
            for i in stride(from: 0, to: colors.count ,by: 1){
                colors[i].isDisplay = false
            }

            if let menu = arView.scene.findEntity(named: "menu@"){
                for node in menu.children{
                    if node.name == "small" || node.name == "large"  {
                        continue
                    }
                    node.removeFromParent()
                }
            }
            
            else{
                let childNodes = getEntityList()
                for node in childNodes {
                    let name = node.name
                    if name.hasPrefix("book@") {
                        arView.scene.removeAnchor(node as! HasAnchoring)
                    }else if name.hasPrefix("color@"){
                        node.removeFromParent()
                    }else{
                        continue;
                    }
                }
            }
            arEntitys = [Entity]()
        }
        
        
        if mode == 0{
//            bookAnchorQueue.async{
            self.updateShouldShowEntities()
//            }
//            setMessage("Showing filtered" + getSubfix() + " after fuzzy search.")
        }else if mode==1{
            guard let menu = arView.scene.findEntity(named: "menu@") else{
                return false
            }
            if menu.findEntity(named: "small") != nil{
                print("find small")
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
    //            let coffee = createCoffeeFont(id: i,coffeeName:coffees[i].name, size: size)
                let coffee = ModelEntity()
                let lineHeight: CGFloat = 0.05
                let font = MeshResource.Font.systemFont(ofSize: lineHeight)
                let textMesh = MeshResource.generateText(coffees[i].name, extrusionDepth: Float(lineHeight * 0.1), font: font)
                let bound = textMesh.bounds
                var textMaterial = UnlitMaterial()
                textMaterial.tintColor = UIColor(red: 108.0/255, green: 71.0/255, blue: 45.0/255, alpha: 0.99)
                let coffeeFont = ModelEntity(mesh: textMesh, materials: [textMaterial])
                coffeeFont.name = "font"
                var radius = Float(0.15)
                if menu.findEntity(named: "big") != nil{
                    radius = Float(0.7)
                }
                coffees[i].size.width = CGFloat(bound.boundingRadius*radius)
                coffeeFont.position = SIMD3<Float>(x: Float(-1*coffees[i].size.width/2), y: 0, z: 0)
                
                coffee.transform = Transform(matrix: trans)
                coffee.name = "coffee@\(i)"
                coffee.addChild(coffeeFont)
                coffeeFont.scale = SIMD3<Float>(x: radius, y: radius, z: radius)
                coffee.generateCollisionShapes(recursive: true)
                menu.addChild(coffee)
                arEntitys.append(coffee)
            }
            if isReset{displayGroups(previousKind, prevSearch, false)}
            else{displayGroups()}

            for i in stride(from: 0, to: coffeeOffset.blockStartx.count, by: 1){
                let size = CGSize(width: coffeeOffset.blockWidth[i]/coffeeOffset.boxrad, height: coffeeOffset.blockHeight[i]/coffeeOffset.boxrad)
                var material = UnlitMaterial()
                
                material.tintColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.0)
                let plane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(size.width), height: Float(size.height)), materials: [material])
                plane.name =  "group@\(i)"
                plane.position = SIMD3<Float>(x: Float(coffeeOffset.blockStartx[i]/coffeeOffset.boxrad+(coffeeOffset.blockWidth[i]/coffeeOffset.boxrad)/2), y: Float(coffeeOffset.blockStarty[i]/coffeeOffset.boxrad-(coffeeOffset.blockHeight[i]/coffeeOffset.boxrad)/2), z: -0.005)
                plane.generateCollisionShapes(recursive: true)
                menu.addChild(plane)
            }
        } else if mode == 2 {
            for i in stride(from: 0, to: colors.count ,by: 1){
                if colors[i].isDisplay{
                    continue;
                }
                let nowMatrix = colors[i].matrixId!-1
                colors[i].isDisplay = true;
                let trans = picMatrix[nowMatrix].getBookTrans(id:i,element:colors[i])
                colors[i].oriTrans = trans
                colors[i].tempTrans = trans
                let currentColor = colors[i]
                let rootLoc = currentColor.loc
    //            let picContents = elementPics[currentBook.picid]
                let size = CGSize(width: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.width),isW: true), height: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.height),isW: false))
                colors[i].size = size
                let color = AnchorEntity(world: trans)
                guard let plane = createPlane(id: i, size: size, mode: mode, isSquare) else{
                    return false
                }
                color.addChild(plane)
                color.name = "color@\(i)"
                color.generateCollisionShapes(recursive: true)

                arView.scene.addAnchor(color)
                arEntitys.append(color)
            }
        }
        checkIfHidden()
        return true
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
        guard let imageAnchor = anchors.first as? ARImageAnchor else{
            return
        }
        print(imageAnchor.referenceImage.name)
        if (imageAnchor.referenceImage.name == "ref_img"){
            staticRefCood = imageAnchor.transform
            NSLog("find refrence image")
            return
        }
        var nowW = 0.5
        var nowH = 0.35

        var resource = try? TextureResource.load(contentsOf: getDocumentsDirectory().appendingPathComponent("small_empty.jpg"))
        if imageAnchor.referenceImage.name == "big"{
            resource = try? TextureResource.load(contentsOf: getDocumentsDirectory().appendingPathComponent("big_empty.jpg"))
            nowW = 1.35
            nowH = 2
            coffeeOffset = BigOffset()
        }
        print("menu width: \(nowW), height:\(nowH)")
        let rotationTrans = imageAnchor.transform*makeRotationMatrix(x: -.pi/2, y: 0, z: 0)
        let trans = getForwardTrans(ori: rotationTrans, dis: 0.1) //开始时设置悬浮在上方10cm， update时向下移动到原位，造成动画效果
        let anchor = AnchorEntity(world:trans)
        picMatrix[0].prevTrans = trans
        var material = UnlitMaterial()
        material.baseColor = MaterialColorParameter.texture(resource!)
        material.tintColor = UIColor.white.withAlphaComponent(0.99)
        let imagePlane = ModelEntity(mesh: MeshResource.generatePlane(width: Float(nowW), height: Float(nowH)), materials: [material])
        anchor.addChild(imagePlane)
        anchor.name = "menu@"
        let identify = AnchorEntity()
        identify.name = imageAnchor.referenceImage.name!
        anchor.addChild(identify)
        arView.scene.anchors.append(anchor)
        resetAndAddAnchor()
    }
    
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        for anchor in anchors{
            if let imgAnchor = anchor as? ARImageAnchor{
                if (imgAnchor.referenceImage.name == "ref_img"){
                    staticRefCood = anchor.transform
                    continue;
                }

                if let childNode = arView.scene.findEntity(named: "menu@"){
                    let rotationTrans = imgAnchor.transform*makeRotationMatrix(x: -.pi/2, y: 0, z: 0)
                    childNode.move(to: rotationTrans, relativeTo: rootnode, duration: 0.4)
                }
            }
        }
    }

//    func scaleNode(_ name: String,_ radio: Float){
//
//    }
    
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
            if childNode.position.z >= 0{
                if let pos = arView.project(coffees[coffeeAbstractUI.id].uiPos(childNode.transformMatrix(relativeTo: rootnode))){
                    var pos2d = CGPoint()
                    pos2d.x = pos.x+125 // +CGFloat(coffeeAbstractUI.imageW/2)
                    pos2d.y = pos.y // -CGFloat(coffeeAbstractUI.imageW/2)
                    coffeeAbstractUI.updatePosition(position: pos2d)
                }
            }
        }
        
        if(colorAbstractUI.getIsHidden() == false){
            guard let childNode = arView.scene.findEntity(named:  "color@\(colorAbstractUI.id)") else{
                print("renderer: no such color \(colorAbstractUI.id)")
                return
            }
                if let pos = arView.project(colors[colorAbstractUI.id].uiPos(childNode.transformMatrix(relativeTo: rootnode))){
                    var pos2d = CGPoint()
                    pos2d.x = pos.x // +CGFloat(coffeeAbstractUI.imageW/2)
                    pos2d.y = pos.y // -CGFloat(coffeeAbstractUI.imageW/2)
                    colorAbstractUI.updatePosition(position: pos2d)
                }
        }


        if(isAntUpdate){
            viewCenterPoint = arView.center
            isAntUpdateCot = (isAntUpdateCot+1)%1000
            var mindis = 100000.0
            var minid = -1
            if mode==1{
                for i in stride(from: 0, to: coffees.count, by: 1) {
                    let trans = arEntitys[i].transformMatrix(relativeTo: rootnode)
                    guard let pos = arView.project(calcuPointPos(trans: trans)) else{continue}
                    let point = CGPoint(x:pos.x,y:pos.y)
                    var screenCenter = arView.center
                    screenCenter.x-=150
                    let dis = calculateScreenDistance(screenCenter,point)
                    if dis<400{
                        let ratio = Float(min(2.3,(dis+28.0)/dis))
                        let node = arView.scene.findEntity(named: "coffee@\(i)")!
                        node.setScale(SIMD3<Float>(x:ratio,y:ratio,z:ratio), relativeTo: rootnode)
                        mindis = min(mindis,dis)
                        if mindis == dis{
                            minid = i
                        }
                    }
                }
            } else if mode == 2 {
                for i in stride(from: 0, to: colors.count, by: 1) {
                    let trans = arEntitys[i].transformMatrix(relativeTo: rootnode)
                    guard let pos = arView.project(calcuPointPos(trans: trans)) else{continue}
                    let point = CGPoint(x:pos.x,y:pos.y)
                    var screenCenter = arView.center
                    screenCenter.x-=150
                    let dis = calculateScreenDistance(screenCenter,point)
                    if dis<400{
                        let ratio = Float(min(1.5,(dis+28.0)/(10+dis)))
                        let node = arEntitys[i]
                        node.setScale(SIMD3<Float>(x:ratio,y:ratio,z:ratio), relativeTo: rootnode)
                        mindis = min(mindis,dis)
                        if mindis == dis{
                            minid = i
                        }
                    }
                }

            }else{
                if isAntUpdateCot > Ant_Eye_Update_Interval{
                    isAntUpdateCot = 0
                    updateAntEyeEffectNodes()
                }
                for i in stride(from: 0, to: nowScaleNodes.count, by: 1) {
                    let trans = books[nowScaleNodes[i]].tempTrans
                    guard let pos = arView.project(calcuPointPos(trans: trans)) else{continue}
                    let point = CGPoint(x:pos.x,y:pos.y-200)
                    let screenCenter = arView.center
                    let dis = calculateScreenDistance(screenCenter,point)
                    let ratio = Float(min(2,(dis+28.0)/dis))
//                    print("now ratio:\(ratio), nowdis:\(dis)")
                    
                    let node = arEntitys[nowScaleNodes[i]]
                    node.setScale(SIMD3<Float>(x:ratio,y:ratio,z:ratio), relativeTo: rootnode)
                    mindis = min(mindis,dis)
                    if mindis == dis{
                        minid = nowScaleNodes[i]
                    }
                }
            }
            var prevId = bookAbstractUI.id
            if mode == 2 {prevId = colorAbstractUI.id}
            else if mode==1 {prevId = coffeeAbstractUI.id}
            if minid != -1 && minid != prevId{
                if mode==2{
                    var translation = matrix_identity_float4x4
                    if prevId != -1
                    {
                        translation.columns.3.z = Float(0.0005*Float(prevId%13))
                        arEntitys[prevId].setTransformMatrix(colors[prevId].tempTrans, relativeTo: rootnode)
                    }
                    translation.columns.3.z = Float(0.01)
                    arEntitys[minid].setTransformMatrix(colors[minid].tempTrans*translation, relativeTo: rootnode)
                }
                showAbstract(id: minid)
            }
        }
        if(true){
            updateShouldShowCot += 1;
            if updateShouldShowCot > Nearby_Anchor_Update_Interval {
                updateShouldShowCot = 0
                updateShouldShowEntities()
            }
        }
        if let backnode = arView.scene.findEntity(named: "trans@1"){
            let nowTrans = arView.session.currentFrame!.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-10)
            backnode.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
        }
        if let backnode = arView.scene.findEntity(named: "cmp@1"){
            let nowTrans = arView.session.currentFrame!.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-0.25)
            translation.columns.3.y = Float(-0.02)
            backnode.setTransformMatrix(nowTrans*translation, relativeTo: rootnode)
        }
    }
    
    // only for books
    func updateAntEyeEffectNodes(){
        if (mode != 0){return}
        nowScaleNodes = [Int]()
        for i in stride(from: 0, to: arEntitys.count, by: 1) {
            if arEntitys[i].name == "book@-1"{
                continue
            }
            let trans = arEntitys[i].transformMatrix(relativeTo: rootnode)
            guard let pos = arView.project(calcuPointPos(trans: trans)) else{continue}
            let point = CGPoint(x:pos.x,y:pos.y-200)
            let screenCenter = arView.center
            let dis = calculateScreenDistance(screenCenter,point)
//            print("book\(i): \(dis)")
            if dis<250 {
                nowScaleNodes.append(i)
            }
        }
    }

    
    struct BookDisCmp: Comparable{
        var id = 0;
        var dis = Float(0.0)
        init(){}
        init(_ _id:Int ,_ _dis:Float){id = _id; dis = _dis}
        static func < (lhs: ViewController.BookDisCmp, rhs: ViewController.BookDisCmp) -> Bool {
            return lhs.dis < rhs.dis
        }
        static func == (lhs: ViewController.BookDisCmp, rhs: ViewController.BookDisCmp) -> Bool {
            return lhs.id == rhs.id
        }
    }
    public var bookDisArray = [BookDisCmp]()

    // only for books
    func updateShouldShowEntities(){
        if (mode != 0){return}
        var book: AnchorEntity
        updateNearbyEntities()
//        NSLog("update book should show, all \(bookDisArray.count) books cmp")
        for i in stride(from: 0, to: books.count ,by: 1){
            if books[i].isDisplay{
                if arEntitys.count>i {
                    let entityId = getIdFromName(arEntitys[i].name)
                    if entityId == i{
                        // already displaying
                        continue;
                    }else{
                        // replace the empty anchor with real one
                        book = createBookAnchor(i)!
                        arView.scene.addAnchor(book)
                        arEntitys[i] = book
                    }
                }else{
                    // add book anchor the first time
                    book = createBookAnchor(i)!
                    arView.scene.addAnchor(book)
                    arEntitys.append(book)
                }
            } else {
                // don't display this book, too far
                if arEntitys.count>i {
                    let entityId = getIdFromName(arEntitys[i].name)
                    if entityId == i{
                        // already displaying, replace it with empty one
                        arView.scene.removeAnchor(arEntitys[i] as! HasAnchoring)
                        let a = AnchorEntity()
                        a.name = "book@-1"
                        arEntitys[i] = a
                        continue;
                    }
                    else{
                        // already has empty one
                        continue;
                    }
                }else{
                    // add empty anchor the first time
                    let a = AnchorEntity()
                    a.name = "book@-1"
                    arEntitys.append(a)
                    continue
                }
            }
        }
    }

    func createBookAnchor(_ i:Int) -> AnchorEntity?{
        let nowMatrix = books[i].matrixId!-1
        books[i].isDisplay = true;
        var trans = picMatrix[nowMatrix].getBookTrans(id:i,element:books[i])
        trans = picMatrix[nowMatrix].refImgOffset * trans
        
        trans = getForwardTrans(ori: trans, dis: 0.01 * Float(i%2)) // avoid collide
        books[i].oriTrans = trans
        books[i].tempTrans = trans
        let currentBook = books[i]
        let rootLoc = currentBook.loc
        var size = CGSize(width: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.width),isW: true), height: picMatrix[nowMatrix].getActualLen(oriLen:Double(rootLoc.height),isW: false))
        books[i].size = size
        print("bookid: \(i),size \(size)")
        let book = AnchorEntity(world: trans)
        size.width *= 0.9 // avoid collide
        guard let plane = createPlane(id: i, size: size, mode: mode) else{
            NSLog("fail to create plane")
            return nil
        }
        book.addChild(plane)
        
        let bookBox = loadBookModel(books[i].color,size)
        book.addChild(bookBox)
        book.name = "book@\(i)"
        book.generateCollisionShapes(recursive: true)
        return book
    }
    
    // only for books
    func updateNearbyEntities(){
        if (mode != 0){return}
        
        // 过滤显示图书
        for i in stride(from: 0, to: books.count ,by: 1){
            if i%Simple_Show_Entity_Filter == 0 {
                books[i].isDisplay = true;
            }else {
                books[i].isDisplay = false;
            }
            if books[i].title == "Operations Management:Concepts,Methods,and Strategies"
            {
                books[i].isDisplay = true;
                NSLog("found \(books[i].title)")
            }
            if books[i].title == "ACCOUNTING PRINCIPLES"
            {
                books[i].isDisplay = true;
                NSLog("found \(books[i].title)")
            }

        }
        return
        bookDisArray = [BookDisCmp]()
        for i in stride(from: 0, to: books.count ,by: 1){
            let dis = calcuPointDis(trans1: books[i].oriTrans, trans2: (arView.session.currentFrame?.camera.transform)!)
            bookDisArray.append(BookDisCmp(i,dis))
        }
        bookDisArray.sort()
        for i in stride(from: 0, to: bookDisArray.count ,by: 1){
            var nowBookCmp = bookDisArray[i]
            // find most nearby entity to show
            if i >= Show_Entity_Limit {
                books[nowBookCmp.id].isDisplay = false;
            }else{
                // lable to be shown
                books[nowBookCmp.id].isDisplay = true;
            }
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        result = nil
    }
  
}
