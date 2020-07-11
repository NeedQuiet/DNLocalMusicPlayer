//
//  Constants.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

import Foundation

//enum BottomPVNotifications: String {
//    case albumClick = "changePlayViewState"
//    case playlistClick = "changeCurrentPlayListViewState"
//}

let kSwitchPlayModeNotificationName: NSNotification.Name = NSNotification.Name(rawValue: "kSwitchPlayModeNotificationName")

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
