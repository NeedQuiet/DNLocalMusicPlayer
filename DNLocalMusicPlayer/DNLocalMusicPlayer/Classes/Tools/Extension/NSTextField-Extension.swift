//
//  NSTextField-Extension.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/16.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class NSTextField_Extension: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}

// NSTextField 自身支持快捷键
extension NSTextField {
//    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
//        switch event.charactersIgnoringModifiers {
//        case "a":
//            return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
//        case "c":
//            return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
//        case "v":
//            return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
//        case "x":
//            return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
//        default:
//            return super.performKeyEquivalent(with: event)
//        }
//    }
}
