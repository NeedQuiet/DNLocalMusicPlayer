//
//  DNBaseView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/7.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   主体View，主要是用来禁止长按拖拽窗口
*/

import Cocoa

class DNBaseView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    // 禁止拖动窗口
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
    
}
