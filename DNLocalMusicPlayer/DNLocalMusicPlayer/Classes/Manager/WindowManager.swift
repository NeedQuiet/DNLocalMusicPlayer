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
    
    @objc dynamic var currentPlaylistIsShow:Bool = false
    
    private override init(){
    }
}

extension WindowManager {
    func showPlayView(show:Bool) {
        playViewIsShow = show
    }
    
    func showCurrentPlayList(show:Bool) {
        currentPlaylistIsShow = show
    }
}
