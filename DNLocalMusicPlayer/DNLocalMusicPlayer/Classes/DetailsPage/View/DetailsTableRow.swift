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
        if isHover || isSelectedRow {
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
    
    // 选中的Row
    override func drawSelection(in dirtyRect: NSRect) {
        /*
            发现单击选中后，mouseEntered/mouseExited等监听都会失效；
            所以强制置为false，刷新row，会去执行drawBackground
            (单击选中会进这里，双击选中后，进入这里一次后会自动设为false)
         */
        isSelected = false
    }
    
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
