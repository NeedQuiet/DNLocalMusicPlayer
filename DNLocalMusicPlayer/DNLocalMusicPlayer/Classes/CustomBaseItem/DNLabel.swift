//
//  DNLabel.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/7.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNLabel: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        isBezeled = false // 边框
        isEditable = false // 不允许编辑
        backgroundColor = NSColor.clear
        lineBreakMode = .byTruncatingTail
        cell?.usesSingleLineMode = true // 单行
    }
}
