//
//  DetailsNoSongsNoteView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RealmSwift

class DetailsNoSongsNoteView: NSView {

    @IBOutlet weak var noteTitle: NSTextField!
    @IBOutlet weak var noteBody: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    static func initialization() -> DetailsNoSongsNoteView {
        var topLevelObjects : NSArray?
        _ = Bundle.main.loadNibNamed("DetailsNoSongsNoteView", owner: self,topLevelObjects: &topLevelObjects)
        return topLevelObjects!.first(where: { $0 is DetailsNoSongsNoteView }) as! DetailsNoSongsNoteView
    }
}

extension DetailsNoSongsNoteView {
    func setupUI() {
        noteTitle.textColor = kDefaultColor
        noteBody.textColor = kLightColor
        
        self.registerForDraggedTypes([kDrapInPasteboardType])
    }
}

// 文件拖入
extension DetailsNoSongsNoteView {
    //MARK: 数据拖入
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let pathArray =  Utility.getPathArrayByFilenamesType(sender) { // 根据 validateDropInfo 获取 拖入文件的路径数组
            let supportFormat = allowedFileTypes // 根据文件格式判断是否允许拖入
            for path in pathArray { // 遍历文件
                let url = URL(fileURLWithPath: path)
                if supportFormat.contains(url.pathExtension) {
                    return .copy // 如果符合格式就copy
                }
            }
        }
        return NSDragOperation.init(rawValue: 0) // 什么都不执行
    }
    
    //MARK: 拖入文件后在view中松开鼠标
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let pathArray =  Utility.getPathArrayByFilenamesType(sender) {
            let songs = List<Song>()
            for path in pathArray {
                let song:Song = Utility.getSongFromMusicFile(path)
                songs.append(song)
            }
            let currentShowPlaylist = PlayerManager.share.currentShowPlaylist
            SongManager.share.addSongsTo(currentShowPlaylist, songs, index: 0) { (success) in
                // 添加歌曲后，直接发通知，重置页面
                NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":currentShowPlaylist])
            }
            return true
        }
        return false
    }
}
