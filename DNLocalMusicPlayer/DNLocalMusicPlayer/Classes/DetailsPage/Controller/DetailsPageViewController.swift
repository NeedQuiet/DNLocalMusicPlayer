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
private let rowHeight:CGFloat = 30 // 行高
private let kRowBorderWidth:CGFloat = 2 // 发现实际上row的高度会上下加1
private let titleColumnDefaultWidth:CGFloat = 300 // 歌名列默认宽度
private let artistColumnDefaultWidth:CGFloat = 200 // 歌手列默认宽度
private let albumColumnDefaultWidth:CGFloat = 200 // 专辑列默认宽度
private let timeColumnDefaultWidth:CGFloat = 100 // 时长列默认宽度
private let kTableHedaerHeight:CGFloat = 35 // tableView的Header高度
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
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.verticalScroller = DNScroller()
//        scrollView.verticalScroller?.setBorder(0, NSColor.clear)
//        scrollView.scrollerStyle = .overlay
        return scrollView
    }()
    //MARK: 主体scrollview的内容View
    //用来添加子视图
    var mainScrollContentView = DNFippedView()
    
    //MARK: tableView
    private lazy var tableView: DNTableView = { [unowned self] in
        let tableView = DNTableView()
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
        tableView.registerForDraggedTypes([kDrapInPasteboardType, kDrapSortPasteboardType])
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
        viewHeader.snp.makeConstraints { (make) in
            make.left.equalTo(mainScrollContentView.snp.left).offset(kViewHeaderMarginTLeft)
            make.right.equalTo(mainScrollContentView.snp.right).offset(kViewHeaderMarginTLeft)
            make.top.equalTo(mainScrollContentView.snp.top).offset(kViewHeaderMarginTop)
            make.height.equalTo(kViewHeaderHeight - kViewHeaderMarginTop)
        }
        viewHeader.setupUI()
        return viewHeader
    }()
    
    //MARK: 无歌曲提示View
    private lazy var noSongsView:DetailsNoSongsNoteView = {
        let view = DetailsNoSongsNoteView.initialization()
        mainScrollContentView.addSubview(view)
        return view
    }()
    
    //MARK: 搜索数组
    private var searchResultSongs:[Song] = []
    private var searchKey:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKVOAndNotification()
        setupUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        mainScrollView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
    }
    
    deinit {
        print("[PlayerManager] deinit!")
    }
}

//MARK: - UI设置
extension DetailsPageViewController {
    //MARK: 设置UI
    func setupUI() {
        setBackgroundColor(r: 37, g: 37, b: 37)
        addRightMenu()

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
        artistColumn.minWidth = 110
        let albumColumn = NSTableColumn.init(identifier: kAlbumColumnID)
        albumColumn.title = "专辑"
        albumColumn.headerToolTip = "专辑"
        albumColumn.resizingMask = .userResizingMask
        albumColumn.width = albumColumnDefaultWidth
        albumColumn.minWidth = 110
        let timeColumn = NSTableColumn.init(identifier: kTimeColumnID)
        timeColumn.title = "时长"
        timeColumn.headerToolTip = "时长"
        timeColumn.resizingMask = .userResizingMask
        timeColumn.width = timeColumnDefaultWidth
        timeColumn.minWidth = 80
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
        _ = self.tableView.tableColumns.map { (tableColumn) in
            let columnTitle = tableColumn.headerCell.stringValue
            let myCell = DetailsTableHeaderCell.init(textCell: columnTitle)
            tableColumn.headerCell = myCell
        }
        
        //MARK: View Header
        viewHeader.delegate = self
        
        noSongsView.isHidden = true
        tableBackScrollView.isHidden = true
        viewHeader.isHidden = true
    }

    //MARK: 添加右键菜单
    func addRightMenu() {
        let menu = NSMenu()
        menu.delegate = self
        tableView.menu = menu
    }
}

