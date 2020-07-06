//
//  CustomButton.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class CustomButton: NSButton {
    private var hover: Bool = false
    
    override func draw(_ dirtyRect: NSRect) {
        // 禁用点击高亮
        self.highlight(false)
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTrackingAreaView()
    }
}

//MARK: - 类拓展方法
extension CustomButton {
    //MARK: 设置圆角
    func setCornerRadius (radius: CGFloat) {
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        self.layer?.masksToBounds = true
    }
}

//MARK: - 鼠标监听
extension CustomButton {
    //MARK: NSTrackingArea对象并关联View
    func addTrackingAreaView() {
        let view = NSView.init(frame: bounds)
        let trackingArea:NSTrackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited,.activeInKeyWindow], owner: view, userInfo: nil)
        view.addTrackingArea(trackingArea)
        self .addSubview(view)
    }
    //MARK: 鼠标Hover
    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }
    //MARK: 鼠标离开
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
    // 点击后，状态会刷新，此时如不做更改会默认改回指针状态
    override func cursorUpdate(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }
}


