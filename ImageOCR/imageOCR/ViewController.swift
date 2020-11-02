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





class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    private var animationInfo: AnimationInfo?
    private var imageBuffer: UIImage?
    private var result: NSDictionary!
//    private var locations: NSMutableArray!
    private var DealBook = [HandleBook]()
    private var books = [Book]()
    private var imageH: CGFloat!
    private var imageW: CGFloat!
    private var timer: Timer?
    private var cot: Int! = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        locations = NSMutableArray()
        imageH = CGFloat()
        imageW = CGFloat()
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        
        createButton(title: "Start", negY: 100, action: #selector(ViewController.buttonTapUpload))
//        createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        createButton(title: "debug", negY: 400, action: #selector(ViewController.buttonTapDebug))
        
        createDirectionButton()
    }
    
    func createButton(title : String, negY : CGFloat, action: Selector){
        let button = UIButton(frame: CGRect(x: self.sceneView.bounds.size.width/2-50, y: self.sceneView.bounds.size.height-negY, width: 100, height: 50))
        button.backgroundColor = UIColor.gray
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        sceneView.addSubview(button)
    }
    
    func createDirectionButton(){
        let buttonL = UIButton(frame: CGRect(x: self.sceneView.bounds.size.width/2-50, y: self.sceneView.bounds.size.height-250, width: 25, height: 25))
        buttonL.backgroundColor = UIColor.gray
        buttonL.setTitle("L", for: .normal)
        buttonL.addTarget(self, action: #selector(ViewController.buttonTapdecx), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonL)
        
        let buttonR = UIButton(frame: CGRect(x: self.sceneView.bounds.size.width/2+25, y: self.sceneView.bounds.size.height-250, width: 25, height: 25))
        buttonR.backgroundColor = UIColor.gray
        buttonR.setTitle("R", for: .normal)
        buttonR.addTarget(self, action: #selector(ViewController.buttonTapaddx), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonR)
        
        let buttonU = UIButton(frame: CGRect(x: self.sceneView.bounds.size.width/2-12.5, y: self.sceneView.bounds.size.height-300, width: 25, height: 25))
        buttonU.backgroundColor = UIColor.gray
        buttonU.setTitle("U", for: .normal)
        buttonU.addTarget(self, action: #selector(ViewController.buttonTapdecy), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonU)
        
        let buttonD = UIButton(frame: CGRect(x: self.sceneView.bounds.size.width/2-12.5, y: self.sceneView.bounds.size.height-200, width: 25, height: 25))
        buttonD.backgroundColor = UIColor.gray
        buttonD.setTitle("D", for: .normal)
        buttonD.addTarget(self, action: #selector(ViewController.buttonTapaddy), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(buttonD)
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
    
    @objc func buttonTapDebug(){
        let radus = HandleBook.getActualLen(oriLen: 1, isW: true)
        let radush = HandleBook.getActualLen(oriLen: 1, isW: false)

        print("radus: \(radus) radush: \(radush) ")
//        let tempBook = HandleBook()
//        tempBook.debug(view: sceneView)
        return
    }
    
    
    @objc func buttonTapaddx(){
        HandleBook.addxOffSet()
        generateRect(isReset: true)
    }
    
    @objc func buttonTapdecx(){
        HandleBook.decxOffSet()
        generateRect(isReset: true)
    }
    
    @objc func buttonTapaddy(){
        HandleBook.addyOffSet()
        generateRect(isReset: true)
    }
    
    @objc func buttonTapdecy(){
        HandleBook.decyOffSet()
        generateRect(isReset: true)
    }
    
    
    @objc func buttonTapUpload(){
        if let capturedImage = sceneView.session.currentFrame?.capturedImage{
            let nowBookDeal = HandleBook()
            nowBookDeal.saveCurrentTrans(view: sceneView)
            DealBook.append(nowBookDeal)

            imageW = CGFloat(CVPixelBufferGetWidth(capturedImage))
            imageH = CGFloat(CVPixelBufferGetHeight(capturedImage))
            let cI = CIImage(cvPixelBuffer: capturedImage).oriented(.right)
            let tempUiImage = UIImage(ciImage: cI)
            //            let data = tempUiImage.pngData()
            if let data = UIImageJPEGRepresentation(tempUiImage, 0.3 ){
                print("Start uploading!")
                Internet.uploadImage(imageData: data,controller:self);
            }
        }
    }
    
    @objc func buttonTapVisit(){
        let url = URL(string: "http://172.20.10.2:8080/ocrtest")!
        Internet.visit(from: url, controller: self)
    }
    
    func setResult(receive: String){
        result = Internet.getDictionaryFromJSONString(jsonString: receive)
        print("visit returns")
        if let hasResult = result {
            if let resultbooks = hasResult["words_result"] {
                let bookarray = resultbooks as! NSArray
                for nowforbook in bookarray{
                    let nowtempbook = nowforbook as! NSArray
                    var nowbook = Book()
                    for wordforlocs in nowtempbook {
                        let wordlocs = wordforlocs as! NSDictionary
                        let resloc = wordlocs["location"] as! NSMutableDictionary
                        var loc = Location()
                        loc.height = resloc["height"] as! Int
                        loc.width = resloc["width"] as! Int
                        loc.top = resloc["top"] as! Int
                        loc.left = resloc["left"] as! Int
                        nowbook.words.append(wordlocs["words"] as! String)
                        nowbook.locations.append(loc);
                    }
                    nowbook.cros_pic = cot;
                    books.append(nowbook);
                }
            }
            self.generateRect()
        }
        cot+=1;
    }
    
    public func generateRect(isReset: Bool = false){
        // Drawing code
        if isReset{
            for i in stride(from: 0, to: books.count ,by: 1){
                var singlebook = books[i] as! Book
                singlebook.isDisplay = false
            }
            

            if let anchorlist = sceneView.session.currentFrame?.anchors {
                for anchor in anchorlist {
                    if let imanchor = anchor as? BookAnchor{
                        sceneView.session.remove(anchor: imanchor)
                    }
                }
            }
            while(true){
                if let book = sceneView.scene.rootNode.childNode(withName: "book",recursively: 1==1){
                    book.removeFromParentNode()
                }else{
                    break
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let bookAnchor = anchor as? BookAnchor else{
            return
        }
        let id = bookAnchor.id;
        let content = UIColor.white
        let rootLoc = bookAnchor.rootLoc!
        let size = CGSize(width: HandleBook.getActualLen(oriLen:Double(rootLoc.height),isW: true), height: HandleBook.getActualLen(oriLen:Double(rootLoc.width),isW: false))
        let book = createPlaneNode(size: size, rotation: 0, contents: content)
        book.name = "book"
        book.transform = SCNMatrix4(anchor.transform)

        let currentBook = books[id!]
        for i in stride(from: 0, to: currentBook.words.count ,by: 1){
            let nowtext = currentBook.words[i]
            let scale = Float(100.0)
            let text = SCNText(string: nowtext, extrusionDepth: 0.1)
            let currentLoc = currentBook.locations[i]
            text.font = UIFont.systemFont(ofSize:1)
            text.alignmentMode = kCAAlignmentLeft
            text.isWrapped = true
            text.containerFrame = CGRect(x: 0, y: 0, width: HandleBook.getActualLen(oriLen:Double(currentLoc.height),isW: true)*Double(scale*1.5), height: HandleBook.getActualLen(oriLen: Double(currentLoc.width), isW: false)*Double(scale)*1.5)
            
            let min = text.boundingBox.min
            let max = text.boundingBox.max
            let width = max.x - min.x
            let height = max.y - min.y
            let length = max.z - min.z
//            if(width == 0){
//                print("restrict w: \(Double(currentLoc.width)*Double(scale)*1.5)")
//            }
            var displacex = Float(HandleBook.getActualLen(oriLen: Double(currentLoc.top-rootLoc.top), isW: true))*scale
            var displacey = Float(HandleBook.getActualLen(oriLen: Double(currentLoc.left-rootLoc.left), isW: false))*scale
            if(i==0){displacex = 0;}
            else{displacex = Float(i)*0.05*scale;}
            
            print("displacex:\(displacex),displacey:\(displacey)")
//            displacex = 0
            displacex = displacex-width/2.0 - min.x
            displacey = displacey-height/2.0 - min.y
            let position = SCNVector3Make(displacex/scale, displacey/scale, (-length/2.0 - min.z)/scale)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.init(red: 0.7, green: 0.2, blue: 0.5, alpha: 1)
            text.materials = [material]
            
            let testNode = SCNNode()
            testNode.scale = SCNVector3(x:1/scale, y:1/scale, z:1/scale)
            testNode.geometry = text
            testNode.position = position
    //        testNode.eulerAngles.z = .pi/2
            
    //        let content = UIImage(named: "test.png")
            book.addChildNode(testNode)
        }
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


