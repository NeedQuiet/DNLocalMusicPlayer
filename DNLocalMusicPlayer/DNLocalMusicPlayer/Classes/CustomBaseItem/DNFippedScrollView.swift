//
//  DNFippedScrollView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   翻转了坐标系的NSScrollView
        - 支持翻滚到顶部
*/

import Cocoa

@objc protocol DNFippedScrollViewDelegate {
    @objc optional func scrollViewIsScrolling(sender:NSScrollView)
    @objc optional func scrollViewScrollEnd(sender:NSScrollView)
}

class DNFippedScrollView: NSScrollView {
    
    weak var delegate:DNFippedScrollViewDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        delegate?.scrollViewIsScrolling?(sender: self)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(delayExecutionEndScrollDelegate), with: nil, afterDelay: 1)
    }
        
    @objc func delayExecutionEndScrollDelegate() {
        delegate?.scrollViewScrollEnd?(sender: self)
    }
}

extension DNFippedScrollView {
    //MARK: 滚动到顶部
    func scrollToTop() {
        scrollToPositionY(0, false)
    }
    
    //MARK: 滚动动画
    func scrollToPositionY(_ positionY:CGFloat, _ animation:Bool? = true){
        if animation! {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 0.5
            let clip:NSClipView = self.contentView
            var newOrigin:NSPoint = clip.bounds.origin
            newOrigin.y = positionY
            clip.animator().setBoundsOrigin(newOrigin)
            self.reflectScrolledClipView(self.contentView)
            NSAnimationContext.endGrouping()
        } else {
            self.contentView.scroll(to: NSPoint(x: 0, y: positionY))
        }
    }
}
