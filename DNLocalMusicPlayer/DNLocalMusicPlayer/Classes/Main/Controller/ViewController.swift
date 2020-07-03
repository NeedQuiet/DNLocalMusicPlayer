//
//  ViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var playViewTop: NSLayoutConstraint!
    @IBOutlet weak var playViewContainerView: NSView!
    private var playViewIsShow: Bool = false
    private var defaultPlayViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化 PlayView 显示状态
        setupPlayContainerView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

//MARK: - PlayViewContainerView
extension ViewController {
    func setupPlayContainerView() {
        // 监听 展示/隐藏 状态
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayViewState), name: NSNotification.Name(rawValue: "changePlayViewState"), object: nil)
        // 删除autoresizingMask
        playViewContainerView.autoresizingMask = []
        // 保留默认高度，在隐藏playview后，将top设为默认高度，防止窗口大小被top撑起来无法缩小
        defaultPlayViewHeight = view.bounds.size.height - 60
        playViewTop.constant = defaultPlayViewHeight
        // 收起时隐藏
        self.playViewContainerView.isHidden = true
    }
    
    @objc func changePlayViewState() {
        playViewIsShow = !playViewIsShow
        var top:CGFloat = 0
        if playViewIsShow == true {
            // 展示playView前先显示
            self.playViewContainerView.isHidden = false
            top = 0
        } else {
            top = view.bounds.size.height - 60
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            self.playViewTop.animator().constant = top
        }) {
            // 收起playView后，先隐藏playView，后将top设为默认高度，防止窗口大小被top撑起来无法缩小
            if self.playViewIsShow == false {
                self.playViewContainerView.isHidden = true
                self.playViewTop.constant = self.defaultPlayViewHeight
            }
        }
    }
}

