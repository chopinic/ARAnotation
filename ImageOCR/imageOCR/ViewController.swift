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
    private var animationInfo: AnimationInfo?
    private var imageBuffer: UIImage?
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
    var focusId = -1
    var bookAbstractUI = UIBookAbstract()
    var nowEnhanceNodes = [SCNNode]()
    var textWidth = 300,textHeight = 200
    var nowTrans: simd_float4x4?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wholewidth = wholeView.bounds.size.width
        let wholeHeight = wholeView.bounds.size.height
//        inputText.ret
        inputText.addDismissButton()
        inputText.delegate = self
        inputText.bounds.size.width = wholewidth-100
        inputText.center.x = wholeView.center.x
        inputText.text = ""
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.findString), name: NSNotification.Name.UITextFieldTextDidChange, object:nil)
        bookAbstractUI = UIBookAbstract()
        bookAbstractUI.isHidden = true
        bookAbstractUI.isEditable = false
        bookAbstractUI.layer.cornerRadius = 15.0
        bookAbstractUI.layer.borderWidth = 2.0
        bookAbstractUI.layer.borderColor = UIColor.red.cgColor
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
                        let resloc = wordlocs["location"] as! NSDictionary
                        nowbook.kinds.append(wordlocs["type"] as! String)
                        nowbook.words.append(wordlocs["words"] as! String)
                        nowbook.locations.append(setLocation(locDic: resloc));
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
//            print(books[i].isDisplay)
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
        
        if(focusId == -1){return}
        
//        if(bookInfoUI.isHidden==true){return}
        guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(focusId)", recursively: false) else{
            print("renderer: no such node \(focusId)")
            return
        }
        let bookTopPos = childNode.position+books[focusId].bookTopVec!
        let pos = sceneView.projectPoint(bookTopPos)
        var pos2d = CGPoint()
        pos2d.x = CGFloat(pos.x-Float(textWidth/2))
        pos2d.y = CGFloat(pos.y-Float(textHeight))
        
        DispatchQueue.main.async{
            self.bookAbstractUI.undatePosition(position: pos2d)
        }
        
    }
    
    
    
    
}


