//
//  Constants.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

import Foundation
import Cocoa

//MARK: - ************* 颜色 *************
let kDefaultColor:NSColor = NSColor.init(r: 211, g: 211, b: 211)
let kLightColor:NSColor = NSColor.init(r: 146, g: 146, b: 146)
let kHighlightColor:NSColor = NSColor.init(r: 255, g: 255, b: 255)

//MARK: - ************* 通知 *************
//MARK: 播放模式改变
let kSwitchPlayModeNotificationName: NSNotification.Name = NSNotification.Name(rawValue: "kSwitchPlayModeNotificationName")
//MARK: 选择Playlist
let kSelectedPlaylistNotificationName: NSNotification.Name = NSNotification.Name(rawValue: "kSelectedPlaylistNotificationName")

//MARK: - ************* 播控 *************
//MARK: 上/下一曲
enum DNPlayControlType: Int {
    case play_previous_song
    case play_next_song
}

//MARK: 播放模式
enum DNPlayMode: Int {
    case play_mode_repeat_all
    case play_mode_repeat_one
    case play_mode_shuffle
}
