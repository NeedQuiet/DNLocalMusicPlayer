//
//  DNVolumeSlider.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/22.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNVolumeSlider: DNSlider {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    //MARK: 坐标翻转
    override var isFlipped: Bool {
        // 竖直的slider坐标翻转默认为true
        return false
    }
}
