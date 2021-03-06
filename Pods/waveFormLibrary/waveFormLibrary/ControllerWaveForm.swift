//
//  ControllerWaveForm.swift
//
//  Created by SSd on 10/30/16.
//

import UIKit
import AVFoundation
import MediaPlayer

@IBDesignable
public class ControllerWaveForm: UIView{

    var urlLocal = URL(fileURLWithPath: "")
    
    var mWaveformView : WaveFormView?
    var mTouchDragging : Bool = false
    var mTouchStart : Int = 0
    var mTouchInitialOffset : Int = 0
    var mOffset : Int = 0
    var mMaxPos : Int = 0
    var mStartPos : Int = 0
    var mEndPos : Int = 0
    var mCurPos : Int = 0
    let buttonWidth : Int = 100
    var mTouchInitialStartPos : Int = 0
    var mTouchInitialEndPos : Int = 0
    var mWidth : Int = 0
    var mOffsetGoal : Int = 0
    var mMyOffset : Int = 0 // For Swipe
    var mFlingVelocity : Int = 0
    var playButton : PlayButtonView?
    var zoomInButton : UIButton?
    var zoomOutButton : UIButton?
    var currentTimeLabel : UILabel?
    var totalTimeLabel : UILabel?
    var audioPlayer : AVAudioPlayer!
    var mPlayStartOffset : Int = 0
    var mPlayStartMsec : Int = 0
    var mPlayEndMsec : Int = 0
    var mTimer : Timer?
    var mButtonStart : CustomButtom?
    var mButtonEnd  : CustomButtom?
    var waveFormBackgroundColorPrivate : UIColor = UIColor.white
    var currentPlayColorPrivate : UIColor = UIColor.blue
    var mediaPlayer:MPMusicPlayerController = MPMusicPlayerController.applicationMusicPlayer()
    var wasPlaying : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func initView() {
        let screenSize: CGRect = UIScreen.main.bounds
        let width = screenSize.width//frame.size.width//
        mWidth = Int(width)
        let rectFrame = CGRect(x: 0, y: 0, width: width, height: frame.size.height*8/10)
        mWaveformView = WaveFormView(frame: rectFrame,deletgate: self,waveFormBackgroundColor: waveFormBackground,currentPlayLineColor: currentPlayColor)
        //controll player
        let controllerViewWidth = frame.width*2/10
        let controllerViewFrame = CGRect(x: 0, y: (mWaveformView?.frame.height)! - 7, width: frame.width, height: controllerViewWidth)
        let controllerView = UIView(frame: controllerViewFrame)
        controllerView.backgroundColor = UIColor.clear
        let playButtonWidth = controllerView.frame.height
        let playButtonRect = CGRect(x: controllerView.frame.width/2-playButtonWidth/2, y: 0, width: playButtonWidth, height: playButtonWidth)
        
        playButton = PlayButtonView(frame: playButtonRect)
        playButton?.backgroundColor = UIColor.clear
        
        
        let zoomInRect = CGRect(x: 0, y: 0, width: controllerView.frame.height, height: controllerView.frame.height)
        let zoomOutRect = CGRect(x: controllerView.frame.width-controllerView.frame.height, y: 0, width: controllerView.frame.height, height: controllerView.frame.height)
        
        zoomInButton = UIButton(frame: zoomInRect)
        zoomInButton?.backgroundColor = UIColor.clear
        zoomInButton?.setTitle("+", for: .normal)
        
        zoomOutButton = UIButton(frame: zoomOutRect)
        zoomOutButton?.backgroundColor = UIColor.clear
        zoomOutButton?.setTitle("-", for: .normal)
        playButton?.addTarget(self, action: #selector(self.clickPlay), for: .touchUpInside)
        zoomOutButton?.addTarget(self, action: #selector(self.waveformZoomOut), for: .touchUpInside)
        zoomInButton?.addTarget(self, action: #selector(self.waveformZoomIn), for: .touchUpInside)
        
        let currentTimeRect = CGRect(x: 10, y: 0, width: controllerView.frame.width/2-10, height: controllerView.frame.height)
        currentTimeLabel = UILabel(frame: currentTimeRect)
        currentTimeLabel?.backgroundColor = UIColor.clear
        currentTimeLabel?.text = "00:00"
        currentTimeLabel?.font = currentTimeLabel?.font.withSize(15)
        
        let totalTimeRect = CGRect(x: width/2, y: 0, width: width/2-10, height: controllerView.frame.height)
        totalTimeLabel = UILabel(frame: totalTimeRect)
        totalTimeLabel?.backgroundColor = UIColor.clear
        totalTimeLabel?.textAlignment = NSTextAlignment.right
        totalTimeLabel?.text = "00:00"
        totalTimeLabel?.font = totalTimeLabel?.font.withSize(15)
        
        controllerView.addSubview(currentTimeLabel!)
        controllerView.addSubview(totalTimeLabel!)
        //add subview
        //controllerView.addSubview(playButton!)
        //controllerView.addSubview(zoomInButton!)
        //controllerView.addSubview(zoomOutButton!)
        
        let buttonWidth = CGFloat(100)
        let buttonHeigh = CGFloat(50)
        mButtonStart = CustomButtom(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeigh),parentViewParam : self,isLeft : true,delegate: self)
        mButtonStart?.setBackgroundImage(UIImage(named : "HandleLeftBig"), for: .normal)
        mButtonEnd = CustomButtom(frame: CGRect(x: width-buttonWidth, y: mWaveformView!.frame.height-buttonHeigh, width: buttonWidth, height: buttonHeigh),parentViewParam : self,isLeft : false,delegate: self)
        mButtonEnd?.setBackgroundImage(UIImage(named: "buttonHandle"), for: .normal)
        
        addSubview(mWaveformView!)
        mWaveformView!.addSubview(mButtonEnd!)
        mWaveformView!.addSubview(mButtonStart!)
        addSubview(controllerView)
    }
    public func setMp3Url(mp3Url : URL){
        let screenSize: CGRect = UIScreen.main.bounds
        urlLocal = mp3Url
        mCurPos = 0
        
        /*let width = screenSize.width//frame.size.width//
        mWidth = Int(width)
        let rectFrame = CGRect(x: 0, y: 0, width: width, height: frame.size.height*8/10)
        mWaveformView = WaveFormView(frame: rectFrame,deletgate: self,waveFormBackgroundColor: waveFormBackground,currentPlayLineColor: currentPlayColor)
        */do {
            try mWaveformView?.setFileUrl(url: urlLocal)
            mWaveformView?.setPlayback(pos: 0)
        } catch let error as NSError{
            print(error)
        }
        //controll player
        /*let controllerViewWidth = frame.width*2/10
        let controllerViewFrame = CGRect(x: 0, y: (mWaveformView?.frame.height)!+8, width: frame.width, height: controllerViewWidth)
        let controllerView = UIView(frame: controllerViewFrame)
        controllerView.backgroundColor = UIColor.clear
        let playButtonWidth = controllerView.frame.height
        let playButtonRect = CGRect(x: controllerView.frame.width/2-playButtonWidth/2, y: 0, width: playButtonWidth, height: playButtonWidth)
        
        playButton = PlayButtonView(frame: playButtonRect)
        playButton?.backgroundColor = UIColor.clear
        
        
        let zoomInRect = CGRect(x: 0, y: 0, width: controllerView.frame.height, height: controllerView.frame.height)
        let zoomOutRect = CGRect(x: controllerView.frame.width-controllerView.frame.height, y: 0, width: controllerView.frame.height, height: controllerView.frame.height)
        
        zoomInButton = UIButton(frame: zoomInRect)
        zoomInButton?.backgroundColor = UIColor.clear
        zoomInButton?.setTitle("+", for: .normal)
        
        zoomOutButton = UIButton(frame: zoomOutRect)
        zoomOutButton?.backgroundColor = UIColor.clear
        zoomOutButton?.setTitle("-", for: .normal)
        playButton?.addTarget(self, action: #selector(self.clickPlay), for: .touchUpInside)
        zoomOutButton?.addTarget(self, action: #selector(self.waveformZoomOut), for: .touchUpInside)
        zoomInButton?.addTarget(self, action: #selector(self.waveformZoomIn), for: .touchUpInside)
        
        let currentTimeRect = CGRect(x: 10, y: 0, width: controllerView.frame.width/2-10, height: controllerView.frame.height)
        currentTimeLabel = UILabel(frame: currentTimeRect)
        currentTimeLabel?.backgroundColor = UIColor.clear
        currentTimeLabel?.text = "00:00"
        
        let totalTimeRect = CGRect(x: width/2, y: 0, width: width/2-10, height: controllerView.frame.height)
        totalTimeLabel = UILabel(frame: totalTimeRect)
        totalTimeLabel?.backgroundColor = UIColor.clear
        totalTimeLabel?.textAlignment = NSTextAlignment.right
        totalTimeLabel?.text = "00:00"
        
        controllerView.addSubview(currentTimeLabel!)
        controllerView.addSubview(totalTimeLabel!)
        //add subview
        //controllerView.addSubview(playButton!)
        //controllerView.addSubview(zoomInButton!)
        //controllerView.addSubview(zoomOutButton!)
        
        let buttonWidth = CGFloat(100)
        let buttonHeigh = CGFloat(50)
        mButtonStart = CustomButtom(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeigh),parentViewParam : self,isLeft : true,delegate: self)
        mButtonStart?.setBackgroundImage(UIImage(named : "HandleLeftBig"), for: .normal)
        mButtonEnd = CustomButtom(frame: CGRect(x: width-buttonWidth, y: mWaveformView!.frame.height-buttonHeigh, width: buttonWidth, height: buttonHeigh),parentViewParam : self,isLeft : false,delegate: self)
        mButtonEnd?.setBackgroundImage(UIImage(named: "buttonHandle"), for: .normal)
        */
        finishOpeningSoundFile()
        /*addSubview(mWaveformView!)
        mWaveformView!.addSubview(mButtonEnd!)
        mWaveformView!.addSubview(mButtonStart!)
        addSubview(controllerView)*/
    }
    func finishOpeningSoundFile() {
       
        if let waveFormUnWrap = mWaveformView {
            mMaxPos = waveFormUnWrap.maxPos()
            mTouchDragging = false;
            mOffset = 0;
            mOffsetGoal = 0;
            mFlingVelocity = 0;
            resetPositions();
            updateDisplay();
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: urlLocal)
            audioPlayer.delegate = self
            
        } catch let error as NSError {
            print(error)
        }
    }
    public func waveformZoomIn(){
        mWaveformView?.zoomIn();
        mStartPos = (mWaveformView?.getStart())!;
        mEndPos = (mWaveformView?.getEnd())!;
        mMaxPos = (mWaveformView?.maxPos())!;
        mOffset = (mWaveformView?.getOffset())!;
        mOffsetGoal = mOffset;
        updateDisplay();
        
    }
    func  waveformZoomOut() {
        mWaveformView?.zoomOut();
        mStartPos = (mWaveformView?.getStart())!;
        mEndPos = (mWaveformView?.getEnd())!;
        mMaxPos = (mWaveformView?.maxPos())!;
        mOffset = (mWaveformView?.getOffset())!;
        mOffsetGoal = mOffset;
        updateDisplay();
    }
    public func clickPlay(){
        onPlay(startPosition: mCurPos)
    }
    public func currentPosition() -> Int {
        return mCurPos
    }
    public func playBookmark(index : Int) {
        mCurPos = index
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.pause()
            mTimer?.invalidate()
            mTimer = nil
            updateButton()
        }
        onPlay(startPosition: mCurPos)
        
    }
    func trap(pos : Int) -> Int {
        if (pos < 0){
            return 0
        }
        if (pos > mMaxPos ){
            return mMaxPos
        }
        return pos;
    }
    func onPlay(startPosition : Int){
       if isPlaying() {
            if let audioPlayerUW = audioPlayer {
                audioPlayerUW.pause()
                mTimer?.invalidate()
                mTimer = nil
                updateButton()
            }
            return
        }
        mPlayStartMsec = mWaveformView!.pixelsToMillisecs(pixels: startPosition)
        mPlayEndMsec = mWaveformView!.pixelsToMillisecs(pixels: mEndPos)
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.currentTime = TimeInterval(exactly: Float(mPlayStartMsec)/1000)!
            audioPlayerUW.play()
        }
        updateButton()
        mTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateDisplay), userInfo: nil, repeats: true)
        mTimer?.fire()
    }
    
    public func setVolume(volume : Float) {
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.volume = volume
        }
    }
    
    public func pixelsToMillisecs(pos : Int) -> Int {
        return (mWaveformView?.pixelsToMillisecs(pixels: pos))!
    }
    public func drawBookmarks(bArray : [Int]) {
        mWaveformView?.drawBookmarks(bmArray : bArray)
    }
    
    public func getBookmark() -> [Int]{
        return (mWaveformView?.mBookmarks)!
    }
    
    func updateButton(){
        if isPlaying() {
            playButton?.setPlayStatus(isPlay: true)
        }else {
            playButton?.setPlayStatus(isPlay: false)
        }
    }
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
    public func updateDisplay() {
        
        if isPlaying() {
            let now : Int = Int(round(Double(audioPlayer.currentTime)*1000) + Double(mPlayStartOffset))
            let frames : Int = mWaveformView!.millisecsToPixels(msecs: now)
            mWaveformView?.setPlayback(pos: frames)
            setOffsetGoalNoUpdate(offset: frames - mWidth / 2)
           
            if now > mPlayEndMsec {
                if let audioPlayerUW = audioPlayer {
                    audioPlayerUW.currentTime = TimeInterval(exactly: Float(mPlayStartMsec)/1000)!
                    audioPlayerUW.play()
                }
            }
            mCurPos = frames
            
            let curSec = now / 1000
            let totSec = mWaveformView!.pixelsToMillisecs(pixels: mEndPos) / 1000
            let (curm, curs) = secondsToMinutesSeconds(seconds: curSec)
            let (totm, tots) = secondsToMinutesSeconds(seconds: totSec)
            
            var curmStr : String = ""
            var cursStr : String = ""
            var totmStr : String = ""
            var totsStr : String = ""
            if curm < 10 {
                curmStr = String(format: "0%d", curm)
            }else {
                curmStr = String(format: "%d", curm)
            }
            if curs < 10 {
                cursStr = String(format: "0%d", curs)
            }else {
                cursStr = String(format: "%d", curs)
            }
            
            if totm < 10 {
                totmStr = String(format: "0%d", totm)
            }else {
                totmStr = String(format: "%d", totm)
            }
            if tots < 10 {
                totsStr = String(format: "0%d", tots)
            }else {
                totsStr = String(format: "%d", tots)
            }
            
            let aStr = String(format: "%@:%@",curmStr, cursStr)
            currentTimeLabel?.text = (aStr)
            
            let bStr = String(format: "%@:%@", totmStr, totsStr)
            totalTimeLabel?.text = (bStr)
            
        }
        
        var offsetDelta : Int = 0
        
        if (!mTouchDragging) {
            if (mFlingVelocity != 0) {
                offsetDelta = mFlingVelocity / 30
                if (mFlingVelocity > 80) {
                    mFlingVelocity -= 80
                } else if (mFlingVelocity < -80) {
                    mFlingVelocity += 80
                } else {
                    mFlingVelocity = 0
                }
                
                mOffset += offsetDelta;
                
                if (mOffset + mWidth / 2 > mMaxPos) {
                    mOffset = mMaxPos - mWidth / 2
                    mFlingVelocity = 0
                }
                if (mOffset < 0) {
                    mOffset = 0;
                    mFlingVelocity = 0
                }
                mOffsetGoal = mOffset
            } else {
                offsetDelta = mOffsetGoal - mOffset
                if (offsetDelta > 10){
                    offsetDelta = offsetDelta / 10
                }
                else if (offsetDelta > 0){
                    offsetDelta = 1
                }
                else if (offsetDelta < -10){
                    offsetDelta = offsetDelta / 10
                }
                else if (offsetDelta < 0){
                    offsetDelta = -1
                }
                else{
                    offsetDelta = 0
                }
                mOffset += offsetDelta
              
            }
        }
        
        if let waveFormUW = mWaveformView {
            waveFormUW.setParameters(start: mStartPos, end: mEndPos, offset: mOffset)
            waveFormUW.setNeedsDisplay()
        }
        
        if let buttonEndUW = mButtonEnd {
            let endX : Int = mEndPos - mOffset - Int(buttonEndUW.getWidth()-buttonEndUW.getWidth()/2)
            buttonEndUW.updateFramePostion(position: endX)
        }
        if let buttonStartUW = mButtonStart {
            let startX : Int = mStartPos - mOffset - Int (buttonStartUW.getWidth()/2)
            buttonStartUW.updateFramePostion(position: startX)
        }
        
    }
    
    func setOffsetGoalStart() {
        setOffsetGoal(offset: mStartPos - mWidth / 2)
    }
    
    func setOffsetGoalEnd() {
        setOffsetGoal(offset: mEndPos - mWidth / 2)
    }
    
    func setOffsetGoal(offset : Int) {
        setOffsetGoalNoUpdate(offset: offset);
        updateDisplay()
    }
    func setOffsetGoalNoUpdate(offset : Int) {
        if (mTouchDragging) {
            return;
        }
        
        mOffsetGoal = offset;
        if (mOffsetGoal + mWidth / 2 > mMaxPos){
            mOffsetGoal = mMaxPos - mWidth / 2
        }
        if (mOffsetGoal < 0){
            mOffsetGoal = 0
        }
    }
    public func resetPositions() {
        mStartPos = 0;
        mEndPos = mMaxPos;
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.currentTime = 0
        }
    }
    // Play state
    func pause(){
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.pause()
        }
    }
    func isPlaying() -> Bool {
        if let audioPlayerUW = audioPlayer {
            if audioPlayerUW.isPlaying {
                return true
            }
            return false
        }
        return false
    }
  
}
extension ControllerWaveForm : AVAudioPlayerDelegate {
   
}
extension ControllerWaveForm : WaveFormMoveProtocol {
    // waveForm touch
    func touchesBegan(position : Int){
        wasPlaying = isPlaying()
        mTouchDragging = true
        mTouchStart = position
        mTouchInitialOffset = mOffset
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.pause()
            mTimer?.invalidate()
            mTimer = nil
            updateButton()
            
        }
        mMyOffset = position
        //position + mTouchInitialOffset is the right position
        //onPlay(startPosition: position)
        
    }
    func touchesMoved(position : Int){
        mOffset = trap(pos: Int(mTouchInitialOffset + (mTouchStart - position)));
        mCurPos = mCurPos - (position-mMyOffset)
        mMyOffset = position
            if let audioPlayerUW = audioPlayer {
                audioPlayerUW.pause()
                mTimer?.invalidate()
                mTimer = nil
                updateButton()
                
            }
        mWaveformView?.setPlayback(pos: mCurPos)
        setOffsetGoalNoUpdate(offset: mCurPos - mWidth / 2)
        updateDisplay()
    }
    func touchesEnded(position : Int){
        mTouchDragging = false;
        mOffsetGoal = mOffset;
        
        let off = position - mTouchStart
        if(wasPlaying == false) {
            if let audioPlayerUW = audioPlayer {
                audioPlayerUW.pause()
                mTimer?.invalidate()
                mTimer = nil
                updateButton()
                
            }
        } else {
            onPlay(startPosition: mCurPos)
        }
        updateDisplay()
    }
   
}

