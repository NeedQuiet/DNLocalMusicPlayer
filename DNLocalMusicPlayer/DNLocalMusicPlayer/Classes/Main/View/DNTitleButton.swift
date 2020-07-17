//
//  DNTitleButton.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNTitleButton: DNButton {
    //MARK: 默认颜色
    var defaultColor:NSColor = NSColor.init(r: 115, g: 170, b: 224) {
        didSet {
            contentTintColor = defaultColor
        }
    }
    //MARK: 高亮色
    var hoverColor:NSColor = NSColor.init(r: 163, g: 192, b: 220)

    override func awakeFromNib() {
        super.awakeFromNib()
        contentTintColor = defaultColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // 重置trackingAreaView，以此来重置鼠标event的范围
        if areaView.bounds != self.bounds {
            self.willRemoveSubview(areaView)
            addTrackingAreaView()
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        contentTintColor = hoverColor
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        contentTintColor = defaultColor
    }
}
