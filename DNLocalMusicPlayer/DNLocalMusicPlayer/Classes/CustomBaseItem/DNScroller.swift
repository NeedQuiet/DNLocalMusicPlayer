//
//  DNScroller.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/24.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
    一个自定义的scroller滑动条
 */

import Cocoa

private let kScrollerDefaultColor = NSColor(r: 48, g: 48, b: 48)
private let kScrollerHighColor = NSColor(r: 56, g: 56, b: 56)
private let backgroundColor = NSColor(r: 28, g: 28, b: 28)
class DNScroller: NSScroller {
    // 鼠标运动区域
    var trackingArea:NSTrackingArea?
    // 滚动条颜色
    var knobBackColor:NSColor = kScrollerDefaultColor
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
//        self.wantsLayer = true
//        self.layer?.backgroundColor = backgroundColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func drawKnob() {
        super.drawKnob()
        
        let knobRext = NSInsetRect(self.rect(for: .knob), 3, 0)
        let bezierPath = NSBezierPath(roundedRect: knobRext, xRadius: knobRext.width / 2, yRadius: knobRext.width / 2)
        knobBackColor.setFill()
        bezierPath.fill()
    }
    
    
//    override class func scrollerWidth(for controlSize: NSControl.ControlSize, scrollerStyle: NSScroller.Style) -> CGFloat {
//        return 10
//    }
    
    override func drawPageBorder(with borderSize: NSSize) {
        
    }
    
    // 刷新鼠标运动区域
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
    
    // 鼠标进入
    override func mouseEntered(with event: NSEvent) {
        knobBackColor = kScrollerHighColor
    }
    
    // 鼠标移出
    override func mouseExited(with event: NSEvent) {
        knobBackColor = kScrollerDefaultColor
    }
}
