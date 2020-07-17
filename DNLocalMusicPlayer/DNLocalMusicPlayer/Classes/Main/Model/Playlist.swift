//
//  Playlist.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RealmSwift

class Playlist: Object {
    @objc dynamic var name:String = "Playlist"
    @objc dynamic var creatTime:String = "0000-00-00"
    var songs = List<Song>()
    var isCustomPlaylist:Bool = true
    
    override class func ignoredProperties() -> [String] {
        return ["isCustomPlaylist"]
    }
}
