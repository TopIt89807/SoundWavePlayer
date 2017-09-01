//
//  WaveFormView.swift
//
//  Created by SSd on 10/26/16.
//

import UIKit

protocol WaveFormMoveProtocol {
    func touchesBegan(position : Int)
    func touchesMoved(position : Int)
    func touchesEnded(position : Int)
    func showPopup(index : Int)
}

class WaveFormView: UIView {

    
    private var caShap : CAShapeLayer
    private var caShapShadow : CAShapeLayer
    private var caShapBefore : CAShapeLayer
    private var caShapMaskTime : CAShapeLayer
    private var caShapUnSelect : CAShapeLayer
    private var caShapBeforeShadow : CAShapeLayer
    private var caShapBookmark : CAShapeLayer
    private var caText : CALayer
    private var urlLocal = URL(fileURLWithPath: "")
    private  var mSoundFile = CheapMp3()
    var mSampleRate: Int = 0
    var mSamplesPerFrame: Int = 0
    var minGain : Float = 0
    var range: Float = 0
    var  mNumZoomLevels : Int = 0
    var  mLenByZoomLevel : [Float]
    var  mZoomFactorByZoomLevel: [Float]
    var  mBookmarks : [Int] = []
    var scaleFactor : Float = 1
    var mFrame : CGRect?
    var mZoomLevel : Int = 0
    var mInitialized : Bool = false
    var  mSelectionStart : Int = 0
    var mSelectionEnd : Int = 0
    var mOffset : Int = 0
    var mTouchStart : Int = 0
    var mTouchInitialOffset : Int = 0
    var mPlaybackPos : Int = -1
    
    var startTest : Int = 0
    var endTest : Int = 0
    let buttonWidth : Int = 100
    var strokeColor:UIColor = UIColor.white
    var fillColor : UIColor = UIColor.yellow
    var bookmarkColor : UIColor = UIColor.purple
    var mWaveFormProtocol : WaveFormMoveProtocol?
    var removeIndex : Int = -1
    
    var mButton = UIButton()
    
    //var unSelectColor : UIColor =
    init(frame: CGRect,deletgate : WaveFormMoveProtocol?,waveFormBackgroundColor : UIColor,currentPlayLineColor : UIColor) {
        strokeColor = waveFormBackgroundColor
        fillColor = currentPlayLineColor
        mSelectionEnd = Int(frame.size.width)
        caShap = CAShapeLayer()
        caShapShadow = CAShapeLayer()
        caShapBefore = CAShapeLayer()
        caShapMaskTime = CAShapeLayer()
        caShapUnSelect = CAShapeLayer()
        caShapBeforeShadow = CAShapeLayer()
        caText = CALayer()
        caShapBookmark = CAShapeLayer()
        
        mLenByZoomLevel = Array(repeatElement(0, count: 4))
        mZoomFactorByZoomLevel = Array(repeating: 0, count: 4)
        super.init(frame: frame)
        mFrame = frame
        self.backgroundColor = UIColor.clear
        caShap.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShap.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShap.backgroundColor = UIColor.clear.cgColor
        caShap.strokeColor = strokeColor.cgColor
        
        caShapShadow.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShapShadow.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShapShadow.backgroundColor = UIColor.clear.cgColor
        caShapShadow.strokeColor = strokeColor.cgColor.copy(alpha: 0.5)
        
        caShapBefore.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShapBefore.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShapBefore.backgroundColor = UIColor.clear.cgColor
        //168,135,245
        //0xA8,0x87,0xF5
        //UIColor(red: 0xA8, green: 0x87, blue: 0xF5, alpha: 1.00)
        caShapBefore.strokeColor = UIColor(red:	0xA8, green: 0x87, blue:0xF5).cgColor
        
        caShapBeforeShadow.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShapBeforeShadow.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShapBeforeShadow.backgroundColor = UIColor.clear.cgColor
        caShapBeforeShadow.strokeColor = UIColor(red: 0xA8, green: 0x87, blue:0xF5).cgColor.copy(alpha: 0.7)
       
        // select shape
        
        caShapUnSelect.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShapUnSelect.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShapUnSelect.backgroundColor = UIColor.clear.cgColor
        caShapUnSelect.strokeColor = UIColor.gray.withAlphaComponent(0.8).cgColor
        
        // mask time shape
        
        caShapMaskTime.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShapMaskTime.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShapMaskTime.backgroundColor = UIColor.clear.cgColor
        caShapMaskTime.strokeColor = fillColor.cgColor
        
        // bookmark shape
        caShapBookmark.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShapBookmark.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShapBookmark.backgroundColor = UIColor.clear.cgColor
        caShapBookmark.strokeColor = bookmarkColor.cgColor
        caShapBookmark.fillColor = bookmarkColor.cgColor
    
        
        caText.backgroundColor = UIColor.clear.cgColor
        caText.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 20)
        
