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

class DetailsTableRow: NSTableRowView {
    // 鼠标运动区域
    var trackingArea:NSTrackingArea?
    // 行数
    var index:Int = 0
    // 鼠标是否悬停
    var isHover:Bool = false
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
        backgroundColor = selectedRowColor
        isHover = true
    }
    
    // 鼠标移出
    override func mouseExited(with event: NSEvent) {
        isHover = false
        if !isSelected {
            backgroundColor = NSColor.clear
        }
    }
    
    // 鼠标运动区域刷新
    override func updateTrackingAreas() {
        if trackingArea != nil{
            self.removeTrackingArea(trackingArea!)
        }
        
        trackingArea = NSTrackingArea.init(rect: bounds, options: [.inVisibleRect, .activeInKeyWindow, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
        
        var mouseLocation:NSPoint = self.window?.mouseLocationOutsideOfEventStream ?? NSPoint.zero
        mouseLocation = self.convert(mouseLocation, from: nil)
        if NSPointInRect(mouseLocation, bounds) {
            self.mouseEntered(with: NSEvent())
        } else {
            self.mouseExited(with: NSEvent())
        }
        super.updateTrackingAreas()
    }
}

extension DetailsTableRow {
    //MARK: 设置背景色
    private func setCellBackgrouColor(_ rect:NSRect) {
        backgroundColor.setFill() // 用背景色填充
        let path = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        path.fill()
    }
}
 
