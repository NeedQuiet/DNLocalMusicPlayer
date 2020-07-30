//
//  DNCustomTableRow.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/26.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
    可以跟踪鼠标区域，并更改背景色
 */

import Cocoa

class DNCustomTableRow: NSTableRowView {

    // 鼠标运动区域
    var trackingArea:NSTrackingArea?
    // 鼠标是否悬停
    var isHover:Bool = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}

extension DNCustomTableRow {
    // 鼠标进入
    override func mouseEntered(with event: NSEvent) {
        isHover = true
    }
    
    // 鼠标移出
    override func mouseExited(with event: NSEvent) {
        isHover = false
        if !isSelected {
            backgroundColor = NSColor.clear // 通过设置背景色辅助刷新
        }
    }
    
    // 鼠标运动区域刷新
    override func updateTrackingAreas() {
        if trackingArea != nil {
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

extension DNCustomTableRow {
    //MARK: 设置背景色
    func setCellBackgrouColor(_ rect:NSRect) {
        backgroundColor.setFill() // 用背景色填充
        let path = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        path.fill()
    }
}
