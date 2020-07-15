//
//  PlayListViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

private enum headerType {
    case item_iTunesPlaylist_type
    case item_CustomPlaylist_type
}

class PlayListViewController: BaseViewController {
    private var headers:[[String: Any]] = [["name":"我的音乐","type":headerType.item_iTunesPlaylist_type],
                                           ["name":"创建的歌单","type":headerType.item_CustomPlaylist_type]]
    private lazy var iTunesPlaylist:Playlist = {
        let playlist = Playlist()
        playlist.name = "iTunes音乐"
        return playlist
    }()
    
    private var playlists = [Playlist]() {
        didSet {
            outlineView.reloadData()
        }
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        outlineView.expandItem(nil, expandChildren: true)
        setupKVO()
    }
}

//MARK: - 设置UI
extension PlayListViewController {
    func setupUI() {
        setBackgroundColor(r: 24, g: 24, b: 24)
        outlineView.backgroundColor = NSColor.init(r: 24, g: 24, b: 24)
        
        let menu = NSMenu()
        menu.delegate = self
        outlineView.menu = menu
    }
}

//MARK: - KVO
extension PlayListViewController {
    func setupKVO() {
        // 监听itunesSongs加载状态
        _ = SongManager.share.rx.observeWeakly(Song.self, "itunesSongs")
            .subscribe { [unowned self] (change) in
                let itunesSongs = SongManager.share.itunesSongs
                _ = itunesSongs.map { (song)  in
                    self.iTunesPlaylist.songs.append(song)
                }
                self.outlineView.reloadData()
                // 默认选中 index：1（iTunes音乐）
                self.outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
                
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
            return playlists.count // 其余的按照playlists数量显示
        }
    }
    
    //MARK: 用来把数据分别传递给HeaderCell or DataCell
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return headers[index]
        } else {
            if isItunesHeader(item: item) {
                return iTunesPlaylist
            }
            return playlists[index]
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
    //MARK: 内容显示
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if isHeader(item: item){
            let headerView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView
            if let headerItem = item as? [String: Any] {
                 headerView?.textField?.stringValue = headerItem["name"] as! String
            }
            return headerView
        } else {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
            if let playlist = item as? Playlist {
                view?.textField?.stringValue = playlist.name
            }
            return view
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
            NotificationCenter.default.post(name: kSelectedPlaylistNotificationName, object: ["playlist":playlist])
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
        if item is Playlist && row != 1{ // playlist
            menu.removeAllItems()
            menu.addItem(NSMenuItem(title: "重命名", action: #selector(renamePlaylist(_:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "删除歌单", action: #selector(deletePlaylist(_:)), keyEquivalent: ""))
        } else {
            menu.removeAllItems()
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
    
    // 重命名歌单
    @objc private func renamePlaylist( _ item:NSMenuItem) {
        let row = outlineView.clickedRow
        print(row)
    }
    
    // 删除歌单
    @objc private func deletePlaylist( _ item:NSMenuItem) {
        let row = outlineView.clickedRow
        print(row)
    }
}

//MARK: 测试
extension PlayListViewController {
    @IBAction func addPlaylist(_ sender: Any) {
        playlists.append(Playlist())
    }
}

