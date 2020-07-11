//
//  PlayerManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/11.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import AVFoundation
import RealmSwift

class PlayerManager: NSObject {
    //MARK: - 属性定义
    
    static let share = PlayerManager()
    //MARK: 播放状态
    @objc dynamic var isPlaying: Bool = false
    //MARK: player
    var player: AVAudioPlayer?
    //MARK: 当前歌曲
    @objc dynamic var currentSong: Song?
    //MARK: 当前播放索引
    var currentIndex: Int? = nil
    //MARK: 音量
    var volume: Float = 0.5
    //MARK: 当前播放列表
    var currentPlaylist: [Song] = []
    //MARK: 播放模式
    var playmode: DNPlayMode = .play_mode_repeat_all
    
    //MARK: - 声明周期
    override init() {
        super.init()
        print("[PlayerManager] init!")
    }
    
    deinit {
        print("[PlayerManager] deinit!")
    }
}

//MARK: - 播控
extension PlayerManager {
    //MARK: 播放
    func play(withIndex index: Int?) {
        _ = checkCurrentSongIsEmpty()
        
        // index有值，说明是选中歌曲播放的
        if index != nil && index! >= 0 {
            currentIndex = index
            currentSong = currentPlaylist[currentIndex!]
        }
        
        playCurrentSong()
    }
    //MARK: 暂停"
    func pause() {
        isPlaying = false
        player?.pause()
    }
    //MARK: 停止
    func stop() {
        isPlaying = false
        player?.stop()
    }
    
    //MARK: 上一曲
    func previous() {
        playPreviousOfNextSong(withType: .play_previous_song)
    }
    
    //MARK: 下一曲
    func next() {
        playPreviousOfNextSong(withType: .play_next_song)
    }
    
    //MARK: 模式切换
    func switchPlayMode() {
        if playmode == .play_mode_shuffle {
            playmode = .play_mode_repeat_all
        } else if playmode == .play_mode_repeat_all {
            playmode = .play_mode_repeat_one
        } else {
            playmode = .play_mode_shuffle
        }
        NotificationCenter.default.post(name: kSwitchPlayModeNotificationName, object: nil)
    }
}

//MARK: - Private
extension PlayerManager {
    //MARK: 判断当前播放歌曲是否为空
    private func checkCurrentSongIsEmpty() -> Bool {
        if currentPlaylist.isEmpty {
            let realm = try! Realm()
            currentPlaylist = realm.objects(Song.self).map { (song) in
                return song
            }
        }
        
        if currentSong == nil {
            currentSong = currentPlaylist[0]
            currentIndex = 0
            return true
        }
        return false
    }
    
    //MARK: 播放currentSong
    private func playCurrentSong() {
        print("播放: \(currentSong!.title)")
        player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: currentSong!.filePath))
        player?.delegate = self
        player?.volume = volume
        isPlaying = true
        player?.play()
    }
    
    //MARK: 上/下一曲方法抽取
    private func playPreviousOfNextSong(withType type:DNPlayControlType) {
        // 暂时按照列表循环处理
        if checkCurrentSongIsEmpty() == false {
            var newIndex:Int = currentIndex!
            if playmode == .play_mode_shuffle{ // 随机播放
                let random = arc4random_uniform(UInt32(currentPlaylist.count)) + 1
                newIndex = Int(random)
                print("随机播放第\(newIndex)首")
            } else { // 列表循环 || 单曲循环
                if type == .play_previous_song { // 上一曲
                    newIndex = newIndex == 0 ? currentPlaylist.count - 1 : currentIndex! - 1
                } else { // 下一曲
                    newIndex = newIndex < currentPlaylist.count - 1 ? currentIndex! + 1 : 0
                }
            }
            
            // 更新 currentSong 和 currentIndex
            currentSong = currentPlaylist[newIndex]
            currentIndex = newIndex
        } else {
            // 如果CurrentSong为空，则说明是首次加载时直接点击的 上/下一曲，直接playCurrentSong 播放当前列表第一首
        }
        playCurrentSong()
    }
}

//MARK: - AVAudioPlayerDelegate
extension PlayerManager:AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("音频播放完毕")
        // 暂时按照列表循环处理
        if playmode == .play_mode_repeat_one { // 单曲循环
            play(withIndex: currentIndex)
        } else { // 列表循环 || 随机播放
            next()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("音频播放器解码错误 \(String(describing: error))")
    }
}
