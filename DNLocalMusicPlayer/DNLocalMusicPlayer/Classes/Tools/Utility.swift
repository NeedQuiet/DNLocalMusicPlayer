//
//  Utility.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/13.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import AVFoundation

class Utility: NSObject {
    
}

extension Utility {
    //MARK: 解析歌曲
    static func getSongFromMusicFile( _ filePath:String) -> Song{
        let url = URL(fileURLWithPath: filePath)
        var asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        if !asset.isPlayable {
            /*
             不知道为什么，‘牧马城市.flac’一直报 ‘ParseAudioFile failed’，无法获取任何信息
             但是如果不添加options初始化，就没有问题了
             */
            asset = AVURLAsset(url: url)
        }
        let songInfo = Song()
        songInfo.title = getFileNameWithURL(url)
        songInfo.filePath = filePath
        let audioDuration = asset.duration // 时长
        songInfo.timeInterval = CMTimeGetSeconds(audioDuration)
        for format:AVMetadataFormat in asset.availableMetadataFormats {
            for metadata:AVMetadataItem in asset.metadata(forFormat: format){
                let key = metadata.commonKey?.rawValue
                if key == "title"{ //歌名
                    if let title = metadata.value as? String {
                        songInfo.title = title
                    }
                }
                if key == "albumName"{ //专辑
                    songInfo.album = metadata.value as! String
                }else if key == "artist"{   //歌手
                    songInfo.artist = (metadata.value as! String)
                }else if key == "artwork"{  //图片
                    songInfo.artworkData = metadata.value as? Data
                }
//                print("key: \(String(describing: key)), value \(String(describing: metadata.value))")
            }
        }
        
//        for metadata:AVMetadataItem in asset.metadata {
//            let key = metadata.commonKey?.rawValue
//            print("key: \(String(describing: key)), value \(String(describing: metadata.value))")
//        }
        
//        asset.loadValuesAsynchronously(forKeys: ["tracks","availableMetadataFormats"]) {
//            let status = asset.statusOfValue(forKey: "availableMetadataFormats", error: nil)
//            switch status {
//            case .loading:
//                print("loading")
//            case .loaded:
//                print("loaded")
//                //获取asset里面的元数据
////                let metadata:[[AVMetadataItem] = []
//                for format in asset.availableMetadataFormats {
////                    print(format)
//                    let metadata = asset.metadata(forFormat: format)
//                    for item:AVMetadataItem in metadata {
//                        let key = item.commonKey?.rawValue
//                        print("key: \(String(describing: key)) -- \(String(describing: item.key))")
//                        if key == "title" {
//                            songInfo.title = item.value as! String
//                        } else if key == "albumName" {
//                            songInfo.album = item.value as! String
//                        } else if key == "artist" {
//                            songInfo.artist = item.value as! String
//                        } else if key == "artwork" {
//                            songInfo.artworkData = item.value as? Data
//                        }
//
////                        let itemKey = item.key as! String
////                        if itemKey == "info-approximate duration in seconds"  {
////                            let audioDuration = item.value // 时长
////                            songInfo.timeInterval = audioDuration as! Double
////                            print(audioDuration! )
////                        }
//                    }
//                }
//
//            case .unknown:
//                print("unknown")
//            case .failed:
//                print("failed")
//            case .cancelled:
//                print("cancelled")
//            @unknown default:
//                print("default")
//            }
//        }

        return songInfo
    }
    
    //MARK: 获取歌词
    static func getMusicLyrics(withFilePath filePath:String) -> String {
        let url = URL(fileURLWithPath: filePath)
        var asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        if !asset.isPlayable {
            asset = AVURLAsset(url: url)
        }
        let lyrics = asset.lyrics ?? ""
        return lyrics
    }
}

//MARK: - Private
extension Utility {
    //MARK: 根据路径获取文件名
    private static func getFileNameWithURL(_ url:URL) -> String {
        let lastPathComponent = url.lastPathComponent
        var fileName:String = lastPathComponent
        let stringRange = fileName.range(of: fileName)
        if let dotRange = fileName.range(of: ".", options: .backwards, range: stringRange, locale: nil) {
            fileName = String(fileName[..<dotRange.lowerBound])
        }
        return fileName
    }
}
