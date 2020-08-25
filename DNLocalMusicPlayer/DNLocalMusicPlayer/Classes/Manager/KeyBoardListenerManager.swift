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
    
    // textField在监听的时候，就不拦截本地键盘了
    var TextFieldIsEditing = false
}

//MARK: - 监听键盘
extension KeyBoardListenerManager {
    //MARK: 监听键盘
    func startListenKeyboardEvent() {
        // 到系统首选项>安全&隐私权>隐私权>辅助功能 - 请确保您的应用已被选中。
        print("辅助功能:",AXIsProcessTrusted() ? "信任" : "不信任")

        /**
         *  全局快捷键监听
         *      上一曲：CMD + Option + ←
         *      下一曲：CMD + Option + →
         *      播放暂停：Option + Space
         */
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [unowned self] (event) in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // 常规 option || 带有左右键时的 cmd+option
            if (flags == NSEvent.ModifierFlags.option || flags.rawValue == 12058624) {
                self.playControlWithKeyCode(event.keyCode)
            }
        }
        
        /**
         *  本地键盘监听
         *      上一曲：Option + ←
         *      下一曲：Option + →
         *      播放暂停：Space
         *      大/小窗口切换：w
         */
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [unowned self] (event) -> NSEvent?  in
            let code = event.keyCode
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // option + 左右时 option的值
            if (flags.rawValue == 11010048) {
                self.playControlWithKeyCode(code)
            } else {
                if (code == kVK_ANSI_W || code == kVK_Space){
                    self.playControlWithKeyCode(code)
                }
            }
            return self.TextFieldIsEditing ? event : nil
        }
    }
    
    //MARK: 播控
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
        } else if (code == kVK_ANSI_W) { // w
            if self.TextFieldIsEditing { return }
            if WindowManager.share.currentWindow == WindowManager.share.mainWindow {
                WindowManager.share.showMiniWindow()
            } else {
                WindowManager.share.showMainWindow()
            }
        }
    }
}

//MARK: - 监听多媒体键
class MyApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if  event.type == .systemDefined &&
            event.subtype == .screenChanged
        {
            let keyCode : Int32 = (Int32((event.data1 & 0xFFFF0000) >> 16))
            let keyFlags = (event.data1 & 0x0000FFFF)
            let keyState = ((keyFlags & 0xFF00) >> 8) == 0xA

            self.mediaKeyEvent(withKeyCode: keyCode, andState: keyState)
            return
        }
        super.sendEvent(event)
    }
    
    private func mediaKeyEvent(withKeyCode keyCode : Int32, andState state : Bool){
        switch keyCode{
            // 播放暂停
            case NX_KEYTYPE_PLAY:
                if state == false {
                    if PlayerManager.share.isPlaying == true {
                        PlayerManager.share.pause()
                    } else {
                        PlayerManager.share.play(withIndex: nil)
                    }
                }
            // 下一曲(键盘上的居然不是Next，而是Fast)
            case NX_KEYTYPE_FAST:
                if state == true {
                    PlayerManager.share.next()
                }
            // 上一曲
            case NX_KEYTYPE_REWIND:
                if state == true {
                    PlayerManager.share.previous()
                }
            default:
                break
        }

    }
}