//MARK: - KVO & Notification
extension DetailsPageViewController {
    func setupKVOAndNotification() {
        //MARK: PlaylistView 选中歌单
        _ = NotificationCenter.default.rx
            .notification(kSelectedPlaylistNotification, object: nil)
            .subscribe({[unowned self] (event) in
                if let object = event.element?.object as? [String : Playlist] {
                    self.songs.removeAll()
                    self.searchResultSongs.removeAll()
                    if let currentShowPlaylist = object["playlist"] {
                        self.playlist = currentShowPlaylist
                        let songs = currentShowPlaylist.songs
                        for song in songs {
                            self.songs.append(song)
                        }
                    }
                    self.refreshUI()
                    self.mainScrollView.scrollToTop()
                }
            })
        
        //MARK: 监听窗口size变化
        _ = NotificationCenter.default.rx
            .notification(NSWindow.didResizeNotification, object: nil)
            .subscribe({[unowned self] (event) in
                // 此时Details页的尺寸
                let viewBounds = self.view.bounds
                // 设置 tableView 的 size
                self.tableView.frame.size.width = viewBounds.width
                var tableSize = NSSize(width: viewBounds.width, height:kTableHedaerHeight +  CGFloat(self.getSongsOnDisplay().count) * (rowHeight + kRowBorderWidth) + kViewFooterHeight)
                let tableViewMinHeight = viewBounds.height - kViewHeaderHeight
                if tableSize.height < tableViewMinHeight {
                    tableSize.height = tableViewMinHeight
                    self.tableView.frame.size.height = tableViewMinHeight
                }
                // 设置 tableBackScrollView 的 size
                self.tableBackScrollView.frame.size = NSSize(width: viewBounds.width, height: tableSize.height)
                // 设置 mainScrollContentView 的 size
                self.mainScrollContentView.frame.size = NSSize(width: viewBounds.width, height: kViewHeaderHeight + tableSize.height)
                
                // 无歌曲提示页frame
                if self.songs.count == 0 {
                    self.noSongsView.frame.size.width = viewBounds.width
                }
                
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
    
    //MARK: 播放歌曲
    private func playSong(withIndex index:Int) {
        if index != -1 {
            PlayerManager.share.play(withIndex: index)
        }
    }
    
    //MARK: 刷新UI
    private func refreshUI() {
        self.tableView.reloadData()
        self.refreshViewHeader()
        self.refreshNoSongsView()
        self.refreshDetailsView()
    }
    
    //MARK: 根据playlist刷新页面
    private func refreshDataSource(_ newPlaylist:Playlist){
        DispatchQueue.main.async {
            self.songs.removeAll()
            self.searchResultSongs.removeAll()
            self.playlist = newPlaylist
            let songs = newPlaylist.songs
            for song in songs {
                self.songs.append(song)
            }
            self.refreshUI()
        }
    }
    
    //MARK: 刷新Header
    private func refreshViewHeader() {
        // HeaderView
        let image:NSImage = NSImage(named: "default_artwork_image")!
        if let imageData = songs.first?.artworkData {
            viewHeader.artworkImageView.image = NSImage(data: imageData) ?? image
        } else {
            viewHeader.artworkImageView.image = image
        }
        
        viewHeader.playlistNameLabel.stringValue = playlist.name
        viewHeader.songNumLabel.stringValue = "\(songs.count)"
        viewHeader.createTimeLabel.stringValue = "\(playlist.creatTime)创建"
        viewHeader.createTimeLabel.isHidden = !playlist.isCustomPlaylist
        viewHeader.playAllButton.isEnabled = songs.count > 0
        viewHeader.addMusicButton.isEnabled = playlist.isCustomPlaylist
        viewHeader.renameButton.isHidden = !playlist.isCustomPlaylist
        
       
    }
    
    //MARK: 刷新NoSongsView
    private func refreshNoSongsView() {
        // NoSongsView
        if songs.count == 0 {
            if playlist.isCustomPlaylist == false {
                noSongsView.noteTitle.stringValue = "你的iTunes没有音乐"
                noSongsView.noteBody.stringValue = "看来你平时从来不用iTunes听音乐 o(*￣︶￣*)o"
            } else {
                noSongsView.noteTitle.stringValue = "赶快去收藏你喜欢的音乐"
                noSongsView.noteBody.stringValue = "点击“添加音乐”按钮，选择你喜欢的音乐，将音乐加入歌单！"
            }
        } else {
            // 歌曲数量大于0，则判读搜索歌曲
            if searchKey.count > 0 && searchResultSongs.count == 0 {
                noSongsView.noteTitle.stringValue = ""
                noSongsView.noteBody.stringValue = "未能找到 `\(searchKey)` 相关的歌曲"
            }
        }
    }
    
    
    //MARK: 刷新内容view，判断tableView | noSongView的frame
    private func refreshDetailsView() {
        // 设置tableView及背景的frame
        let viewSize = view.bounds.size
        viewHeader.isHidden = false
        let isSearchNoSong = songs.count > 0 && searchKey.count > 0 && searchResultSongs.count == 0
        if songs.count == 0 || isSearchNoSong{ // 无歌曲 或者 无搜索结果
            self.mainScrollContentView.frame = self.view.bounds
            self.tableBackScrollView.isHidden = true
            // 无歌曲提示
            self.noSongsView.isHidden = false
            self.noSongsView.frame = CGRect(x: 0, y: kViewHeaderHeight, width: viewSize.width , height: viewSize.height - kViewHeaderHeight)
        } else { // 有歌曲
            noSongsView.isHidden = true
            tableBackScrollView.isHidden = false
            var tableSize = NSSize(width: view.bounds.width, height:kTableHedaerHeight + CGFloat(getSongsOnDisplay().count) * (rowHeight + kRowBorderWidth) + kViewFooterHeight)
            let tableViewMinHeight = viewSize.height - kViewHeaderHeight
            if tableSize.height < tableViewMinHeight {
                tableSize.height = tableViewMinHeight
            }
            
            // 设置 tableView 的 frame
            tableView.frame = CGRect(x: 0, y: 0, width: tableSize.width, height: tableSize.height)
            // 设置 tableBackScrollView 的 frame
            tableBackScrollView.frame = CGRect(x: 0, y: kViewHeaderHeight, width: tableSize.width, height: tableSize.height)
            // 设置 mainScrollContentView 的 frame
            let frame = NSRect(x: 0, y: 0, width: viewSize.width, height: kViewHeaderHeight + tableBackScrollView.frame.height)
            mainScrollContentView.frame = frame
        }
    }
    
    //MARK: 检测是否为当前播放的歌曲
    private func isCurrentPlayingSong(_ song:Song) -> Bool {
        if playlist == PlayerManager.share.currentPlayingPlaylist {
            if song.filePath == PlayerManager.share.currentSong?.filePath {
                return true
            }
        }
        return false
    }
    
    //MARK: ****************** Menu ******************
    //MARK: 播放
    @objc private func menuPlay() {
        if PlayerManager.share.currentShowPlaylist != PlayerManager.share.currentPlayingPlaylist {
            PlayerManager.share.currentPlayingPlaylist = PlayerManager.share.currentShowPlaylist
        }
        let clickedRow = tableView.clickedRow
        let selectedSong:Song
        
        if searchResultSongs.count > 0 {
            selectedSong = searchResultSongs[clickedRow]
        } else {
            selectedSong = songs[clickedRow]
        }
        
        if clickedRow != -1 {
            PlayerManager.share.play(withSong: selectedSong)
        }
    }
    
    //MARK: Show in finder
    @objc private func showInFinder() {
        let clickedRow = tableView.clickedRow
        let song = getSongsOnDisplay()[clickedRow]
        let filePath = song.filePath
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: filePath)])
    }
    
