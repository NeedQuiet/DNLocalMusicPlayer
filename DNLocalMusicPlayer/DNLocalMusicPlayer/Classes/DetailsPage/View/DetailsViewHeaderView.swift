//
//  DetailsViewHeaderView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DetailsViewHeaderView: NSView {
    @IBOutlet weak var artworkImageView: NSImageView!
    @IBOutlet weak var logoBackView: NSView!
    @IBOutlet weak var logoLabel: NSTextField!
    @IBOutlet weak var playlistNameLabel: NSTextField!
    @IBOutlet weak var createTimeLabel: NSTextField!
    @IBOutlet weak var playAllButton: DNDefaultButton!
    @IBOutlet weak var addMusicButton: DNDefaultButton!
    @IBOutlet weak var songNumLabel: NSTextField!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func initialization() -> DetailsViewHeaderView {
        var topLevelObjects : NSArray?
        _ = Bundle.main.loadNibNamed("DetailsViewHeaderView", owner: self,topLevelObjects: &topLevelObjects)
        return topLevelObjects!.first(where: { $0 is DetailsViewHeaderView }) as! DetailsViewHeaderView
    }
}

//MARK: UI设置
extension DetailsViewHeaderView {
    func setupUI() {
        // logo
        logoLabel.textColor = kRedHighlightColor
        logoBackView.setCornerRadius(4)
        logoBackView.setBorder(1, kRedHighlightColor)
        
        // 歌单名
        playlistNameLabel.textColor = kDefaultColor

        // 专辑图
        artworkImageView.setCornerRadius(8)
        
        // playAll 按钮
        playAllButton.setBackgroundColor(color: kRedHighlightColor)
        playAllButton.setCornerRadius(15)
        playAllButton.contentTintColor = kWhiteHighlightColor
        
        // 添加歌曲按钮
        addMusicButton.setCornerRadius(15)
        addMusicButton.setBorder(1, kLightColor)
        addMusicButton.contentTintColor = kDefaultColor
    }
}
