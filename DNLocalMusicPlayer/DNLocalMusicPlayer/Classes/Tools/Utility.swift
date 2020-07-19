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
    static func getSongFromMusicFile( _ filePath:String) -> Song{
        let url = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: url)
        let songInfo = Song()
        songInfo.title = getFileNameWithURL(url)
        songInfo.filePath = filePath
        let audioDuration = asset.duration // 时长
        songInfo.timeInterval = CMTimeGetSeconds(audioDuration)
        
//        for format:AVMetadataFormat in asset.availableMetadataFormats {
            for metadata:AVMetadataItem in asset.commonMetadata{
                let key = metadata.commonKey?.rawValue
//                if key == "title"{ //歌名
//                    songInfo.title = metadata.value as! String
//                }
                if key == "albumName"{ //专辑
                    songInfo.album = metadata.value as! String
                }else if key == "artist"{   //歌手
                    songInfo.artist = (metadata.value as! String)
                }else if key == "artwork"{  //图片
                    songInfo.artworkData = metadata.value as? Data
                }
            }
//        }
        return songInfo
    }
}

//MARK: - Private
extension Utility {
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
