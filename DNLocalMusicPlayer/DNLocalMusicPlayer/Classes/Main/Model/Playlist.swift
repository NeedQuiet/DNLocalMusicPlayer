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
    //MARK: 歌单名字
    @objc dynamic var name:String = "Playlist"
    //MARK: 创建时间
    @objc dynamic var creatTime:String = "0000-00-00"
    //MARK: 唯一标识
    @objc dynamic var id = NSUUID().uuidString
    //MARK: 下标
    @objc dynamic var index:Int = 0
    //MARK: 歌单内歌曲
    var songs = List<Song>()
    //MARK: 是否是床架的歌单
    var isCustomPlaylist:Bool = true //(用以区分创建的歌单和iTunes歌单)
    
    //MARK: 忽略的属性
    override class func ignoredProperties() -> [String] {
        return ["isCustomPlaylist"]
    }
    
    //MARK: 主键
    override class func primaryKey() -> String? {
        return "id"
    }
    
    //MARK: 增量索引
    func incrementaIndex() -> Int {
        let playlists = SongManager.share.playlists
        if playlists.count > 0 {
            let lastPlaylist = playlists.last
            return lastPlaylist!.index + 1
        }
        return 0
    }
}
