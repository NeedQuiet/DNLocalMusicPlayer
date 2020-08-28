//
//  AppDelegate.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainWindow = NSApplication.shared.mainWindow
        WindowManager.share.mainWindow = mainWindow
        WindowManager.share.currentWindow = mainWindow
        // 开始扫描Realm
        SongManager.share.startScanRealmData()
        // 监听键盘
        KeyBoardListenerManager.share.startListenKeyboardEvent()
        // 监听媒体功能键
        KeyBoardListenerManager.share.startListenCGEventTap()

//        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
//            //            let str = event.characters
//            let code = event.keyCode
//            print("Global: \(code)")
//
//            switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
//            case [.command] where event.characters == "1", [.command, .shift] where event.characters == "1":
//                print("command+1 or command+shift+1")
//            default:
//                break
//            }
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("applicationWillTerminate")
    }
}

extension AppDelegate: NSWindowDelegate {
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            WindowManager.share.currentWindow?.makeKeyAndOrderFront(nil)
        }
        return false
    }
}

