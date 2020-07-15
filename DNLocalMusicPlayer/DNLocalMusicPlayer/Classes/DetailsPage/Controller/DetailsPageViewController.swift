//
//  DetailsPageViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RealmSwift

class DetailsPageViewController: BaseViewController {
    
    @objc dynamic var songs: [Song] = []
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

//MARK: - UI设置
extension DetailsPageViewController {
    func setupUI() {
        setBackgroundColor(r: 28, g: 28, b: 28)
        
        let realm = try! Realm()
        songs = realm.objects(Song.self).map { (song) in
            return song
        }
        

        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.allowsColumnReordering = false
        
        addRightMenu()
        
        clipView.backgroundColor = NSColor.blue
        
        NotificationCenter.default.addObserver(self, selector: #selector(change), name: NSWindow.didResizeNotification, object: nil)
    }
    
    @objc func change() {
        print("change \(view.bounds) ")
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

//MARK: - Private
extension DetailsPageViewController {
    //MARK: tableView双击
    @objc private func tableViewDoubleClick(_ sender:AnyObject) {
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
        return 35
    }
    
    
    //设置每行容器视图
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRowView = DNTableRow()
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
