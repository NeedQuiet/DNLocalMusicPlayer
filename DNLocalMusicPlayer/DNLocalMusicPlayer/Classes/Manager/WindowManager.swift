//
//  WindowManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/9.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class WindowManager: NSObject {
    static let share: WindowManager = WindowManager()
    
    //MARK: 播放详情页是否展示
    @objc dynamic var playViewIsShow:Bool = false
    
    //MARK: currentplaylist是否展示
    @objc dynamic var currentPlaylistIsShow:Bool = false
    
    //MARK: 主窗口
    var mainWindow:NSWindow? {
        didSet {
            mainWindow?.setFrameAutosaveName("mainWindow")
        }
    }
    
    //MARK: 当前窗口
    var currentWindow:NSWindow?
    
    //MARK: 小窗口
    lazy var miniWindowController:MiniWindowController =  {
        let miniController = MiniViewController()
        let miniWindow = MiniWindowController(WithRootViewController: miniController)
        miniWindow.window?.setFrameAutosaveName("miniWindow")
        return miniWindow
    }()
    
    override init() {
        super.init()
        print("WindowManager init")
    }
}

extension WindowManager {
    //MARK: 播放详情页是否展示
    func showPlayView(show:Bool) {
        playViewIsShow = show
    }
    
    //MARK: currentplaylist是否展示
    func showCurrentPlayList(show:Bool) {
        currentPlaylistIsShow = show
    }
    
    //MARK: 展示小播放窗口
    func showMiniWindow() {
        mainWindow?.close()
        miniWindowController.window?.makeKeyAndOrderFront(nil)
        currentWindow = miniWindowController.window
        let playModeValue:Int? = UserDefaults.standard.value(forKey: "firstShowMiniPlayer") as? Int
        if playModeValue == nil {
            UserDefaults.standard.set(1, forKey: "firstShowMiniPlayer")
            UserDefaults.standard.synchronize()
            miniWindowController.window?.center()
        }
    }
    
    //MARK: 展示主播放窗口
    func showMainWindow() {
        miniWindowController.window?.close()
        mainWindow?.makeKeyAndOrderFront(nil)
        currentWindow = mainWindow
    }
}
