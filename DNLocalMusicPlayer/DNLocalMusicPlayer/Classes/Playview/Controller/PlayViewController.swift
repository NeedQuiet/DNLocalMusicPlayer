//
//  PlayViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class PlayViewController: BaseViewController {
    
    @IBOutlet weak var artworkBackView: NSView!
    @IBOutlet weak var artworkImageView: NSImageView!
//    var initArtworkPosition:CGPoint = CGPoint.zero
    
    @IBOutlet weak var songTitle: NSTextField!
    @IBOutlet weak var albumButton: DNTitleButton!
    @IBOutlet weak var artistButton: DNTitleButton!
    @IBOutlet weak var fromButton: DNTitleButton!
    
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

//MARK: - KVO
extension PlayViewController {
    func setupKVO() {
        //MARK: currentSong
        _ = PlayerManager.share.rx.observeWeakly(Song.self, "currentSong")
            .subscribe({  [unowned self] (change) in
                if let currentSong = change.element {
                    guard currentSong != nil else {  return }
                    self.refreshUI(withSong: currentSong!)
                    self.setupAndStartAnimation()
                }
        })
        
        //MARK: isPlaying
        _ = PlayerManager.share.rx.observeWeakly(Bool.self, "isPlaying")
            .subscribe { [unowned self] (change) in
                if let isPlaying = change.element {
                    let layer = self.artworkBackView.layer
                    if isPlaying == true {
                        self.resumeLayer(layer)
                    } else {
                        self.pauseLayer(layer)
                    }
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
}
