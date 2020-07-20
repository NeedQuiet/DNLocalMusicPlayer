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
    
    // iTunes 歌单
    lazy var iTunesPlaylist:Playlist = {
        let playlist = Playlist()
        playlist.name = "iTunes音乐"
        playlist.isCustomPlaylist = false
        return playlist
    }()
    // 自定义的歌单
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
        }).map {(songItem) -> Song in
            return Song(iTunesItem: songItem)
        }
        print("已找到\(Songs.count)首iTunes本地歌曲")
        _ = Songs.map { (song)  in
            iTunesPlaylist.songs.append(song)
        }
        NotificationCenter.default.post(name: kFinishGetItunesSongs, object: nil)
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
    
    //MARK: 根据歌曲地址判断歌曲是否重复
    private func checkSongIsExist(song:Song ,inSongs songs:List<Song>) -> Bool {
        for songItem in songs {
            if songItem.filePath == song.filePath {
                return true
            }
        }
        return false
    }
    
    //MARK: - 根据custom playlist数量重新获取应该展示或者播放的歌单
    private func resetCurrentPlaylist() {
        
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
        if let index = playlists.firstIndex(of: playlist) {
            // 删除前，要刷新当前的歌单展示问题
            // 1 删除的是当前展示的歌单
            if playlist == PlayerManager.share.currentShowPlaylist {
                var newPlaylist = Playlist()
                if index == 0 { // 如果删除的是第一个歌单
                    if playlists.count > 1 {
                        newPlaylist = playlists[1]
                        print("删除了当前`展示`的歌单：\(playlist.name) ,即将展示歌单：\(playlists[1].name)")
                    } else {
                        newPlaylist = iTunesPlaylist
                        print("删除了当前`展示`的歌单：\(playlist.name) ,即将展示iTunes歌单")
                    }
                } else {
                    print("删除了当前`展示`的歌单：\(playlist.name) ,即将展示歌单：\(playlists[0].name)")
                    newPlaylist = playlists[0]
                }
                
                PlayerManager.share.currentShowPlaylist = newPlaylist
                NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":newPlaylist])
            }
            
            // 2 删除的歌单是当前正在播放的歌单
            if playlist == PlayerManager.share.currentPlayingPlaylist {
                print("删除了当前`播放`的歌单：\(playlist.name) 清空当前播放歌单")
                PlayerManager.share.currentPlayingPlaylist = Playlist()
                PlayerManager.share.stop()
            }
            
            
            playlists.remove(at: index)
            print("删除歌单：\(playlist.name)")
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
    
    //MARK: 给歌单添加歌曲
    func addSongsTo(_ playlist:Playlist, _ songs:List<Song>, _ callback: @escaping (_ finish:Bool)->()) {
        let realm = try! Realm()
        try! realm.write {
            print("歌单'\(playlist.name)'添加歌曲：")
            for song in songs {
                if checkSongIsExist(song: song, inSongs: playlist.songs) {
                    print("歌曲'\(song.title)'已存在")
                } else {
                    print("添加：'\(song.title)'")
                    playlist.songs.insert(song, at: 0)
                }
            }
        }
        callback(true)
    }
    
    //MARK: 删除歌曲
    func removeSongFrom(_ playlist:Playlist, _ withSong:Song,_ callback:@escaping (_ finish:Bool)->()) {
       let realm = try! Realm()
        try! realm.write {
            print("歌单'\(playlist.name)'删除歌曲：")
            if let index = playlist.songs.index(of: withSong), index >= 0{
                print("删除：'\(withSong.title)'")
                playlist.songs.remove(at: index)
                //删除index0的正在播放的歌曲，index会减为-1
                if playlist == PlayerManager.share.currentPlayingPlaylist {
                    if withSong.filePath == PlayerManager.share.currentSong?.filePath {
                        PlayerManager.share.currentIndex! -= 1
                    }
                }
            } else {
                print("歌曲'\(withSong.title)'不存在")
                callback(false)
            }
        }
        callback(true)
    }
}
