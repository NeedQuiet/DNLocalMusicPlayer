//
//  CurrentPlaylistViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RealmSwift
import SnapKit

private let kDefaultColumnID = NSUserInterfaceItemIdentifier(rawValue: "kDefaultColumnID")
private let rowHeight:CGFloat = 60 // 行高
private let kRowBorderWidth:CGFloat = 2 // 发现实际上row的高度会上下加1
private let kDefaultBackColor = NSColor(r: 24, g: 24, b: 24)

class CurrentPlaylistViewController: BaseViewController {
    // title
    @IBOutlet weak var viewTitle: NSTextField!
    // 歌曲数量
    @IBOutlet weak var songsNum: NSTextField!
    // scrollView
    @IBOutlet weak var scrollView: NSScrollView!
    // tableView
    @IBOutlet weak var tableView: NSTableView!
    // 当前歌单
    private var playlist:Playlist = Playlist()
    
    var area:NSTrackingArea!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVO()
    }
    
    deinit {
        self.view.removeTrackingArea(area)
    }
}

//MARK - 鼠标跟踪
extension CurrentPlaylistViewController {
    override func viewDidLayout() {
        super.viewDidLayout()
        if area != nil { self.view.removeTrackingArea(area) }
        area = NSTrackingArea.init(rect: NSRect.zero, options:[.inVisibleRect, .activeInKeyWindow, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.view.addTrackingArea(area)
    }
    
    override func mouseDown(with event: NSEvent) {}
    override func rightMouseDown(with event: NSEvent) {}
    
    //TODO: 目前拦截不掉底部detailsTableView，以后想办法处理
    override func mouseEntered(with event: NSEvent) {}
    override func mouseExited(with event: NSEvent) {}
}

//MARK: - UI配置相关
extension CurrentPlaylistViewController {
    //MARK: UI设置
    func setupUI() {
        setBackgroundColor(kDefaultBackColor)
        // title
        viewTitle.textColor = kWhiteHighlightColor
        // 歌曲数量
        songsNum.textColor = kLightColor

        // tableView
        tableView.enclosingScrollView?.borderType = .noBorder // 边框
        tableView.backgroundColor = kDefaultBackColor
        tableView.doubleAction = #selector(tableViewDoubleClick(_:)) // 双击

        // scrollView
        scrollView.verticalScroller = DNScroller()
    }
}

//MARK: - KVO & Notification
extension CurrentPlaylistViewController {
    //MARK: PlaylistView 选中歌单
    func setupKVO() {
        //MARK: currentPlayingPlaylist
        _ = PlayerManager.share.rx
            .observeWeakly(Playlist.self, "currentPlayingPlaylist")
            .subscribe {[unowned self] (event) in
                self.refreshUIWithCurrentPlayingPlaylist()
        }
        
        //MARK: currentSong
        _ = PlayerManager.share.rx.observeWeakly(Song.self, "currentSong")
            .subscribe({[unowned self] (change) in
                if (change.element != nil) {
                    self.tableView.reloadData()
                }
        })
        
        //MARK: isPlaying
        _ = PlayerManager.share.rx.observeWeakly(Bool.self, "isPlaying")
            .subscribe {[unowned self] (change) in
                self.tableView.reloadData()
        }
        
        //MARK: kRefreshCurrentPlaylistView
        _ = NotificationCenter.default.rx
            .notification(kRefreshCurrentPlaylistView)
            .subscribe({[unowned self] (event) in
                self.refreshUIWithCurrentPlayingPlaylist()
        })
    }
}

//MARK: - NSTableViewDataSource & NSTableViewDelegate
extension CurrentPlaylistViewController: NSTableViewDataSource {
    // MARK: 行高
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    // MARK: 行数
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.songs.count
    }

    // MARK: 设置每行容器视图
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRowView = CurrentPLTableRow()
        tableRowView.singleRowColor = NSColor.clear
        tableRowView.doubleRowColor = NSColor.clear
        tableRowView.selectedRowColor = NSColor.clear
        tableRowView.hoverRowColor = NSColor(r: 39, g: 39, b: 41)
        
        let song = playlist.songs[row]
        if isCurrentPlayingSong(song) {
            tableRowView.isSelectedRow = true
        } else {
            tableRowView.isSelectedRow = false
        }
        tableRowView.index = row
        return tableRowView
    }
}

