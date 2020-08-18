//
//  MiniViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/10.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa
import SnapKit

private let kWindowHeightOffset:CGFloat = 150

class MiniViewController: NSViewController {
    // 关闭
    @IBOutlet weak var closeButton: NSButton!
    // 放大
    @IBOutlet weak var enlargeButton: NSButton!
    // 专辑
    @IBOutlet weak var albumButton: NSButton!
    // 歌曲信息BackView
    @IBOutlet weak var infoBackView: NSView!
    // 歌曲信息
    var songInfoView = NSView()
    // 播控View
    var songControlView = NSView()
    // 歌名Label
    var songNameLabel = DNLabel()
    // 歌手-专辑Label
    var songArtistLabel = DNLabel()
    // 播放按钮
    var playButton = MiniButton()
    // 上一曲
    var previousButton = MiniButton()
    // 下一曲
    var nextButton = MiniButton()
    // 音量
    @IBOutlet weak var volumeButton: DNButton!
    // 是否展示playlist
    var showPlaylist = false
    
    private lazy var volumePopover:NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = MiniVolumePopover.init()
        popover.behavior = .transient // 点击外部自动close popover
        return popover
    }()
    
    @IBOutlet weak var progressSlider: DNSlider!
    @IBOutlet weak var progressSliderCell: DNSliderCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
    }
}

//MARK: - UI设置
extension MiniViewController {
    func setupUI() {
        albumButton.setCornerRadius(2)
        makeInfoBackView()
        setupKVO()

        let backView:MiniBackView = view as! MiniBackView
        backView.delegate = self
        
        // 进度条
        progressSlider.minValue = 0
        progressSlider.maxValue = 100
        progressSliderCell.needControlKnobHidden = true
        progressSliderCell.sliderThickness = 2
        progressSliderCell.KnobWidth = 6
        progressSliderCell.KnobHeight = 6
        progressSliderCell.knobColor = kWhiteHighlightColor
        progressSliderCell.progressColor = kLightColor
        progressSliderCell.backgroundColor = kLightestColor
        progressSliderCell.delegate = self
    }
    
    //MARK: 刷新UI
    func refreshUI(withSong currentSong:Song) {
        var image:NSImage = NSImage(named: "MiniPlayerLargeAlbumDefault")!
        if let imageData = currentSong.artworkData {
            image = NSImage(data: imageData) ?? image
        }
        albumButton.image = image
        
        songNameLabel.stringValue = currentSong.title
        songArtistLabel.stringValue = "\(currentSong.artist) -- \(currentSong.album)"
    }
    
    //MARK: 歌曲信息/播控
    func makeInfoBackView() {
        infoBackView.addSubview(songInfoView)
        infoBackView.addSubview(songControlView)
        
        //MARK: 歌曲信息
        songInfoView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        songInfoView.addSubview(songNameLabel)
        songInfoView.addSubview(songArtistLabel)
        // 歌名
        songNameLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(15)
        }
        songNameLabel.textColor = kDefaultColor
        songNameLabel.font = NSFont.systemFont(ofSize: 12)
        // 歌手-专辑
        songArtistLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(songNameLabel.snp.bottom).offset(2)
        }
        songArtistLabel.textColor = kLightColor
        songArtistLabel.font = NSFont.systemFont(ofSize: 10)

        
        //MARK: 播控
        songControlView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        songControlView.isHidden = true
        songControlView.addSubview(playButton)
        songControlView.addSubview(previousButton)
        songControlView.addSubview(nextButton)
        
        let size = 28
        // 播放/暂停
        playButton.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(0)
            make.width.height.equalTo(size)
        }
        playButton.target = self
        playButton.action = #selector(playButtonclick)
        playButton.imageScaling = .scaleAxesIndependently
        // 上一曲
        let offset = 15
        previousButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(0)
            make.right.equalTo(playButton.snp.left).offset(-offset)
            make.width.height.equalTo(size)
        }
        previousButton.image = NSImage.init(named: "MiniPlayerRewindButton")
        previousButton.target = self
        previousButton.action = #selector(previousClick)
        
        // 下一曲
        nextButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(0)
            make.left.equalTo(playButton.snp.right).offset(offset)
            make.width.height.equalTo(size)
        }
        nextButton.image = NSImage.init(named: "MiniPlayerFastForwardButton")
        nextButton.target = self
        nextButton.action = #selector(nextClick)
    }
    
    // 根据鼠标进入/移出切换页面
    func mouseIsEnter(_ isEnter:Bool) {
        songInfoView.isHidden = isEnter
        songControlView.isHidden = !isEnter
    }
    
    // 展示或隐藏playlist
    func displayPlaylist(withAnimate animate:Bool) {
        var frame = self.view.window?.frame
        if showPlaylist {
            frame?.size.height += kWindowHeightOffset
            if frame?.origin.y ?? 0 >= kWindowHeightOffset { // 判断边界
                frame?.origin.y -= kWindowHeightOffset
            }
        } else {
            frame?.size.height -= kWindowHeightOffset
            if frame?.origin.y ?? 0 >= kWindowHeightOffset {
                frame?.origin.y += kWindowHeightOffset
            }
        }
        //        self.view.frame.size.height += 100
        self.view.window?.setFrame(frame ?? NSRect.zero, display: true, animate: animate)
    }
}

