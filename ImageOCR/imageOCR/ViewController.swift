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
    //var bookInfo = [BookInfo]()
    //var bookSCNNode = [SCNNode]()
    var bookweights = [BookWeight]()
    var imageH = CGFloat()
    var imageW = CGFloat()
    var timer: Timer?
    var radio: Float = 1
    var bookPics = [UIImage]()
    var bookAbstractUI = UIBookAbstract()
    var nowEnhanceNodes = [SCNNode]()
    var nowGroup = [Int]()
    var textWidth = 300,textHeight = 200
    var isAntUpdate = false
    var isAntUpdateCot = 0
    var shouldBeInPlace = false
    
    
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


        
        sceneView.bounds.size.width = wholewidth
        sceneView.bounds.size.height = wholeHeight
        sceneView.center = wholeView.center
        
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        
        arViewGestureSetup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        createButton( title: "Start",negX: -100, negY: 100, action: #selector(ViewController.buttonTapUpload))
//        ButtonCreate.createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        
        
        createButton(title: "debug", negY: 150, action: #selector(ViewController.buttonTapDebug))
        
        createButton(title: "sort",negX: 100,  negY: 100, action: #selector(ViewController.changeToSortDisplay))
        
        createButton(title: "restore",negX: -100, negY: 150, action: #selector(ViewController.restoreDisplay))
        
        createButton(title: "Ant",negX: 100, negY: 150, action: #selector(ViewController.changeToAntEyeDisplay))

        createDirectionButton()
        
//        createButton(title: "regrouping", negY: 200, action: #selector(ViewController.displayGroups))
        createButton(title: "back",negX: -100,negY: 250, action: #selector(ViewController.buttonTapCreateBigPlane))
    }

    
    func setLocation(locDic: NSDictionary)->Location{
        var loc = Location()
        loc.height = locDic["width"] as! Int
        loc.width = locDic["height"] as! Int
        loc.top = locDic["left"] as! Int
        loc.left = locDic["top"] as! Int
        return loc;
    }
    
    func setResult(cot:Int, receive: String, isDebug: Bool = false){
        result = Internet.getDictionaryFromJSONString(jsonString: receive)
        print("visit returns")
        if let hasResult = result {
            if let resultbooks = hasResult["words_result"] {
                let bookarray = resultbooks as! NSArray
                print("Found \(bookarray.count) books")
                for nowforbook in bookarray{
                    let nowtempbook = nowforbook as! NSDictionary
                    var nowbook = BookSt()
                    let bookloc = nowtempbook["location"] as! NSDictionary
                    nowbook.bookLoc = setLocation(locDic: bookloc)
                    nowbook.title = nowtempbook["title"] as! String
                    nowbook.author = nowtempbook["author"] as! String
                    nowbook.publisher = nowtempbook["publisher"] as! String
                    nowbook.relatedBook = nowtempbook["relatebooks"] as! String
                    nowbook.score = Int((nowtempbook["score"] as! Double)*5)
                    nowbook.remark = nowtempbook["remark"] as! String
                    if(isDebug){
                        bookPics.append(UIImage(named: "test2.png")!)
                    }else{
                        let strBase64 = nowtempbook["base64"] as! String
                        let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                        if let pic = UIImage(data: dataDecoded){
                            bookPics.append(pic)
                        }else{
                            bookPics.append(UIImage(named: "test2.png")!)
                        }
                    }
                    let parts = nowtempbook["part"] as! NSArray
                    for wordforlocs in parts {
                        let wordlocs = wordforlocs as! NSDictionary
//                        let resloc = wordlocs["location"] as! NSDictionary
                        nowbook.kinds.append(wordlocs["type"] as! String)
                        nowbook.words.append(wordlocs["words"] as! String)
//                        nowbook.locations.append(setLocation(locDic: resloc));
                    }
                    nowbook.matrixId = cot;
                    books.append(nowbook);
                    bookweights.append(BookWeight())
                }
            }
            self.resetAndAddAnchor()
        }
    }
    

    
    public func resetAndAddAnchor(isReset: Bool = false){
        if isReset{
            for i in stride(from: 0, to: books.count ,by: 1){
                books[i].isDisplay = false
            }
            if let anchorlist = sceneView.session.currentFrame?.anchors {
                for anchor in anchorlist {
                    if let imanchor = anchor as? BookAnchor{
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
    }
    
        
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let bookAnchor = anchor as? BookAnchor else{
            return
        }
        let id = bookAnchor.id!;
//        let content = UIColor.white
        let currentBook = books[id]
        let rootLoc = currentBook.bookLoc
        let picContents = bookPics[id]
        let size = CGSize(width: PicMatrix.getActualLen(oriLen:Double(rootLoc.height),isW: true), height: PicMatrix.getActualLen(oriLen:Double(rootLoc.width),isW: false))
        print("bookid: \(id)")
        for str in currentBook.words {
            print(" words: \(str)")
        }
        
        let book = createPlaneNode(size: size, rotation: 0, contents: picContents)
        book.name = "book@\(id)"
        book.transform = SCNMatrix4(anchor.transform)
        books[id].bookOriTrans = book.transform
        sceneView.scene.rootNode.addChildNode(book)
        print(book.position)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.x = -Float(size.width)
        translation.columns.3.y = -Float(size.height)
        let bookTopPos = anchor.transform*translation
        let bookTop = SCNNode();
        bookTop.transform = SCNMatrix4(bookTopPos)
        books[id].bookTopVec = bookTop.position-book.position

    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        var centerPoint = CGPoint()
        var isHidden = true
        var nowShowAbsId = -1

        DispatchQueue.main.async{
            centerPoint = self.sceneView.center
            isHidden = self.bookAbstractUI.isHidden
            nowShowAbsId = self.bookAbstractUI.bookId
        }

        
        if let backnode = sceneView.scene.rootNode.childNode(withName: "trans@1", recursively: false){
            let trans = sceneView.session.currentFrame!.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float(-10*PicMatrix.itemDis-0.01)
            backnode.transform = SCNMatrix4(trans*translation)

        }

        if(isHidden == false){
            guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(bookAbstractUI.bookId)", recursively: false) else{
                print("renderer: no such node \(bookAbstractUI.bookId)")
                return
            }
            let bookTopPos = childNode.position+books[bookAbstractUI.bookId].bookTopVec!
            let pos = sceneView.projectPoint(bookTopPos)
            var pos2d = CGPoint()
            pos2d.x = CGFloat(pos.x-Float(textWidth/2))
            pos2d.y = CGFloat(pos.y-Float(textHeight))
            
            DispatchQueue.main.async{
                self.bookAbstractUI.updatePosition(position: pos2d)
            }
        }
        
        if(isAntUpdate){
//            isAntUpdateCot = (isAntUpdateCot+1)%5
            if isAntUpdateCot==0{
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
                        let dis = calculateScreenDistance(centerPoint,point)
                        if dis<1000{
                            let ratio = CGFloat(min(3,(dis+50.0)/dis))
                            let scale = SCNAction.scale(to: ratio, duration: 0)
                            node.runAction(scale)
                            mindis = min(mindis,dis)
                            if mindis == dis{
                                minid = bookid
                            }
                        }
                        else if shouldBeInPlace{
                            node.transform = books[bookid].bookOriTrans
                        }
                    }
                }
                if minid != -1 && minid != nowShowAbsId{
                    let node = sceneView.scene.rootNode.childNode(withName: "book@\(minid)", recursively: false)
                    let prevNode = sceneView.scene.rootNode.childNode(withName: "book@\(nowShowAbsId)", recursively: false)
                    node?.runAction(SCNAction.moveBy(x: 0, y: 0, z: 0.005, duration: 0))
                    prevNode?.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.005, duration: 0))
                    showBookAbstract(id: minid)
                }
            }
        }
        
    }
    
    
    
    
}


