//
//  String-Extension.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/8/7.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class String_Extension: NSString {

}

extension String {
    //MARK: 查找string的首个NSRange
    func rangeOfString(_ string:String, ignoreCase:Bool? = false) -> NSRange? {
        // 判断是否忽略大小写
        let options:CompareOptions = ignoreCase! ? [.regularExpression, .caseInsensitive] : [.regularExpression]
        if let range:Range = self.range(of: string, options: options, range: self.range(of: self), locale: nil){
            let location = self.distance(from: self.startIndex, to: range.lowerBound)
            let nsRange = NSRange(location: location, length: string.count)
            return nsRange
        }
        return nil
    }
    
    //MARK: 查找String的所有NSRange数组（可设置是否忽略大小写）
    func rangesOfString(_ string:String, ignoreCase:Bool? = false) -> [NSRange] {
        // 判断是否忽略大小写
        let options:CompareOptions = ignoreCase! ? [.regularExpression, .caseInsensitive] : [.regularExpression]
        // 返回的NSRange数组
        var rangeArray:[NSRange] = []
        // 搜索到的Range
        var range:Range? = self.range(of: string, options: options, range: self.range(of: self), locale: nil)
        // 启动shile，添加并重新计算查询，如果range在while循环中最终为nil则终止
        while let searchRange = range {
            // 搜索到的location
            let location = self.distance(from: self.startIndex, to: searchRange.lowerBound)
            // 根据location和length创建NSRange
            let nsRange = NSRange(location: location, length: string.count)
            // 添加进数组
            rangeArray.append(nsRange)
            // 重新计算Range（前闭后开的区域 searchRange.upperBound..<self.endIndex）
            let searchedRange = Range(uncheckedBounds: (searchRange.upperBound, self.endIndex))
            range = self.range(of: string, options: options, range: searchedRange, locale: nil)
        }
        return rangeArray
    }
    
}
