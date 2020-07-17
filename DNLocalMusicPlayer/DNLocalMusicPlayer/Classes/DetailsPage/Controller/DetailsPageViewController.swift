//
//  DetailsPageViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RealmSwift
import SnapKit

private let kTitleColumnID = NSUserInterfaceItemIdentifier(rawValue: "kTitleColumnID")
private let kArtistColumnID = NSUserInterfaceItemIdentifier(rawValue: "kArtistColumnID")
private let kAlbumColumnID = NSUserInterfaceItemIdentifier(rawValue: "kAlbumColumnID")
private let kTimeColumnID = NSUserInterfaceItemIdentifier(rawValue: "kTimeColumnID")
private let rowHeight:CGFloat = 35
private let titleColumnDefaultWidth:CGFloat = 300
private let artistColumnDefaultWidth:CGFloat = 200
private let albumColumnDefaultWidth:CGFloat = 200
private let timeColumnDefaultWidth:CGFloat = 100

class DetailsPageViewController: BaseViewController {
    
    @objc dynamic var songs: [Song] = []
    private var playlist:Playlist = Playlist()
    private lazy var scrollView: NSScrollView = { [unowned self] in
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        return scrollView
    }()
    private lazy var tableView: NSTableView = { [unowned self] in
        let tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = NSColor(r: 28, g: 28, b: 28)
        tableView.doubleAction = #selector(tableViewDoubleClick(_:)) // 双击
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.allowsColumnReordering = false // 禁止header拖动排序
        tableView.allowsColumnResizing = false
        // 设置默认行高
        tableView.rowSizeStyle = .custom
        tableView.rowHeight = rowHeight
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKVO()
        setupUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        scrollView.frame = view.bounds
//        tableView.frame = NSRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 300)
    }
}

//MARK: - UI设置
extension DetailsPageViewController {
    func setupUI() {
        setBackgroundColor(r: 37, g: 37, b: 37)
        
        // scrollview
        view.addSubview(scrollView)
        
        // tableView
        let titleColumn = NSTableColumn.init(identifier: kTitleColumnID)
        titleColumn.title = "音乐标题"
        titleColumn.headerToolTip = "歌曲名"
        titleColumn.resizingMask = .userResizingMask
        titleColumn.width = titleColumnDefaultWidth
        titleColumn.minWidth = 150
        let artistColumn = NSTableColumn.init(identifier: kArtistColumnID)
        artistColumn.title = "歌手"
        artistColumn.headerToolTip = "歌手"
        artistColumn.resizingMask = .userResizingMask
        artistColumn.width = artistColumnDefaultWidth
        artistColumn.minWidth = 120
        let albumColumn = NSTableColumn.init(identifier: kAlbumColumnID)
        albumColumn.title = "专辑"
        albumColumn.headerToolTip = "专辑"
        albumColumn.resizingMask = .userResizingMask
        albumColumn.width = albumColumnDefaultWidth
        albumColumn.minWidth = 120
        let timeColumn = NSTableColumn.init(identifier: kTimeColumnID)
        timeColumn.title = "时长"
        timeColumn.headerToolTip = "时长"
        timeColumn.resizingMask = .userResizingMask
        timeColumn.width = timeColumnDefaultWidth
        albumColumn.minWidth = 60
        tableView.addTableColumn(titleColumn)
        tableView.addTableColumn(artistColumn)
        tableView.addTableColumn(albumColumn)
        tableView.addTableColumn(timeColumn)
        
        scrollView.contentView.documentView = tableView
    }

    func addRightMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "播放", action: #selector(menuPlay), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "收藏", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "在Finder中显示", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "删除", action: nil, keyEquivalent: ""))
        tableView.menu = menu
    }
}

//MARK: - KVO
extension DetailsPageViewController {
    func setupKVO() {
        // PlaylistView 选中歌单
        _ = NotificationCenter.default.rx
            .notification(kSelectedPlaylistNotificationName, object: nil)
            .subscribe({ [unowned self] (event) in
                if let object = event.element?.object as? [String : Playlist] {
                    self.songs.removeAll()
                    if let currentPlayingPlaylist = object["playlist"] {
                        self.playlist = currentPlayingPlaylist
                        let songs = currentPlayingPlaylist.songs
                        for song in songs {
                            self.songs.append(song)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        
        // 监听窗口size变化
        _ = NotificationCenter.default.rx
            .notification(NSWindow.didResizeNotification, object: nil)
            .subscribe({ [unowned self] (event) in
                // 改变scrollview宽度
                self.scrollView.frame = self.view.bounds
                // 改变column宽度
                let scale:CGFloat = self.view.bounds.width / 800
                for tableCoulumn in self.tableView.tableColumns {
                    let defaultWidth:CGFloat
                    switch tableCoulumn.identifier {
                    case kTitleColumnID:
                        defaultWidth = titleColumnDefaultWidth
                    case kArtistColumnID:
                        defaultWidth = artistColumnDefaultWidth
                    case kAlbumColumnID:
                        defaultWidth = albumColumnDefaultWidth
                    case kTimeColumnID:
                        defaultWidth = timeColumnDefaultWidth
                    default:
                        defaultWidth = titleColumnDefaultWidth
                    }
                    tableCoulumn.width = defaultWidth * scale
                }
            })
    }
}

//MARK: - Private
extension DetailsPageViewController {
    //MARK: tableView双击
    @objc private func tableViewDoubleClick(_ sender:AnyObject) {
        // 如果当前正在播放的歌单，不是当前展示的歌单，那么在选中歌曲后，应当将当给 currentPlayingPlaylist 赋值为 currentShowPlaylist
        if PlayerManager.share.currentShowPlaylist != PlayerManager.share.currentPlayingPlaylist {
            PlayerManager.share.currentPlayingPlaylist = PlayerManager.share.currentShowPlaylist
        }
        let clickedRow = tableView.clickedRow
        playSong(withIndex: clickedRow)
    }
    
    //MARK: Menu - 播放
    @objc private func menuPlay() {
        let clickedRow = tableView.clickedRow
        playSong(withIndex: clickedRow)
    }
    
    //MARK: 播放歌曲
    private func playSong(withIndex index:Int) {
        if index != -1 {
            PlayerManager.share.play(withIndex: index)
        }
    }
}

extension DetailsPageViewController: NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cellId"), owner: self)
        if cellView == nil {
            cellView = NSView.init()
            let textField = NSTextField()
            textField.isBezeled = false
            textField.isEditable = false
            textField.backgroundColor = NSColor.clear
            textField.cell?.usesSingleLineMode = true
            textField.lineBreakMode = .byTruncatingTail
            cellView!.addSubview(textField)
            
            switch tableColumn?.identifier {
            case kTitleColumnID:
                textField.stringValue = songs[row].title
            case kArtistColumnID:
                textField.stringValue = songs[row].artist
            case kAlbumColumnID:
                textField.stringValue = songs[row].album
            case kTimeColumnID:
                textField.stringValue = songs[row].totalTime
            default:
                textField.stringValue = ""
            }
            
            textField.snp.makeConstraints { (make) in
                make.left.right.equalTo(3)
                make.top.bottom.equalTo(10)
            }
            
        }
        return cellView
    }
    
    
    //设置每行容器视图
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRowView = DNTableRow()
        tableRowView.index = row
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalTo(0)
//            make.height.equalTo(1)
//        }
        return tableRowView
    }
}

extension DetailsPageViewController: NSTableViewDelegate {
   //设置鼠标悬停在cell上显示的提示文本(没有效果呢？)
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        print("columnID： \(String(describing: tableColumn?.identifier) )")
        return "ttttt"
    }
}