extension CurrentPlaylistViewController: NSTableViewDelegate {
    // MARK: 设置每个Item的容器
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cellId"), owner: self)
        if cellView == nil {
            cellView = NSView.init()
            // 此行歌曲
            let song = playlist.songs[row]
            
            // 专辑图
            let imageView = NSImageView()
            var image:NSImage = NSImage(named: "default_artwork_image")!
            if let imageData = song.artworkData {
                image = NSImage(data: imageData) ?? image
            }
            imageView.image = image
            cellView!.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.centerY.equalTo(0)
                make.left.equalTo(15)
                make.width.height.equalTo(40)
            }
            
            // 歌曲名
            let textLabel = DNLabel()
            textLabel.stringValue = song.title
            cellView!.addSubview(textLabel)
            textLabel.snp.makeConstraints { (make) in
                make.left.equalTo(imageView.snp.right).offset(10)
                make.right.equalTo(-15)
                make.top.equalTo(10)
            }
            
            // 歌手
            let AritstLabel = DNLabel()
            AritstLabel.stringValue = song.artist
            cellView!.addSubview(AritstLabel)
            AritstLabel.snp.makeConstraints { (make) in
                make.left.equalTo(imageView.snp.right).offset(10)
                make.bottom.equalTo(-10)
            }
            
            // 时间
            let timeLabel = DNLabel()
            timeLabel.stringValue = song.totalTime
            cellView!.addSubview(timeLabel)
            timeLabel.snp.makeConstraints { (make) in
                make.left.equalTo(AritstLabel.snp.right).offset(10)
                make.centerY.equalTo(AritstLabel.snp.centerY).offset(0)
                make.right.equalTo(-15)
                make.width.equalTo(40)
            }
            
            // 左侧线
            let leftLine = NSView()
            leftLine.setBackgroundColor(color: kRedHighlightColor)
            cellView!.addSubview(leftLine)
            leftLine.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(0)
                make.width.equalTo(1)
            }
            
            // 底部线
            let bottomLine = NSView()
            bottomLine.setBackgroundColor(color: kLightColor)
            bottomLine.alphaValue = 0.1
            cellView!.addSubview(bottomLine)
            bottomLine.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.height.equalTo(1)
                make.bottom.equalTo(-1)
            }
            
            if isCurrentPlayingSong(song) {
                textLabel.textColor = kRedHighlightColor
                AritstLabel.textColor = kRedHighlightColor
                timeLabel.textColor = kRedHighlightColor
                leftLine.isHidden = false
            } else {
                textLabel.textColor = kDefaultColor
                AritstLabel.textColor = kDefaultColor
                timeLabel.textColor = kDefaultColor
                leftLine.isHidden = true
            }
 
        }
        return cellView
    }
}

//MARK: - Private
extension CurrentPlaylistViewController {
    //MARK: 检测是否为当前播放的歌曲
    private func isCurrentPlayingSong(_ song:Song) -> Bool {
        if playlist == PlayerManager.share.currentPlayingPlaylist {
            if song.filePath == PlayerManager.share.currentSong?.filePath {
                return true
            }
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

        // 如果当前正在播放的歌单，不是当前展示的歌单，那么在选中歌曲后，应当将当给 currentPlayingPlaylist 赋值为 currentShowPlaylist
        if PlayerManager.share.currentShowPlaylist != PlayerManager.share.currentPlayingPlaylist {
            PlayerManager.share.currentPlayingPlaylist = PlayerManager.share.currentShowPlaylist
        }
        PlayerManager.share.play(withIndex: clickedRow) // 播放clickedRow
    }
    
    func refreshUIWithCurrentPlayingPlaylist() {
        let currentPlaylist = PlayerManager.share.currentPlayingPlaylist
        self.songsNum.stringValue = "总\(currentPlaylist.songs.count)首"
        self.playlist = currentPlaylist
        self.tableView.reloadData()
    }
}

