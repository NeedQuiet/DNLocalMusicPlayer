//
//  DNProgressSliderCell.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/21.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa

class DNProgressSliderCell: NSSliderCell {
    let Offset:CGFloat = 2 // 进度条，实际上像左/右各偏移2
    let progressColor = kRedHighlightColor // 进度条进度背景色
    let backgroundColor = NSColor.clear // 进度条整体背景色
    let knobColor = kRedHighlightColor // 按钮颜色
    let sliderHeight:CGFloat = 3.0 // 进度条高度
    let sliderBarRadius:CGFloat = 0 // 进度条圆角
    let KnobWidth:CGFloat = 12.0 // 按钮宽度
    let KnobHeight:CGFloat = 12.0 // 按钮高度
    
    var progressRect = NSRect() // 进度的Rect
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func drawBar(inside rect: NSRect, flipped: Bool) {
        //MARK: 修改进度条'整体'背景色
        // 1. 获取 slider 的 rect
        var sliderRect = rect
        // 2. 更改 slider 高度
        sliderRect.size.height = sliderHeight
        // 3. 填充背景色
        let background = NSBezierPath(roundedRect: sliderRect, xRadius: sliderBarRadius, yRadius: sliderBarRadius)
        self.backgroundColor.setFill()
        background.fill()
        
        //MARK: 修改进度条'进度'背景色
        // 1. 计算当前进度的占有比例
        let value:CGFloat = CGFloat((doubleValue - minValue) / (maxValue - minValue))
        // 2. 根据比例计算进度应有的宽度
        let viewWith = (controlView?.frame.size.width)!
        let finalWidth:CGFloat = value * (viewWith - Offset * 2)
        // 3. 计算进度的Rect
        progressRect = sliderRect
        progressRect.size.width = finalWidth
        progressRect.origin.x = Offset
        // 4. 填充进度背景色
        let active = NSBezierPath(roundedRect: progressRect, xRadius: sliderBarRadius, yRadius: sliderBarRadius)
        self.progressColor.setFill()
        active.fill()
    }
    
    override func drawKnob() {
        // 根据比例计算进度应有的OriginX
        let value:CGFloat = CGFloat((doubleValue - minValue) / (maxValue - minValue))
        let viewWith = (controlView?.frame.size.width)!
        //                   Offset +  进度  * ((       实际宽度     ) -  knob宽度 )
        let finalX:CGFloat = Offset + value * (viewWith - Offset * 2 - KnobWidth)
        // 计算Knob的Rect
        let customKnobRect = NSRect(x: finalX, y: progressRect.origin.y + progressRect.size.height / 2 - KnobHeight / 2, width: KnobWidth , height: KnobHeight)
        // 填充Knob的颜色
        let background = NSBezierPath(roundedRect: customKnobRect, xRadius: KnobWidth / 2, yRadius: KnobHeight / 2)
        if (controlView as? DNProgressSlider)?.shouKnob == true {
            self.knobColor.setFill()
        } else {
            NSColor.clear.setFill()
        }
        
        background.fill()
    }
    
    //MARK: 开始拖动
    override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        NotificationCenter.default.post(name: SliderNotification.startTracking, object: doubleValue)
        (controlView as? DNProgressSlider)?.shouKnob = true
        return super.startTracking(at: startPoint, in: controlView)
    }
    
    //MARK: 拖动中
    override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        NotificationCenter.default.post(name: SliderNotification.continueTracking, object: doubleValue)
        return super.continueTracking(last: lastPoint, current: currentPoint, in: controlView)
    }
    
    //MARK: 结束拖动
    override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
        NotificationCenter.default.post(name: SliderNotification.stopTracking, object: doubleValue)
        super.stopTracking(last: lastPoint, current: stopPoint, in: controlView, mouseIsUp: flag)
    }
}
