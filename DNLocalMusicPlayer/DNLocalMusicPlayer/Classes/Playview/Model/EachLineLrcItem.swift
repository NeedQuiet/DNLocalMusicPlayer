//
//  EachLineLrcItem.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/4.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class EachLineLrcItem: NSObject {
    var time:TimeInterval = 0
    var lrc:String = ""
    
    convenience init(lrc:String, time:TimeInterval) {
        self.init()
        self.lrc = lrc
        self.time = time
    }
}
