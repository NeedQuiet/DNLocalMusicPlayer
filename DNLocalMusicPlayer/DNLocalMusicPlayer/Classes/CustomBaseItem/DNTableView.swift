//
//  DNTableView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/24.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   可以隐藏NSMenu右键点击后cell上的边框
*/

import Cocoa

class DNTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // 禁止右键cell 边框
    override func addSubview(_ view: NSView) {
        if view.className == "NSMenuHighlightView" { // 右键后cell上的线
            return
        } else if view.className == "NSDraggingDestinationView" { // 拖动文件后，cell上的线
            let newLineView = NSView()
            newLineView.frame = view.bounds
            newLineView.wantsLayer = true
            newLineView.layer?.backgroundColor = kRedHighlightColor.cgColor
            view.addSubview(newLineView)
            super.addSubview(view)
        } else {
            super.addSubview(view)
        }
    }
}
