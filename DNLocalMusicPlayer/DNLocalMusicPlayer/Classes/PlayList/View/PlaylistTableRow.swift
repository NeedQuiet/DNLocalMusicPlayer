//
//  DetailsTableRow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/26.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

private let selectedRowColor = NSColor(r: 20, g: 20, b: 20)
private let defaultRowColor = NSColor(r: 24, g: 24, b: 24)

class PlaylistTableRow: DNCustomTableRow {
    var isPlaylist:Bool = true
    var hasSelected:Bool = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // 画背景色
    override func drawBackground(in dirtyRect: NSRect) {
        if hasSelected || isHover{
            backgroundColor = selectedRowColor
        } else {
            backgroundColor = defaultRowColor
        }
        
        setCellBackgrouColor(dirtyRect)
    }
    
    override func drawSelection(in dirtyRect: NSRect) {}
}

extension PlaylistTableRow {
    // 鼠标进入
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        backgroundColor = selectedRowColor
    }
}


