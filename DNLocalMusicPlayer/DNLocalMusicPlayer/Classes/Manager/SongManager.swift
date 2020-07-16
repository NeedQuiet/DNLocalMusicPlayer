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
    @objc dynamic var playlists:[Playlist] = []
}

//MARK: - Private
extension SongManager {
    //MARK: 查找iTunes本地歌曲
    private func scanItunesSongs() {
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
        print("已找到\(Songs.count)首iTunes本地歌曲")
        itunesSongs = Songs
    }
    
    //MARK: 查找realm中的所有playlist
    private func scanPlaylists() {
        let realm = try! Realm()
        print(realm.configuration.fileURL ?? "")
        let result = realm.objects(Playlist.self)
        playlists = result.map { (piaylist) in
            return piaylist
        }
        print("已找到\(playlists.count)个自定义歌单")
    }
}

//MARK: - Public
extension SongManager {
    //MARK: 开始扫描Realm
    func startScanRealmData() {
        scanItunesSongs()
        scanPlaylists()
    }
    
    //MARK: 创建歌单
    func createPlaylist(_ playlist:Playlist) {
        print("创建新歌单：\(playlist.name)")
        playlists.append(playlist)
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(playlist)
        }
    }
    
    //MARK: 删除歌单
    func removePlaylist(_ playlist:Playlist) {
        print("删除歌单：\(playlist.name)")
        if let index = playlists.firstIndex(of: playlist) {
            playlists.remove(at: index)
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(playlist)
        }
    }
    
    //MARK: 重命名歌单
    func renamePlaylist(_ playlist:Playlist, _ name:String) {
        guard let index = playlists.firstIndex(of: playlist) else { return }
        print("歌单 \(playlist.name) 重命名为: \(name)")

        let realm = try! Realm()
        try! realm.write {
            // 浅copy，会同时修改 playlists[index].name 和 入参playlist.name
            playlists[index].name = name
        }
    }
}