        print("frame \(frame.size.height/2)")
//        let button = CustomButtom(frame: CGRect(x: 0, y: 100, width: buttonWidth, height: 50),parentViewParam : self,isLeft : true)
//        button.backgroundColor = UIColor.green
//        button.setTitle("Test Button", for: .normal)
//    
//        let buttonRight = CustomButtom(frame: CGRect(x: frame.size.width-100, y: frame.size.height-100, width: 100, height: 50),parentViewParam : self,isLeft : false)
//        buttonRight.backgroundColor = UIColor.green
//        buttonRight.setTitle("Test Button", for: .normal)
       
       // caShap.fillColor =  UIColor.red.cgColor
        self.layer.addSublayer(caShap)
        self.layer.addSublayer(caShapShadow)
        self.layer.addSublayer(caShapBefore)
        self.layer.addSublayer(caShapMaskTime)
        self.layer.addSublayer(caShapUnSelect)
        self.layer.addSublayer(caShapBeforeShadow)
        self.layer.addSublayer(caText)
        self.layer.addSublayer(caShapBookmark)
       
        mButton.setTitle("Remove", for: .normal)
        mButton.setTitleColor(UIColor.black, for: .normal)
        mButton.backgroundColor = UIColor.white
        mButton.frame = CGRect(x: 0, y: -20, width: 80, height: 20)
        mButton.isHidden = true
        mButton.addTarget(self, action: "buttonClicked:", for: .touchUpInside)
        addSubview(mButton)

//        addSubview(button)
//        addSubview(buttonRight)
        if let delegateProtocol = deletgate {
             mWaveFormProtocol = delegateProtocol
        }
       // self.setNeedsDisplay()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        var point : CGPoint
        let linePath = UIBezierPath()
        let lineShadowPath = UIBezierPath()
        let lineBeforeShadowPath = UIBezierPath()
        let linePathBefore = UIBezierPath()
        let lineTimePath = UIBezierPath()
        let unSelectPath = UIBezierPath()
        let lineBookmark = UIBezierPath()
        
        let start = mOffset    //currrentPlayPosition frame
        //print(pixelsToMillisecs(pixels: start))
        let ctr = Int(rect.height/2) + 15
        
