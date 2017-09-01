//
//  CloudViewController.swift
//  SoundWavePlayer
//
//  Created by Admin User on 5/4/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import os.log

class CloudViewController: UIViewController {
    @IBOutlet weak var buttonCloudPlay: UIBarButtonItem!
    var delegate : CloudDelegate!
    @IBOutlet weak var textUrl: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPlay(_ sender: Any) {
        let url = NSURL(string: textUrl.text!)
        _ = navigationController?.popViewController(animated: true)
        delegate.playCloud(url: url as! URL)
    }


}
