//
//  CurrentPlaylistViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class CurrentPlaylistViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
    }
}

//MARK: - UI设置
extension CurrentPlaylistViewController {
    func setupUI() {
        setBackgroundColor(r: 54, g: 54, b: 54)
    }
}
