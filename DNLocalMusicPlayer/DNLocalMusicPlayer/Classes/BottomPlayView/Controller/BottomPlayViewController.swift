//
//  BottomPlayViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class BottomPlayViewController: BaseViewController {
    
    //MARK: 专辑图按钮
    @IBOutlet weak var albumButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
    }
}

//MARK: - UI设置
extension BottomPlayViewController {
    func setupUI() {
        setBackgroundColor(r: 37, g: 37, b: 37)
        albumButton.image = NSImage.init(named: "MiniPlayerMiniAlbumDefault")
        albumButton.setCornerRadius(radius: 4)
    }
}

//MARK: - 按钮点击事件
extension BottomPlayViewController {
    //MARK: 专辑图点击
    @IBAction func albumButtonClick(_ sender: NSButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePlayViewState"), object: nil)
    }
}
