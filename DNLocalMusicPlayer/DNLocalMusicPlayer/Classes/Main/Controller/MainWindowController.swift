//
//  MainWindowController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    /**
     * NSDocument 并无 setTitle 这样设置标题的方法
     *  1. NSDocument  有一个 displayName 的方法
     *  2. 重写windowTitle方法
     */
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return "DN播放器"
    }
}
