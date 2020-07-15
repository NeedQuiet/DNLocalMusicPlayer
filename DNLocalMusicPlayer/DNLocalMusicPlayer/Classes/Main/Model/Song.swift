//
//  Song.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/10.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RealmSwift
import iTunesLibrary

//@objcMembers
class Song: Object {
    //MARK: 标题
    @objc dynamic var title: String = ""
    //MARK: 文件地址
    @objc dynamic var filePath: String = ""
    //MARK: 时长
    @objc dynamic var timeInterval: Double = 0
    //MARK: 歌手
    @objc dynamic var artist: String = ""
    //MARK: 专辑
    @objc dynamic var album: String = ""
    //MARK: 专辑图data
    @objc dynamic var artworkData: Data?
    
    
    static let formatter = DateComponentsFormatter()
    //MARK: 时长 字符串
    @objc dynamic var totalTime: String {
        get {
            return Song.formatter.string(from: timeInterval)!
        }
    }
    
    convenience init(iTunesItem item: ITLibMediaItem) {
        self.init()
        self.title = item.title
        self.filePath = item.location?.path ?? ""
        self.timeInterval = TimeInterval(item.totalTime) / 1000.0
        self.artist = item.artist?.name ?? ""
        self.album = item.album.title ?? ""
        if let artwork = item.artwork?.image {
            self.artworkData = artwork.tiffRepresentation // 转为Data存储
        }
       
    }
    
    override class func ignoredProperties() -> [String] {
        return ["totalTime"]
    }
}
