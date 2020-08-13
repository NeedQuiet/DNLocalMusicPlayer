//
//  MiniBackView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class MiniBackView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        self.setBackgroundColor(color:NSColor.init(r: 32, g: 32, b: 32))
        setCornerRadius(4)
        setBorder(1,kLightestColor)
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true;
    }
}
