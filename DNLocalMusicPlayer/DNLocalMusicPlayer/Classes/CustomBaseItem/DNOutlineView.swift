//
//  DNOutlineView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/24.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNOutlineView: NSOutlineView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    // 禁止右键cell 边框
    override func addSubview(_ view: NSView) {
        if view.className != "NSMenuHighlightView" {
            super.addSubview(view)
        }
    }
}
