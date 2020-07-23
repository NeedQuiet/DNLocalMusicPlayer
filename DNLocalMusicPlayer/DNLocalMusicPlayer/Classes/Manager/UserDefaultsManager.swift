//
//  UserDefaultsManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/22.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class UserDefaultsManager: NSObject {
    static let share = UserDefaultsManager()
    
    //MARK: 音量
    var volume: Float = 1
    //MARK: 播放模式
    var playmode: DNPlayMode = .play_mode_repeat_all
    //MARK: 播放歌单的索引
    var playingPlaylistIndex:Int = -1 // -1 为 iTunes；其余为Custom歌单
    //MARK: 选中歌曲的索引
    var songSelectedIndex:Int?
}

//MARK: - Get
extension UserDefaultsManager {
    // 音量
    func getVolume() -> Float {
        if let volume = UserDefaults.standard.value(forKey: kUserDefaultsKey_Volume) as? Float {
            self.volume = volume
        }
        return volume
    }
    // 播放模式
    func getPlayMode() -> DNPlayMode {
        if let playModeValue = UserDefaults.standard.value(forKey: kUserDefaultsKey_PlayMode) as? Int {
            playmode = DNPlayMode(rawValue: playModeValue)!
        }
        return playmode
    }
    // 播放歌单的索引
    func checkSeletedPlaylistIndex() -> Int {
        if let playlistIndex = UserDefaults.standard.value(forKey: kPlaylingPlaylistIndex) as? Int {
            playingPlaylistIndex = playlistIndex
        }
        return playingPlaylistIndex
    }
    // 选中歌曲的索引
    func getSongSelectedIndex() -> Int? {
        if let songIndex = UserDefaults.standard.value(forKey: kSelectedSongIndex) as? Int {
            songSelectedIndex = songIndex
        }
        return songSelectedIndex
    }
}

//MARK: - Set
extension UserDefaultsManager {
    // 音量
    func setVolume(_ volume:Float) {
        self.volume = volume
        UserDefaults.standard.setValue(volume, forKey: kUserDefaultsKey_Volume)
        UserDefaults.standard.synchronize()
    }
    // 播放模式
    func setPlayMode(_ modeValue:Int) {
        playmode = DNPlayMode(rawValue: modeValue)!
        UserDefaults.standard.setValue(modeValue, forKey: kUserDefaultsKey_PlayMode)
        UserDefaults.standard.synchronize()
    }
    // 播放歌单的索引
    func setPlayingPlaylistIndex(_ index:Int) {
        playingPlaylistIndex = index
        UserDefaults.standard.setValue(index, forKey: kPlaylingPlaylistIndex)
        UserDefaults.standard.synchronize()
    }
    // 选中歌曲的索引
    func setSongSelectedIndex(_ index:Int?){
        songSelectedIndex = index
        UserDefaults.standard.setValue(index, forKey: kSelectedSongIndex)
        UserDefaults.standard.synchronize()
    }
}
