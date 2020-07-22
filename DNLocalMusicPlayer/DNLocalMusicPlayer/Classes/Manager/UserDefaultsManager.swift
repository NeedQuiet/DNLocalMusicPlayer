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
    
    //MARK: 选中歌单的索引
    @objc dynamic var playlistSelectedIndex:Int = -1 // -1 为 iTunes；其余为Custom歌单
}

//MARK: - Get
extension UserDefaultsManager {
    func getVolume() -> Float {
        if let volume = UserDefaults.standard.value(forKey: kUserDefaultsKey_Volume) as? Float {
            self.volume = volume
        }
        return volume
    }
    
    func getPlayMode() -> DNPlayMode {
        if let playModeValue = UserDefaults.standard.value(forKey: kUserDefaultsKey_PlayMode) as? Int {
            playmode = DNPlayMode(rawValue: playModeValue)!
        }
        return playmode
    }
    
    func getSeletedPlaylistIndex() {
        if let playlistIndex = UserDefaults.standard.value(forKey: kSelectedPlaylistIndex) as? Int {
            playlistSelectedIndex = playlistIndex
            print("playlistIndex \(playlistIndex)")
        }
    }
}

//MARK: - Set
extension UserDefaultsManager {
    func setVolume(_ volume:Float) {
        self.volume = volume
        UserDefaults.standard.setValue(volume, forKey: kUserDefaultsKey_Volume)
        UserDefaults.standard.synchronize()
    }
    
    func setPlayMode(_ modeValue:Int) {
        playmode = DNPlayMode(rawValue: modeValue)!
        UserDefaults.standard.setValue(modeValue, forKey: kUserDefaultsKey_PlayMode)
        UserDefaults.standard.synchronize()
    }
    
    func setPlaylistSelectedIndex(_ index:Int) {
        playlistSelectedIndex = index
        UserDefaults.standard.setValue(index, forKey: kSelectedPlaylistIndex)
        UserDefaults.standard.synchronize()
    }
}
