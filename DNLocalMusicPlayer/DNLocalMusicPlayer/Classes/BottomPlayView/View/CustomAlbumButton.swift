//
//  CustomAlbumButton.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/21.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class CustomAlbumButton: DNButton {
    
    private var playViewIsShow:Bool = false
    private var maskView = NSView()
    private var noteImageView = NSImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

//MARK: - UI设置
extension CustomAlbumButton {
    func setupUI(){
        maskView.frame = bounds
        maskView.setBackgroundColor(color: NSColor.black)
        maskView.alphaValue = 0.2
        maskView.isHidden = true
        self.addSubview(maskView)
        
        noteImageView.image = NSImage(named: "TouchBarMvFullscreen")
        noteImageView.frame = bounds
        noteImageView.alphaValue = 0.8
        noteImageView.isHidden = true
        self.addSubview(noteImageView)
        
        setKVO()
    }
    
    private func showMask() {
        if playViewIsShow == false {
            hiddenMask(false)
        }
    }
    
    private func hideMask() {
        if playViewIsShow == false {
            hiddenMask(true)
        }
    }
    
    private func hiddenMask(_ hidden:Bool) {
        maskView.isHidden = hidden
        noteImageView.isHidden = hidden
    }
    
    private func setKVO() {
        //MARK: 监听 WindowManager.share.playViewIsShow
        _ = WindowManager.share.rx.observeWeakly(Bool.self, "playViewIsShow")
            .subscribe { [unowned self] (change) in
                if let playViewIsShow = change.element {
                    self.playViewIsShow = playViewIsShow!
                    if playViewIsShow == true {
                        self.hiddenMask(false)
                        self.noteImageView.image = NSImage(named: "TouchBarMvNormalscreen")
                    } else {
                        self.hiddenMask(true)
                        self.noteImageView.image = NSImage(named: "TouchBarMvFullscreen")
                    }
                }
        }
    }
}

//MARK: - 重写鼠标移入&移出方法
extension CustomAlbumButton {
    //MARK: 鼠标Hover
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        // 显示
        showMask()
    }
    //MARK: 鼠标离开
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        // 隐藏
        hideMask()
    }
}
