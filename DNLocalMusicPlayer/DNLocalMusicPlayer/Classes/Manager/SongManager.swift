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
        let result = realm.objects(Playlist.self).sorted(byKeyPath: "index", ascending: true)
        playlists = result.map { (piaylist) in
            return piaylist
        }
        print("已找到\(playlists.count)个自定义歌单")
        //MARK: 获取记录的播放的Playlist
        let playingPlaylistIndex = UserDefaultsManager.share.checkSeletedPlaylistIndex()
        
        if playingPlaylistIndex == -1 { // 如果存储的为-1，那么就展示 iTunesPlaylist
            PlayerManager.share.currentShowPlaylist = iTunesPlaylist
            NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":iTunesPlaylist])
        }
        
        if playlists.count == 0 {
            PlayerManager.share.currentShowPlaylist = iTunesPlaylist
            NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":iTunesPlaylist])
            return
        }
        
        var currentPlaylist = iTunesPlaylist
        if playingPlaylistIndex != -1 {
            // 如果存储的不是-1，那么就展示 currentPlaylist
            currentPlaylist = playlists[playingPlaylistIndex]
            PlayerManager.share.currentShowPlaylist = currentPlaylist
            NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":currentPlaylist])
        }
        
        //MARK: 获取记录的选择的Song
        if let songSelectedIndex = UserDefaultsManager.share.getSongSelectedIndex() { // songSelectedIndex 不为空
            // 给currentIndex赋值
            PlayerManager.share.currentIndex = songSelectedIndex
            // 获取记录的播放列表
            PlayerManager.share.currentPlayingPlaylist = currentPlaylist
            print("已找到记录歌单：'\(currentPlaylist.name)'")
            // 如果当前播放列表的 歌曲数量-1 大于 songSelectedIndex
            if currentPlaylist.songs.count - 1 >= songSelectedIndex {
                // 根据 songSelectedIndex 获取 Song
                let currentPlayingSong = currentPlaylist.songs[songSelectedIndex]
                // 给 currentSong 赋值
                print("已找到记录歌曲：'\(currentPlayingSong.title)'")
                PlayerManager.share.currentSong = currentPlayingSong
            } else {
                UserDefaultsManager.share.setSongSelectedIndex(nil)
            }
        }
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
                print("删除了当前`播放`的歌单：\(playlist.name)")
                // 设置当前播放歌单为 iTunesPlaylist，并展示
                PlayerManager.share.currentPlayingPlaylist = iTunesPlaylist
                PlayerManager.share.currentShowPlaylist = iTunesPlaylist
                NotificationCenter.default.post(name: kSelectedPlaylistNotification, object: ["playlist":iTunesPlaylist])
                // 停止播放
                PlayerManager.share.stop()
                // 本地化存储
                UserDefaultsManager.share.setPlayingPlaylistIndex(-1)
                UserDefaultsManager.share.setSongSelectedIndex(nil)
            } else {
                // 此时 playlists.count 肯定大于1，不然删除的就是当前播放歌单了
                var newPlayingPlaylistIndex:Int = UserDefaultsManager.share.playingPlaylistIndex
                let selectedIndex = UserDefaultsManager.share.playingPlaylistIndex
                if index < selectedIndex { // 如果删除的歌单在选中歌单上面，那选中歌单Index-1
                    newPlayingPlaylistIndex = selectedIndex  - 1
                }
                // 本地化存储当前播放歌单Index
                UserDefaultsManager.share.setPlayingPlaylistIndex(newPlayingPlaylistIndex)
            }

            playlists.remove(at: index)
            print("删除歌单：\(playlist.name)")
            // 删除歌单后再设置，方便Playlsit刷新
            
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
    func addSongsTo(_ playlist:Playlist, _ songs:List<Song>, index:Int? = 0,_ callback: @escaping (_ finish:Bool)->()) {
        let realm = try! Realm()
        try! realm.write {
            print("歌单'\(playlist.name)'添加歌曲：")
            var addCount = 0 // 成功添加的歌曲数量
            for song in songs.reversed() {
                if checkSongIsExist(song: song, inSongs: playlist.songs) {
                    print("歌曲'\(song.title)'已存在")
                } else {
                    print("添加：'\(song.title)'")
                    playlist.songs.insert(song, at: index!)
                    addCount += 1
                }
            }
            // 如果添加歌曲的歌单是当前正在播放的歌单
            if playlist == PlayerManager.share.currentPlayingPlaylist {
                if var currentPlayingIndex = PlayerManager.share.currentIndex {
                    // 如果在当前播放歌曲的index上面添加
                    if index! <= currentPlayingIndex {
                        // currentIndex自增addCount
                        currentPlayingIndex += addCount
                        PlayerManager.share.currentIndex = currentPlayingIndex
                    }
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
                if playlist == PlayerManager.share.currentPlayingPlaylist {
                    // 如果删除的是当前播放的歌曲，那么 currentIndex - 1（即使删除index为0也无所谓，currentIndex会变成-1）
                    if withSong.filePath == PlayerManager.share.currentSong?.filePath { // 删除的是当前播放的歌曲
                        PlayerManager.share.currentIndex! -= 1
                    } else { // 删除当前播放列表其他歌曲
                        if index < PlayerManager.share.currentIndex! {
                            /*
                             如果删除歌曲index 小于当前播放歌曲的index
                             也就是说如果删除的歌曲在当前播放歌曲上面，那么currentIndex要减1
                             */
                            PlayerManager.share.currentIndex! -= 1
                        }
                    }
                }
            } else {
                print("歌曲'\(withSong.title)'不存在")
                callback(false)
            }
        }
        callback(true)
    }
    
    //MARK: 拖拽歌曲排序
    func dragSongWith(_ playlist:Playlist, _ from:Int, _ to:Int, _ callback:@escaping (_ finish:Bool)->()) {
        let realm = try! Realm()
        try! realm.write {
            let songs = playlist.songs
            let fromSong = songs[from] // 获取拖拽歌曲
            songs.insert(fromSong, at: to) // 将歌曲插入到指定位置
            // 删除原index歌曲
            if to > from {
                songs.remove(at: from)
            } else {
                songs.remove(at: from + 1)
//                newIndex -= 1`
            }
            playlist.songs = songs
            
            let newIndex = songs.index(of: fromSong)!
            // 处理currentSong index 逻辑
            // 如果是当前播放的歌单
            if playlist == PlayerManager.share.currentPlayingPlaylist {
                // 如果是当前播放额歌曲
                let currentIndex = PlayerManager.share.currentIndex!
                if fromSong.filePath == PlayerManager.share.currentSong?.filePath {
                    // 直接更改即可
                    PlayerManager.share.currentIndex = newIndex
                } else {
                    // 如果不是当前播放额歌曲
                    if from < currentIndex {
                        // 如果原始位置小于当前播放歌曲
                        if newIndex > currentIndex { // 并且移动后的坐标大于currentIndex
                           PlayerManager.share.currentIndex = currentIndex - 1
                        }
                    } else {
                        // 如果原始位置大于当前播放歌曲
                        if newIndex < currentIndex { // 并且移动后的坐标小于currentIndex
                            PlayerManager.share.currentIndex = currentIndex + 1
                        }
                    }
                }
            }
        }
        callback(true)
    }
    
    //MARK: 拖拽歌单排序
    func dragPlaylistWith(_ id:String, _ to:Int, _ callback:@escaping (_ finish:Bool)->()) {
        // 获取拖拽的歌曲
        var fromIndex:Int = 0
        for (index, playlist) in playlists.enumerated() {
            if id == playlist.id {
                fromIndex = index
                break;
            }
        }
        
        let drag:Playlist = playlists[fromIndex]
        
        if fromIndex == to || fromIndex == to - 1{
            callback(false) // 相当于原地不动
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            if fromIndex > to { // 向上拖拽
                for playlist in playlists[to..<fromIndex] {
                    playlist.index += 1
                }
                drag.index = to
            } else { // 向下拖拽
                for playlist in playlists[(fromIndex+1)..<to] {
                    playlist.index -= 1
                }
                
                if to == playlists.count { // 尾部
                    drag.index = playlists.last!.index + 1 // 直接取最后一个playlist的index + 1
                } else {
                    drag.index = playlists[to].index - 1 // 去to对应playlist的index - 1
                }
            }
        }
        

        let result = realm.objects(Playlist.self).sorted(byKeyPath: "index", ascending: true)
        playlists = result.map { (piaylist) in
            return piaylist
        }
        
        if drag.id == PlayerManager.share.currentPlayingPlaylist.id {
            PlayerManager.share.currentPlayingPlaylist = drag // 为了执行didset方法，更新Userdefault
        }
        
        callback(true)
    }
}