    //MARK: 删除歌曲
    @objc private func removeSong() {
        let clickedRow = tableView.clickedRow
        let song = getSongsOnDisplay()[clickedRow]
        SongManager.share.removeSongFrom(playlist, song) {[unowned self] (success) in
            self.refreshDataSource(self.playlist)
        }
    }
    
    //MARK: 根据拖拽的数据返回坐标
    func getIndexWithDropInfo(_ info:NSDraggingInfo) -> Int? {
        if let rowData = info.draggingPasteboard.data(forType: kDrapSortPasteboardType){
            if let rowIndexes:NSIndexSet = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rowData) as? NSIndexSet {
                return rowIndexes.firstIndex
            }
        }
        return nil
    }
    
    //MARK: 获取本页需要展示的歌曲
    func getSongsOnDisplay() -> [Song] {
        return searchResultSongs.count > 0 ? searchResultSongs : songs
    }
}

//MARK: - NSTableViewDataSource & NSTableViewDelegate
extension DetailsPageViewController: NSTableViewDataSource {
    // MARK: 行高
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    // MARK: 行数
    func numberOfRows(in tableView: NSTableView) -> Int {
        return getSongsOnDisplay().count
    }

    // MARK: 设置每行容器视图
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRowView = DetailsTableRow()
//        tableView.draggingDestinationFeedbackStyle = .none
        let song = getSongsOnDisplay()[row]
        if isCurrentPlayingSong(song) {
            tableRowView.isSelectedRow = true
        } else {
            tableRowView.isSelectedRow = false
        }
        tableRowView.index = row
        tableRowView.focusRingType = .none
        return tableRowView
    }
}

