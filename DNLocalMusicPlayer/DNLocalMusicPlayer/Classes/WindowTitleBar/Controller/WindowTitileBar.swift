//
//  WindowTitileBar.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/21.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

class WindowTitileBar: NSViewController {
    //MARK: 关闭PlayView按钮
    @IBOutlet weak var closeButton: DNButton!
    
    @IBOutlet weak var controlContainer: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        setupKVOAndNotifi()
        self.view.window?.title = "aaaa"
    }
}

//MARK: - UI设置
extension WindowTitileBar {
    private func setupUI() {
        closeButton.isHidden = true
    }
}

//MARK: - KVO & Notification
extension WindowTitileBar {
    private func setupKVOAndNotifi() {
        //MARK: 监听 WindowManager.share.playViewIsShow
        _ = WindowManager.share.rx.observeWeakly(Bool.self, "playViewIsShow")
            .subscribe { [weak self] (change) in
            if let playViewIsShow = change.element {
                self?.closeButton.isHidden = !playViewIsShow!
            }
        }
    }
}

//MARK: - Action
extension WindowTitileBar {
    @IBAction func closeButtonClick(_ sender: Any) {
        WindowManager.share.showPlayView(show: false)
    }
}
