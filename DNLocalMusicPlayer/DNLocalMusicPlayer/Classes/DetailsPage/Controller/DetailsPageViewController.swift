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
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setBackgroundColor(r: 28, g: 28, b: 28)
        
        let realm = try! Realm()
        songs = realm.objects(Song.self).map { (song) in
            return song
        }
        
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let clickedRow = tableView.clickedRow
        if clickedRow != -1 {
            PlayerManager.share.play(withIndex: clickedRow)
        }
    }
}
