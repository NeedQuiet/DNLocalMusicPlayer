//
//  MiniBackView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

protocol MiniBackViewDelegate {
    func mouseEntered()
    func mouseExited()
}

class MiniBackView: NSView {
    
    var delegate:MiniBackViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTrackingAreaView(withFrame: bounds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        setBackgroundColor(color:NSColor.init(r: 35, g: 35, b: 35))
        setCornerRadius(6)
        setBorder(1,kLightestColor)
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return true;
    }
    
    override func mouseEntered(with event: NSEvent) {
//        super.mouseEntered(with: event)
        delegate?.mouseEntered()
    }
    
    override func mouseExited(with event: NSEvent) {
//        super.mouseExited(with: event)
        delegate?.mouseExited()
    }
}

extension MiniBackView {
    func addTrackingAreaView(withFrame frame:NSRect) {
        let areaView:NSView = NSView.init(frame: frame)
        let trackingArea:NSTrackingArea = NSTrackingArea.init(rect: frame, options: [.inVisibleRect, .mouseEnteredAndExited,.activeAlways], owner: areaView, userInfo: nil)
        areaView.addTrackingArea(trackingArea)
        self.addSubview(areaView)
    }
}
