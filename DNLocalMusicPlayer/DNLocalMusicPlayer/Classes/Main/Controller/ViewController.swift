//
//  ViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var playViewHeight: NSLayoutConstraint!
    private var playViewIsShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayViewState), name: NSNotification.Name(rawValue: "changePlayViewState"), object: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func changePlayViewState() {
        var height:CGFloat = 0
        if playViewIsShow == false {
            let screenHeight: CGFloat = view.bounds.size.height
            height = screenHeight - 60
        } else {
            height = 0
        }
        print(height)
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            self.playViewHeight.animator().constant = height
        })

        playViewIsShow = !playViewIsShow
    }
}

