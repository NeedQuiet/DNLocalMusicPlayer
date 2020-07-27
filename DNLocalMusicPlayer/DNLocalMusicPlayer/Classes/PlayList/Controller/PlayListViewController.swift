//
//  PlayListViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa
import RealmSwift
import SnapKit

private enum headerType {
    case item_iTunesPlaylist_type
    case item_CustomPlaylist_type
}

private let kHeaderCell = NSUserInterfaceItemIdentifier(rawValue: "kHeaderCell")
private let kItemCell = NSUserInterfaceItemIdentifier(rawValue: "kItemCell")
private let kHeaderHeight:CGFloat = 30
private let kCellHeight:CGFloat = 35

class PlayListViewController: BaseViewController{
    private var headers:[[String: Any]] = [["name":"我的音乐","type":headerType.item_iTunesPlaylist_type],
                                           ["name":"创建的歌单","type":headerType.item_CustomPlaylist_type]]

    @IBOutlet weak var outlineView: DNOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKVOAndNotifi()
    }
}

//MARK: - 设置UI
extension PlayListViewController {
    func setupUI() {
        setBackgroundColor(r: 24, g: 24, b: 24)
        outlineView.backgroundColor = NSColor.init(r: 24, g: 24, b: 24)
        outlineView.expandItem(nil, expandChildren: true) // 展开
        outlineView.enclosingScrollView?.borderType = .noBorder // 边框
        
        //MARK: 右键菜单按钮
        let menu = NSMenu()
        menu.delegate = self
        outlineView.menu = menu
    }
}

//MARK: - KVO & Notification
extension PlayListViewController {
    func setupKVOAndNotifi() {
        //MARK: itunesPlaylist
        _ = NotificationCenter.default.rx
            .notification(kFinishGetItunesSongs, object: nil)
            .subscribe({ (event) in
            self.outlineView.reloadData()
        })

        //MARK: custom_playlists
        _ = SongManager.share.rx
            .observeWeakly([Playlist].self, "playlists")
            .subscribe({ [unowned self] (change) in
                self.outlineView.reloadData()
        })
        
        //MARK: 改歌单名时刷新监听
        _ = NotificationCenter.default.rx
            .notification(kRefreshPlaylistView, object: nil)
            .subscribe({ (event) in
                self.outlineView.reloadData()
        })
        
        //MARK: 选中歌单
        _ = NotificationCenter.default.rx
            .notification(kSelectedPlaylistNotification, object: nil)
            .subscribe({[unowned self] (event) in
                self.outlineView.reloadData()
        })
        
        //MARK: isPlaying
        _ = PlayerManager.share.rx.observeWeakly(Bool.self, "isPlaying")
            .subscribe { [unowned self] (change) in
                self.outlineView.reloadData()
        }
    }
}

//MARK: - NSOutlineViewDataSource & NSOutlineViewDelegate
extension PlayListViewController: NSOutlineViewDataSource {
    //MARK: 根据特征分别返回header 和 data的数量
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return headers.count
        } else {
            if isItunesHeader(item: item) {
                return 1 // 如果item是iTunes，那么下面的子节点，只返回一个
            }
            return SongManager.share.playlists.count // 其余的按照playlists数量显示
        }
    }
    
    //MARK: 用来把数据分别传递给HeaderCell or DataCell
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return headers[index]
        } else {
            if isItunesHeader(item: item) {
                return SongManager.share.iTunesPlaylist
            }
            return SongManager.share.playlists[index]
        }
    }
    
    //MARK: 是否允许展开
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if isHeader(item: item) {
            return true
        } else {
            return false
        }
    }
    
//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//        return "aaa"
//    }
}

