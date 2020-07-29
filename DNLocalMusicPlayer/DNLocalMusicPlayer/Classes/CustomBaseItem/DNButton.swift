//
//  DNButton.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

/**
   自定义的NSButton， 用来跟踪鼠标 Entered / Exited
*/

import Cocoa

class DNButton: NSButton {
    private var hover: Bool = false
    var areaView:NSView = NSView()
    var defaultImage:NSImage?
    var highlightImage:NSImage?
    
    override func draw(_ dirtyRect: NSRect) {
        // 禁用点击高亮
        self.highlight(false)
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTrackingAreaView()
    }
    
    convenience init(image:NSImage?) {
        self.init()
        self.bezelStyle = .rounded
        self.isBordered = false
        self.image = image
    }

}

//MARK: - 类拓展方法
extension DNButton {
    //MARK: 设置圆角
    func setCornerRadius (radius: CGFloat) {
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        self.layer?.masksToBounds = true
    }
}

//MARK: - 鼠标监听
extension DNButton {
    //MARK: NSTrackingArea对象并关联View
    func addTrackingAreaView() {
        addTrackingAreaView(withFrame: bounds)
    }
    
    func addTrackingAreaView(withFrame frame:NSRect) {
        areaView = NSView.init(frame: frame)
        let trackingArea:NSTrackingArea = NSTrackingArea.init(rect: frame, options: [.inVisibleRect, .mouseEnteredAndExited,.activeInKeyWindow], owner: areaView, userInfo: nil)
        areaView.addTrackingArea(trackingArea)
        self.addSubview(areaView)
    }
    
    //MARK: 鼠标Hover
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.pointingHand.set()
        if highlightImage != nil {
            self.image = highlightImage
        }
    }
    //MARK: 鼠标离开
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow.set()
        if defaultImage != nil {
            self.image = defaultImage
        }
    }
    // 点击后，状态会刷新，此时如不做更改会默认改回指针状态
    override func cursorUpdate(with event: NSEvent) {
        super.cursorUpdate(with: event)
        NSCursor.pointingHand.set()
    }
}