//MARK: - KVO
extension MiniViewController {
    func setupKVO() {
        //MARK: isPlaying
        _ = PlayerManager.share.rx.observeWeakly(Bool.self, "isPlaying")
            .subscribe { [unowned self] (change) in
                if let isPlaying = change.element {
                    if isPlaying == true {
                        self.playButton.image = NSImage.init(named: "MiniPlayerPauseButton")
                    } else {
                        self.playButton.image = NSImage.init(named: "MiniPlayerPlayButton")
                    }
                }
        }
        
        //MARK: currentProgress
        _ = PlayerManager.share.rx.observeWeakly(Double.self, "currentProgress")
            .subscribe { [unowned self] (change) in
                if let currentProgress = change.element {
                    // 如果 currentProgress 为无穷大(currentSong为空)
                    if currentProgress == Double.infinity {
                        self.progressSlider.doubleValue = 0
                    } else {
                        self.progressSlider.doubleValue = currentProgress!
                    }
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

//MARK: - MiniBackViewDelegate
extension MiniViewController:MiniBackViewDelegate {
    func mouseEntered() {
        mouseIsEnter(true)
    }
    
    func mouseExited() {
        mouseIsEnter(false)
    }
}

//MARK: - DNSliderCellDelegate
extension MiniViewController:DNSliderCellDelegate {
    //MARK: 开始拖动
    func startTracking(doubleValue:Double ,sender:DNSliderCell) {
        PlayerManager.share.canObservProgress = false
    }
    
    //MARK: 拖动中
    func continueTracking(doubleValue:Double ,sender:DNSliderCell) {
        NotificationCenter.default.post(name: kProgressContinueTracking, object: doubleValue)
    }
    
    //MARK: 结束拖动 & 点击结束
    func stopTracking(doubleValue:Double ,sender:DNSliderCell) {
        // 先设置canObservProgress，防止抖动
        PlayerManager.share.canObservProgress = true
        // seek
        let progress = progressSlider.doubleValue
        PlayerManager.share.seekToProgress(progress)
    }
}

//MARK: - Action
extension MiniViewController {
    //MARK: 关闭
    @IBAction func closeButtonClick(_ sender: Any) {
        self.view.window?.close()
    }
    
    //MARK: 恢复大窗口
    @IBAction func showMainWindow(_ sender: Any) {
        // 如果是展开状态再执行，不然高度减没了
        if showPlaylist {
            showPlaylist = false
            displayPlaylist(withAnimate: false)
        }
        
        WindowManager.share.showMainWindow()
    }
    
    //MARK: 播放暂停
    @objc func playButtonclick() {
        if PlayerManager.share.isPlaying == true {
            PlayerManager.share.pause()
        } else {
            PlayerManager.share.play(withIndex: nil)
        }
    }
    
    //MARK: 下一曲
    @objc func nextClick() {
        PlayerManager.share.next()
    }
    
    //MARK: 上一曲
    @objc func previousClick() {
        PlayerManager.share.previous()
    }
    
    //MARK: 音量
    @IBAction func volumeButtonCLick(_ sender: Any) {
        if volumePopover.isShown {
            volumePopover.close()
        } else {
            volumePopover.show(relativeTo: volumeButton.bounds, of: volumeButton, preferredEdge: .minY)
        }
    }
    
    @IBAction func playlistButtonCLick(_ sender: Any) {
        showPlaylist = !showPlaylist
        displayPlaylist(withAnimate: true)
    }
}
