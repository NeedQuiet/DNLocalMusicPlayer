//
//  PlayManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/9.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class PlayManager: NSObject {
    static let share: PlayManager = PlayManager()
    
    //MARK: 播放详情页是否展示
    var playViewIsShow:Bool = false {
        didSet {
            print("playViewIsShow: \(playViewIsShow)")
        }
    }
    
    private override init(){
    }
}

extension PlayManager {
    func showPlayView(show:Bool) {
        playViewIsShow = show
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BottomPVNotifications.albumClick.rawValue), object: nil)
    }
}
