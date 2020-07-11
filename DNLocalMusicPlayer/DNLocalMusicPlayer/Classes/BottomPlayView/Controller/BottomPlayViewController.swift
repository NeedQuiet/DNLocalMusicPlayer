//
//  BottomPlayViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

class BottomPlayViewController: BaseViewController {
    
    //MARK: 专辑图
    @IBOutlet weak var albumButton: CustomButton!
    //MARK: 播放模式
    @IBOutlet weak var playModeButton: CustomButton!
    //MARK: 播放列表
    @IBOutlet weak var playlistButton: CustomButton!
    //MARK: 歌词
    @IBOutlet weak var lyricButton: CustomButton!
    //MARK: 声音
    @IBOutlet weak var volumeButton: CustomButton!
    private lazy var volumePopover:NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = VolumePopover.init()
        popover.behavior = .transient // 点击外部自动close popover
        return popover
    }()
    
    //MARK: 播放暂停
    @IBOutlet weak var playButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVOAndNotication()
    }

}

//MARK: - UI设置
extension BottomPlayViewController {
    func setupUI() {
        setBackgroundColor(r: 28, g: 28, b: 28)
        albumButton.image = NSImage.init(named: "MiniPlayerMiniAlbumDefault")
        albumButton.setCornerRadius(radius: 4)
    }
}

//MARK: - 按钮点击事件
extension BottomPlayViewController {
    //MARK: 专辑图点击
    @IBAction func albumButtonClick(_ sender: NSButton) {
        let playViewIsShow = WindowManager.share.playViewIsShow
        WindowManager.share.showPlayView(show: !playViewIsShow)
    }
    
    //MARK: 播放列表点击
    @IBAction func playlistButtonClick(_ sender: Any) {
        var showCurrentPlaylist = WindowManager.share.currentPlaylistIsShow
        showCurrentPlaylist = !showCurrentPlaylist
        if showCurrentPlaylist == true {
            playlistButton.image = NSImage.init(named: "CurrentPlaylist_Highlight")
        } else {
            playlistButton.image = NSImage.init(named: "CurrentPlaylist_Default")
        }
        WindowManager.share.showCurrentPlayList(show: showCurrentPlaylist)
    }
    
    //MARK: 声音按钮点击
    @IBAction func volumeButtonClick(_ sender: NSButton) {
        if volumePopover.isShown {
            volumePopover.close()
        } else {
            volumePopover.show(relativeTo: volumeButton.bounds, of: volumeButton, preferredEdge: .minY)
        }
    }
    
    //MARK: 播放暂停
    @IBAction func playButtonclick(_ sender: Any) {
        if PlayerManager.share.isPlaying == true {
            PlayerManager.share.pause()
        } else {
            PlayerManager.share.play(withIndex: nil)
        }
    }
    
    //MARK: 下一曲
    @IBAction func nextClick(_ sender: Any) {
        PlayerManager.share.next()
    }
    
    //MARK: 上一曲
    @IBAction func previousClick(_ sender: Any) {
        PlayerManager.share.previous()
    }
    
    //MARK: 模式切换
    @IBAction func playModeButtonClick(_ sender: Any) {
        PlayerManager.share.switchPlayMode()
    }
}

//MARK: - KVO & Notification
extension BottomPlayViewController {
    func setupKVOAndNotication() {
        //MARK: 监听 WindowManager.share.playViewIsShow
        _ = PlayerManager.share.rx.observeWeakly(Bool.self, "isPlaying")
            .subscribe { [weak self] (change) in
            if let isPlaying = change.element {
                if isPlaying == true {
                    self?.playButton.image = NSImage.init(named: "MiniPlayerPauseButton")
                } else {
                    self?.playButton.image = NSImage.init(named: "MiniPlayerPlayButton")
                }
            }
        }
        
        //MARK: 监听 NotificationCenter kSwitchPlayModeNotificationName
        _ = NotificationCenter.default.rx
            .notification(kSwitchPlayModeNotificationName, object: nil)
            .subscribe{ [weak self] (event) in
                let playMode:DNPlayMode = PlayerManager.share.playmode
                if playMode == .play_mode_repeat_all {
                    self?.playModeButton.image = NSImage.init(named: "TouchBarPlayModeRepeatAll")
                } else if playMode == .play_mode_repeat_one{
                    self?.playModeButton.image = NSImage.init(named: "TouchBarPlayModeRepeatOne")
                } else {
                    self?.playModeButton.image = NSImage.init(named: "TouchBarPlayModeShuffle")
                }
            }
    }
}
