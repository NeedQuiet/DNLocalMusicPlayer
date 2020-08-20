//
//  KeyBoardListenerManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/18.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import Carbon

class KeyBoardListenerManager: NSObject {
    static let share = KeyBoardListenerManager()
    
    //MARK: 监听键盘
    func startListenKeyboardEvent() {
        // 到系统首选项>安全&隐私权>隐私权>辅助功能 - 请确保您的应用已被选中。
        print("辅助功能:",AXIsProcessTrusted() ? "信任" : "不信任")

        // 全局键盘监听
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown,.magnify,.flagsChanged]) { [unowned self] (event) in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // 常规 option || 带有左右键时的 cmd+option
            if (flags == NSEvent.ModifierFlags.option || flags.rawValue == 12058624) {
                self.playControlWithKeyCode(event.keyCode)
            }
        }
        
        // 本地键盘监听
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [unowned self] (event) -> NSEvent?  in
            let code = event.keyCode
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // 常规 option || option + 左右时 option的值
            if (flags == NSEvent.ModifierFlags.option || flags.rawValue == 11010048) {
                self.playControlWithKeyCode(code)
            } else {
                if (code == kVK_ANSI_W || code == kVK_Space){
                    self.playControlWithKeyCode(code)
                }
            }
            return event
        }
    }
    
    // 播控
    func playControlWithKeyCode(_ code:UInt16) {
        if (code == kVK_LeftArrow) { // Left
            PlayerManager.share.previous()
        } else if (code == kVK_RightArrow) { // Right
            PlayerManager.share.next()
        } else if (code == kVK_Space){ // Space
            if PlayerManager.share.isPlaying == true {
                PlayerManager.share.pause()
            } else {
                PlayerManager.share.play(withIndex: nil)
            }
        } else if (code == kVK_ANSI_W) {
            if WindowManager.share.currentWindow == WindowManager.share.mainWindow {
                WindowManager.share.showMiniWindow()
            } else {
                WindowManager.share.showMainWindow()
            }
        }
    }
}
