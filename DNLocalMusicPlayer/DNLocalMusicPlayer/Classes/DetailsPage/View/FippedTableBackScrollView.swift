//
//  FippedTableBackScrollView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class FippedTableBackScrollView: DNFippedScrollView {
    var superScrollView = DNFippedScrollView()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    // 禁止滚动
    override func reflectScrolledClipView(_ cView: NSClipView) {}
    
    override func scrollWheel(with event: NSEvent) {
        superScrollView.scrollWheel(with: event)
    }
}
