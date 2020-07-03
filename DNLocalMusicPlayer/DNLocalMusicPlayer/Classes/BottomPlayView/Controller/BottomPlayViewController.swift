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
    private var showCurrentPlaylist: Bool = false
    //MARK: 歌词
    @IBOutlet weak var lyricButton: CustomButton!
    //MARK: 声音
    @IBOutlet weak var volumeButton: CustomButton!
    
    private var showVolumePopover:Bool = false
    private lazy var volumePopover:NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = VolumePopover.init()
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
        setBackgroundColor(r: 37, g: 37, b: 37)
        albumButton.image = NSImage.init(named: "MiniPlayerMiniAlbumDefault")
        albumButton.setCornerRadius(radius: 4)
    }
}

//MARK: - 按钮点击事件
extension BottomPlayViewController {
    //MARK: 专辑图点击
    @IBAction func albumButtonClick(_ sender: NSButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePlayViewState"), object: nil)
    }
    
    //MARK: 播放列表点击
    @IBAction func playlistButtonClick(_ sender: Any) {
        showCurrentPlaylist = !showCurrentPlaylist
        if showCurrentPlaylist {
            playlistButton.image = NSImage.init(named: "CurrentPlaylist_Highlight")
        } else {
            playlistButton.image = NSImage.init(named: "CurrentPlaylist_Default")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCurrentPlayListViewState"), object: nil)
    }
    
    //MARK: 声音按钮点击
    @IBAction func volumeButtonClick(_ sender: NSButton) {
        showVolumePopover = !showVolumePopover
        if showVolumePopover == true {
            volumePopover.show(relativeTo: volumeButton.bounds, of: volumeButton, preferredEdge: .minY)
        } else {
            volumePopover.close()
        }
    }
}
