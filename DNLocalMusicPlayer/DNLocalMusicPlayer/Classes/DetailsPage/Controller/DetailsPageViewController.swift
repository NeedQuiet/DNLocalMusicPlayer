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
private let rowHeight:CGFloat = 35 // 行高
private let titleColumnDefaultWidth:CGFloat = 300 // 歌名列默认宽度
private let artistColumnDefaultWidth:CGFloat = 200 // 歌手列默认宽度
private let albumColumnDefaultWidth:CGFloat = 200 // 专辑列默认宽度
private let timeColumnDefaultWidth:CGFloat = 100 // 时长列默认宽度
private let kTableHedaerHeight:CGFloat = 30 // tableView的Header高度
private let kViewHeaderHeight:CGFloat = 280 // 页面的Header高度
private let kViewHeaderMarginTop:CGFloat = 20 // 页面的Header MarginTop
private let kViewHeaderMarginTLeft:CGFloat = 30 // 页面的Header MarginLeft
private let kViewFooterHeight:CGFloat = 30 // 页面Footer高度
private let kDefaultBackColor = NSColor(r: 28, g: 28, b: 28)

class DetailsPageViewController: BaseViewController {
    
    @objc dynamic var songs: [Song] = []
    private var playlist:Playlist = Playlist()
    //MARK: 主体scrollview
    //用来控制整个视图滚动
    private lazy var mainScrollView: DNFippedScrollView = { [unowned self] in
        let scrollView = DNFippedScrollView()
        scrollView.hasVerticalScroller = true
        return scrollView
    }()
    //MARK: 主体scrollview的内容View
    //用来添加子视图
    var mainScrollContentView = DNFippedView()
    
    //MARK: tableView
    private lazy var tableView: NSTableView = { [unowned self] in
        let tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = kDefaultBackColor
        tableView.doubleAction = #selector(tableViewDoubleClick(_:)) // 双击
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.allowsColumnReordering = false // 禁止header拖动排序
        tableView.allowsColumnResizing = false
        // 设置默认行高
        tableView.rowSizeStyle = .custom
        tableView.rowHeight = rowHeight
        return tableView
    }()
    
    //MARK: TableView`s Back ScrollView
    //用来装载tableView的ScrollView
    private lazy var tableBackScrollView: FippedTableBackScrollView = { [unowned self] in
        let scrollView = FippedTableBackScrollView()
        scrollView.superScrollView = self.mainScrollView
        return scrollView
    }()
    
    //MARK: 页面Header
    private lazy var viewHeader:DetailsViewHeaderView = {
        let viewHeader = DetailsViewHeaderView.initialization()
        mainScrollContentView.addSubview(viewHeader)
        viewHeader.setupUI()
        return viewHeader
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKVO()
        setupUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        mainScrollView.frame = view.bounds
    }
}

//MARK: - UI设置
extension DetailsPageViewController {
    //MARK: 设置UI
    func setupUI() {
        setBackgroundColor(r: 37, g: 37, b: 37)
        
        // scrollview
        view.addSubview(mainScrollView)
        
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

        mainScrollContentView.setBackgroundColor(color: kDefaultBackColor)
        
        // 1.将 tableView 设置为 tableBackScrollView 的 document
        tableBackScrollView.contentView.documentView = tableView
        // 2.将 tableBackScrollView 添加到 mainScrollContentView
        mainScrollContentView.addSubview(tableBackScrollView)
        // 3.将 mainScrollContentView 设置为 mainScrollView 的 document
        mainScrollView.contentView.documentView = mainScrollContentView
        
        //MARK: tableView Header
        let TableHeaderView = NSTableHeaderView()
        TableHeaderView.frame.size.height = kTableHedaerHeight
        tableView.headerView = TableHeaderView
    }

    //MARK: 添加右键菜单
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
                    self.refreshViewHeader()
                    
                    // 设置tableView及背景的frame
                    if self.songs.count > 0 { // 有歌曲
                        let viewSize = self.view.bounds.size
                        let tableSize = self.tableView.bounds.size
                        // 设置 tableView 的 frame
                        self.tableView.frame = CGRect(x: 0, y: 0, width: tableSize.width, height: tableSize.height + kTableHedaerHeight)
                        // 设置 mainScrollContentView 的 frame
                        let frame = NSRect(x: 0, y: 0, width: viewSize.width, height: tableSize.height + kViewHeaderHeight + kTableHedaerHeight + kViewFooterHeight)
                        self.mainScrollContentView.frame = frame
                        // 设置 tableBackScrollView 的 frame
                        self.tableBackScrollView.frame = CGRect(x: 0, y: kViewHeaderHeight, width: tableSize.width, height: tableSize.height + kTableHedaerHeight)
                        // 设置 HeaderView 的 frame
                        self.viewHeader.frame = CGRect(x: kViewHeaderMarginTLeft, y: kViewHeaderMarginTop, width: viewSize.width - 2 * kViewHeaderMarginTLeft, height: kViewHeaderHeight - kViewHeaderMarginTop)
                    } else {
                         self.mainScrollContentView.frame = self.view.bounds
                    }
                }
            })
        
        // 监听窗口size变化
        _ = NotificationCenter.default.rx
            .notification(NSWindow.didResizeNotification, object: nil)
            .subscribe({ [unowned self] (event) in
                let viewBounds = self.view.bounds
                // 设置 scrollview 宽度
                self.mainScrollView.frame = viewBounds
                // 设置 mainScrollContentView 宽度
                self.mainScrollContentView.frame.size.width = viewBounds.width
                // 设置 tableView 宽度
                self.tableView.frame.size.width = viewBounds.width
                // 设置 tableBackScrollView 宽度
                self.tableBackScrollView.frame.size.width = viewBounds.width
                // 设置 HeaderView 的 frame
                self.viewHeader.frame = CGRect(x: kViewHeaderMarginTLeft, y: kViewHeaderMarginTop, width: viewBounds.width - 2 * kViewHeaderMarginTLeft, height: kViewHeaderHeight - kViewHeaderMarginTop)
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
    
    //MARK: 刷新Header
    private func refreshViewHeader() {
        if songs.count > 0 {
            if let imageData = songs.first!.artworkData {
                let image:NSImage = NSImage(named: "MiniPlayerLargeAlbumDefault")!
                viewHeader.artworkImageView.image = NSImage(data: imageData) ?? image
            }
        }
        
        viewHeader.playlistNameLabel.stringValue = playlist.name
        viewHeader.songNumLabel.stringValue = "歌曲数: \(songs.count)"
    }
}

extension DetailsPageViewController: NSTableViewDataSource {
    // MARK: 行高
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    // MARK: 行数
    func numberOfRows(in tableView: NSTableView) -> Int {
        return songs.count
    }

    // MARK: 设置每行容器视图
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRowView = DNTableRow()
        tableRowView.index = row
        return tableRowView
    }
}

extension DetailsPageViewController: NSTableViewDelegate {
    // MARK: 设置每个Item的容器
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
}

