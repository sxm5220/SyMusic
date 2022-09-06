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
    private let toolBarHeight: CGFloat = 50
    private let pickerHeight: CGFloat = 250
    private let bgHeight: CGFloat = 300
    
    fileprivate lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = viewbgColor
        view.alpha = viewAlpha
        return view
    }()
    
    fileprivate lazy var pickerView :UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    fileprivate lazy var toolBarView: UIView = {
        let tv = UIView()
        tv.backgroundColor = viewbgColor
        tv.alpha = viewAlpha
        return tv
    }()
    
    fileprivate lazy var cancleBtn: UIButton = {
        let btn = buttonWithTitleFrame(title: strCommon(key: "sy_canel"), titleColor: .white, backgroundColor: .clear, cornerRadius: 5, tag: 0, target: self, action: #selector(actionBtnClick(sender:)))
        return btn
    }()
    
    fileprivate lazy var sureBtn: UIButton = {
        let btn = buttonWithTitleFrame(title: strCommon(key: "sy_sure"), titleColor: .white, backgroundColor: .clear, cornerRadius: 5, tag: 1, target: self, action: #selector(actionBtnClick(sender:)))
        return btn
    }()
    
    @objc
    func actionBtnClick(sender: UIButton) {
        self.hidePickerView()
        switch sender.tag {
        case 0:
            self.hidePickerView()
        case 1:
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
    
    //TODO: snapkit动画没有实现????
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.addSubview(self.bgView)
        [self.cancleBtn,self.sureBtn].forEach { view in
            self.toolBarView.addSubview(view)
        }
        [self.pickerView,self.toolBarView].forEach { view in
            self.bgView.addSubview(view)
        }
        
        self.bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(self.bgHeight)
        }
        
        self.pickerView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(self.pickerHeight)
        }
        
        self.toolBarView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(self.toolBarHeight)
        }
        
        self.cancleBtn.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        self.sureBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }
    
    convenience init(dataSource: [SyMusicsItem]) {
        self.init(frame: CGRect.zero)
        self.dataSource = dataSource
        if self.dataSource.count > 0 {
            let model = self.dataSource[0]
            self.id = model.id
        }
        /*///  告诉self.view约束需要更新
        self.needsUpdateConstraints()
        /// 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
        self.updateConstraintsIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            self.bgView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().offset(-self.bgHeight)
            })
           ///更新动画
            self.layoutIfNeeded()
        }*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //hidePickerView
    private func hidePickerView() {
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.bgView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            ///更新动画
//            self.layoutIfNeeded()
            self.alpha = 0
            UIView.animate(withDuration: 0.2) {
                self.removeFromSuperview()
            }
        }
        /*UIView.animate(withDuration: 0.5, animations: {
            self.bgView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            ///更新动画
            self.layoutIfNeeded()
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }*/
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 30))
//        label.adjustsFontSizeToFitWidth = true
//        label.textAlignment = NSTextAlignment.center
//        label.textColor = .white
        let label = SyLabel(text: "", textColor: .white, font: UIFont.systemFont(ofSize: 18), textAlignment: .center)
        label.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 30)
        label.adjustsFontSizeToFitWidth = true
        if self.dataSource.count > row {
            let musicItem = self.dataSource[row]
            label.text = musicItem.musicName
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
