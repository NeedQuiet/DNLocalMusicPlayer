//
//  DNTableRow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/14.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNTableRow: NSTableRowView {
    var index:Int = 0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        backgroundColor = NSColor.red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    // 画背景色
    override func drawBackground(in dirtyRect: NSRect) {
        let rect = NSInsetRect(self.bounds, 0, 0)
        if index % 2 == 0 {
            NSColor.init(r: 28, g: 28, b: 28).setFill()
        } else {
            NSColor.init(r: 31, g: 31, b: 31).setFill()
        }
        
        let path = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        path.fill()
    }
    
    // 画选中背景
    override func drawSelection(in dirtyRect: NSRect) {
        let rect = NSInsetRect(self.bounds, 0, 0)
//        NSColor.init(calibratedWhite: 72, alpha: 0.6).setStroke() // 路径（边框）
        NSColor.init(r: 50, g: 50, b: 50).setFill() // 填充(内容)
        let selectionPath = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        selectionPath.fill()
//        selectionPath.stroke()
    }
}
