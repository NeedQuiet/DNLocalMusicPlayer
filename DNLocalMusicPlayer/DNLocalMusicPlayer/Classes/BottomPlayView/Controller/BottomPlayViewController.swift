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
    @IBOutlet weak var albumButton: DNButton!
    //MARK: 播放模式
    @IBOutlet weak var playModeButton: DNButton!
    //MARK: 播放列表
    @IBOutlet weak var playlistButton: DNButton!
    //MARK: 歌词
    @IBOutlet weak var lyricButton: DNButton!
    //MARK: 声音
    @IBOutlet weak var volumeButton: DNButton!
    private lazy var volumePopover:NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = VolumePopover.init()
        popover.behavior = .transient // 点击外部自动close popover
        return popover
    }()
    
    //MARK: 播放暂停
    @IBOutlet weak var playButton: DNButton!
    //MARK: 歌名
    @IBOutlet weak var songTitleButton: DNTitleButton!
    //MARK: 间隔线
    @IBOutlet weak var partingLine: NSTextField!
    //MARK: 歌手
    @IBOutlet weak var songArtistButton: DNTitleButton!
    //MARK: 歌曲时间
    @IBOutlet weak var songTime: NSTextField!
    
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
        
        songTitleButton.defaultColor = kDefaultColor
        songTitleButton.hoverColor = kHighlightColor
        
        songArtistButton.defaultColor = kLightColor
        songArtistButton.hoverColor = kHighlightColor
        
        partingLine.isHidden = true
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
    
    //MARK: 歌名
    @IBAction func songTitleClick(_ sender: Any) {
        let playViewIsShow = WindowManager.share.playViewIsShow
        WindowManager.share.showPlayView(show: !playViewIsShow)
    }
    
    //MARK: 歌手
    @IBAction func songArtistClick(_ sender: Any) {}
}

//MARK: - KVO & Notification
extension BottomPlayViewController {
    func setupKVOAndNotication() {
        //MARK: isPlaying
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
        
        //MARK: playMode
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
        
        //MARK: currentSong
        _ = PlayerManager.share.rx.observeWeakly(Song.self, "currentSong")
            .subscribe({  [unowned self] (change) in
                if let currentSong = change.element {
                    guard currentSong != nil else {  return }
                    self.refreshUI(withSong: currentSong!)
                }
        })
    }
}

//MARK: - Private
extension BottomPlayViewController {
    //MARK: 根据歌曲刷新页面信息
    private func refreshUI(withSong currentSong: Song) {
        var image:NSImage = NSImage(named: "MiniPlayerLargeAlbumDefault")!
        if let imageData = currentSong.artworkData {
            image = NSImage(data: imageData) ?? image
        }
        albumButton.image = image
        
        songTitleButton.title = currentSong.album.count > 0 ? currentSong.album : ""
        songArtistButton.title = currentSong.artist.count > 0 ? currentSong.artist : ""
        partingLine.isHidden = !(currentSong.artist.count > 0)
        
        setTime(currentTime: "00:00", totalTime: currentSong.totalTime)
    }
    
    //MARK: 设置时间显示
    private func setTime(currentTime:String = "00:00" ,totalTime:String = "00:00") {
        songTime.stringValue = "\(currentTime) / \(totalTime)"
    }
}
