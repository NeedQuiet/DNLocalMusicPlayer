//
//  DNAlphaButton.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   继承自DNButton，hover的时候会有个浅白色遮罩层
*/

import Cocoa

class DNAlphaButton: DNButton {
    var alphaView:NSView?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if alphaView == nil || alphaView?.bounds != self.bounds{
            alphaView?.removeFromSuperview()
            alphaView = NSView(frame: self.bounds)
            alphaView?.setBackgroundColor(color: NSColor.gray)
            alphaView?.alphaValue = 0.2
            alphaView?.isHidden = true
            self.addSubview(alphaView!)
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: 鼠标Hover
    override func mouseEntered(with event: NSEvent) {
        if WindowManager.share.currentPlaylistIsShow ||
            WindowManager.share.playViewIsShow {
            return
        };
        super.mouseEntered(with: event)
        if isEnabled {
            alphaView?.isHidden = false
        }
    }
    //MARK: 鼠标离开
    override func mouseExited(with event: NSEvent) {
        if WindowManager.share.currentPlaylistIsShow ||
            WindowManager.share.playViewIsShow {
            return
        };
        super.mouseExited(with: event)
        alphaView?.isHidden = true
    }
}
