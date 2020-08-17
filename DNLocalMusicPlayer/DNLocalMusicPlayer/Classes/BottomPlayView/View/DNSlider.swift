//
//  DNSlider.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/22.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNSlider: NSSlider {
    private var trackingArea:NSTrackingArea?
    // 是否显示knob
    var shouKnob:Bool = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

extension DNSlider {
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        
        // 将设置追踪区域为控件大小
        // 设置鼠标追踪区域，如果不设置追踪区域，mouseEntered和mouseExited会无效
        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
//        super.mouseEntered(with: event)
        NSCursor.pointingHand.set()
        /*
            通过设置 isHighlighted 取反来触发 cell 的 drawKnob 方法;
            通过 shouKnob 来控制是否显示(因为isHighlighted受其他状态影响，无法精准控制)
         */
        shouKnob = true
        isHighlighted = !isHighlighted
    }
    
    override func mouseExited(with event: NSEvent) {
//        super.mouseExited(with: event)
        NSCursor.arrow.set()
        shouKnob = false
        
        // 不直接设置true/false是因为如果在mouseExited前isHighlighted已经是true/false，那就无法触发cell重新渲染了
        isHighlighted = !isHighlighted
    }
    // 点击后，状态会刷新，此时如不做更改会默认改回指针状态
    override func cursorUpdate(with event: NSEvent) {
        super.cursorUpdate(with: event)
        NSCursor.pointingHand.set()
    }
}
