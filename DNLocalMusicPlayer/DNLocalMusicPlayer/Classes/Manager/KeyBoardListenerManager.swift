//
//  KeyBoardListenerManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/18.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import Foundation
import Carbon

class KeyBoardListenerManager: NSObject {
    static let share = KeyBoardListenerManager()
    
    // textField在监听的时候，就不拦截本地键盘了
    var TextFieldIsEditing = false
}

//MARK: - 监听按键
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
            if self.TextFieldIsEditing == true { return event}
            let code = event.keyCode
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // option + 左右时 option的值
            if (flags.rawValue == 11010048) {
                self.playControlWithKeyCode(code)
            } else {
                if flags == NSEvent.ModifierFlags.command {
                    if code == kVK_ANSI_W {
                        WindowManager.share.currentWindow?.close()
                    }
                } else {
                    if (code == kVK_ANSI_W || code == kVK_Space){
                        self.playControlWithKeyCode(code)
                    }
                }
            }
            return nil
        }
    }

    //MARK: 监听媒体播放键
    // 这个方法也可以拿来监听键盘其他key的点击
    func startListenCGEventTap() {
        func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            if(type == .tapDisabledByTimeout){
                return Unmanaged.passRetained(event)
            }
            
//            if type.rawValue != NX_SYSDEFINEDMASK {
//                return Unmanaged.passRetained(event)
//            }
            
            if let nsEvent = NSEvent.init(cgEvent: event) {
                if (nsEvent.type == .systemDefined && nsEvent.subtype == .screenChanged ) {
                    let keyCode : Int32 = (Int32((nsEvent.data1 & 0xFFFF0000) >> 16))
                    let keyFlags = (nsEvent.data1 & 0x0000FFFF)
                    let keyState = ((keyFlags & 0xFF00) >> 8) == 0xA
//                    let keyIsRepeat = (keyFlags & 0x1) > 0
//                    if keyIsRepeat {
//                        print("keyIsRepeat")
//                        return nil
//                    }
                    mediaKeyEvent(withKeyCode: keyCode, andState: keyState)
                    return nil
                }
            }

            return Unmanaged.passRetained(event)
        }
        
        // let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue | (1 << CGEventType.flagsChanged.rawValue))
        
        // 创建eventTap，此时会唤起’打开隐私权限‘弹窗
        if let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                            place: .headInsertEventTap,
                                            options: .defaultTap,
                                            eventsOfInterest: CGEventMask(NX_SYSDEFINEDMASK),
                                            callback: myCGEventCallback,
                                            userInfo: nil) {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            CFRunLoopRun()
        } else {
            print("failed to create event tap")
//            exit(1)
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

//MARK: 媒体功能键播控
func mediaKeyEvent(withKeyCode keyCode : Int32, andState state : Bool){
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
                // 加pause是因为媒体播放按钮有时会引发多个歌曲一起播的混乱(可能是因为线程的原因？.commonModes)
                PlayerManager.share.pause()
                PlayerManager.share.next()
            }
        // 上一曲
        case NX_KEYTYPE_REWIND:
            if state == true {
                PlayerManager.share.pause()
                PlayerManager.share.previous()
            }
        default:
            break
    }
}

//MARK: - 监听多媒体键
class MyApplication: NSApplication {
    // 可以通过重写sendEvent监听媒体功能键，但是会唤起iTunes音乐，无法拦截，所以放弃
//    override func sendEvent(_ event: NSEvent) {
//        if  event.type == .systemDefined &&
//            event.subtype == .screenChanged
//        {
//            let keyCode : Int32 = (Int32((event.data1 & 0xFFFF0000) >> 16))
//            let keyFlags = (event.data1 & 0x0000FFFF)
//            let keyState = ((keyFlags & 0xFF00) >> 8) == 0xA
//
//            mediaKeyEvent(withKeyCode: keyCode, andState: keyState)
//            return
//        }
//        super.sendEvent(event)
//    }
}
