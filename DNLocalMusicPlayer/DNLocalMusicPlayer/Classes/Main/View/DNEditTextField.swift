//
//  DNEditTextField.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/21.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import Carbon

protocol DNEditDelegate : NSObjectProtocol {
    //MARK: enter点击
    func enterKeyPressed()
    //MARK: ESC点击
    func escKeyPressed()
}

class DNEditTextField: NSTextField {
    
    weak var editDelegate:DNEditDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let keyCode = event.keyCode
        if keyCode == kVK_Escape {
            editDelegate?.escKeyPressed()
            return true // return true 就不会发出”咚“的声音
        } else if keyCode == kVK_Return {
            editDelegate?.enterKeyPressed()
            return true
        }
        
        switch event.charactersIgnoringModifiers {
        case "a":
            return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
        case "c":
            return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
        case "v":
            return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
        case "x":
            return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
        default:
            return super.performKeyEquivalent(with: event)
        }
    }
}
