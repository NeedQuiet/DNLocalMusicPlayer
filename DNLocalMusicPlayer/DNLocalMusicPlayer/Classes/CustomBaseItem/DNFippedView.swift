//
//  DNFippedView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   翻转了坐标系的NSView
*/

import Cocoa

class DNFippedView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    //MARK: 坐标翻转
    override var isFlipped: Bool {
        return true
    }
}
