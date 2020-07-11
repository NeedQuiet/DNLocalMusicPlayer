//
//  PlayListViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class PlayListViewController: BaseViewController {

    @IBOutlet weak var sourceList: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setBackgroundColor(r: 24, g: 24, b: 24)
    }
}

extension PlayListViewController {
    func setupUI() {

    }
}
