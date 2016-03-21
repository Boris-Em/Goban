//
//  ViewController.swift
//  GobanSampleProject
//
//  Created by Bobo on 3/19/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GobanTouchProtocol {

    @IBOutlet weak var gobanView: GobanView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gobanView.gobanSize = GobanSize(width: 9, height: 9)
        gobanView.gobanTouchDelegate = self
        
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 2, y: 2), gobanStoneColor: .White, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 3, y: 3), gobanStoneColor: .White, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 3, y: 4), gobanStoneColor: .Black, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 3, y: 10), gobanStoneColor: .Black, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 9, y: 7), gobanStoneColor: .Black, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 11, y: 4), gobanStoneColor: .Black, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 9, y: 5), gobanStoneColor: .White, overwrite: true)
        gobanView.setStoneAtGobanPoint(GobanPoint(x: 9, y: 4), gobanStoneColor: .White, overwrite: true)
    }
    
    func didTouchGobanWithClosestGobanPoint(gobanView: GobanView, gobanPoint: GobanPoint) {
        gobanView.setStoneAtGobanPoint(gobanPoint, gobanStoneColor: gobanView.lastSetStonePlayer == .Black ? .White : .Black, overwrite: false)
    }
    
    @IBAction func didTapClearGobanButton(sender: AnyObject) {
        gobanView.clearGoban()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

