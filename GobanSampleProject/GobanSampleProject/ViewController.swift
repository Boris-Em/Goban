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
        gobanView.gobanSize = GobanSize(width: 13, height: 13)
        
        let path = Bundle.main.url(forResource: "AB-AE-Tests", withExtension:"sgf")
        gobanManager?.loadSGFFileAtURL(path!)
    }
    
    @IBAction func didTapClearGobanButton(_ sender: AnyObject) {
        gobanManager?.removeAllStonesAnimated(true)
    }
    
    @IBAction func didTapNextButton(_ sender: AnyObject) {
        gobanManager?.handleNextNode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
