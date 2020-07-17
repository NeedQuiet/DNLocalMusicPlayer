//
//  NSView-Extension.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/16.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class NSView_Extension: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

extension NSView {
    func setBackgroundColor(color:NSColor) {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
    }
    
    func setCornerRadius(_ cornerRadius:CGFloat) {
        self.wantsLayer = true
        self.layer?.cornerRadius = cornerRadius
        self.layer?.masksToBounds = true
    }
    
    func setBorder(_ width:CGFloat ,_ color:NSColor) {
        self.wantsLayer = true
        self.layer?.borderWidth = width
        self.layer?.borderColor = color.cgColor
    }
}
