//
//  BaseViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class BaseViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setBackgroundColor (r : CGFloat, g : CGFloat, b : CGFloat) {
        self.view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.init(r: r, g: g, b: b).cgColor
    }
}