extension DetailsPageViewController: NSTableViewDelegate {
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
            let song = getSongsOnDisplay()[row]
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
            case kAlbumColumnID: // 专辑列
                textLabel.stringValue = song.album
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
                        make.left.equalTo(29)
                        make.centerY.equalTo(0)
                        make.width.height.equalTo(16)
                    })
                    // 歌曲名 约束
                    textLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(playStateImageView.snp.right).offset(15)
                        make.right.equalTo(3)
                        make.centerY.equalTo(0)
                    }
                } else {
                    // 如果不是，前面展示index
                    let indexRowLabel = NSTextField()
                    indexRowLabel.isBezeled = false
                    indexRowLabel.isEditable = false
                    indexRowLabel.backgroundColor = NSColor.clear
                    indexRowLabel.alignment = .right
                    indexRowLabel.textColor = kLightColor
                    indexRowLabel.stringValue = String(format: "%02d", row + 1)
                    cellView!.addSubview(indexRowLabel)
                    // index 约束
                    indexRowLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(0)
                        make.centerY.equalTo(0)
                        make.width.equalTo(45)
                    }
                    // 歌曲名 约束
                    textLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(indexRowLabel.snp.right).offset(15)
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

//MARK: - 拖拽
extension DetailsPageViewController {
    //设置响应，建立属性面板
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        if playlist.isCustomPlaylist == false || searchResultSongs.count > 0{
            return false
        }
        
        let indexSetData = try? NSKeyedArchiver.archivedData(withRootObject: rowIndexes, requiringSecureCoding: false)
        pboard.declareTypes([kDrapSortPasteboardType], owner: self)
        pboard.setData(indexSetData, forType: kDrapSortPasteboardType)
        
//        // 可以将拖拽歌曲的信息暂存，如果需使用可以用pboard.string(forType: kDrapSortPasteboardType)来取
//        if let row = rowIndexes.first {
//            let song = songs[row]
//            pboard.setString(song.filePath, forType: kDrapSortPasteboardType)
//        }
        
        return true
    }
    // 响应处理：替换数据（文件拖入时，列表的状态和鼠标的变化）
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if playlist.isCustomPlaylist == false || searchResultSongs.count > 0{
            return NSDragOperation.init(rawValue: 0)
        }
        
        if dropOperation == .above {
            if getIndexWithDropInfo(info) != nil{
                // 内部拖拽排序
                return .move
            } else {
                // 从外部拖入的文件
                if let pathArray = Utility.getPathArrayByFilenamesType(info) { // 根据 validateDropInfo 获取 拖入文件的路径数组
                    let supportFormat = allowedFileTypes // 根据文件格式判断是否允许拖入
                    for path in pathArray { // 遍历文件
                        let url = URL(fileURLWithPath: path)
                        if supportFormat.contains(url.pathExtension) {
                            return .copy // 如果符合格式就copy
                        }
                    }
                }
            }
        }
        return NSDragOperation.init(rawValue: 0) // 什么都不执行
    }
    
    // 结束拖拽：UI效果上是否允许拖入，false 文件就自动飘回去，true 文件松手就在列表上消失
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if let dragRow = getIndexWithDropInfo(info) {
            // 内部拖拽排序
            if dragRow == row || dragRow == row - 1 {
                return false
            } else {
                SongManager.share.dragSongWith(playlist, dragRow, row) {[unowned self] (result) in
                    self.refreshDataSource(self.playlist)
                    if self.playlist == PlayerManager.share.currentPlayingPlaylist {
                        NotificationCenter.default.post(name: kRefreshCurrentPlaylistView, object: nil)
                    }
                }
                return true
            }
        } else {
            // 从外部拖入的文件
            if let pathArray = Utility.getPathArrayByFilenamesType(info) {
                let songs = List<Song>()
                for path in pathArray {
                    let song:Song = Utility.getSongFromMusicFile(path)
                    songs.append(song)
                }
                SongManager.share.addSongsTo(playlist, songs, index: row) { (success) in
                    self.refreshDataSource(self.playlist)
                }
                return true
            }
        }
        return false
    }
}

