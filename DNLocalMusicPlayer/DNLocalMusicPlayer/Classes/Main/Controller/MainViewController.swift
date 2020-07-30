//
//  MainViewController.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

class MainViewController: NSViewController {
    //MARK: 结构
    @IBOutlet weak var mainContainerView: NSView!
    
    //MARK: PlayView
    @IBOutlet weak var playViewTop: NSLayoutConstraint!
    @IBOutlet weak var playViewContainerView: NSView!
    private var defaultPlayViewHeight: CGFloat = 0
    
    //MARK: CurrentPlaylist
    @IBOutlet weak var currentPlaylistContainerView: NSView!
    private var showCurrentPlaylist: Bool = false
    var currentPlaylistView: NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKVO()
        setupPlayContainerView()
        setupCurrentPlayListContainerView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

//MARK: - KVO
extension MainViewController {
    func setupKVO() {
        //MARK: 监听 WindowManager.share.playViewIsShow
        _ = WindowManager.share.rx.observeWeakly(Bool.self, "playViewIsShow")
            .subscribe { [unowned self] (change) in
            if let playViewIsShow = change.element {
                self.showPlayView(show: playViewIsShow!)
            }
        }
        
        //MARK: 监听 WindowManager.share.currentPlaylistIsShow
        _ = WindowManager.share.rx.observeWeakly(Bool.self, "currentPlaylistIsShow")
            .subscribe({  [unowned self] (change) in
            if let currentPlaylistIsShow = change.element {
                self.showCurrentPlayListView(show: currentPlaylistIsShow!)
            }
        })
    }
}

//MARK: - PlayView
extension MainViewController {
    //MARK: 配置palyView
    func setupPlayContainerView() {
        // 删除autoresizingMask
        playViewContainerView.autoresizingMask = []
        // 保留默认高度，在隐藏playview后，将top设为默认高度，防止窗口大小被top撑起来无法缩小
        defaultPlayViewHeight = mainContainerView.bounds.size.height - 60
        playViewTop.constant = defaultPlayViewHeight
        // 收起时隐藏
        self.playViewContainerView.isHidden = true
    }
    
    //MARK: 显示/隐藏 PlayView
    func showPlayView(show:Bool) {
        var top:CGFloat = 0
        if show == true {
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
            if show == false {
                self.playViewContainerView.isHidden = true
                self.playViewTop.constant = self.defaultPlayViewHeight
            }
        }
    }
}

//MARK: - CurrentPlayList
extension MainViewController {
    //MARK: 配置 currentPlaylistView
    func setupCurrentPlayListContainerView() {
        currentPlaylistContainerView.isHidden = true
    }
    
    //MARK: 显示/隐藏 currentPlaylist
    func showCurrentPlayListView(show:Bool) {
        currentPlaylistContainerView.isHidden = !show
    }
}

