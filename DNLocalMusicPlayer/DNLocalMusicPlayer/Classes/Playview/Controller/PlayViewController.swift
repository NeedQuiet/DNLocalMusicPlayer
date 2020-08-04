//
//  PlayViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import AVFoundation
import RxCocoa

private let kLRCLineHeight:CGFloat = 35

class PlayViewController: BaseViewController {
    
    @IBOutlet weak var artworkBackView: NSView!
    @IBOutlet weak var artworkImageView: NSImageView!
//    var initArtworkPosition:CGPoint = CGPoint.zero
    
    @IBOutlet weak var songTitle: NSTextField!
    @IBOutlet weak var albumButton: DNTitleButton!
    @IBOutlet weak var artistButton: DNTitleButton!
    @IBOutlet weak var fromButton: DNTitleButton!
    
    @IBOutlet weak var lrcScrollView: DNFippedScrollView!
    
    var IsScrollingByWheel:Bool = false
    
    // 歌词数组
    var lrcArray:[EachLineLrcItem] = []
    // 歌词label数组
    var lrcLabelArray:[NSTextField] = []
    //
    var tempLRCTime:[TimeInterval] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVO()
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // 每次展示播放页，都重新转专辑图
        setupArtworkLayer()
    }
}

//MARK: - UI设置
extension PlayViewController {
    func setupUI() {
        setBackgroundColor(r: 32, g: 32, b: 32)
        // 专辑图
        artworkImageView.wantsLayer = true
        artworkImageView.layer?.cornerRadius = artworkImageView.bounds.size.width / 2
        artworkImageView.layer?.masksToBounds = true
        
        // 歌词scrollView
        lrcScrollView.setBackgroundColor(color: NSColor.clear) // 背景色
        lrcScrollView.borderType = .noBorder // 无边框
        lrcScrollView.delegate = self
//        lrcScrollView.autohidesScrollers = true
//        lrcScrollView.hasVerticalScroller = true
//        lrcScrollView.scrollerStyle = .overlay
        // 需要设置 self.contentView 可以发送 Bounds 改变通知
    }
    
    // 重写mouseDown方法，防止鼠标点击穿透至下一层
    override func mouseDown(with event: NSEvent) {}
    
    func setupArtworkLayer() {
        // 计算专辑图layer的中心，不然旋转有问题
        let frame = NSRectFromCGRect(artworkBackView.frame)
        let positionX = frame.origin.x + frame.size.width / 2
        let positionY = frame.origin.y + frame.size.height / 2
        artworkBackView.layer?.position = CGPoint(x: positionX,y: positionY)
        artworkBackView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        if PlayerManager.share.isPlaying {
            setupAndStartAnimation()
        }
    }
}

//MARK: - DNFippedScrollViewDelegate
extension PlayViewController:DNFippedScrollViewDelegate {
    //MARK: scrollview正在滚动
    func scrollViewIsScrolling(sender:NSScrollView) {
        print("IsScrolling")
        IsScrollingByWheel = true
    }
    
    //MARK: scrollview滚动结束
    func scrollViewScrollEnd(sender:NSScrollView) {
        print("ScrollEnd")
        IsScrollingByWheel = false
        updateLRCScrollView()
    }
}

//MARK: - KVO
extension PlayViewController {
    func setupKVO() {
        //MARK: currentSong
        _ = PlayerManager.share.rx.observeWeakly(Song.self, "currentSong")
            .subscribe({ (change) in
                if let currentSong = change.element {
                    guard currentSong != nil else {  return }
                    self.refreshUI(withSong: currentSong!)
                    if PlayerManager.share.isPlaying {
                        self.setupAndStartAnimation()
                    }
                }
        })
        
        //MARK: isPlaying
        _ = PlayerManager.share.rx.observeWeakly(Bool.self, "isPlaying")
            .subscribe { (change) in
                if let isPlaying = change.element {
                    let layer = self.artworkBackView.layer
                    if isPlaying == true {
                        self.resumeLayer(layer)
                    } else {
                        self.pauseLayer(layer)
                    }
                }
        }
        
        //MARK: currentProgress
        _ = PlayerManager.share.rx.observeWeakly(Double.self, "currentProgress")
            .subscribe { [unowned self] (change) in
                if (self.IsScrollingByWheel == false) {
                    self.updateLRCScrollView()
                }
        }
    }
}