        var e1 = Float(mSelectionEnd * 1000) / Float(pixelsToMillisecs(pixels: mSelectionEnd))
        var e2 = Float(mSelectionEnd * 250) / Float(pixelsToMillisecs(pixels: mSelectionEnd))
        var unit1 = millisecsToPixels(msecs: 1000)//Int(frame.width/5)
        let unit2 = millisecsToPixels(msecs: 250)//Int(frame.width/20)
        caText.sublayers?.forEach { $0.removeFromSuperlayer() }
        if mInitialized{
            point = CGPoint(x: 0, y: 15)
            linePath.move(to: point)
            point.x = CGFloat(Int(rect.width))
            linePath.addLine(to: point)
            
            point = CGPoint(x: 0, y: rect.height + 15)
            linePath.move(to: point)
            point.x = CGFloat(Int(rect.width))
            linePath.addLine(to: point)

            var cnt : Int = 0
            for i in 0 ..< Int(rect.width){
                
                let zoomLevelFloat : Float = mZoomFactorByZoomLevel[mZoomLevel]
                let h : Int  = (Int) (getScaledHeight(zoomLevel: zoomLevelFloat , i: start + i ) * Float(getMeasuredHeight() / 2));
               
                let y0 = ctr - h
                let y1 = ctr + 1
                let y2 = ctr + 1 + h/2
                if i % 2 == 0 {
                    point = CGPoint(x: i, y: y1)
                    linePath.move(to: point)
                    point.y = CGFloat(y0)
                    linePath.addLine(to: point)
                    
                    point = CGPoint(x: i, y: y1)
                    lineShadowPath.move(to: point)
                    point.y = CGFloat(y2)
                    lineShadowPath.addLine(to: point)

                    
                    if i+start < mPlaybackPos {
                        point = CGPoint(x: i, y: y1)
                        linePathBefore.move(to: point)
                        point.y = CGFloat(y0)
                        linePathBefore.addLine(to: point)
                        
                        point = CGPoint(x: i, y: y1)
                        lineBeforeShadowPath.move(to: point)
                        point.y = CGFloat(y2)
                        lineBeforeShadowPath.addLine(to: point)
                        

                    }
                
                }
                var aaa = Int(Float(Int(Float(start+i) / e1)) * e1)
                var bbb = Int(Float(Int(Float(start+i) / e2)) * e2)
                if ((start+i) == aaa || (start+i) == aaa+1) && (start+i) != 0{
                    point = CGPoint(x: i, y: -10)
                    linePath.move(to: point)
                    point.y = CGFloat(15)
                    linePath.addLine(to: point)
                    
                    let text = CATextLayer()
                    text.backgroundColor = UIColor.clear.cgColor
                    text.foregroundColor = UIColor.black.cgColor
                    text.fontSize = 14
                    
                    //Normal
                    var sec = (start+i) / unit1
                    var str : String
                    if sec < 10 {
                        str = String(format: "0%d:00", sec)
                    }else {
                        str = String(format: "%d:00", sec)
                    }
                    
                    text.string = str
                    text.frame = CGRect(x: i + 2, y: -12, width: 50, height: 20)
                    caText.addSublayer(text)
                    
                    //Special(first view)
                    if cnt == 0 {
                    let text_spec = CATextLayer()
                    text_spec.backgroundColor = UIColor.clear.cgColor
                    text_spec.foregroundColor = UIColor.black.cgColor
                    text_spec.fontSize = 14
                    sec -= 1
                    if sec < 10 {
                        str = String(format: "0%d:00", sec)
                    }else {
                        str = String(format: "%d:00", sec)
                    }
                    
                    text_spec.string = str
                    text_spec.frame = CGRect(x: i-unit1+2, y: -12, width: 50, height: 20)
                    caText.addSublayer(text_spec)
                        cnt += 1
                    }
                    
                }else if (start+i) == bbb || (start+i) == bbb+1 {
                    point = CGPoint(x: i, y: 10)
                    linePath.move(to: point)
                    point.y = CGFloat(15)
                    linePath.addLine(to: point)
                    
                }
                
                if removeIndex != -1  {
                    mButton.frame = CGRect(x: mBookmarks[removeIndex] - start - 50, y: -10, width: 80, height: 20)
                }
                
                if i+start == mPlaybackPos {
                    //i is offset displaying on current rect,
                    //start is the timeframe which is not displayed on current rect
                    //mPlaybackPos is current position frame
                    
                    //masker time
                    
                    point = CGPoint(x: i, y: 10)
                    lineTimePath.move(to: point)
                    point.y = CGFloat(rect.height + 15)
                    lineTimePath.addLine(to: point)
                    
                }
                for arr in mBookmarks {
                    if i+start == arr {
                        //lineB
                        
                        point = CGPoint(x: i, y: 15)
                        lineBookmark.move(to: point)
                        point.y = CGFloat(rect.height + 15)
                        lineBookmark.addLine(to: point)
                        
                        point.y = CGFloat(15)
                        lineBookmark.move(to: point)
                        lineBookmark.addLine(to: CGPoint(x: point.x + 4, y: 8))
                        lineBookmark.addLine(to: CGPoint(x: point.x - 4, y: 8))
                    }
                }
                // draw unselect
                if i+start < mSelectionStart || i+start > mSelectionEnd {
                    point = CGPoint(x:i, y: 15)
                    unSelectPath.move(to: point)
                    point.y = CGFloat(rect.height+15)
                    unSelectPath.addLine(to: point)
                }

            }

            caShap.path = linePath.cgPath
            caShapShadow.path = lineShadowPath.cgPath
            caShapBefore.path = linePathBefore.cgPath
            caShapBeforeShadow.path = lineBeforeShadowPath.cgPath
            caShapUnSelect.path = unSelectPath.cgPath
            caShapMaskTime.path = lineTimePath.cgPath
            caShapBookmark.path = lineBookmark.cgPath
           
        }
    }
    
    public func drawBookmarks(bmArray : [Int]) {
        mBookmarks = bmArray
        self.setNeedsDisplay()
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mButton.isHidden = true
        if let touch = touches.first{
            if let waveformDelegate = mWaveFormProtocol {
                waveformDelegate.touchesBegan(position: Int(touch.location(in: self).x))
                
                let point = touch.location(in:self)
                
                if let layer = self.caShapBookmark.hitTest(point) as? CAShapeLayer { // If you hit a layer and if its a Shapelayer
                    if caShapBookmark.contains(point) {//(caShapBookmark.path, nil, point, false) { // Optional, if you are inside its content path
                        let start = mOffset    //currrentPlayPosition frame
                        for arr in mBookmarks {
                            if arr - start <= Int(point.x)+5 && arr - start >= Int(point.x) - 5 {
                                mButton.frame = CGRect(x: arr - start - 50, y: -10, width: 100, height: 30)
                                removeIndex = mBookmarks.index(of: arr)!
                                mButton.isHidden = false
                                self.setNeedsDisplay()
                            }
                        }
                    }
                }
                

                
            }

        }
        
    }
    
    func buttonClicked(_ sender: AnyObject?) {
        mButton.isHidden = true
        mBookmarks.remove(at: removeIndex)
        removeIndex = -1
        setNeedsDisplay()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         if let touch = touches.first{
            let point = touch.location(in: self)
            
            if let waveformDelegate = mWaveFormProtocol {
                waveformDelegate.touchesMoved(position: Int(point.x))
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.location(in: self)
            if let waveformDelegate = mWaveFormProtocol {
                waveformDelegate.touchesEnded(position: Int(point.x))
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch cancel")
    }
    public func updateStart(x : Float) {
        startTest = Int(x)
        self.setNeedsDisplay()
    }
    public func updateEnd(x : Float) {
        endTest = Int(x) + buttonWidth
        self.setNeedsDisplay()
    }
   
    func setFileUrl(url:URL) throws  {
        urlLocal = url
        try mSoundFile.ReadFile(url: urlLocal)
        mSampleRate = mSoundFile.getSampleRate();
        mSamplesPerFrame = mSoundFile.getSamplesPerFrame();
        computeDoublesForAllZoomLevels();
       
    }
    // init request data
    func computeDoublesForAllZoomLevels(){
        let numFrames = mSoundFile.getNumFrames();
        
        // Make sure the range is no more than 0 - 255
        var maxGain : Float = 1.0
        for i in 0 ..< numFrames {
            let gain = getGain( i: i, numFrames: numFrames, frameGains: mSoundFile.getFrameGains())
            if (gain > maxGain) {
                maxGain = gain
            }
        }
        
        scaleFactor = 1
        if (maxGain > 255.0) {
            scaleFactor = 255 / maxGain
        }
        
        // Build histogram of 256 bins and figure out the new scaled max
        maxGain = 0;
        //int gainHist[] = new int[256]
        var gainHist : [Int]
        gainHist = Array(repeating: 0, count: 256)
        
        for i in 0 ..< numFrames {
            
            var smoothedGain : Int = Int(getGain(i: i, numFrames: numFrames, frameGains: mSoundFile.getFrameGains()) * scaleFactor)
            if (smoothedGain < 0){
                smoothedGain = 0
            }
            if (smoothedGain > 255){
                smoothedGain = 255
            }
            if (Float(smoothedGain) > maxGain){
                maxGain = Float(smoothedGain)
            }
            
            gainHist[smoothedGain] += 1;
            
        }
        
        
        // Re-calibrate the min to be 5%
        minGain = 0
        var sum : Int = 0
        while (minGain < Float(255) && sum < numFrames / 20) {
            sum += gainHist[Int(minGain)];
            minGain+=1;
        }
        
        // Re-calibrate the max to be 99%
        sum = 0;
        while (maxGain > 2 && sum < numFrames / 100) {
            sum += gainHist[Int(maxGain)]
            maxGain-=1;
        }
        
        range = maxGain - minGain;
        
        mNumZoomLevels = 3;
        mLenByZoomLevel = Array(repeatElement(0, count: 4))
        mZoomFactorByZoomLevel = Array(repeating: 0, count: 4)
        
        let ratio : Float = Float(getMeasuredWidth()) / 1
        //let ratio : Float = Float(382) / Float(getMeasuredWidth())//Float(numFrames)//
        if (ratio < 1) {
            mLenByZoomLevel[0]  = round(Float(numFrames) * ratio)
            
            mZoomFactorByZoomLevel[0] = ratio
            
            mLenByZoomLevel[1] = Float(numFrames)
            mZoomFactorByZoomLevel[1] = 1
            
            mLenByZoomLevel[2] = Float(numFrames * 2)
            mZoomFactorByZoomLevel[2] = 2
            
            mLenByZoomLevel[3] = Float(numFrames * 3)
            mZoomFactorByZoomLevel[3] = 3.0
            
            mZoomLevel = 0;
        } else
        {
            mLenByZoomLevel[0] = Float(numFrames)
            mZoomFactorByZoomLevel[0] = 1

            mLenByZoomLevel[1] = Float(numFrames) * 2
            mZoomFactorByZoomLevel[1] = 2
            
            mLenByZoomLevel[2] = Float(numFrames * 3)
            mZoomFactorByZoomLevel[2] = 3
            
            mLenByZoomLevel[3] = Float(numFrames * 4)
            mZoomFactorByZoomLevel[3] = 4
            
            mZoomLevel = 0;
            for i in 0 ..< 4 {
                if (mLenByZoomLevel[mZoomLevel] - Float(getMeasuredWidth()) > 0) {
                    break;
                } else {
                    mZoomLevel = i;
                }
            }
        }
        
        mInitialized = true;
    }
    
    //draw waveForm 
    func drawWaveform(){
        
    }
    
    func drawWaveformLine() {
        
    }

    
    func maxPos() -> Int {
         return Int(mLenByZoomLevel[mZoomLevel]);
    }
    
    func getGain(i : Int, numFrames : Int, frameGains : [Int]) -> Float {
        let x : Int = min(i, numFrames - 1);
        if (numFrames < 2) {
            return Float(frameGains[x]);
        } else {
            if (x == 0) {
                return (Float(frameGains[0]) / 2) + (Float(frameGains[1]) / 2)
            } else if (x == numFrames - 1) {
                return (Float(frameGains[numFrames - 2]) / 2) + ( Float(frameGains[numFrames - 1]) / 2)
            } else {
                return (Float(frameGains[x - 1]) / 3) + (Float(frameGains[x]) / 3) + (Float(frameGains[x + 1]) / 3)
            }
        }
    }
    
    func getMeasuredWidth()-> Int {
        if let frame = mFrame{
            return Int(frame.width)
        }else{
            return 0
        }
    }
    
    func getMeasuredHeight() -> Int {
        if let frame = mFrame{
            return Int(frame.height)
        }else{
            return 0
        }

    }
    
    func getScaledHeight(zoomLevel : Float, i : Int) -> Float {
        if (zoomLevel == 1.0) {
            return getNormalHeight(i: Int(Float(i)))
        } else if (zoomLevel < 1.0) {
            return getZoomedOutHeight(zoomLevel: zoomLevel, i: i);
        }
        return getZoomedInHeight(zoomLevel: zoomLevel, i: i);
    }
    
    func getNormalHeight(i : Int) -> Float {
         return getHeight(i: i, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
    }
    
    func getHeight(i : Int,numFrames : Int, frameGains : [Int],scaleFactor : Float,minGain : Float,range : Float) -> Float {
        var value : Float = (getGain(i: i, numFrames: numFrames, frameGains: frameGains) * scaleFactor - minGain) / range;
        if (value < 0.0){
            value = 0
        }
        if (value > 1.0){
            value = 1
        }
        return value;
    }
    // zoom
    func getZoomedOutHeight(zoomLevel : Float,i: Int) -> Float {
        let f = Int(Float(i) / zoomLevel)
        let x1 = getHeight(i: f, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        let x2 = getHeight(i: f + 1, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        return 0.5 * (x1 + x2);
    }
    func getZoomedInHeight(zoomLevel : Float, i: Int) -> Float {
        /*var aaa = Int(Float(Int(Float(i) / zoomLevel)) * zoomLevel)
        var bbb = Int(Float(Int(Float(i-1) / zoomLevel)) * zoomLevel)
        
        let f =  zoomLevel
        if (i == 0) {
            return 0.5 * getHeight(i: 0, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        }
        if (i == 1) {
            return getHeight(i: 0, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        }
        //if (i % f == 0) {
        if (i == aaa || i == aaa+1) {
            let x1 = getHeight(i: i / Int(f) - 1, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
            let x2 = getHeight(i: i / Int(f), numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
            return 0.5 * (x1 + x2);
        //} else if ((i - 1) % f == 0) {
        } else if (i-1) == bbb || (i-1) == bbb+1 {
            return getHeight(i: (i - 1) / Int(f), numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        }
        return 0;*/
        return getHeight(i: Int(Float(i)/zoomLevel), numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);

    }
    func canZoomIn() -> Bool {
        return (mZoomLevel < mNumZoomLevels - 1);
    }
   
    func zoomIn()  {
        if (canZoomIn()) {
            let ff = Float(getMeasuredWidth())/Float(millisecsToPixels(msecs: 5000))
            mLenByZoomLevel[1] = mLenByZoomLevel[1] / 2 * ff
            mZoomFactorByZoomLevel[1] = ff

            mZoomLevel+=1;
            let factor : Float = Float(mLenByZoomLevel[mZoomLevel]) / Float(mLenByZoomLevel[mZoomLevel - 1])
            //let factorInt = Int(factor)
            mSelectionStart = Int(Float(mSelectionStart)*factor) // TODO check it out
            mSelectionEnd = Int(Float(mSelectionEnd)*factor)
            var offsetCenter: Float  = Float(mOffset) + Float(getMeasuredWidth()) / factor
            offsetCenter = offsetCenter*factor;
            mOffset = 0//Int(offsetCenter - Float(getMeasuredWidth()) / factor);
            if (mOffset < 0){
                mOffset = 0
            }
            self.setNeedsDisplay()
        }
    }
    
    func canZoomOut() -> Bool {
        return (mZoomLevel > 0)
    }
    
    func zoomOut(){
        if (canZoomOut()) {
            mZoomLevel-=1;
            let factor : Float = Float(mLenByZoomLevel[mZoomLevel + 1]) / Float(mLenByZoomLevel[mZoomLevel])
            let factorInt = Int(factor)
            mSelectionStart /= factorInt;
            mSelectionEnd /= factorInt;
            var offsetCenter =  Int(mOffset + getMeasuredWidth() / factorInt);
            offsetCenter /= factorInt
            mOffset = offsetCenter -  Int(getMeasuredWidth() / factorInt);
            if (mOffset < 0){
                mOffset = 0
            }
            self.setNeedsDisplay()
        }
    }
   
    // touch event 
    func trap(pos : Int) -> Int {
        if (pos < 0){
            return 0
        }
        if (pos > maxPos() ){
            return maxPos();
        }
        return pos;
            

    }
    
    // Play event
    public func setPlayback(pos : Int)  {
        mPlaybackPos = pos
    }
    
    func millisecsToPixels(msecs : Int) -> Int {
        let z : Double = Double(mZoomFactorByZoomLevel[mZoomLevel])
        let first = Double(msecs) * 1.0 * Double(mSampleRate) * z
        let last = (1000.0 * Double(mSamplesPerFrame)) + 0.5
        return Int(first/last)
        
    }
    
    func setParameters(start : Int, end : Int, offset : Int) {
        mSelectionStart = start
        mSelectionEnd = end
        mOffset = offset
    }
    
    func getStart() -> Int {
        return mSelectionStart
    }
    
    func getEnd() -> Int{
        return mSelectionEnd
    }
    // Play convert
    func pixelsToMillisecs(pixels : Int) -> Int {
        let z : Double = Double(mZoomFactorByZoomLevel[mZoomLevel])
        let first : Float = Float (pixels) * Float(1000 * mSamplesPerFrame)
        let second = (Double(mSampleRate) * z) + 0.5
        return Int( Double(first)/second )
    }
    
    // get value
    
    func getOffset() -> Int {
        return mOffset
    }
   
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
