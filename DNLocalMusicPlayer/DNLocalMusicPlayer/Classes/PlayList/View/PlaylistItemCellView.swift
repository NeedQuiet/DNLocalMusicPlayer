//
//  PlaylistItemCellView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/26.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import SnapKit

class PlaylistItemCellView: NSTableCellView {
    //MARK: 歌单名
    var playlistNameLabel = NSTextField()
    var playlistImageView:NSImageView?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaylistItemCellView {
    func setupUI() {
        playlistImageView = NSImageView()
        playlistImageView?.image = NSImage(named: "playlist_default")
        addSubview(playlistImageView!)
        playlistImageView?.snp.makeConstraints({ (make) in
            make.left.centerY.equalTo(0)
            make.width.height.equalTo(20)
        })
        
        playlistNameLabel.isBezeled = false // 边框
        playlistNameLabel.isEditable = false
        playlistNameLabel.backgroundColor = NSColor.clear
        playlistNameLabel.cell?.usesSingleLineMode = true
        playlistNameLabel.textColor = kDefaultColor
        playlistNameLabel.lineBreakMode = .byTruncatingTail
        addSubview(playlistNameLabel)
        playlistNameLabel.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(0)
            make.left.equalTo(playlistImageView!.snp.right).offset(5)
        }
    }
    
    func setSeleted(_ seleted:Bool) {
        if seleted == true {
            playlistNameLabel.textColor = kRedHighlightColor
            playlistImageView?.image = NSImage(named: "playlist_highlight")
        } else {
            playlistNameLabel.textColor = kDefaultColor
            playlistImageView?.image = NSImage(named: "playlist_default")
        }
    }
}
