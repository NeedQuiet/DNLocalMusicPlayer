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
    private lazy var volumePopover:NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = MiniVolumePopover.init()
        popover.behavior = .transient // 点击外部自动close popover
        return popover
    }()
    // 是否展示playlist
    var showPlaylist = false
    // scrollview
    private lazy var scrollView:DNFippedScrollView = {
        let scrollView = DNFippedScrollView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        return scrollView
    }()
    
    private lazy var tableView:NSTableView = { [unowned self] in
        let tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.allowsColumnReordering = false // 禁止header拖动排序
        tableView.allowsColumnResizing = false
        tableView.rowSizeStyle = .custom
        tableView.rowHeight = 30
        tableView.enclosingScrollView?.borderType = .noBorder // 边框
        tableView.headerView = nil
        tableView.backgroundColor = NSColor.init(r: 35, g: 35, b: 35)
        
        let titleColumn = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier(rawValue: "TitleColumnID"))
        titleColumn.resizingMask = .userResizingMask
        titleColumn.width = 300
        tableView.doubleAction = #selector(tableViewDoubleClick(_:)) // 双击
        tableView.target = self
        tableView.addTableColumn(titleColumn)
        
        return tableView
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
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(albumButton.snp.bottom).offset(8)
            make.height.equalTo(kWindowHeightOffset)
        }
        // tableView
        scrollView.contentView.documentView = tableView
        tableView.reloadData()
    }
    
    //MARK: 刷新UI
    func refreshUI(withSong currentSong:Song) {
        DispatchQueue.main.async { [unowned self] in
            var image:NSImage = NSImage(named: "MiniPlayerLargeAlbumDefault")!
            if let imageData = currentSong.artworkData {
                image = NSImage(data: imageData) ?? image
            }
            self.albumButton.image = image
            
            self.songNameLabel.stringValue = currentSong.title
            self.songArtistLabel.stringValue = "\(currentSong.artist) -- \(currentSong.album)"
        }
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
                    self.tableView.reloadData()
                }
        })
        
        //MARK: currentPlayingPlaylist
        _ = PlayerManager.share.rx
            .observeWeakly(Playlist.self, "currentPlayingPlaylist")
            .subscribe {[unowned self] (event) in
                self.tableView.reloadData()
        }
        
        //MARK: kRefreshCurrentPlaylistView
        _ = NotificationCenter.default.rx
            .notification(kRefreshCurrentPlaylistView)
            .subscribe({[unowned self] (event) in
                self.tableView.reloadData()
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

//MARK: - NSTableViewDelegate/NSTableViewDataSource
extension MiniViewController:NSTableViewDelegate,NSTableViewDataSource {
    // MARK: 行高
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    // MARK: 行数
    func numberOfRows(in tableView: NSTableView) -> Int {
        return PlayerManager.share.currentPlayingPlaylist.songs.count
    }
    
    // MARK: 设置每行容器视图
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRowView = CurrentPLTableRow()
        tableRowView.needActiveInKeyWindow = false

        let song = PlayerManager.share.currentPlayingPlaylist.songs[row]
        if isCurrentPlayingSong(song) {
            tableRowView.isSelectedRow = true
        } else {
            tableRowView.isSelectedRow = false
        }
        tableRowView.index = row
        return tableRowView
    }
    
    // MARK: 设置每个Item的容器
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?  {
        var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "miniCellID"), owner: self)
        if cellView == nil {
            cellView = NSView.init()

            let song = PlayerManager.share.currentPlayingPlaylist.songs[row]
            
            // 歌曲名
            let textLabel = DNLabel()
            textLabel.stringValue = song.title
            cellView!.addSubview(textLabel)
            textLabel.snp.makeConstraints { (make) in
                make.left.equalTo(10)
                make.right.equalTo(10)
                make.top.equalTo(7.5)
            }
            
            if isCurrentPlayingSong(song) {
                textLabel.textColor = kRedHighlightColor
            } else {
                textLabel.textColor = kDefaultColor
            }
        }
        return cellView
    }
}

//MARK: - private
extension MiniViewController {
    //MARK: 检测是否为当前播放的歌曲
    private func isCurrentPlayingSong(_ song:Song) -> Bool {
        if song.filePath == PlayerManager.share.currentSong?.filePath {
            return true
        }
        return false
    }
    
    //MARK: tableView双击
    @objc private func tableViewDoubleClick(_ sender:AnyObject) {
        let clickedRow = tableView.clickedRow
        
        if clickedRow == -1  {
            return // 此时可能点击tableview 空白处
        }
        
        // 如果重复点击，那就 播放/暂停
        if UserDefaultsManager.share.songSelectedIndex ==  clickedRow{
            if PlayerManager.share.isPlaying {
                PlayerManager.share.pause() // 暂停
            } else {
                PlayerManager.share.play(withIndex: nil) // 播放
            }
            return
        }

        PlayerManager.share.play(withIndex: clickedRow) // 播放clickedRow
    }
}
