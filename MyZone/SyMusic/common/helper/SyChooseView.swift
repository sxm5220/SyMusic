//
//  SyChooseView.swift
//  SyMusic
//
//  Created by sxm on 2020/5/18.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

//public let pickerHeight: CGFloat = 266
//public let bgHeight: CGFloat = 306

typealias ResultClosure = (String, String, String) -> Void

class SyChooseView: UIView,  UIPickerViewDelegate , UIPickerViewDataSource {
    
    var selectRow: Int = 0
    
    var provinceStr: String?
    var cityStr: String?
    var areaStr: String?
    
    var myClosure: ResultClosure?
    
    fileprivate lazy var bgView: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: screenHeight(), width: screenWidth(), height: bgHeight)
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var pickerView :UIPickerView = {
        let pv = UIPickerView()
        pv.frame = CGRect.init(x: 0, y: bgHeight - pickerHeight, width: screenWidth(), height: pickerHeight)
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    fileprivate lazy var toolBarView: UIView = {
        let tv = UIView()
        tv.frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: bgHeight - pickerHeight)
        tv.backgroundColor = UIColor.systemGroupedBackground
        return tv
    }()
    
    fileprivate lazy var cancleBtn: UIButton = {
        let btn = buttonWithTitleFrame(frame: CGRect.init(x: 10, y: 5, width: 50, height: bgHeight - pickerHeight - 10), title: strCommon(key: "sy_canel"), titleColor: UIColor.black, backgroundColor: .clear, cornerRadius: 5, tag: 10, target: self, action: #selector(actionBtnClick(sender:)))
        return btn
    }()
    
    fileprivate lazy var sureBtn: UIButton = {
        let btn = buttonWithTitleFrame(frame: CGRect.init(x: screenWidth() - 60, y: 5, width: 50, height: bgHeight - pickerHeight - 10), title: strCommon(key: "sy_sure"), titleColor: .black, backgroundColor: .clear, cornerRadius: 5, tag: 11, target: self, action: #selector(actionBtnClick(sender:)))
        return btn
    }()
    
    @objc
    func actionBtnClick(sender: UIButton) {
        self.hidePickerView()
        switch sender.tag {
        case 11:
            if self.myClosure != nil {
                self.myClosure!(self.provinceStr!, self.cityStr!, self.areaStr!)
            }
        default:
            break
        }
    }
    
    fileprivate lazy var provinceArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    fileprivate lazy var cityArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    fileprivate lazy var areaArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    fileprivate lazy var dataSource: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubViews()
        self.loadDatas()
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
            self.bgView.frame = CGRect.init(x: 0, y: screenHeight() - bgHeight - (isIphoneX() ? 100 : 30), width: screenWidth(), height: bgHeight + (isIphoneX() ? 100 : 30))
        }
    }
    
    //hidePickerView
    func hidePickerView() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.frame = CGRect.init(x: 0, y: screenHeight(), width: screenWidth(), height: bgHeight + (isIphoneX() ? 100 : 30))
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    func loadDatas() -> Void {
        let path = Bundle.main.path(forResource: "city", ofType: "plist")
        self.dataSource = NSArray.init(contentsOfFile: path!)!
        
        let tempArray = NSMutableArray()
        for dic in self.dataSource {
            for (province,_) in dic as! NSDictionary {
                tempArray.add(province)
            }
        }
        
        self.provinceArray = tempArray.copy() as! NSArray
        self.cityArray = self.getCityNameFromProvince(row: 0)
        self.areaArray = self.getAreaNameFromCity(row: 0)
        
        self.provinceStr = self.provinceArray[0] as? String
        self.cityStr = self.cityArray[0] as? String
        self.areaStr = self.areaArray[0] as? String
    }
    
    //根据市获取区
    func getAreaNameFromCity(row: NSInteger) -> NSArray {
        let tempDic = self.dataSource[self.selectRow] as! NSDictionary
        let tepDic = tempDic.object(forKey: self.provinceArray[self.selectRow]) as! NSDictionary
        
        var array = NSArray()
        
        let dic = tepDic.allValues[row] as! NSDictionary
        
        array = dic.object(forKey: self.cityArray[row]) as! NSArray
        
        return array
    }
    
    //根据省名称获取市
    func getCityNameFromProvince(row: NSInteger) -> NSArray {
        let tempDic = self.dataSource[row] as! NSDictionary
        let tepDic = tempDic.object(forKey: self.provinceArray[row]) as! NSDictionary
        
        let cityArray = NSMutableArray()
        for dic in tepDic.allValues {
            for (key,_) in dic as! NSDictionary {
                cityArray.add(key)
            }
        }
        return cityArray
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.provinceArray.count
        case 1:
            return self.cityArray.count
        case 2:
            return self.areaArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width / 3, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        switch component {
        case 0:
            label.text = self.provinceArray[row] as? String
        case 1:
            label.text = self.cityArray[row] as? String
        case 2:
            label.text = self.areaArray[row] as? String
        default:
            label.text = nil
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: //选择省
            self.selectRow = row
            self.cityArray = self.getCityNameFromProvince(row: row)
            self.areaArray = self.getAreaNameFromCity(row: 0)
            
            self.pickerView.reloadComponent(1)
            self.pickerView.selectRow(0, inComponent: 1, animated: true)
            self.pickerView.reloadComponent(2)
            self.pickerView.selectRow(0, inComponent: 2, animated: true)
            
            self.provinceStr = self.provinceArray[row] as? String
            self.cityStr = self.cityArray[0] as? String
            self.areaStr = self.areaArray[0] as? String
            
        case 1: //选择市
            self.areaArray = self.getAreaNameFromCity(row: row)
            self.pickerView.reloadComponent(2)
            self.pickerView.selectRow(0, inComponent: 2, animated: true)
            
            self.cityStr = self.cityArray[row] as? String
            self.areaStr = self.areaArray[0] as? String
            
        default:
            self.areaStr = self.areaArray[row] as? String
            break//选择区
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hidePickerView()
    }
    
}
