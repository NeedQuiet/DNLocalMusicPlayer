//
//  NSColor-Extension.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/2.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class NSColor_Extension: NSColor {

}

extension NSColor {
    convenience init (r : CGFloat, g : CGFloat, b : CGFloat) {
        self.init(calibratedRed: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
}
