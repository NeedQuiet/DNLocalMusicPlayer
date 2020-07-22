//
//  VolumePopover.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/3.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

class VolumePopover: BaseViewController {

    @IBOutlet weak var volumeSlider: DNVolumeSlider!
    @IBOutlet weak var volumeSliderCell: DNSliderCell!
    var isTrackingVolume:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVO()
    }
}

//MARK: - UI配置
extension VolumePopover {
    //MARK: - 设置UI
    func setupUI() {
        setBackgroundColor(r: 37, g: 37, b: 37)
        
        volumeSlider.minValue = 0
        volumeSlider.maxValue = 100
        volumeSliderCell.backgroundColor = kLightColor
        volumeSliderCell.delegate = self
    }
    
    //MARK: - KVO
    func setupKVO() {
        // 监听音量变化
        _ = PlayerManager.share.rx
            .observeWeakly(Float.self, "volume")
            .subscribe({[unowned self] (event) in
                if let volume = event.element , volume != nil , self.isTrackingVolume == false{
                    self.volumeSlider.doubleValue = Double(volume! * 100)
                }
        })
    }
}

//MARK: - DNSliderCellDelegate
extension VolumePopover: DNSliderCellDelegate{
    //MARK: 拖动中
    func continueTracking(doubleValue:Double ,sender:DNSliderCell) {
        let volume = Float(volumeSlider.doubleValue / 100)
        PlayerManager.share.changeVolume(volume)
        isTrackingVolume = true
    }
    
    //MARK: 结束拖动
    func stopTracking(doubleValue:Double ,sender:DNSliderCell) {
        let volume = Float(volumeSlider.doubleValue / 100)
        PlayerManager.share.changeVolume(volume)
        isTrackingVolume = false
    }
}
