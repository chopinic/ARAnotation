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
    var DealBook = [HandleBook]()
    var books = [BookSt]()
    //var bookInfo = [BookInfo]()
    //var bookSCNNode = [SCNNode]()
    var imageH = CGFloat()
    var imageW = CGFloat()
    var timer: Timer?
    var cot: Int! = 0
    var radio: Float = 1
    var bookPics = [UIImage]()
    var focusId = -1
    var bookInfoUI = BookInfo()
    var nowEnhanceNodes = [SCNNode]()
    var textWidth = 300,textHeight = 200;

    
    
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
        bookInfoUI = BookInfo()
        bookInfoUI.isHidden = true
        bookInfoUI.isEditable = false
        bookInfoUI.layer.cornerRadius = 15.0
        bookInfoUI.layer.borderWidth = 2.0
        bookInfoUI.layer.borderColor = UIColor.red.cgColor

        self.sceneView.addSubview(bookInfoUI)


        
        sceneView.bounds.size.width = wholewidth
        sceneView.bounds.size.height = wholeHeight
        sceneView.center = wholeView.center
        
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        createButton( title: "Start", negY: 100, action: #selector(ViewController.buttonTapUpload))
//        ButtonCreate.createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        createButton(title: "debug", negY: 150, action: #selector(ViewController.buttonTapDebug))
        
        createButton(title: "sort", negY: 200, action: #selector(ViewController.buttonSort))
//        ButtonCreate.createButton( title: "resize", negY: 300, action: #selector(ViewController.resize))
        //ButtonCreate.createDirectionButton()
    }    
    
    
    func setLocation(locDic: NSDictionary)->Location{
        var loc = Location()
        loc.height = locDic["width"] as! Int
        loc.width = locDic["height"] as! Int
        loc.top = locDic["left"] as! Int
        loc.left = locDic["top"] as! Int
        return loc;
    }
    
    func setResult(receive: String, isDebug: Bool = false){
        result = Internet.getDictionaryFromJSONString(jsonString: receive)
        print("visit returns")
        if let hasResult = result {
            if let resultbooks = hasResult["words_result"] {
                let bookarray = resultbooks as! NSArray
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
                        bookPics.append(UIImage(data: dataDecoded)!)
                    }
                    let parts = nowtempbook["part"] as! NSArray
                    for wordforlocs in parts {
                        let wordlocs = wordforlocs as! NSDictionary
                        let resloc = wordlocs["location"] as! NSDictionary
                        nowbook.kinds.append(wordlocs["type"] as! String)
                        nowbook.words.append(wordlocs["words"] as! String)
                        nowbook.locations.append(setLocation(locDic: resloc));
                    }
                    nowbook.cros_pic = cot;
                    print(cot)
                    books.append(nowbook);
                }
            }
            self.resetAndAddAnchor()
            cot+=1;
        }
    }
    

    
    public func resetAndAddAnchor(isReset: Bool = false){
        // Drawing code
        if isReset{
            for i in stride(from: 0, to: books.count ,by: 1){
                var singlebook = books[i]
                singlebook.isDisplay = false
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
            var singlebook = books[i]
            if singlebook.isDisplay{
                    continue;
            }
            let nowpic = singlebook.cros_pic
            singlebook.isDisplay = true;
            DealBook[nowpic!].addBookAnchor(view:sceneView, id:i,book:singlebook)
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
        let size = CGSize(width: HandleBook.getActualLen(oriLen:Double(rootLoc.height),isW: true), height: HandleBook.getActualLen(oriLen:Double(rootLoc.width),isW: false))
        print("bookid: \(id)")
        for str in currentBook.words {
            print(" words: \(str)")
        }
        
        let book = createPlaneNode(size: size, rotation: 0, contents: picContents)
        book.name = "book@\(id)"
        book.transform = SCNMatrix4(anchor.transform)
        books[id].bookOriVec = book.position
        sceneView.scene.rootNode.addChildNode(book)
        print(book.position)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.x = -Float(size.width)
        translation.columns.3.y = -Float(size.height)
        let bookTopPos = anchor.transform*translation
        let bookTop = SCNNode();
        bookTop.transform = SCNMatrix4(bookTopPos)
        books[id].bookTopPos = bookTop
        

    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            
        if(focusId == -1){return}
        
        let bookTop = books[focusId].bookTopPos!
        let pos = sceneView.projectPoint(bookTop.position)
        var pos2d = CGPoint()
        pos2d.x = CGFloat(pos.x-Float(textWidth/2))
        pos2d.y = CGFloat(pos.y-Float(textHeight))
        
        DispatchQueue.main.async{
            self.bookInfoUI.undatePosition(position: pos2d)
        }
        
    }
    
    func refreshAnimationVariables(startTime: TimeInterval, initialPosition: float3, finalPosition: float3, initialOrientation: simd_quatf, finalOrientation: simd_quatf) {
        let distance = simd_distance(initialPosition, finalPosition)
        // Average speed of movement is 0.15 m/s.
        let speed = Float(0.15)
        // Total time is calculated as distance/speed. Min time is set to 0.1s and max is set to 2s.
        let animationDuration = Double(min(max(0.1, distance/speed), 2))
        // Store animation information for later usage.
        animationInfo = AnimationInfo(startTime: startTime,
                                      duration: animationDuration,
                                      initialModelPosition: initialPosition,
                                      finalModelPosition: finalPosition,
                                      initialModelOrientation: initialOrientation,
                                      finalModelOrientation: finalOrientation)
    }
    
}


