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
//MARK: 默认颜色
let kDefaultColor:NSColor = NSColor.init(r: 162, g: 162, b: 162)
//MARK: 浅色颜色
let kLightColor:NSColor = NSColor.init(r: 120, g: 120, b: 120)
//MARK: 最浅的颜色
let kLightestColor:NSColor = NSColor.init(r: 64, g: 64, b: 64)
//MARK: 纯白色高亮色
let kWhiteHighlightColor:NSColor = NSColor.init(r: 255, g: 255, b: 255)
//MARK: 红色高亮
let kRedHighlightColor:NSColor = NSColor.init(r: 222, g: 46, b: 46)
//MARK: 搜索高亮
let kSearchHighColor:NSColor = NSColor.init(r: 115, g: 169, b: 224)

//MARK: - ************* 通知 *************
//MARK: iTunes歌曲读取完毕
let kFinishGetItunesSongs: NSNotification.Name = NSNotification.Name(rawValue: "kFinishGetItunesSongs")
//MARK: 播放模式改变
let kSwitchPlayModeNotification: NSNotification.Name = NSNotification.Name(rawValue: "kSwitchPlayModeNotification")
//MARK: 选择Playlist
let kSelectedPlaylistNotification: NSNotification.Name = NSNotification.Name(rawValue: "kSelectedPlaylistNotification")
//MARK: 歌曲进度条拖动
let kProgressContinueTracking: NSNotification.Name = NSNotification.Name(rawValue: "kProgressSliderContinueTracking")
//MARK: 通知刷新Playlist
let kRefreshPlaylistView: NSNotification.Name = NSNotification.Name(rawValue: "kRefreshPlaylistView")
//MARK: 通知刷新CurrentPlaylistView
let kRefreshCurrentPlaylistView: NSNotification.Name = NSNotification.Name(rawValue: "kRefreshCurrentPlaylistView")

//MARK: - ************* 播控 *************
//MARK: 上/下一曲
enum DNPlayControlType: Int {
    case play_previous_song
    case play_next_song
}

//MARK: 播放模式
enum DNPlayMode: Int {
    case play_mode_repeat_all = 0
    case play_mode_repeat_one = 1
    case play_mode_shuffle = 2
}

//MARK: - ************* UserDefaults *************
//MARK: 音量
let kUserDefaultsKey_Volume:String = "kUserDefaultsKey_Volume"
//MARK: 播放模式
let kUserDefaultsKey_PlayMode:String = "kUserDefaultsKey_PlayMode"
//MARK: 播放的歌单Index
let kPlaylingPlaylistIndex:String = "kPlaylingPlaylistIndex"
//MARK: 选中歌曲的Index
let kSelectedSongIndex:String = "kSelectedSongIndex"

//MARK: - ************* 歌曲添加 *************
//MARK: 允许添加的文件格式
let allowedFileTypes = ["mp3", "flac", "wav", "m4a"]
//MARK: 拖入歌曲的PasteboardType
let kDrapInPasteboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
//MARK: 拖拽歌曲/歌单排序的PasteboardType
let kDrapSortPasteboardType = NSPasteboard.PasteboardType.string