extension ControllerWaveForm : ButtonMoveProtocol{
    // Button touch
    
    func buttonTouchesBegan(position : Int,isLeft : Bool){
        mTouchDragging = true;
        mTouchStart = position;
        mTouchInitialStartPos = mStartPos;
        mTouchInitialEndPos = mEndPos;
    }
    func buttonTouchesMoved(position : Int,isLeft : Bool){
        let delta = position - mTouchStart;
        if isLeft {
            mStartPos = trap(pos: Int (mTouchInitialStartPos + delta));
            if mStartPos > mEndPos {
                mStartPos = mEndPos
            }
        }else {
            mEndPos = trap(pos: Int(mTouchInitialEndPos + delta));
            if mEndPos < mStartPos {
                mEndPos = mStartPos
            }
            //waveFormView.updateEnd(x: Float(position))
        }
        mPlayStartMsec = mWaveformView!.pixelsToMillisecs(pixels: mStartPos)
        mPlayEndMsec = mWaveformView!.pixelsToMillisecs(pixels: mEndPos)
        updateDisplay()
        
    }
    func buttonTouchesEnded(position : Int,isLeft : Bool){
        //print("buttonTouchesEnded")
        mTouchDragging = false
        if isLeft {
            setOffsetGoalStart()
        }else {
            setOffsetGoalEnd()
        }
        
    }
    
    func showPopup(index : Int){
        
    }

}
extension ControllerWaveForm{
    @IBInspectable public
    var waveFormBackground : UIColor{
        get {
            return waveFormBackgroundColorPrivate
        }
        set(newValue){
            waveFormBackgroundColorPrivate = newValue
        }
    }
    @IBInspectable public
    var currentPlayColor : UIColor {
        get{
            return currentPlayColorPrivate
        }
        set(newValue){
            currentPlayColorPrivate = newValue
        }
    }
}



