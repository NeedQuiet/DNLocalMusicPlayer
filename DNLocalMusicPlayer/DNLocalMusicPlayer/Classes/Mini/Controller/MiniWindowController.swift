//
//  MiniWindowController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/10.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class MiniWindowController: NSWindowController {
    
    var rootViewController:NSViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    convenience init(WithRootViewController rootViewController:NSViewController) {
        self.init()
        window = MiniPlayerWindow(contentRect: NSRect(x: 0, y: 0, width: 325, height: 50), styleMask: [.borderless,.fullSizeContentView], backing: .buffered, defer: true)
        window?.windowController = self
        
        self.rootViewController = rootViewController
        self.contentViewController = self.rootViewController
    }

}
