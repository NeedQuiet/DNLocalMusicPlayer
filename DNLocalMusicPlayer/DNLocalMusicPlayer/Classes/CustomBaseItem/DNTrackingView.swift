//
//  DNTrackingView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/27.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNTrackingView: NSView {
    var trackingArea:NSTrackingArea?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

//MARK: - TrackingArea
extension DNTrackingView {
    override func mouseDown(with event: NSEvent) {}
    override func rightMouseDown(with event: NSEvent) {}
    override func mouseEntered(with event: NSEvent) {}
    override func mouseExited(with event: NSEvent) {}
    
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
