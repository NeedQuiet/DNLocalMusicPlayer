//
//  DetailsNoSongsNoteView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/17.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

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
    }
}
