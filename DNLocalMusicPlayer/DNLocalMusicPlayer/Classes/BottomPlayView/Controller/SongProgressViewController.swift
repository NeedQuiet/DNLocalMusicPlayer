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
    @IBOutlet weak var progressSlider: NSSlider!
    
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
    }
}

//MARK: - Action
extension SongProgressViewController {
    @IBAction func sliderClick(_ sender: Any) {
        if PlayerManager.share.currentSong != nil{
            let progress = progressSlider.doubleValue
            PlayerManager.share.seekToProgress(progress)
        } else {
            self.progressSlider.doubleValue = 0
        }
    }
}
