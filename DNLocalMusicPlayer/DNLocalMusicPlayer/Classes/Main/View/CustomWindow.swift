//
//  CustomWindow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/6.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import SnapKit

private let kMarginTop = 9

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
        // 设置window title （无效）
        title = "DN播放器"
        
        // 给window buttons设置约束
        setupWindowButton()
    }
    
    func setupWindowButton() {
        if let closeBtn:NSButton = self.standardWindowButton(.closeButton) {
            closeBtn.translatesAutoresizingMaskIntoConstraints = false
            closeBtn.snp.makeConstraints { (make) in
                make.top.equalTo(kMarginTop)
            }
        }
        
        if let miniaturizeBtn:NSButton = self.standardWindowButton(.miniaturizeButton) {
            miniaturizeBtn.translatesAutoresizingMaskIntoConstraints = false
            miniaturizeBtn.snp.makeConstraints { (make) in
                make.top.equalTo(kMarginTop)
            }
        }
        
        if let zoomBtn:NSButton = self.standardWindowButton(.zoomButton) {
            zoomBtn.translatesAutoresizingMaskIntoConstraints = false
            zoomBtn.snp.makeConstraints { (make) in
                make.top.equalTo(kMarginTop)
            }
        }
    }
    
//    override func keyDown(with event: NSEvent) {
//        let keyCode = event.keyCode
//        print("Local: \(keyCode)")
//        if (event.modifierFlags == NSEvent.ModifierFlags.command) {
//            print("cmd + ")
//        }
//    }
}
