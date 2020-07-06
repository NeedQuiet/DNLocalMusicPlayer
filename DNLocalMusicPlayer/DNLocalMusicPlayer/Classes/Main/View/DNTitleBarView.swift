//
//  DNTitleBarView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/6.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNTitleBarView: DNBaseView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.init(r: 32, g: 32, b: 32).cgColor
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true;
    }
}
