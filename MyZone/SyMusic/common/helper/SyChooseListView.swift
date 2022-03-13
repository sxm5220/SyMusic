//
//  SyChooseListView.swift
//  SyMusic
//
//  Created by sxm on 2020/5/18.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

typealias ResultSure = (String) -> Void

class SyChooseListView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var id: String?
    var myClosure: ResultSure?
    private let viewbgColor = UIColor.black
    private let viewAlpha = 0.8
    private let pickerHeight: CGFloat = 266
    private let bgHeight: CGFloat = 306
    
    fileprivate lazy var bgView: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: screenHeight(), width: screenWidth(), height: bgHeight)
        view.backgroundColor = viewbgColor
        view.alpha = viewAlpha
        return view
    }()
    
    fileprivate lazy var pickerView :UIPickerView = {
        let pv = UIPickerView()
        pv.frame = CGRect.init(x: 0, y: bgHeight - pickerHeight - 30, width: screenWidth(), height: pickerHeight)
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    fileprivate lazy var toolBarView: UIView = {
        let tv = UIView()
        tv.frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: bgHeight - pickerHeight + 10)
        tv.backgroundColor = viewbgColor
        tv.alpha = viewAlpha
        return tv
    }()
    
    fileprivate lazy var cancleBtn: UIButton = {
        let btn = buttonWithTitleFrame(frame: CGRect.init(x: 10, y: 10, width: 50, height: bgHeight - pickerHeight - 10), title: strCommon(key: "sy_canel"), titleColor: .white, backgroundColor: .clear, cornerRadius: 5, tag: 10, target: self, action: #selector(actionBtnClick(sender:)))
        return btn
    }()
    
    fileprivate lazy var sureBtn: UIButton = {
        let btn = buttonWithTitleFrame(frame: CGRect.init(x: screenWidth() - 60, y: 10, width: 50, height: bgHeight - pickerHeight - 10), title: strCommon(key: "sy_sure"), titleColor: .white, backgroundColor: .clear, cornerRadius: 5, tag: 11, target: self, action: #selector(actionBtnClick(sender:)))
        return btn
    }()
    
    @objc
    func actionBtnClick(sender: UIButton) {
        self.hidePickerView()
        switch sender.tag {
        case 11:
            if self.myClosure != nil {
                self.myClosure!(self.id!)
            }
        default:
            break
        }
    }
    
    fileprivate lazy var dataSource: [SyMusicsItem] = {
        let array: [SyMusicsItem] = [SyMusicsItem]()
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubViews()
    }
    
    convenience init(frame: CGRect, dataSource: [SyMusicsItem]) {
        self.init(frame: frame)
        self.dataSource = dataSource
        if self.dataSource.count > 0 {
            let model = self.dataSource[0]
            self.id = model.id
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //loadSubViews
    func initSubViews() -> Void {
        self.addSubview(self.bgView)
        
        self.bgView.addSubview(self.pickerView)
        self.bgView.addSubview(self.toolBarView)
        self.toolBarView.addSubview(self.cancleBtn)
        self.toolBarView.addSubview(self.sureBtn)
        
        self.showPickerView()
    }
    
    //showPickerView
    func showPickerView() -> Void {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.bgView.frame = CGRect.init(x: 0, y: screenHeight() - self.bgHeight - (isIphoneX() ? 50 : 30), width: screenWidth(), height: self.bgHeight + (isIphoneX() ? 50 : 30))
        }
    }
    
    //hidePickerView
    func hidePickerView() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.frame = CGRect.init(x: 0, y: screenHeight(), width: screenWidth(), height: self.bgHeight + (isIphoneX() ? 50 : 30))
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = .white
        if self.dataSource.count > row {
            let model = self.dataSource[row]
            label.text = model.name
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.dataSource.count > row {
            let model = self.dataSource[row]
            self.id = model.id
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hidePickerView()
    }
    
}