extension PlayListViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if isHeader(item: item) {
            return kHeaderHeight
        } else {
            
        }
        return kCellHeight
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let row = PlaylistTableRow()
        if isHeader(item: item) {
            row.isPlaylist = false
        } else {
            if let playlist = item as? Playlist {
                row.hasSelected = playlist == PlayerManager.share.currentShowPlaylist
            }
        }
        return row
    }
    
    //MARK: 内容显示
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if isHeader(item: item){
            var headerCellView = outlineView.makeView(withIdentifier: kHeaderCell, owner: self) as? PlaylistHeaderCellView
            
            if headerCellView == nil {
                headerCellView = PlaylistHeaderCellView()
                if let headerItem = item as? [String: Any] {
                    headerCellView?.playlistTypeLabel.stringValue = headerItem["name"] as! String
                    if headerItem["type"] as! headerType == headerType.item_CustomPlaylist_type{
                        headerCellView?.addCreatePlaylistButton({ [unowned self] in
                            self.addPlaylist()
                        })
                    }
                }
            }

            return headerCellView
        } else {
            var itemCellView = outlineView.makeView(withIdentifier: kItemCell, owner: self) as? PlaylistItemCellView
            if itemCellView == nil {
                itemCellView = PlaylistItemCellView()
                if let playlist = item as? Playlist {
                    itemCellView?.playlistNameLabel.stringValue = playlist.name
                    // 是否是当前展示的歌单
                    let hasSelected = playlist == PlayerManager.share.currentShowPlaylist
                    itemCellView?.setSeleted(hasSelected)
                    // 是否是当前播放的歌单
                    let isCurrentPlayingPlaylist = playlist == PlayerManager.share.currentPlayingPlaylist
                    itemCellView?.isCurrentPlayingPlaylist(isCurrentPlayingPlaylist)
                }
            }
            
            return itemCellView
        }
    }
    
    //MARK: 节点选中或取消
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let treeView = notification.object as! NSOutlineView
        // 获取选中节点模型
        let row = treeView.selectedRow
        let model = treeView.item(atRow: row)
        
        if let playlist = model as? Playlist { // playlist
            PlayerManager.share.currentShowPlaylist = playlist
            NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":playlist])
        } else { // header
            return
        }
    }

    //MARK: item是否可以点击
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    //MARK: 是否展示左侧箭头
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
}

//MARK: - NSMenuDelegate
extension PlayListViewController: NSMenuDelegate{
    func menuNeedsUpdate(_ menu: NSMenu) {
        //获取右键选中的row
        let row = outlineView.clickedRow
        //根据相中的row得到对应的item
        let item = outlineView.item(atRow: row)
        
        menu.removeAllItems()
        if row == 1 { // iTunes
            menu.addItem(NSMenuItem(title: "播放", action: #selector(playPlaylist(_:)), keyEquivalent: ""))
        } else if item is Playlist { // custom_playlist
            menu.addItem(NSMenuItem(title: "播放", action: #selector(playPlaylist(_:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "重命名", action: #selector(renamePlaylist(_:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "删除歌单", action: #selector(deletePlaylist(_:)), keyEquivalent: ""))
        } else {
            
        }
    }
}

//MARK: - Private
extension PlayListViewController {
    private func isHeader(item: Any) -> Bool {
        if ((item as? [String : Any]) != nil) {
            return true
        }
        return false
    }
    
    private func isItunesHeader(item: Any?) -> Bool {
        let headerItem = item as! [String : Any]
        if let type = headerItem["type"] as? headerType {
            if type == .item_iTunesPlaylist_type {
                return true
            }
        }
        return false
    }
    
    private func addPlaylist() {
        let alertView = DNAlertView.initialization()
        alertView.setInfo(title: "新建歌单", placeholderString: "请输入新歌单标题", type: .textFieldType)
        alertView.show(target: self) { (string) in
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd"
            let currentTimeString = dateFormat.string(from: Date())
            
            let newPlaylist = Playlist()
            newPlaylist.name = string
            newPlaylist.creatTime = currentTimeString
            SongManager.share.createPlaylist(newPlaylist)
        }
    }
}

//MARK: - Menu Method
extension PlayListViewController {
    // 播放歌单
    @objc private func playPlaylist( _ item:NSMenuItem) {
        let row = outlineView.clickedRow
        print(row)
    }
    
   // 重命名歌单
    @objc private func renamePlaylist( _ item:NSMenuItem) {
        let row = outlineView.clickedRow
        if let item_playlist = outlineView.item(atRow: row) as? Playlist {
            let alertView = DNAlertView.initialization()
            alertView.setInfo(title: "重命名歌单", placeholderString: "请输入歌单标题", type: .textFieldType)
            alertView.submitButton.title = "确认"
            alertView.defaultString = item_playlist.name
            alertView.show(target: self) { [unowned self] (string) in
                // 此刻的item_playlist是浅copy，因此在realm那更新后，item_playlist的name也会改变
                SongManager.share.renamePlaylist(item_playlist, string)
                self.outlineView.reloadData()
            }
        }
    }
    
    // 删除歌单
    @objc private func deletePlaylist( _ item:NSMenuItem) {
        let row = outlineView.clickedRow
        if let item_playlist = outlineView.item(atRow: row) as? Playlist {
            SongManager.share.removePlaylist(item_playlist)
        }
    }
}

