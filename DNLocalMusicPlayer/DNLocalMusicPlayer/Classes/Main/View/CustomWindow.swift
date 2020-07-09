//
//  CustomWindow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/6.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class CustomWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        // styleMask 默认是 [.titled, .closable, .miniaturizable, .resizable]
        super.init(contentRect: contentRect,
                   styleMask:[.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: backingStoreType,
                   defer: flag)
        // titlebar透明
        titlebarAppearsTransparent = true
        // 隐藏title
        titleVisibility = NSWindow.TitleVisibility.hidden
        // 点击窗口背景支持鼠标拖动窗口
        isMovableByWindowBackground = true
        // 设置透明背景
        isOpaque = false
        backgroundColor = NSColor.clear
    }
}
