//
//  ViewController.swift
//  GobanSampleProject
//
//  Created by Bobo on 3/19/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gobanView: GobanView! {
        didSet {
            gobanManager = GobanManager(gobanView: gobanView)
            gobanView.gobanTouchDelegate = gobanManager
        }
    }
    
    var gobanManager: GobanManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gobanView.gobanSize = GobanSize(width: 9, height: 9)
    }
    
    @IBAction func didTapClearGobanButton(sender: AnyObject) {
        gobanManager?.removeAllStones()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

