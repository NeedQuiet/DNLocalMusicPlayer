//
//  DNSliderCell.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/22.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

@objc protocol DNSliderCellDelegate {
    // 开始拖动
    @objc optional func startTracking(doubleValue:Double ,sender:DNSliderCell)
    // 正在拖动
    @objc optional func continueTracking(doubleValue:Double ,sender:DNSliderCell)
    // 拖动结束 & 点击结束
    @objc optional func stopTracking(doubleValue:Double ,sender:DNSliderCell)
}

class DNSliderCell: NSSliderCell {
    let Offset:CGFloat = 2 // 进度条，实际上向（根据slider方向）左/右 或者 上/下 偏移2
    let progressColor = kRedHighlightColor // 进度条进度背景色
    var backgroundColor = NSColor.clear // 进度条整体背景色
    let knobColor = kRedHighlightColor // 按钮颜色
    let sliderThickness:CGFloat = 3.0 // 进度条厚度
    let sliderBarRadius:CGFloat = 0 // 进度条圆角
    let KnobWidth:CGFloat = 12.0 // 按钮宽度
    let KnobHeight:CGFloat = 12.0 // 按钮高度
    var progressRect = NSRect() // 进度的Rect
    var needControlKnobHidden = false // 是否需要控制旋钮显示隐藏
    
    weak var delegate:DNSliderCellDelegate?
    
    // slider是否是竖直
    lazy var isSliderVertical:Bool = {
        let isVertical = (controlView as? DNSlider)?.isVertical == true
        return isVertical
    }()
}

extension DNSliderCell {
    //MARK: - 重绘slider
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        //MARK: 修改进度条'整体'背景色
        // 1. 获取 slider 的 rect
        var sliderRect = rect
        // 2. 更改 slider 厚度
        if isSliderVertical {
            sliderRect.size.width = sliderThickness
        } else {
            sliderRect.size.height = sliderThickness
        }
        // 3. 填充背景色
        let background = NSBezierPath(roundedRect: sliderRect, xRadius: sliderBarRadius, yRadius: sliderBarRadius)
        self.backgroundColor.setFill()
        background.fill()
        
        //MARK: 修改进度条'进度'背景色
        // 1. 计算当前进度的占有比例
        let value:CGFloat = CGFloat((doubleValue - minValue) / (maxValue - minValue))
        // 2. 根据比例计算进度应有的长度
        var viewLength:CGFloat
        if isSliderVertical {
            viewLength = (controlView?.frame.size.height)!
        } else {
            viewLength = (controlView?.frame.size.width)!
        }
 
        let finalLength:CGFloat = value * (viewLength - Offset * 2)
        // 3. 计算进度的Rect
        progressRect = sliderRect
        if isSliderVertical {
            progressRect.size.height = finalLength
            progressRect.origin.y = Offset
        } else {
            progressRect.size.width = finalLength
            progressRect.origin.x = Offset
        }
        
        // 4. 填充进度背景色
        let active = NSBezierPath(roundedRect: progressRect, xRadius: sliderBarRadius, yRadius: sliderBarRadius)
        self.progressColor.setFill()
        active.fill()
    }
    
    //MARK: - 重绘旋钮
    override func drawKnob() {
        // 根据比例计算进度应有的OriginX
        let value:CGFloat = CGFloat((doubleValue - minValue) / (maxValue - minValue))
        var viewLength:CGFloat
        if isSliderVertical{
            viewLength = (controlView?.frame.size.height)!
        } else {
            viewLength = (controlView?.frame.size.width)!
        }
        
        var customKnobRect:NSRect
        
        if isSliderVertical {
            //                   Offset +  进度  * ((       实际宽度     ) -  knob宽度 )
            let finalStart:CGFloat = Offset + value * (viewLength - Offset * 2 - KnobHeight)
            // 计算Knob的Rect
            customKnobRect = NSRect(x: progressRect.origin.x + progressRect.size.width / 2 - KnobWidth / 2, y: finalStart, width: KnobWidth , height: KnobHeight)
        } else {
            //                   Offset +  进度  * ((       实际宽度      ) -  knob宽度 )
            let finalStart:CGFloat = Offset + value * (viewLength - Offset * 2 - KnobWidth)
            // 计算Knob的Rect
            customKnobRect = NSRect(x: finalStart, y: progressRect.origin.y + progressRect.size.height / 2 - KnobHeight / 2, width: KnobWidth , height: KnobHeight)
        }
        
        
        // 填充Knob的颜色
        let background = NSBezierPath(roundedRect: customKnobRect, xRadius: KnobWidth / 2, yRadius: KnobHeight / 2)
        if needControlKnobHidden == true {
            if (controlView as? DNSlider)?.shouKnob == true {
                self.knobColor.setFill()
            } else {
                NSColor.clear.setFill()
            }
        } else {
            self.knobColor.setFill()
        }

        background.fill()
    }
}

extension DNSliderCell {
    //MARK: 开始拖动
    override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        delegate?.startTracking?(doubleValue: doubleValue, sender: self)
        (controlView as? DNSlider)?.shouKnob = true
        return super.startTracking(at: startPoint, in: controlView)
    }
    
    //MARK: 拖动中
    override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        delegate?.continueTracking?(doubleValue: doubleValue, sender: self)
        return super.continueTracking(last: lastPoint, current: currentPoint, in: controlView)
    }
    
    //MARK: 结束拖动 & 点击结束
    override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
        delegate?.stopTracking?(doubleValue: doubleValue, sender: self)
        super.stopTracking(last: lastPoint, current: stopPoint, in: controlView, mouseIsUp: flag)
    }
}
