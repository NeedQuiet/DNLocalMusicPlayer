//
//  DetailsViewHeaderView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

protocol DetailsViewHeaderViewDelegate : NSObjectProtocol {
    //MARK: 播放全部
    func playAll()
    //MARK: 添加歌曲
    func addSong()
    //MARK: 重命名
    func renamePlaylist()
    //MARK: search文字改变
    func controlTextDidChange(_ stringValue: String)
    //MARK: 清空搜索内容
    func clearSearchField()
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
    @IBOutlet weak var renameButton: DNButton!
    @IBOutlet weak var searchField: DNSearchField!
    
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
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        searchField.window?.makeFirstResponder(nil)
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
        
        // rename
        renameButton.defaultImage = NSImage(named: "edit_default")
        renameButton.highlightImage = NSImage(named: "edit_highlight")
        
        // 创建时间
        createTimeLabel.textColor = kLightColor

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
        
        // 歌曲数量
        songNumLabel.textColor = kLightColor
        
        // 歌曲列表Label
        noteLabel.textColor = kRedHighlightColor
        
        // 下划线
        lineView.setBackgroundColor(color: kLightColor)
        lineView.alphaValue = 0.2
        
        // 搜索
        searchField.focusRingType = .none
        searchField.delegate = self
        let searBtnCell = searchField.cell as! NSSearchFieldCell
        //清空按钮
        let cancelBtnCell = searBtnCell.cancelButtonCell
        cancelBtnCell?.target = self
        cancelBtnCell?.action = #selector(cancelBtnAction(_:))
    }
}

//MARK: - IBAction
extension DetailsViewHeaderView {
    @IBAction func playallButtonClick(_ sender: Any) {
        delegate?.playAll()
    }
    
    @IBAction func addSongButtonClick(_ sender: Any) {
        delegate?.addSong()
    }
    
    @IBAction func renameButtonPressed(_ sender: Any) {
        delegate?.renamePlaylist()
    }
    
    @objc func cancelBtnAction(_ sender: NSSearchField) {
        sender.stringValue = ""
        delegate?.clearSearchField()
    }
}

//MARK: - NSSearchFieldDelegate
extension DetailsViewHeaderView:NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        delegate?.controlTextDidChange(searchField.stringValue)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        KeyBoardListenerManager.share.TextFieldIsEditing = false
    }
}
