//
//  SyTabBarController.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit
import LTMorphingLabel
import Lottie

class SyNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = rgbWithHex(rgbValue: 0x121112)
        self.navigationBar.isTranslucent = false
        self.navigationBar.titleTextAttributes = (NSDictionary.init(object: rgbWithHexBm(rgbValue: 0xffffff), forKey: NSAttributedString.Key.foregroundColor as NSCopying) as! [NSAttributedString.Key : Any])
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //如果不是栈底控制器才会隐藏
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
}

class SyTabBarController: UITabBarController {
    
    var lotAnimationNameArray: NSArray = ["Video","ASMR"]
    var animationBarItem: LOTAnimationView?
    var animationlabel: LTMorphingLabel?
    
    let navigationItemTitleArray = [strCommon(key: "sy_main_title"),strCommon(key: "sy_me_title")]
    
    var tabbarTitleArray = [strCommon(key: "sy_music_title"),
                            strCommon(key: "sy_me_title")]
    
    func tabbarImageArray() -> NSArray {
        return  ["item_tabbar_me_icon","item_tabbar_main_icon"]
    }
    
    let viewControllerArray = [SyMainVC(),SyMeVC()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.contentMode = .scaleAspectFill
        self.tabBar.barStyle = .black
        self.tabBar.backgroundColor = .clear
        self.tabBar.tintColor = rgbWithHex(rgbValue: 0xc676ff)
        
        setupChildController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //开屏默认选择第一个tabItem
        self.didSelectItem(index: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //设置所有控制器
    func setupChildController()  {
        for i in 0..<tabbarTitleArray.count {
            addChildViewController(index: i, self.viewControllerArray[i],
                                   navigationItemTitle: self.navigationItemTitleArray[i],
                                   title: self.tabbarTitleArray[i] ,
                                   imageName: self.tabbarImageArray()[i] as! String)
        }
    }
    
    //重载下列方法
    /** 方法的重载:方法名称相同,但是参数不同. --> 1.参数的类型不同 2.参数的个数不同
     private在当前文件中可以访问,但是其他文件不能访问
     */
    private func addChildViewController(index: Int, _ childController: UIViewController,navigationItemTitle: String, title : String, imageName : String) {
        
        let dictTextAttrs = NSMutableDictionary()
        //正常状态下
        dictTextAttrs.setObject(rgbAWithHex(rgbValue: 0xFFFFFF, alpha: 0.5), forKey: NSAttributedString.Key.foregroundColor as NSCopying)
        childController.tabBarItem.setTitleTextAttributes(dictTextAttrs as? [AnyHashable : Any] as? [NSAttributedString.Key : Any], for: .normal)
        
        // 选中状态下
        let selctedTextAttributes = NSMutableDictionary()
        selctedTextAttributes.setObject(rgbWithHex(rgbValue: 0xc676ff), forKey: NSAttributedString.Key.foregroundColor as NSCopying)
        childController.tabBarItem.setTitleTextAttributes(selctedTextAttributes as? [AnyHashable : Any] as? [NSAttributedString.Key : Any], for: .selected)
        
        childController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        
        childController.tabBarItem.title = title
        childController.tabBarItem.tag = index
        
        //导航栏title
//        childController.navigationItem.title = navigationItemTitle
        
        //设置导航栏控制器
        let childNaVc = SyNavigationController(rootViewController: childController)
        addChild(childNaVc)
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.didSelectItem(index: item.tag)
    }
    
    func didSelectItem(index: Int) {
        
        let tabbatButtonArray: NSMutableArray = NSMutableArray()
        tabBar.subviews.forEach { (v) in
            if v.isMember(of: NSClassFromString("UITabBarButton")!) {
                tabbatButtonArray.add(v)
            }
        }
        let views: UIView = (tabbatButtonArray[index] as? UIView)!
        views.subviews.forEach { (v) in
            if v.isMember(of: NSClassFromString("UITabBarSwappableImageView")!) {
                self.animationBarItem?.removeFromSuperview()
                let lottieLogoView = LOTAnimationView(name: lotAnimationNameArray[index] as! String)
                lottieLogoView.frame = CGRect(x: 0, y: 0, width: v.bounds.size.width, height: v.bounds.size.height)
                lottieLogoView.center = CGPoint(x: v.bounds.size.width / 2, y: v.bounds.size.height / 2)
                lottieLogoView.play { (isAnimationFinished) in
                    //
                }
                v.addSubview(lottieLogoView)
                self.animationBarItem = lottieLogoView
            }
        }
        
        views.subviews.forEach { (v) in
            if v.isMember(of: NSClassFromString("UITabBarButtonLabel")!) {
                self.animationlabel?.removeFromSuperview()
                let lab = LTMorphingLabel(frame: CGRect(x: 0, y: 0, width: v.bounds.size.width, height: v.bounds.size.height))
                lab.center = CGPoint(x: v.bounds.size.width / 2, y: v.bounds.size.height / 2)
                lab.textAlignment = .center
                lab.text = self.tabbarTitleArray[index]
                lab.morphingDuration = 0.8
                lab.morphingEffect = LTMorphingEffect(rawValue: 5)!
                lab.font = UIFont.systemFont(ofSize: 10)
                lab.textColor = rgbWithHex(rgbValue: 0xc676ff)
                v.addSubview(lab)
                self.animationlabel = lab
            }
        }
    }
}
