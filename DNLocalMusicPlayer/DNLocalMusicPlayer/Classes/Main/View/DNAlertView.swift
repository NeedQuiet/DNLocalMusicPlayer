//
//  CustomAlertView.swift
//  DNLocalMusicPlayer
//
//  Created by 许一宁 on 2020/7/16.
//  Copyright © 2020 大宁. All rights reserved.
//

import Cocoa
import RxCocoa

enum DNAlertType {
    case defaultType
    case textFieldType
}

class DNAlertView: NSView {

    private var type:DNAlertType?
    private var superVC:NSViewController = NSViewController()
    private var placeholderString:String?
    private var callBack:(String) -> () = {_ in }
    var defaultString:String = "" {
        didSet {
            textField.stringValue = defaultString
            if defaultString.count == 0 {
                setSubmitButtonEanbled(isEnabled: false)
            }
        }
    }
    
    // 提示框背景
    @IBOutlet weak var alertBackView: NSView!
    // 标题
    @IBOutlet weak var titleLabel: NSTextField!
    // message
    @IBOutlet weak var messageLabel: NSTextField!
    // textField
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var textfieldBackView: NSView!
    // 确认按钮
    @IBOutlet weak var submitButton: NSButton!
    // 关闭按钮
    @IBOutlet weak var closeButton: NSButton!


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    static func initialization() -> DNAlertView {
        var topLevelObjects : NSArray?
        _ = Bundle.main.loadNibNamed("DNAlertView", owner: self,topLevelObjects: &topLevelObjects)
        return topLevelObjects!.first(where: { $0 is DNAlertView }) as! DNAlertView
    }
    
    // 重写mouseDown方法，防止鼠标点击穿透至下一层
    override func mouseDown(with event: NSEvent) {}
}

extension DNAlertView {
    //MARK: 设置信息
    func setInfo(title:String, message:String? = "", buttonTitle:String? = "OK", placeholderString:String? = "请输入" ,type:DNAlertType? = .defaultType) {
        titleLabel.stringValue = title
        messageLabel.stringValue = message!
        self.placeholderString = placeholderString
        self.type = type
        setupUI()
        setKVO()
    }
    
    //MARK: 设置UI
    func setupUI() {
        alertBackView.setBackgroundColor(color: NSColor(r: 41, g: 41, b: 41))
        alertBackView.setCornerRadius(4)
        
        titleLabel.textColor = kDefaultColor
        
        if messageLabel.stringValue.count == 0 {
            messageLabel.isHidden = true
        }

        if type == DNAlertType.textFieldType {
            textfieldBackView.setBackgroundColor(color: NSColor(r: 52, g: 52, b: 52))
            textfieldBackView.setCornerRadius(4)
            textField.backgroundColor = NSColor.clear
            textField.placeholderString = placeholderString!
            textField.textColor = kDefaultColor
            textField.delegate = self
        } else {
            textfieldBackView.isHidden = true
        }
        
        submitButton.setBackgroundColor(color: kRedHighlightColor)
        submitButton.setCornerRadius(15)
        submitButton.contentTintColor = kWhiteHighlightColor
    }
    
    func setKVO() {
        // 监听窗口size变化
        _ = NotificationCenter.default.rx
            .notification(NSWindow.didResizeNotification, object: nil)
            .subscribe({ [unowned self] (event) in
                if let windowView = self.superVC.view.window?.contentView {
                    self.frame = NSRect(x: 0, y: 60, width: windowView.bounds.size.width, height: windowView.bounds.size.height - 60 - 50)
                }
            })
    }
    
    func setSubmitButtonEanbled(isEnabled:Bool) {
        submitButton.isEnabled = isEnabled
        submitButton.alphaValue = isEnabled ? 1.0 : 0.5
    }
}

//MARK: - IBAction
extension DNAlertView {
    //MARK: 关闭
    @IBAction func closeButtonClick(_ sender: Any) {
        self.removeFromSuperview()
    }
    //MARK: 确认
    @IBAction func submitButtonClick(_ sender: Any) {
        if type == DNAlertType.textFieldType {
            callBack(textField.stringValue)
        }
        self.removeFromSuperview()
    }
}

//MARK: - Public
extension DNAlertView {
    // 显示
    func show(target:NSViewController, finishCallBack: @escaping (_ string:String) -> ()) {
        superVC = target
        self.callBack = finishCallBack
        if let windowView = superVC.view.window?.contentView {
            self.frame = NSRect(x: 0, y: 60, width: windowView.bounds.size.width, height: windowView.bounds.size.height - 60 - 50)
            windowView.addSubview(self)
            if type == DNAlertType.textFieldType {
                textField.becomeFirstResponder()
            }
        }
    }
}

//MARK: - NSTextFieldDelegate
extension DNAlertView: NSTextFieldDelegate {
    // textField 文字内容改变
    func controlTextDidChange(_ obj: Notification) {
        let tf = obj.object as? NSTextField
        print("controlTextDidChange,text:" + (tf?.stringValue ?? ""))
        setSubmitButtonEanbled(isEnabled: textField.stringValue.count > 0)
    }
}
