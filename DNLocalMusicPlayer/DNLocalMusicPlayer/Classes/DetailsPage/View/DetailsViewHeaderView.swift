//
//  DetailsViewHeaderView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

protocol DetailsViewHeaderViewDelegate : NSObjectProtocol {
    func playAll()
    func addSong()
}

class DetailsViewHeaderView: NSView {
    @IBOutlet weak var artworkImageView: NSImageView!
    @IBOutlet weak var logoBackView: NSView!
    @IBOutlet weak var logoLabel: NSTextField!
    @IBOutlet weak var playlistNameLabel: NSTextField!
    @IBOutlet weak var createTimeLabel: NSTextField!
    @IBOutlet weak var playAllButton: DNAlphaButton!
    @IBOutlet weak var addMusicButton: DNAlphaButton!
    @IBOutlet weak var songNumLabel: NSTextField!
    @IBOutlet weak var lineView: NSView!
    @IBOutlet weak var noteLabel: NSTextField!
    weak var delegate:DetailsViewHeaderViewDelegate?
    
    
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
        /*
         alignmentRect瞎调的，猜测：
            x：正数向右左动，负数想右移动，猜测数值为常规像素的2倍
            width/height: 数值越大图片越小
         */
        playAllButton.image?.alignmentRect = NSRect(x: -40, y: 0, width: 64, height: 64)

        // 添加歌曲按钮
        addMusicButton.setCornerRadius(15)
        addMusicButton.setBorder(1, kLightColor)
        addMusicButton.contentTintColor = kDefaultColor
        
        // 歌曲列表Label
        noteLabel.textColor = kRedHighlightColor
        
        // 下划线
        lineView.setBackgroundColor(color: kLightColor)
        lineView.alphaValue = 0.2
    }
}

//MARK: - IBAction
extension DetailsViewHeaderView {
    @IBAction func playallButtonClick(_ sender: Any) {
        if delegate != nil {
            delegate?.playAll()
        }
    }
    
    @IBAction func addSongButtonClick(_ sender: Any) {
        if delegate != nil {
            delegate?.addSong()
        }
    }
}