//MARK: - Private
extension PlayViewController {
    //MARK: 根据歌曲刷新页面信息
    private func refreshUI(withSong currentSong: Song) {
        var image:NSImage = NSImage(named: "MiniPlayerLargeAlbumDefault")!
        if let imageData = currentSong.artworkData {
            image = NSImage(data: imageData) ?? image
        }
        artworkImageView.image = image
        
        songTitle.stringValue = currentSong.title.count > 0 ? currentSong.title : "无"
        albumButton.title = currentSong.album.count > 0 ? currentSong.album : "无"
        artistButton.title = currentSong.artist.count > 0 ? currentSong.artist : "无"
        let lyrics = Utility.getMusicLyrics(withFilePath: currentSong.filePath)
        if lyrics.count > 0 {
            // 歌词长度大于0
            lrcArray = []
            analysisLyrics(lyrics:lyrics)
        }
    }
    
    //MARK: 创建并开始动画
    private func setupAndStartAnimation() {
        let layer = artworkBackView.layer

        if layer?.animation(forKey: "animation") != nil {
            layer?.removeAllAnimations()
        }
        
        let animation = CABasicAnimation.init(keyPath: "transform")
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(-CGFloat(Double.pi / 2), 0, 0, 1))
        animation.duration = 10
        animation.isCumulative = true
        animation.repeatCount = Float(INT_MAX)
        layer?.add(animation, forKey: "animation")
    }

    //MARK: 恢复动画
    private func resumeLayer(_ layer: CALayer? = nil) {
        guard (layer != nil) else { return }
        let pausedTime = layer!.timeOffset
        layer!.speed = 1.0
        layer!.timeOffset = 0.0
        layer!.beginTime = 0.0
        let timeSincePause = layer!.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer!.beginTime = timeSincePause
    }
    
    //MARK: 暂停动画
    private func pauseLayer( _ layer: CALayer? = nil) {
        guard (layer != nil) else { return }
        let pausedTime = layer!.convertTime(CACurrentMediaTime(), from: nil)
        layer!.speed = 0.0
        layer!.timeOffset = pausedTime
    }
    
    //MARK: 解析歌词
    private func analysisLyrics(lyrics contentOfLRC:String) {
        // 将歌词中的每行字符串截取出来放入数组
        var tempArrayOfLRC = contentOfLRC.components(separatedBy: "\r")
        // 去掉完全没有内容的空行，数组中每个元素的内容将为“[时间]歌词”
        tempArrayOfLRC = tempArrayOfLRC.filter { $0 != "" }
//        tempArrayOfLRC = tempArrayOfLRC.filter({ (lyric) -> Bool in
//            return lyric != ""
//        })
        // 将歌词以对应的时间为Key放入字典
        for j in 0 ..< tempArrayOfLRC.count {
            // 用“]”分割字符串，可能含有多个时间对应个一句歌词的现象,并且歌词可能为空,例如：“[00:12.34][01:56.78]”，这样分割后的数组为：["[00:12.34", "[01:56.78", ""]
            let eachLrcArray = tempArrayOfLRC[j].components(separatedBy: "]")
            let lrc = eachLrcArray.last
            let datefomat = DateFormatter()
            datefomat.dateFormat = "[mm:ss.SS"
            let date1 = datefomat.date(from: eachLrcArray[0])
            let date2 = datefomat.date(from: "[00:00.00")
            
            if let interval1 = date1?.timeIntervalSince1970, let interval2 = date2?.timeIntervalSince1970 {
                // 歌词绝对时间
                let lrcTime = abs(interval1 - interval2)
                let eachLineLrc = EachLineLrcItem(lrc: lrc!, time: lrcTime)
                lrcArray.append(eachLineLrc)
            }
        }
        
        if lrcArray.count > 0 {
            lrcScrollView.scrollToTop()
            addLrcToScrollView()
        }
    }
    
    //MARK: 将歌词添加到scrollView上
    private func addLrcToScrollView() {
        // scrollView 宽度
        let width = lrcScrollView.bounds.width
        // 歌词数组数量
        let num = lrcArray.count
        // 即将添加到scrollView上的documentView
        let documentView = DNFippedView(frame: NSRect(x: 0, y: 0, width: width, height: CGFloat(num) * kLRCLineHeight))
        // 清空lrcLabel/tempLRCTime数组
        lrcLabelArray.removeAll()
        tempLRCTime.removeAll()
        for index in 0..<lrcArray.count {
            // 创建歌词label
            let eachLineLrc = lrcArray[index]
            let lrcLabel = NSTextField(frame: NSRect(x: 0, y: CGFloat(index) * kLRCLineHeight, width: width, height: kLRCLineHeight))
            lrcLabel.stringValue = eachLineLrc.lrc
            lrcLabel.backgroundColor = NSColor.clear
            lrcLabel.textColor = kLightColor
            lrcLabel.font = NSFont.systemFont(ofSize: 14)
            lrcLabel.isBezeled = false // 边框
            lrcLabel.isEditable = false
            lrcLabel.usesSingleLineMode = true // 单行
            lrcLabel.lineBreakMode = .byTruncatingTail
            documentView.addSubview(lrcLabel)
            // 歌词label存入数组
            lrcLabelArray.append(lrcLabel)
            // time存入数组
            tempLRCTime.append(eachLineLrc.time)
        }
        lrcScrollView.documentView = documentView
    }
    
    //MARK: 刷新scrollView
    private func updateLRCScrollView() {
        // 如果歌词为空，不刷新
        if lrcArray.count == 0 || lrcLabelArray.count == 0{ return }
        guard let player = PlayerManager.share.player else { return }
        // 获取当前播放的时间
        let currentTime:TimeInterval = CMTimeGetSeconds(player.currentItem!.currentTime())
        // 总时长
        guard let maxLRCTime = PlayerManager.share.currentSong?.timeInterval else { return }
        // 当前播放时间 >= 歌词第一句时间 && 当前时间 <= 总时长
        if currentTime >= lrcArray[0].time , Double(currentTime) <= maxLRCTime {
            // 获取需要高亮的时间
            guard let selectedTime = getTheSelectedTimeBy(currentTime) else { return }
            // 获取其所在行
            guard let lrcRowNumber = tempLRCTime.firstIndex(of: selectedTime) else { return }
            // 设置所有label文字颜色、大小
            for lineLRCLabel in lrcLabelArray {
                lineLRCLabel.textColor = kLightColor
                lineLRCLabel.font = NSFont.systemFont(ofSize: 14)
            }
            // 高亮当前Label中的歌词
            let selectedLabel = lrcLabelArray[lrcRowNumber]
            selectedLabel.textColor = kWhiteHighlightColor
            selectedLabel.font = NSFont.systemFont(ofSize: 16)
            
            let labelY = selectedLabel.frame.origin.y
            let offSet = lrcScrollView.bounds.height / 2
            if labelY < offSet {
                lrcScrollView.scrollToPositionY(0)
            } else {
                lrcScrollView.scrollToPositionY(labelY - offSet)
            }
        }
    }
    
    //MARK: 获取需要高亮的时间
    private func getTheSelectedTimeBy(_ CurrentTime:TimeInterval) -> TimeInterval? {
        // 遍历时间数组，找出所有 <= 当前播放时间的item，取中间最大值
        return tempLRCTime.filter{ $0 <= CurrentTime }.max()
    }

}
