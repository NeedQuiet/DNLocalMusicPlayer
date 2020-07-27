//
//  DetailsTableHeaderCell.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/24.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DetailsTableHeaderCell: NSTableHeaderCell {

    override init(textCell string: String) {
        super.init(textCell: string)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        NSColor(r: 28, g: 28, b: 28).setFill()
        let path = NSBezierPath.init(roundedRect: cellFrame, xRadius: 0, yRadius: 0)
        path.fill()
        
        self.drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        textColor = kLightColor
        font = NSFont.systemFont(ofSize: 12)
        var titleRect = self.titleRect(forBounds: cellFrame)
        titleRect.origin.x += 5
        titleRect.origin.y += 9
              
        if stringValue == "音乐标题" {
            titleRect.origin.x += 45 + 12
        }
        
        self.attributedStringValue.draw(in: titleRect)
    }
}
