//
//  MainViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    //MARK: 结构
    @IBOutlet weak var titleBarView: NSView!
    @IBOutlet weak var mainContainerView: NSView!
    
    //MARK: PlayView
    @IBOutlet weak var playViewTop: NSLayoutConstraint!
    @IBOutlet weak var playViewContainerView: NSView!
    private var playViewIsShow: Bool = false
    private var defaultPlayViewHeight: CGFloat = 0
    
    //MARK: CurrentPlaylist
    @IBOutlet weak var currentPlaylistContainerView: NSView!
    private var showCurrentPlaylist: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayContainerView()
        setupCurrentPlayListContainerView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

//MARK: - PlayView
extension MainViewController {
    func setupPlayContainerView() {
        // 监听 展示/隐藏 状态
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayViewState), name: NSNotification.Name(rawValue: BottomPVNotifications.albumClick.rawValue), object: nil)
        // 删除autoresizingMask
        playViewContainerView.autoresizingMask = []
        // 保留默认高度，在隐藏playview后，将top设为默认高度，防止窗口大小被top撑起来无法缩小
        defaultPlayViewHeight = mainContainerView.bounds.size.height - 60
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
            top = mainContainerView.bounds.size.height - 60
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

//MARK: - CurrentPlayList
extension MainViewController {
    func setupCurrentPlayListContainerView() {
        currentPlaylistContainerView.isHidden = true
        // 监听 展示/隐藏 状态
        NotificationCenter.default.addObserver(self, selector: #selector(changeCurrentPlayListViewState), name: NSNotification.Name(rawValue: BottomPVNotifications.playlistClick.rawValue), object: nil)
    }
    
    @objc func changeCurrentPlayListViewState() {
        showCurrentPlaylist = !showCurrentPlaylist
        currentPlaylistContainerView.isHidden = !showCurrentPlaylist
    }
}

