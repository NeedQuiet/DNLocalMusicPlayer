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
import RxCocoa

class PlayerManager: NSObject {
    //MARK: - 属性定义
    
    static let share = PlayerManager()
    //MARK: 播放状态
    @objc dynamic var isPlaying: Bool = false
    //MARK: player
    @objc dynamic var player: AVPlayer?
    //MARK: 当前歌曲
    @objc dynamic var currentSong: Song?
    //MARK: 当前播放索引
    var currentIndex: Int? = nil
    //MARK: 音量
    var volume: Float = 0.5
    //MARK: 当前正在播放的播放列表
    var currentShowPlaylist: Playlist = Playlist() {
        didSet {
            if currentPlayingPlaylist.songs.isEmpty { // 在没有正在播放列表的情况下，就以当前展示列表复制
                currentPlayingPlaylist = currentShowPlaylist
            }
        }
    }
    //MARK: 当前正在播放的播放列表
    var currentPlayingPlaylist: Playlist = Playlist()
    //MARK: 播放模式
    var playmode: DNPlayMode = .play_mode_repeat_all
    
    //MARK: - 声明周期
    override init() {
        super.init()
//        print("[PlayerManager] init!")
        notification()
    }
    
    deinit {
        print("[PlayerManager] deinit!")
    }
}

//MARK: - 播控
extension PlayerManager {
    //MARK: 播放
    func play(withIndex index: Int?) {
        if checkPlaylistIsEmpty() { return }
        
        _ = checkCurrentSongIsEmpty()
        
        if index == nil { // index没有值：底部bottomBar点击的播放
            if player == nil { // player为空：播放第0首
                playCurrentSong()
            } else { // 不为空：是从pause状态，恢复为play状态，直接play即可
                isPlaying = true
                player?.play()
            }
        } else { // index有值：选中歌曲播放
            currentIndex = index
            currentSong = currentPlayingPlaylist.songs[currentIndex!]
            playCurrentSong()
        }
    }
    //MARK: 暂停
    func pause() {
        isPlaying = false
        player?.pause()
    }
    //MARK: 停止
    func stop() {
        isPlaying = false
        player?.pause()
        currentSong = Song()
    }
    
    //MARK: 上一曲
    func previous() {
        if checkPlaylistIsEmpty() { return }
        playPreviousOfNextSong(withType: .play_previous_song)
    }
    
    //MARK: 下一曲
    func next() {
        if checkPlaylistIsEmpty() { return }
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
        NotificationCenter.default.post(name: kSwitchPlayModeNotification, object: nil)
    }
}

//MARK: - Private
extension PlayerManager {
    //MARK: 判断是否有playlist
    private func checkPlaylistIsEmpty() -> Bool {
        let isEmpty = currentPlayingPlaylist.songs.isEmpty
        if isEmpty {
            print("当前播放列表为空，中断操作！！")
        }
        return isEmpty
    }
    
    //MARK: 判断当前播放歌曲是否为空
    private func checkCurrentSongIsEmpty() -> Bool {
        if currentSong == nil {
            currentSong = currentPlayingPlaylist.songs[0]
            currentIndex = 0
            return true
        }
        return false
    }
    
    //MARK: 播放currentSong
    private func playCurrentSong() {
        player = AVPlayer(playerItem: AVPlayerItem(url: URL(fileURLWithPath: currentSong!.filePath)))
        player?.volume = volume
        isPlaying = true
        player?.play()
        print("播放: \(currentSong!.title)")
    }
    
    //MARK: 上/下一曲方法抽取
    private func playPreviousOfNextSong(withType type:DNPlayControlType) {
        // 暂时按照列表循环处理
        if checkCurrentSongIsEmpty() == false {
            var newIndex:Int = currentIndex!
            if playmode == .play_mode_shuffle{ // 随机播放
                let random = arc4random_uniform(UInt32(currentPlayingPlaylist.songs.count)) + 1
                newIndex = Int(random)
                print("随机播放第\(newIndex)首")
            } else { // 列表循环 || 单曲循环
                if type == .play_previous_song { // 上一曲 (删除index0的正在播放的歌曲，index会减为-1)
                    newIndex = newIndex <= 0 ? currentPlayingPlaylist.songs.count - 1 : currentIndex! - 1
                } else { // 下一曲
                    newIndex = newIndex < currentPlayingPlaylist.songs.count - 1 ? currentIndex! + 1 : 0
                }
            }
            
            // 更新 currentSong 和 currentIndex
            currentSong = currentPlayingPlaylist.songs[newIndex]
            currentIndex = newIndex
        } else {
            // 如果CurrentSong为空，则说明是首次加载时直接点击的 上/下一曲，直接playCurrentSong 播放当前列表第一首
        }
        playCurrentSong()
    }
}

//MARK: - NSNotification
extension PlayerManager {
    func notification() {
        //MARK: 播放结束
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            .subscribe({ [unowned self] (event) in
                print("音频播放完毕")
                // 暂时按照列表循环处理
                if self.playmode == .play_mode_repeat_one { // 单曲循环
                    self.play(withIndex: self.currentIndex)
                } else { // 列表循环 || 随机播放
                    self.next()
                }
        })
        
        //MARK: 播放失败
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
            .subscribe({ [unowned self] (event) in
                print("音频播放失败")
                self.stop()
        })
    }
}
    