//MARK: - DetailsViewHeaderViewDelegate
extension DetailsPageViewController: DetailsViewHeaderViewDelegate {
    //MARK: 播放全部点击
    func playAll() {
        PlayerManager.share.currentPlayingPlaylist = playlist
        PlayerManager.share.play(withIndex: 0)
    }
    
    //MARK: 添加歌曲点击
    func addSong() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true //是否允许多选file
        openPanel.canChooseDirectories = false //是否能打开文件夹
        openPanel.canCreateDirectories = false // 能不能创建文件夹
        openPanel.canChooseFiles = true //是否能选择文件file
        openPanel.allowedFileTypes = allowedFileTypes
//        openPanel.title = "选择歌曲或文件夹"
        openPanel.beginSheetModal(for:self.view.window!) { (response) in
            if response == .OK {
                let songs = List<Song>()
                for url in openPanel.urls {
                    let song = Utility.getSongFromMusicFile(url.path)
                    songs.append(song)
                }
                
                if songs.count > 0 {
                    SongManager.share.addSongsTo(self.playlist, songs) {[unowned self] (success) in
                        self.refreshDataSource(self.playlist)
                    }
                }
            }
            openPanel.close()
        }
    }
    
    //MARK: 重命名歌单
    func renamePlaylist() {
        let alertView = DNAlertView.initialization()
        alertView.setInfo(title: "重命名歌单", placeholderString: "请输入歌单标题", type: .textFieldType)
        alertView.submitButton.title = "确认"
        alertView.defaultString = playlist.name
        alertView.show(target: self) { [unowned self] (string) in
            // 此刻的item_playlist是浅copy，因此在realm那更新后，item_playlist的name也会改变
            SongManager.share.renamePlaylist(self.playlist, string)
            self.refreshViewHeader()
            self.refreshNoSongsView()
            NotificationCenter.default.post(name: kRefreshPlaylistView, object: nil)
        }
    }
    
    //MARK: 搜索
    func controlTextDidChange(_ stringValue:String) {
        let pSearch = NSPredicate(format: "self.title contains[c] %@ || self.artist contains[c] %@ || self.album contains[c] %@ ",stringValue,stringValue,stringValue)
        searchResultSongs = songs.filter { (song) -> Bool in
            return pSearch.evaluate(with: song)
        }
        
        searchKey = stringValue
        tableView.reloadData()
        refreshUI()
    }
    
    //MARK: 清空搜索
    func clearSearchField() {
        //TODO: 隐藏 无搜索结果 提示页
        searchKey = ""
        searchResultSongs.removeAll()
        tableView.reloadData()
        refreshUI()
    }
}

//MARK: - NSMenuDelegate
extension DetailsPageViewController: NSMenuDelegate{
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        if playlist.isCustomPlaylist == true {
            menu.addItem(NSMenuItem(title: "播放", action: #selector(menuPlay), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "收藏", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "在Finder中显示", action: #selector(showInFinder), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "删除", action: #selector(removeSong), keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "播放", action: #selector(menuPlay), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "在Finder中显示", action: #selector(showInFinder), keyEquivalent: ""))
        }
    }
}
