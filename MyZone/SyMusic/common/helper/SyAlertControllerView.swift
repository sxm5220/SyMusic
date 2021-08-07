//
//  SyAlertControllerView.swift
//  wwsq
//
//  Created by 宋晓明 on 2018/6/20.
//  Copyright © 2018年 wwsq. All rights reserved.
//

import UIKit

extension UIAlertController {
    //点击背景区域后退出消失的实现
    func tapGesAlert() {
        let arrayViews: NSArray = UIApplication.shared.keyWindow?.subviews as! NSArray
        if arrayViews.count > 0 {
            let backView: UIView = arrayViews.lastObject as? UIView ?? UIView()
            backView.isUserInteractionEnabled = true
            backView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap)))
        }
    }
    
    @objc
    func tap() {
        self.dismiss(animated: true, completion: nil)
    }
}

class SyAlertControllerView {
 
    /**
     alterController 输入框 textField多属性 两个按钮 处理otherBtn事件
     
     - parameter currentVC: 当前控制器
     - parameter title:     提示标题
     - parameter textFieldhandler:   textField多属性
     - parameter cancelBtn: 取消按钮
     - parameter otherBtn:  其他按钮
     - parameter handler:   其他按钮处理事件
     */
    static func showAlert(title: String, message: String, textFieldhandler: ((_ textField: UITextField) -> Void)?, cancelBtn: String, otherBtn: String?, handler: ((UIAlertAction, _ textFieldString: String) -> Void)?){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:message ,
                                                    preferredStyle: .alert)
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textFieldhandler!(textField)
            }
            
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            
            if otherBtn != nil{
                let settingsAction = UIAlertAction(title: otherBtn, style: .destructive, handler: { (action) -> Void in
                    let textField = alertController.textFields![0]
                    handler?(action, textField.text ?? "")
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     alterController 输入框 textField多属性 两个按钮 都处理事件
     
     - parameter currentVC: 当前控制器
     - parameter title:     提示标题
     - parameter textFieldhandler:   textField多属性
     - parameter cancelBtn: 取消按钮
     - parameter otherBtn:  其他按钮
     - parameter handler:   其他按钮处理事件
     */
    static func showAlert(title: String, message: String, textFieldhandler: ((_ textField: UITextField) -> Void)?, cancelBtn: String, otherBtn: String?, cencelHandler: ((UIAlertAction) -> Void)?, handler: ((UIAlertAction, _ textFieldString: String) -> Void)?){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:message ,
                                                    preferredStyle: .alert)
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textFieldhandler!(textField)
            }
            
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:{ (action) -> Void in
                cencelHandler?(action)
            })
            
            alertController.addAction(cancelAction)
            
            if otherBtn != nil{
                let settingsAction = UIAlertAction(title: otherBtn, style: .destructive, handler: { (action) -> Void in
                    let textField = alertController.textFields![0]
                    handler?(action, textField.text ?? "")
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     alterController 输入框 两个按钮 处理otherBtn事件
     
     - parameter currentVC: 当前控制器
     - parameter title:     提示标题
     - parameter textFieldString:   输入框默认显示
     - parameter cancelBtn: 取消按钮
     - parameter otherBtn:  其他按钮
     - parameter handler:   其他按钮处理事件
     */
    static func showAlert(title: String, textFieldString: String, cancelBtn: String, otherBtn: String?, handler: ((UIAlertAction, _ textFieldString: String) -> Void)?){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:nil ,
                                                    preferredStyle: .alert)
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textField.text = textFieldString
            }
            
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            
            if otherBtn != nil{
                let settingsAction = UIAlertAction(title: otherBtn, style: .destructive, handler: { (action) -> Void in
                    let textField = alertController.textFields![0]
                    handler?(action, textField.text ?? "")
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     alterController 两个按钮 处理otherBtn事件
     
     - parameter currentVC: 当前控制器
     - parameter title:     提示标题
     - parameter message:   提示消息
     - parameter cancelBtn: 取消按钮
     - parameter otherBtn:  其他按钮
     - parameter handler:   其他按钮处理事件
     */
    static func showAlert(title: String, message: String, cancelBtn: String?, otherBtn: String?, handler: ((UIAlertAction) -> Void)?){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:message ,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            
            if otherBtn != nil{
                let settingsAction = UIAlertAction(title: otherBtn, style: .destructive, handler: { (action) -> Void in
                    handler?(action)
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     alterController 一个按钮 不处理事件，简单实用
     - parameter title:     提示标题
     - parameter message:   提示消息
     - parameter currentVC: 当前控制器
     - parameter meg:       提示消息
     */
    static func showAlert(title: String, message: String, cancelBtn: String){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:message ,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     alterController 一个按钮 处理事件，简单实用
     - parameter title:     提示标题
     - parameter message:   提示消息
     - parameter currentVC: 当前控制器
     - parameter meg:       提示消息
     */
    static func showAlert(title: String, message: String, sureBtn: String?, handler: ((UIAlertAction) -> Void)?){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:message ,
                                                    preferredStyle: .alert)
            if sureBtn != nil{
                let settingsAction = UIAlertAction(title: sureBtn, style: .destructive, handler: { (action) -> Void in
                    handler?(action)
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     两个按钮 都处理事件
     
     - parameter currentVC:     当前控制器
     - parameter title:         提示标题
     - parameter message:       提示消息
     - parameter cancelBtn:     取消按钮
     - parameter otherBtn:      其他按钮
     - parameter cencelHandler: 取消按钮事件回调 （不处理可不写，考虑到有些场合需要使用）
     - parameter handler:       其他按钮事件回调
     */
    static func showAlert(title: String, message: String, cancelBtn: String?, otherBtn: String?, cencelHandler: ((UIAlertAction) -> Void)?, sureHandler:((UIAlertAction) -> Void)?){
        DispatchQueue.main.async{
            guard let currentVC = currentViewController() else{ return }
            let alertController = UIAlertController(title:title,
                                                    message:message ,
                                                    preferredStyle: .alert)
            if cancelBtn != nil {
                let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:{ (action) -> Void in
                    cencelHandler?(action)
                })
                alertController.addAction(cancelAction)
            }

            if otherBtn != nil{
                let sureAction = UIAlertAction(title: otherBtn, style: .destructive, handler: { (action) -> Void in
                    sureHandler?(action)
                })
                alertController.addAction(sureAction)
            }
            currentVC.present(alertController, animated: true, completion: {
                //触屏取消
                alertController.tapGesAlert()
            })
        }
    }
}
