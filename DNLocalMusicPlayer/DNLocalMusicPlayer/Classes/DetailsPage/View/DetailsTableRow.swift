//
//  DetailsTableRow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/14.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

private let singleRowColor = NSColor(r: 28, g: 28, b: 28)
private let doubleRowColor = NSColor(r: 31, g: 31, b: 31)
private let selectedRowColor = NSColor(r: 38, g: 38, b: 38)

class DetailsTableRow: DNCustomTableRow {
    // 行数
    var index:Int = 0
    // 是否是选中的行
    var isSelectedRow: Bool = false
    
    // 画背景色
    override func drawBackground(in dirtyRect: NSRect) {
        if isHover || isSelectedRow{
            backgroundColor = selectedRowColor
        } else {
            if index % 2 == 0 {
                backgroundColor = doubleRowColor
            } else {
                backgroundColor = singleRowColor
            }
        }
        setCellBackgrouColor(dirtyRect)
    }
    
    // 拖拽时row的背景色，重写则不加颜色，以isHover为主
    override func drawDraggingDestinationFeedback(in dirtyRect: NSRect) {}

    // 鼠标进入
    override func mouseEntered(with event: NSEvent) {
        if WindowManager.share.currentPlaylistIsShow ||
            WindowManager.share.playViewIsShow {
            return
        };
        super.mouseEntered(with: event)
        backgroundColor = selectedRowColor
    }
    
    // 鼠标移出
    override func mouseExited(with event: NSEvent) {
        if WindowManager.share.currentPlaylistIsShow ||
            WindowManager.share.playViewIsShow {
            return
        };
        super.mouseExited(with: event)
    }
}
