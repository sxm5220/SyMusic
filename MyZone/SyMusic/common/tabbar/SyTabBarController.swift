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
        //TODO: 导航栏透明？？
        self.navigationBar.barTintColor = rgbWithHex(rgbValue: 0x121112)
        self.navigationBar.isTranslucent = false
        self.navigationBar.titleTextAttributes = (NSDictionary.init(object: rgbWithHexBm(rgbValue: 0xffffff), forKey: NSAttributedString.Key.foregroundColor as NSCopying) as! [NSAttributedString.Key : Any])
       /* if #available(iOS 15.0, *) {
            let app = UINavigationBarAppearance()
            app.configureWithOpaqueBackground()  // 重置背景和阴影颜色
            app.backgroundEffect = nil
            app.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            app.backgroundColor = .clear // 设置导航栏背景色
            app.shadowColor = nil
            UINavigationBar.appearance().scrollEdgeAppearance = nil  // 带scroll滑动的页面
            UINavigationBar.appearance().standardAppearance = app // 常规页面。描述导航栏以标准高度
        }*/
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //如果不是栈底控制器才会隐藏
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
}

struct tabbarItem {
    let title,image,lotAnimationName: String
    let viewController: UIViewController
}

class SyTabBarController: UITabBarController {

    private var animationBarItem: AnimationView?
    private var animationlabel: LTMorphingLabel?
    //tabbarItem(title: strCommon(key: "sy_main_title"), image: "item_tabbar_home_icon",lotAnimationName: "Home", viewController: SyT1()),
    private let tabbarArray = [tabbarItem(title: strCommon(key: "sy_music_title"), image: "item_tabbar_music_icon",lotAnimationName: "ASMR",viewController: SyMainVC()),
                               
                               tabbarItem(title: strCommon(key: "sy_mv_title"), image: "item_tabbar_mv_icon",lotAnimationName: "Video",viewController: SyMVVC())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.contentMode = .scaleAspectFill
        self.tabBar.barStyle = .black
        self.tabBar.backgroundColor = .clear
        self.tabBar.tintColor = rgbWithHex(rgbValue: 0xc676ff)
        
        self.setupChildController()
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
        for i in 0..<self.tabbarArray.count {
            addChildViewController(index: i, self.tabbarArray[i].viewController,
                                   navigationItemTitle: self.tabbarArray[i].title,
                                   title: self.tabbarArray[i].title ,
                                   imageName: self.tabbarArray[i].image)
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
        
        guard let views = tabbatButtonArray[index] as? UIView else { return }
        views.subviews.forEach { (v) in
            if v.isMember(of: NSClassFromString("UITabBarSwappableImageView")!) {
                self.animationBarItem?.removeFromSuperview()
                let lottieLogoView = AnimationView(name: self.tabbarArray[index].lotAnimationName)
                lottieLogoView.contentMode = .scaleAspectFit
                lottieLogoView.play()
//                lottieLogoView.loopMode = .loop //循环模式
//                lottieLogoView.animationSpeed = 0.5 //动画速度
//                lottieLogoView.play { (isAnimationFinished) in
//                    //
//                }
                v.addSubview(lottieLogoView)
                lottieLogoView.snp.makeConstraints { make in
                    //lottieLogoView.frame = CGRect(x: 0, y: 0, width: v.bounds.size.width, height: v.bounds.size.height)
//                    lottieLogoView.center = CGPoint(x: v.bounds.size.width / 2, y: v.bounds.size.height / 2)
                    make.left.top.equalTo(0)
                    make.width.equalTo(v.width)
                    make.height.equalTo(v.height)
                    make.centerX.equalTo(v.centerX).offset(-v.width/2)
                    make.centerY.equalTo(v.centerY).offset(-v.height/2)
                }
                SyPrint("tag==>\(v.tag)")
                self.animationBarItem = lottieLogoView
            }
        }
        
        views.subviews.forEach { (v) in
            if v.isMember(of: NSClassFromString("UITabBarButtonLabel")!) {
                self.animationlabel?.removeFromSuperview()
                let lab = LTMorphingLabel()
                lab.center = CGPoint(x: v.bounds.size.width / 2, y: v.bounds.size.height / 2)
                lab.textAlignment = .center
                lab.text = self.tabbarArray[index].title
                lab.morphingDuration = 0.8
                lab.morphingEffect = LTMorphingEffect(rawValue: 5)!
                lab.font = UIFont.systemFont(ofSize: 10)
                lab.textColor = rgbWithHex(rgbValue: 0xc676ff)
                v.addSubview(lab)
                lab.snp.makeConstraints { make in
                    //frame: CGRect(x: 0, y: 0, width: v.bounds.size.width, height: v.bounds.size.height)
                    make.left.top.equalTo(0)
                    make.width.equalTo(v.width)
                    make.height.equalTo(v.height)
                }
                SyPrint("tag==>\(v.tag)")
                self.animationlabel = lab
            }
        }
    }
}
