//
//  DNFippedScrollView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   翻转了坐标系的NSScrollView
        - 支持翻滚到顶部
*/

import Cocoa

class DNFippedScrollView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var isFlipped: Bool {
        return true
    }
}

extension DNFippedScrollView {
    //MARK: 滚动到顶部
    func scrollToTop() {
        self.contentView.scroll(to: NSPoint(x: 0, y: 0))
    }
}
