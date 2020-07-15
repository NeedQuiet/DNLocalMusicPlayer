//
//  SongManager.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/10.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import iTunesLibrary
import RealmSwift

final class SongManager:NSObject {
    static let share = SongManager()
    
    @objc dynamic var itunesSongs:[Song] = []

    func importSongs() {
        do {
            let realm = try! Realm()
            print(realm.configuration.fileURL ?? "")
            let result = realm.objects(Song.self)
            let songs:[Song] = result.map { (song) in
                return song
            }
            
            if songs.count > 0 {
                print("发现iTunes本地歌曲： \(songs.count)首")
            } else {
                print("未发现ITunes本地歌曲，开始查找")
                let library = try ITLibrary(apiVersion: "1.0")
                let allItems = library.allMediaItems
                let itunrsSongs = allItems.filter( { item -> Bool in
                    return item.mediaKind == ITLibMediaItemMediaKind.kindSong
                        && item.location != nil
                        && item.locationType == ITLibMediaItemLocationType.file
                }).map { (songItem) -> Song in
                    return Song(iTunesItem: songItem)
                }
                try! realm.write {
                    realm.add(itunrsSongs)
                }
                print("已找到\(itunrsSongs.count)首歌曲")
            }
            
            
        } catch let error as NSError{
            print("error loading iTunesLibrary: \(error)")
        }
    }
}

extension SongManager {
    //MARK: 查找iTunes本地歌曲
    func scanItunesSongs() {
        print("开始查找iTunes本地歌曲")
        let library = try! ITLibrary(apiVersion: "1.0")
        let allItems = library.allMediaItems
        let Songs = allItems.filter( { item -> Bool in
            return item.mediaKind == ITLibMediaItemMediaKind.kindSong
                && item.location != nil
                && item.locationType == ITLibMediaItemLocationType.file
        }).map { (songItem) -> Song in
            return Song(iTunesItem: songItem)
        }
        print("已找到\(Songs.count)首歌曲")
        itunesSongs = Songs
    }
}
