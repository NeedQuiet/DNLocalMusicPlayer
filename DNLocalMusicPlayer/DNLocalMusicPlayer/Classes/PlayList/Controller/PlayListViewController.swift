//
//  PlayListViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class PlayListViewController: BaseViewController {
    var playlists = [Playlist]() {
        didSet {
            outlineView.reloadData()
//            outlineView.expandItem(nil, expandChildren: true)
            outlineView.expandItem("Library", expandChildren: true)
        }
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
 
}

//MARK: - 设置UI
extension PlayListViewController {
    func setupUI() {
        setBackgroundColor(r: 24, g: 24, b: 24)
        outlineView.backgroundColor = NSColor.init(r: 24, g: 24, b: 24)
    }
}

//MARK: - NSOutlineViewDataSource & NSOutlineViewDelegate
extension PlayListViewController: NSOutlineViewDataSource {
    // 根据特征分别返回header 和 data的数量
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else {
            return playlists.count
        }
    }
    
    // 是否允许展开
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item as? String == "Library" {
            return true
        } else {
            return false
        }
    }
    
    // 用来把数据分别传递给HeaderCell or DataCell
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return "Library"
        } else {
            return playlists[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return "aaa"
    }
}

extension PlayListViewController: NSOutlineViewDelegate {
    // 内容显示
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item as? String == "Library" {
            return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self)
        } else {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
            if let playlist = item as? Playlist {
                view?.textField?.stringValue = playlist.name
            }
            return view
        }
    }
    
    // item是否可以点击
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
//        if item as? String == "Library" {
//            return false
//        }
        return true
    }
    
    // 是否展示左侧箭头
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
}

//MARK: 测试
extension PlayListViewController {
    @IBAction func addPlaylist(_ sender: Any) {
        playlists.append(Playlist())
    }
}
