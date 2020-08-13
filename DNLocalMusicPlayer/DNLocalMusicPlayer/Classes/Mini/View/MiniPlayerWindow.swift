//
//  MiniPlayerWindow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class MiniPlayerWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
//        // titlebar透明
//        titlebarAppearsTransparent = true
        // 点击窗口背景支持鼠标拖动窗口
        isMovableByWindowBackground = true
        // 设置透明背景
        isOpaque = false
        backgroundColor = NSColor.clear
    }
}
