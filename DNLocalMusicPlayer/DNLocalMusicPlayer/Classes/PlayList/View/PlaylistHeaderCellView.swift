//
//  PlaylistHeaderCellView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/25.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import SnapKit

class PlaylistHeaderCellView: NSTableCellView {

    var playlistTypeLabel = NSTextField()
    var needAddPlaylist:Bool = false
    var creatBlock:() -> () = {}
    
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

extension PlaylistHeaderCellView {
    func setupUI() {
        playlistTypeLabel.isBezeled = false // 边框
        playlistTypeLabel.isEditable = false
        playlistTypeLabel.backgroundColor = NSColor.clear
        playlistTypeLabel.cell?.usesSingleLineMode = true
        playlistTypeLabel.lineBreakMode = .byTruncatingTail
        playlistTypeLabel.textColor = kLightColor
        addSubview(playlistTypeLabel)
        playlistTypeLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalTo(0)
        }
    }
    
    func addCreatePlaylistButton(_ callback: @escaping () -> ()) {
        creatBlock = callback
        let button = DNButton(image: NSImage(named: "playlist_create"))
        button.addTrackingAreaView(withFrame: NSRect(x: 0, y: 0, width: 20, height: 20))
        button.action = #selector(create(_:))
        button.target = self
        button.ignoresMultiClick = true
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerY.equalTo(0)
            make.right.equalTo(0)
            make.width.height.equalTo(20)
            make.left.equalTo(playlistTypeLabel.snp.right).offset(0)
        }
    }
    
    @objc private func create(_ sender: NSButton) {
        creatBlock()
    }
}
