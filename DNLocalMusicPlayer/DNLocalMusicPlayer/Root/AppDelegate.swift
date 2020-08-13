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
    var mainWindow: NSWindow?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        SongManager.share.startScanRealmData()
        let windows = NSApplication.shared.windows
        if windows.count > 0 {
            mainWindow = windows[0]
            WindowManager.share.mainWindow = mainWindow
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("applicationWillTerminate")
    }
}

extension AppDelegate: NSWindowDelegate {
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            mainWindow?.makeKeyAndOrderFront(nil)
        }
        return false
    }
}

