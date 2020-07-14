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
    dynamic var name:String = "Playlist"
    let songs = List<Song>()
}
