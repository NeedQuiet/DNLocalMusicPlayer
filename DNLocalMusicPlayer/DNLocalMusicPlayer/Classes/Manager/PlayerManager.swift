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
    var currentSong: Song?
    //MARK: 当前播放索引
    var currentIndex: Int? = nil
    //MARK: 音量
    var volume: Float = 0.5
    //MARK: 当前播放列表
    var currentPlaylist: [Song] = []
    
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
    func play(withIndex: Int?) {
        _ = checkCurrentSongIsEmpty()
        
        if let index = withIndex {
            if index >= 0 {
                currentIndex = index
                currentSong = currentPlaylist[currentIndex!]
            }
        }
        
        playMusic()
    }
    //MARK: 暂停"
    func pause() {
        isPlaying = false
        player?.pause()
    }
    //MARK: 停止
    func stop() {
        
    }
    //MARK: 下一曲
    func next() {
        // 暂时按照列表循环处理
        if checkCurrentSongIsEmpty() == false {
            var nextIndex:Int = currentIndex!
            if nextIndex < currentPlaylist.count - 1 {
                nextIndex += 1
            } else {
                nextIndex = 0
            }
            currentSong = currentPlaylist[nextIndex]
            currentIndex = nextIndex
        }
        playMusic()
    }
    
    //MARK: 上一曲
    func previous() {
        // 暂时按照列表循环处理
        if checkCurrentSongIsEmpty() == false {
            var nextIndex:Int = currentIndex!
            if nextIndex == 0 {
                nextIndex = currentPlaylist.count - 1
            } else {
                nextIndex -= 1
            }
            currentSong = currentPlaylist[nextIndex]
            currentIndex = nextIndex
        }
        playMusic()
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
    
    private func playMusic() {
        if currentSong!.filePath != player?.url?.path {
            print("播放: \(currentSong!.title)")
            player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: currentSong!.filePath))
            player?.volume = volume
        } else {
            print("重复点击: \(currentSong!.title)")
        }
        isPlaying = true
        player?.play()
    }
}
