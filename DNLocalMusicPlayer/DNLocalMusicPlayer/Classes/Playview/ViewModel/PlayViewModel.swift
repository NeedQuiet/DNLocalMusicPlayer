//
//  PlayViewModel.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/9/27.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class PlayViewModel: NSObject {
    lazy var lrcArray:[EachLineLrcItem] = []
    
    func startGetLyrics(name:String, artists:String ,album:String, finishaCallback:@escaping (_ success: Bool) -> ()) {
        lrcArray.removeAll()
        
        searchSongByWYY(name: name, artists: artists, album: album, finishaCallback)
    }
}

//MARK: - 网易搜索
extension PlayViewModel {
    //MARK: 搜索歌曲
    func searchSongByWYY(name:String, artists:String ,album:String, _ finishaCallback:@escaping (_ success: Bool) -> ()) {
        var param:String = name
        if artists.count > 0 {
            param.append(" \(artists)")
        }
        
        print("搜索歌词：\(param)")
        NetworkTools.requestJsonData(URL: "http://music.163.com/api/search/pc", method: .POST, parameters: ["s":param,"type":1]) { [weak self] (isSuccess, Result) in
            if isSuccess {
                guard let resultDic = Result as? [String : Any] else {
                    finishaCallback(false)
                    return
                }
                
                guard let searchResult = resultDic["result"] as? [String : Any] else {
                    finishaCallback(false)
                    return
                }
                
                guard let songs = searchResult["songs"] as? [[String : Any]] else {
                    finishaCallback(false)
                    return
                }
                
                if songs.count > 0 {
                    var searchSong:[String : Any]?
                    // 如果有歌手，则判断歌手是否相同，以此来找到自己想要找的歌词
                    if artists.count > 0 {
                        for song in songs {
                            if let artistsArray = song["artists"] as? [[String : Any]],
                               let songName = song["name"] as? String,
                               let art = artistsArray.first,
                               let artName = art["name"] as? String{
                                if let _ = songName.rangeOfString("伴奏")?.location {
                                    // 排除伴奏，伴奏没歌词
                                    continue
                                }
                                if let _ = artName.rangeOfString(artists)?.location{
                                    // 歌手匹配，确认歌曲
                                    searchSong = song
                                    break
                                }
                            }
                        }
                    }
                    
                    if searchSong == nil {
                        // 如果没有z匹配，则直接取第一个吧，万一蒙对了呢
                        searchSong = songs.first!
                    }
                    
                    guard let songID = searchSong?["id"] as? Int else {
                        finishaCallback(false)
                        return
                    }
                    self?.getLyrics(songID,finishaCallback)
                }
            }
        }
    }
    
    //MARK: 根据song id获取歌词
    func getLyrics(_ songID:Int ,_ finishaCallback:@escaping (_ success: Bool) -> ()) {
        NetworkTools.requestJsonData(URL: "http://music.163.com/api/song/media", method: .GET, parameters: ["id":String(songID)]) { [weak self] (isSuccess, Result) in
            if isSuccess {
                guard let resultDic = Result as? [String : Any] else {
                    finishaCallback(false)
                    return
                }
                
                guard let lyric = resultDic["lyric"] as? String else {
                    finishaCallback(false)
                    return
                }
                
                Utility.analysisLyrics(lyrics: lyric) { (lrcs) in
                    if lrcs.count > 0 {
                        self?.lrcArray = lrcs
                        finishaCallback(true)
                    }
                }
            }
        }
    }
}
