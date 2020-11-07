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
    private var imageH: CGFloat!
    private var imageW: CGFloat!
    private var timer: Timer?
    private var cot: Int! = 0
    private var radio: Float = 1
    private var bookPics = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wholewidth = wholeView.bounds.size.width
        let wholeHeight = wholeView.bounds.size.height
        inputText.bounds.size.width = wholewidth
        inputText.text = "Showing!"
        sceneView.bounds.size.width = wholewidth
        sceneView.bounds.size.height = wholeHeight
        sceneView.center = wholeView.center
        imageH = CGFloat()
        imageW = CGFloat()
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        createButton(title: "Start", negY: 100, action: #selector(ViewController.buttonTapUpload))
//        createButton(title: "Timer", negY: 200, action: #selector(ViewController.buttonTapTimer))
        createButton(title: "debug", negY: 200, action: #selector(ViewController.buttonTapDebug))
        createButton(title: "resize", negY: 300, action: #selector(ViewController.resize))
//        createDirectionButton()
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
        guard let childNode = sceneView.scene.rootNode.childNode(withName: "book@\(id)", recursively: false) else{
            print("no such node")
            return;
        }
        let appearanceAction = SCNAction.scale(to: CGFloat(2), duration: 0.4)
        appearanceAction.timingMode = .easeOut
        childNode.runAction(appearanceAction)
    }
    
    
    @objc func buttonTapDebug(){
        let nowBookDeal = HandleBook()
        nowBookDeal.saveCurrentTrans(view: sceneView)
        DealBook.append(nowBookDeal)
        let receive = "{\"log_id\":3368777552734162400,\"books_result_num\":2,\"words_result\":[{\"part\":[{\"location\":{\"width\":39,\"top\":66,\"left\":180,\"height\":17},\"words\":\"Free Will\",\"type\":\"name\",\"base64\":\"this part photo base64code\"},{\"location\":{\"width\":39,\"top\":66,\"left\":180,\"height\":17},\"words\":\"Sam Harris\",\"type\":\"author\",\"base64\":\"this part photo base64code\"},{\"location\":{\"width\":39,\"top\":66,\"left\":180,\"height\":17},\"words\":\"Nanjing Normal University\",\"type\":\"publisher\",\"base64\":\"this part photo base64code\"}],\"location\":{\"top\":1695,\"left\":1639,\"width\":185,\"height\":1465},\"base64\":\"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l19++diVqcB8FzC4IAT50ksvJauuuqoVnI4R2267bfL1119b8FTYmo+b3gVDn2u+v/32m21tI0aMSOabbz4LTvv27SMwrqBUWNRkhKkCxX355ZeTFVdc0bYWajbjyk477WSFCih6EdcnzcsPd/0PPfRQsvTSS9sJxFJLLRWBcYXj3qswETi1H2DWXHPNZOaZZ06mm246C0zPnj2Tr776ynZlgMlFfD+t6+deibh0g99++21y2223JUsuuaQFhm4yjjEqpQxXhaotxgoNwcnVvXv35Pvvv0+BcLNQgAgjD/xK6nfD7r///oRpc5q/Ro7uvxJwBacCBpiVVlrJTm11jNl0002TN99807aaX375JZ0k0MJoPTpGcU/LIF/CuHdBIezee+9NFl54YTvGkH9sMf/iEbxDmFzjxo1LttxyS7vWoCtjnLEClJZz6aWXWkH//PPPCYM58d2ujTCmxoRDuAADIFyffPJJct111yXzzjuvXajOPvvsEZggGpMDESCC09qPXxeFAKPgHHfccck777yTAIzGp1UAiLYkFxBthUy1H3/88WSLLbawYxYTCtZHtkWSQPq1SI4EEImKRdYsRgRp/dJSzLBhw4wsKM0HH3xgZHyxqQQws8wyy5iTTjrJdOrUyUjNNyJcI8AZ0kPqSuswsvK3YXfddZc588wzzfzzz2/jkifvtenkJgJjxfTPD+JA0AgW4h6h6sVzADn77LPNk08+aQUpe2NW2DyTKbTZe++9jbSWVMjkQ37SGszVV19trrrqKoLMIossYlZZZRWzzz77GGmV1gU08plGfiIwVkz//CAOK5jJYDiP7C1A8VwBQ+ADBw40sqFpwwFJNiuNbGhav4wt1iWedFVmwQUXNDL7skB369bN9O3b14I2ZswY06dPHyP7cP9UAnlJBMaRvi8OWoof5kS3QqR10N0heFmPmOuvv976iQcggMgF9ejRw+y44442nYbTRT788MMpMLPMMktsMVZazo+CoGOC+nE1zIledks8LgCBAIx7P61MEmwY48nzzz9vW5xskBpZsBpZaEZgyiQbCFBw3Eca5gtc42SF63NNT6uRsxjbynhGunbt2kVgVFCui9B8wRKm3ZH7TO/VdfPRe9K6eXLPYP/ee++ZZ5991lxxxRXmiSeesHGYDDD24InkSUAAKAnBz9pDL9YqXPj9uCUJxeOnVT/r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\"}]}"
//        let receive =                 "{\"words_result_num\":0,\"log_id\":2948028992248156860,\"books\":[{\"loc\":{\"top\":1695,\"left\":1639,\"width\":185,\"height\":1465},\"parts\":[{\"words\":\"算法竞赛入门典\",\"location\":{\"top\":1695,\"left\":1639,\"width\":185,\"height\":1465}},{\"words\":\"刘亮程\",\"location\":{\"top\":2632,\"left\":2368,\"width\":81,\"height\":351}}]}]}"
;
        setResult(receive: receive);
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
                if let book = node as? BookNode {
                    book.removeFromParentNode()
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


