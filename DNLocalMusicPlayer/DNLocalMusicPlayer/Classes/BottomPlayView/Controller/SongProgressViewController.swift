//
//  SongProgressViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/21.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

class SongProgressViewController: NSViewController {
    @IBOutlet weak var progressSlider: DNSlider!
    @IBOutlet weak var progressSliderCell: DNSliderCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVO()
    }
}

//MARK: - UI配置
extension SongProgressViewController {
    //MARK: UI
    func setupUI () {
        progressSlider.minValue = 0
        progressSlider.maxValue = 100
        progressSliderCell.needControlKnobHidden = true
        progressSliderCell.delegate = self
    }
    //MARK: KVO
    func setupKVO() {
        //MARK: currentProgress
        _ = PlayerManager.share.rx.observeWeakly(Double.self, "currentProgress")
            .subscribe { [unowned self] (change) in
                if let currentProgress = change.element {
                    self.progressSlider.doubleValue = currentProgress!
                }
        }
        
        //MARK: currentSong
        _ = PlayerManager.share.rx.observeWeakly(Song.self, "currentSong")
            .subscribe({  [unowned self] (change) in
                if let currentSong = change.element {
                    self.progressSlider.isEnabled = currentSong != nil
                }
        })
    }
}

//MARK: - DNSliderCellDelegate
extension SongProgressViewController: DNSliderCellDelegate{
    //MARK: 开始拖动
    func startTracking(doubleValue:Double ,sender:DNSliderCell) {
        PlayerManager.share.canObservProgress = false
    }
    
    //MARK: 拖动中
    func continueTracking(doubleValue:Double ,sender:DNSliderCell) {
        NotificationCenter.default.post(name: kProgressContinueTracking, object: doubleValue)
    }
    
    //MARK: 结束拖动 & 点击结束
    func stopTracking(doubleValue:Double ,sender:DNSliderCell) {
        // 先设置canObservProgress，防止抖动
        PlayerManager.share.canObservProgress = true
        // seek
        let progress = progressSlider.doubleValue
        PlayerManager.share.seekToProgress(progress)
    }
}
