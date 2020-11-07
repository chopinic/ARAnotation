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





class ViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var wholeView: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var inputText: UITextField!
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    private var animationInfo: AnimationInfo?
    private var imageBuffer: UIImage?
    private var result: NSDictionary!
    private var DealBook = [HandleBook]()
    private var books = [BookSt]()
    private var imageH = CGFloat()
    private var imageW = CGFloat()
    private var timer: Timer?
    private var cot: Int! = 0
    private var radio: Float = 1
    private var bookPics = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wholewidth = wholeView.bounds.size.width
        let wholeHeight = wholeView.bounds.size.height
//        inputText.ret
        inputText.addDismissButton()
        inputText.delegate = self
        inputText.bounds.size.width = wholewidth-100
        inputText.center.x = wholeView.center.x
        inputText.text = "Showing!"
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.findString), name: NSNotification.Name.UITextFieldTextDidChange, object:nil)

        
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
        ButtonCreate.createButton(control:self, title: "Start", negY: 100, action: #selector(ViewController.buttonTapUpload))
//        ButtonCreate.createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        ButtonCreate.createButton(control:self, title: "debug", negY: 200, action: #selector(ViewController.buttonTapDebug))
        ButtonCreate.createButton(control:self, title: "resize", negY: 300, action: #selector(ViewController.resize))
//        ButtonCreate.createDirectionButton(control:self)
    }

    
    
    @objc func timerAction(){
        buttonTapUpload()
    }
    
    @objc func buttonTapTimer(){
        if let nowTimer = timer{
            if nowTimer.isValid{
                nowTimer.invalidate()
                return
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    public func findString(lookFor: String){
        print("start find")
        var id = -1 as Int
        for i in stride(from: 0, to: books.count ,by: 1){
            let singlebook = books[i]
            for j in stride(from: 0, to: singlebook.kinds.count ,by: 1){
//                if singlebook.kinds[j] == "author"{
                if singlebook.words[j].contains(lookFor){
                    id = i
                    break;
                }
            }
            if(id != -1){break};
        }
        if(id == -1){
            print("no such book")
            return;
        }
        print("find A book, id: \(id)")
        enhance(id: id)
    }
    
    public func enhance(id: Int){
        guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false) else{
            print("no such node")
            return;
        }
        let appearanceAction = SCNAction.scale(to: CGFloat(2), duration: 0.4)
        appearanceAction.timingMode = .easeOut
        childNode.runAction(appearanceAction)

    }
    
    @objc func resize(){
        var id = -1 as Int
        for i in stride(from: 0, to: books.count ,by: 1){
            let singlebook = books[i]
            for j in stride(from: 0, to: singlebook.kinds.count ,by: 1){
                if singlebook.kinds[j] == "author"{
                    if singlebook.words[j] == "Sam Harris"{
                        id = i
                        break;
                    }
                }
            }
            if(id != -1){break};
        }
        if(id == -1){
            print("no such book")
            return;
        }
        enhance(id: id)
        
    }
    
    
    @objc func buttonTapDebug(){
        let nowBookDeal = HandleBook()
        nowBookDeal.saveCurrentTrans(view: sceneView)
        DealBook.append(nowBookDeal)
        
        setResult(receive: DebugString.jsonString);
        return
    }
    
    @objc func buttonTapaddx(){
        HandleBook.addxOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapdecx(){
        HandleBook.decxOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapaddy(){
        HandleBook.addyOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    @objc func buttonTapdecy(){
        HandleBook.decyOffSet()
        resetAndAddAnchor(isReset: true)
    }
    
    
    @objc func buttonTapUpload(){
        if let capturedImage = sceneView.session.currentFrame?.capturedImage{
            let nowBookDeal = HandleBook()
            nowBookDeal.saveCurrentTrans(view: sceneView)
            DealBook.append(nowBookDeal)
            
            imageW = CGFloat(CVPixelBufferGetWidth(capturedImage))
            imageH = CGFloat(CVPixelBufferGetHeight(capturedImage))
            let cI = CIImage(cvPixelBuffer: capturedImage).oriented(.up)
            let tempUiImage = UIImage(ciImage: cI)

            //            let data = tempUiImage.pngData()
            if let data = UIImageJPEGRepresentation(tempUiImage, 0.3 ){
                let url:NSURL = NSURL(string : "urlHere")!
                //Now use image to create into NSData format
                let imageData = data.base64EncodedString()
                print("Start uploading!")
                Internet.uploadImage(imageData: imageData.data(using: .utf8)!,controller:self);
            }
        }
    }
    
    @objc func buttonTapVisit(){
        let url = URL(string: "http://172.20.10.2:8080/ocrtest")!
        Internet.visit(from: url, controller: self)
    }
    
    func setLocation(locDic: NSDictionary)->Location{
        var loc = Location()
        loc.height = locDic["height"] as! Int
        loc.width = locDic["width"] as! Int
        loc.top = locDic["top"] as! Int
        loc.left = locDic["left"] as! Int
        return loc;
    }
    
    func setResult(receive: String){
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
                    let strBase64 = nowtempbook["base64"] as! String
                    let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    bookPics.append(UIImage(data: dataDecoded)!)
//                    bookPics.append(UIImage(named: "test.png")!)
                    let parts = nowtempbook["part"] as! NSArray
                    for wordforlocs in parts {
                        let wordlocs = wordforlocs as! NSDictionary
                        let resloc = wordlocs["location"] as! NSDictionary
                        nowbook.kinds.append(wordlocs["type"] as! String)
                        nowbook.words.append(wordlocs["words"] as! String)
                        nowbook.locations.append(setLocation(locDic: resloc));
                    }
                    nowbook.cros_pic = cot;
                    books.append(nowbook);
                }
            }
            self.resetAndAddAnchor()
            cot+=1;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        let text = textField.text ?? ""
        if text != ""{
            findString(lookFor:text)
        }
        textField.resignFirstResponder()
        return true
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
        print("bookid: \(id)")
//        let content = UIColor.white
        let currentBook = books[id]
        let rootLoc = currentBook.bookLoc
        let picContents = bookPics[id]
        let size = CGSize(width: HandleBook.getActualLen(oriLen:Double(rootLoc.height),isW: true), height: HandleBook.getActualLen(oriLen:Double(rootLoc.width),isW: false))
        let book = createPlaneNode(size: size, rotation: 0, contents: picContents)
        book.name = "book@\(id)"
        book.transform = SCNMatrix4(anchor.transform)
        sceneView.scene.rootNode.addChildNode(book)
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let imageNode = imageNode, let planeNode = planeNode else {
            return
        }
        
        // 1. Unwrap animationInfo. Calculate animationInfo if it is nil.
        guard let animationInfo = animationInfo else {
            refreshAnimationVariables(startTime: time,
                                      initialPosition: planeNode.simdWorldPosition,
                                      finalPosition: imageNode.simdWorldPosition,
                                      initialOrientation: planeNode.simdWorldOrientation,
                                      finalOrientation: imageNode.simdWorldOrientation)
            return
        }
        
        // 2. Calculate new animationInfo if image position or orientation changed.
        if !simd_equal(animationInfo.finalModelPosition, imageNode.simdWorldPosition) || animationInfo.finalModelOrientation != imageNode.simdWorldOrientation {
            
            refreshAnimationVariables(startTime: time,
                                      initialPosition: planeNode.simdWorldPosition,
                                      finalPosition: imageNode.simdWorldPosition,
                                      initialOrientation: planeNode.simdWorldOrientation,
                                      finalOrientation: imageNode.simdWorldOrientation)
        }
        
        // 3. Calculate interpolation based on passedTime/totalTime ratio.
        let passedTime = time - animationInfo.startTime
        var t = min(Float(passedTime/animationInfo.duration), 1)
        // Applying curve function to time parameter to achieve "ease out" timing
        t = sin(t * .pi * 0.5)
        
        // 4. Calculate and set new model position and orientation.
        let f3t = simd_make_float3(t, t, t)
        planeNode.simdWorldPosition = simd_mix(animationInfo.initialModelPosition, animationInfo.finalModelPosition, f3t)
        planeNode.simdWorldOrientation = simd_slerp(animationInfo.initialModelOrientation, animationInfo.finalModelOrientation, t)
        //planeNode.simdWorldOrientation = imageNode.simdWorldOrientation
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


