//
//  ViewController.swift
//  SoundWavePlayer
//
//  Created by Admin User on 5/4/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import waveFormLibrary
import AVFoundation
import CircularSpinner

protocol BookmarkDelegate {
    func getBookmarkData(index : Int)
    func playBookmark(index : Int)
}
protocol LocalDelegate {
    func playLocal(filename : String)
}
protocol CloudDelegate {
    func playCloud(url : URL)
}
class ViewController: UIViewController  {
    @IBOutlet weak var controller: ControllerWaveForm!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonVolumeUp: UIButton!
    @IBOutlet weak var buttonVolumeDown: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelArtist: UILabel!
    var bundlePath : URL!
    var status : Int = 0
    var volume : Float = 0.5
    var player:AVAudioPlayer!
    var mbookmarkArray: [Int] = []
    var mLocalArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)

        mLocalArray.append("test.mp3")
        mLocalArray.append("451.mp3")
        mLocalArray.append("457.mp3")
        mLocalArray.append("1302.mp3")
        mLocalArray.append("4177.mp3")
        mLocalArray.append("4318.mp3")
        mLocalArray.append("12952.mp3")
        mLocalArray.append("13303.mp3")

        ////http://www.noiseaddicts.com/samples_1w72b820/2514.mp3
        ////http://www.noiseaddicts.com/samples_1w72b820/2958.mp3
       
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.setHidesBackButton(true, animated:true);
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)

        
        let mp3file = Bundle.main.path(forResource: "audio/test", ofType: "mp3")
        let url = URL(fileURLWithPath: mp3file!)
        bundlePath = url.deletingLastPathComponent()

        controller.initView()
        setUrl(url: url)
        configureAlbum(url: url)
        
        /*let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "cloud"), for: UIControlState.normal)
        //button.addTarget(self, action:#selector(ViewController.callMethod), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        
        let button2 = UIButton.init(type: .custom)
        button2.setImage(UIImage.init(named: "local"), for: UIControlState.normal)
        //button.addTarget(self, action:#selector(ViewController.callMethod), for: UIControlEvents.touchUpInside)
        button2.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton2 = UIBarButtonItem.init(customView: button2)
        
        self.navigationItem.rightBarButtonItems = [barButton, barButton2]*/

    }
    
    func setUrl(url: URL) {
        status = 0
        buttonPlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
        labelStatus.text = "Stopped"
        mbookmarkArray.removeAll()
        controller.drawBookmarks(bArray: mbookmarkArray)
        
        controller.setMp3Url(mp3Url: url)
        controller.waveformZoomIn()
    }
    
    func configureAlbum(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
        var title = "No Title"
        var artist = "No Artist"
        for item in metadataList {
            
            guard let key = item.commonKey, let value = item.value else{
                continue
            }
            
            switch key {
            case "title" : title = value as! String
            case "artist": artist = value as! String
            //case "artwork" where value is NSData : print("Artwork")//artistImage.image = UIImage(data: value as! NSData)
            default:
                continue
            }
        }
    
        labelTitle.text = title
        labelArtist.text = artist
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPlayPause(_ sender: UIButton) {
        status += 1
        status = status%2
        if status == 1 {
            buttonPlayPause.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
            labelStatus.text = "Now Playing"
            controller.clickPlay()

        }else if status == 0 {
            buttonPlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
            labelStatus.text = "Paused"
            controller.clickPlay()
        }
    }

    @IBAction func onVolumeUp(_ sender: Any) {
        if volume == 0 {
            buttonVolumeDown.setImage(UIImage(named : "volumedec"), for: UIControlState.normal)
        }
        volume += 0.1
        if volume >= 1 {
            volume = 1
            buttonVolumeUp.setImage(UIImage(named : "volumemax"), for: UIControlState.normal)
        }
        
        sliderVolume.setValue(Float(volume), animated:true)
        controller.setVolume(volume: volume)
    }
    @IBAction func onVolumeDown(_ sender: Any) {
        if volume == 1 {
            buttonVolumeUp.setImage(UIImage(named : "volumeinc"), for: UIControlState.normal)
        }
        volume -= 0.1
        if volume <= 0 {
            volume = 0
            buttonVolumeDown.setImage(UIImage(named : "volumemin"), for: UIControlState.normal)
        }
        sliderVolume.setValue(Float(volume), animated:true)
        controller.setVolume(volume: volume)
    }

    @IBAction func onSliderChangeEnd(_ sender: UISlider) {
        volume = Float(sender.value)
        
        if volume == 0 {
            buttonVolumeDown.setImage(UIImage(named : "volumemin"), for: UIControlState.normal)
            buttonVolumeUp.setImage(UIImage(named : "volumeinc"), for: UIControlState.normal)
        }
        
        if volume == 1 {
            buttonVolumeUp.setImage(UIImage(named : "volumemax"), for: UIControlState.normal)
            buttonVolumeDown.setImage(UIImage(named : "volumedec"), for: UIControlState.normal)
        }
        
        if volume > 0 && volume < 1 {
            buttonVolumeDown.setImage(UIImage(named : "volumedec"), for: UIControlState.normal)
            buttonVolumeUp.setImage(UIImage(named : "volumeinc"), for: UIControlState.normal)
        }
        controller.setVolume(volume: volume)
    }
    
    @IBAction func onBookmarkTap(_ sender: Any) {
        let curPos = controller.currentPosition()
        mbookmarkArray = controller.getBookmark()
        if !mbookmarkArray.contains(curPos) {
            mbookmarkArray.append(curPos)
            controller.drawBookmarks(bArray: mbookmarkArray)
        }
        
        /*let config = FTConfiguration.shared
        config.textColor = UIColor.black
        config.backgoundTintColor = UIColor.white
        config.borderColor = UIColor.lightGray
        config.menuWidth = 80
        config.menuSeparatorColor = UIColor.lightGray
        config.textAlignment = .center
        config.textFont = UIFont.systemFont(ofSize: 14)
        config.menuRowHeight = 40
        config.cornerRadius = 6

        let menuOptionNameArray : [String] = ["Remove"]
        
        let menuOptionImageNameArray : [String] = ["Remove"]
        
        FTPopOverMenu.showForSender(sender: sender as! UIView, with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, done: { (selectedIndex) -> () in
            print(selectedIndex)
        }) {
            
        }
*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if(segue.identifier == "BookmarkID") {
            let viewController = segue.destination as! BookmarkTableViewController
            viewController.delegate = self
            mbookmarkArray = controller.getBookmark()
            viewController.array = mbookmarkArray
            viewController.controller = controller
        }
        if(segue.identifier == "CloudID") {
            let cloudController = segue.destination as! CloudViewController
            cloudController.delegate = self
        }
        if(segue.identifier == "LocalID") {
            let localController = segue.destination as! LocalTableViewController
            localController.delegate = self
            localController.array = mLocalArray
        }
        
    }
    
}
extension ViewController : BookmarkDelegate{
    func getBookmarkData(index : Int) {
        mbookmarkArray.remove(at: index)
        self.controller.drawBookmarks(bArray: mbookmarkArray)
    }
    func playBookmark(index : Int) {
        self.controller.playBookmark(index : mbookmarkArray[index])
        status = 1
        buttonPlayPause.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
        labelStatus.text = "Now Playing"
    }
}

extension ViewController : LocalDelegate{
    func playLocal(filename: String) {
        controller.resetPositions()
        let strArray = filename.components(separatedBy: ".")
        let name = strArray[0]
        let ext = strArray[1]
        let fullname : String = String.init(format: "audio/%@", name)
        let mp3file = Bundle.main.path(forResource: fullname, ofType: ext)
        let url = URL(fileURLWithPath: mp3file!)
        
        setUrl(url: url)
        configureAlbum(url: url)
    }
}

extension ViewController : CloudDelegate{
    func playCloud(url : URL) {
        //CircularSpinner.dismissButton = true
        CircularSpinner.show("Loading...", animated: true, type: .indeterminate)
        
        if self.status == 1 {
            self.status = 0
            self.buttonPlayPause.setImage(UIImage(named: "Play"), for: UIControlState.normal)
            self.labelStatus.text = "Paused"
            self.controller.clickPlay()
        }
        
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!//bundlePath
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: (destinationUrl.path)) {
            
            self.setUrl(url: destinationUrl)
            self.configureAlbum(url: destinationUrl)
            CircularSpinner.hide()
            // if the file doesn't exist
        } else {
            
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    
                    //self.mLocalArray.append((destinationUrl?.lastPathComponent)!)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                CircularSpinner.hide()
                delayWithSeconds(0.0001, completion: {
                    self.setUrl(url: destinationUrl)
                    self.configureAlbum(url: destinationUrl)
                    
                })

            }).resume()
            
        }
        
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
