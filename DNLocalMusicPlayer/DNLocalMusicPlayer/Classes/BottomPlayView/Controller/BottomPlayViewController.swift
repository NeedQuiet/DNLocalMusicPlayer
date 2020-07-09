//
//  BottomPlayViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class BottomPlayViewController: BaseViewController {
    
    //MARK: 专辑图
    @IBOutlet weak var albumButton: CustomButton!
    //MARK: 播放模式
    @IBOutlet weak var channelButton: CustomButton!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
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
}
