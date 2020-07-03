//
//  PlayViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class PlayViewController: BaseViewController {
    
    @IBOutlet weak var artworkBackView: NSView!
    @IBOutlet weak var artworkImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
    }
}

//MARK: - UI设置
extension PlayViewController {
    func setupUI() {
        setBackgroundColor(r: 42, g: 42, b: 42)
        //MARK: 专辑图
        artworkImageView.wantsLayer = true
        artworkImageView.layer?.cornerRadius = artworkImageView.bounds.size.width / 2
        artworkImageView.layer?.masksToBounds = true
    }
}
