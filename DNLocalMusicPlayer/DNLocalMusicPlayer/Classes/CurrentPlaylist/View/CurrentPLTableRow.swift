//
//  DetailsTableRow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/14.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class CurrentPLTableRow: DNCustomTableRow {
    // 行数
    var index:Int = 0
    // 是否是选中的行
    var isSelectedRow: Bool = false
    
    // 单数行背景色
    var singleRowColor = NSColor(r: 44, g: 44, b: 44)
    // 双数行背景色
    var doubleRowColor = NSColor(r: 41, g: 41, b: 41)
    // 选中行背景色
    var selectedRowColor = NSColor(r: 38, g: 38, b: 38)
    // hover行背景色
    var hoverRowColor = NSColor(r: 47, g: 47, b: 47)
    
    
    // 画背景色
    override func drawBackground(in dirtyRect: NSRect) {
        if isHover {
            backgroundColor = hoverRowColor
        } else if isSelectedRow{
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
    
    // 鼠标进入
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        backgroundColor = hoverRowColor
    }
}
