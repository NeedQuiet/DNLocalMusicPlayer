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

private let kTitleColumnID = NSUserInterfaceItemIdentifier(rawValue: "kTitleColumnID")
private let kArtistColumnID = NSUserInterfaceItemIdentifier(rawValue: "kArtistColumnID")
private let kTimeColumnID = NSUserInterfaceItemIdentifier(rawValue: "kTimeColumnID")
private let rowHeight:CGFloat = 30 // 行高
private let kRowBorderWidth:CGFloat = 2 // 发现实际上row的高度会上下加1
private let titleColumnDefaultWidth:CGFloat = 190 // 歌名列默认宽度
private let artistColumnDefaultWidth:CGFloat = 110 // 歌手列默认宽度
private let timeColumnDefaultWidth:CGFloat = 90 // 时长列默认宽度
private let kDefaultBackColor = NSColor(r: 41, g: 41, b: 41)

class CurrentPlaylistViewController: BaseViewController {
    // title
    @IBOutlet weak var viewTitle: NSTextField!
    // 歌曲数量
    @IBOutlet weak var songsNum: NSTextField!
    // scrollView
    @IBOutlet weak var scrollView: NSScrollView!
    // tableView
    @IBOutlet weak var tableView: NSTableView!
    // 下划线
    @IBOutlet weak var lineView: NSView!
    // 当前歌单
    private var playlist:Playlist = Playlist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVO()
    }
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
        // 下划线
        lineView.setBackgroundColor(color: kLightColor)
        lineView.alphaValue = 0.2
        
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
        _ = PlayerManager.share.rx
            .observeWeakly(Playlist.self, "currentPlayingPlaylist")
            .subscribe {[unowned self] (event) in
                let currentPlaylist = PlayerManager.share.currentPlayingPlaylist
                self.songsNum.stringValue = "总\(currentPlaylist.songs.count)首"
                self.playlist = currentPlaylist
                self.tableView.reloadData()
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
            .subscribe { [unowned self] (change) in
                self.tableView.reloadData()
        }
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
            
            let textLabel = NSTextField()
            textLabel.isBezeled = false // 边框
            textLabel.isEditable = false
            textLabel.backgroundColor = NSColor.clear
            textLabel.cell?.usesSingleLineMode = true
            textLabel.lineBreakMode = .byTruncatingTail
            cellView!.addSubview(textLabel)
            
            // 此行歌曲
            let song = playlist.songs[row]
            // 根据cell ID 区分是row的哪一列
            switch tableColumn?.identifier {
            case kTitleColumnID: // 标题列
                textLabel.stringValue = song.title
                if isCurrentPlayingSong(song) {
                    textLabel.textColor = kRedHighlightColor
                } else {
                    textLabel.textColor = kDefaultColor
                }
            case kArtistColumnID: // 歌手列
                textLabel.stringValue = song.artist
                textLabel.textColor = kLightColor
            case kTimeColumnID: // 时长列
                textLabel.stringValue = song.totalTime
                textLabel.textColor = kLightestColor
            default:
                textLabel.stringValue = ""
            }
            
            // 标题列
            if tableColumn?.identifier ==  kTitleColumnID{
                // 如果是当前播放歌曲，前面展示播放状态
                if isCurrentPlayingSong(song) {
                    let playStateImageView = NSImageView()
                    let imageName = PlayerManager.share.isPlaying ? "yinliangda" : "yinliangxiao"
                    playStateImageView.image = NSImage(named: imageName)
                    cellView!.addSubview(playStateImageView)
                    // 播放状态imageView 约束
                    playStateImageView.snp.makeConstraints({ (make) in
                        make.left.equalTo(2.5)
                        make.centerY.equalTo(0)
                        make.width.height.equalTo(10)
                    })
                    // 歌曲名 约束
                    textLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(15)
                        make.right.equalTo(3)
                        make.centerY.equalTo(0)
                    }
                } else {
                    // 歌曲名 约束
                    textLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(15)
                        make.right.equalTo(3)
                        make.centerY.equalTo(0)
                    }
                }
            } else {
                textLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(3)
                    make.centerY.equalTo(0)
                }
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
}

