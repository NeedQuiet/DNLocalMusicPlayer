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
        setupKVO()
    }
}

//MARK: - UI设置
extension PlayViewController {
    func setupUI() {
        setBackgroundColor(r: 32, g: 32, b: 32)
        //MARK: 专辑图
        artworkImageView.wantsLayer = true
        artworkImageView.layer?.cornerRadius = artworkImageView.bounds.size.width / 2
        artworkImageView.layer?.masksToBounds = true
    }
}

//MARK: - KVO
extension PlayViewController {
    func setupKVO() {
        //MARK: currentSong
        _ = PlayerManager.share.rx.observeWeakly(Song.self, "currentSong")
            .subscribe({  [weak self] (change) in
                if let currentSong = change.element {
                    var image:NSImage = NSImage(named: "MiniPlayerLargeAlbumDefault")!
                    if let imageData = currentSong?.artworkData {
                        image = NSImage(data: imageData) ?? image
                    }
                    self?.artworkImageView.image = image
                }
        })
    }
}
