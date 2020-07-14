//
//  DNTableRow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/14.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNTableRow: NSTableRowView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        let selectionRect = NSInsetRect(self.bounds, 0, 0)
//        NSColor.init(calibratedWhite: 72, alpha: 0.6).setStroke() // 路径（边框）
        NSColor.init(r: 50, g: 50, b: 50).setFill() // 填充(内容)
        let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
        selectionPath.fill()
//        selectionPath.stroke()
    }
}
