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
        SongManager.share.startScanRealmData()
//        mainWindow?.setFrameAutosaveName("mainWindow")
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

