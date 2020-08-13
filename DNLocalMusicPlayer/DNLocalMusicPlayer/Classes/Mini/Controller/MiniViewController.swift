//
//  MiniViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/10.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class MiniViewController: NSViewController {
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var enlargeButton: NSButton!
    @IBOutlet weak var albumButton: CustomAlbumButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

//MARK: - IBAction
extension MiniViewController {
    //MARK: 关闭
    @IBAction func closeButtonClick(_ sender: Any) {
    }
    
    //MARK: 恢复大窗口
    @IBAction func showMainWindow(_ sender: Any) {
        WindowManager.share.showMainWindow()
    }
}
