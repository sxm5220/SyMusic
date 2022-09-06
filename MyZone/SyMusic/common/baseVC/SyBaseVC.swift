//
//  SyBaseVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/1.
//  Copyright © 2020 wwsq. All rights reserved.
//

import UIKit

class SyBaseVC: UIViewController, UIGestureRecognizerDelegate {
    
    lazy var navItem = UINavigationItem()
    
    var rightBarButton: SyBadgeButton!
    var isBackBar: Bool = false //返回按钮
    let imagesArray = [#imageLiteral(resourceName: "item_cover01_icon"),#imageLiteral(resourceName: "item_cover02_icon"),#imageLiteral(resourceName: "item_cover03_icon"),#imageLiteral(resourceName: "item_cover04_icon"),#imageLiteral(resourceName: "item_cover05_icon"),#imageLiteral(resourceName: "item_cover06_icon"),#imageLiteral(resourceName: "item_cover07_icon")]
    
    func leftBarButtonItemWithImage(image: UIImage) -> UIBarButtonItem {
        let leftButton = buttonWithImageFrame(imageName: image,
                                              tag: 0,
                                              target: self,
                                              action: #selector(leftBarButtonAction(sender:)))
        leftButton.frame = CGRect.init(x: 5, y: 5, width: 15, height: 15)
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        return leftBarButton
    }
    
    @objc func leftBarButtonAction(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func rightBarButtonItemWithImage(image: UIImage) -> UIBarButtonItem {
        self.rightBarButton = buttonWithImageFrame(imageName: image,
                                                   tag: 0,
                                                   target: self,
                                                   action: #selector(rightBarButtonAction(sender:)))
        self.rightBarButton.frame = CGRect.init(x: 0, y: 0, width: 25, height: 20)
        return UIBarButtonItem.init(customView: self.rightBarButton)
    }
    
    func rightBarButtonItemWithTitle(title: String) -> UIBarButtonItem {
        self.rightBarButton = buttonWithTitleFrame(title: title,
                                                   titleColor: .darkGray,
                                                   backgroundColor: .clear,
                                                   cornerRadius: 2,
                                                   tag: 0,
                                                   target: self,
                                                   action: #selector(rightBarButtonAction(sender:)))
        self.rightBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.rightBarButton.frame = CGRect.init(x: 0, y: 0, width: 60, height: 20)
        return UIBarButtonItem.init(customView: self.rightBarButton)
    }
    
    @objc func rightBarButtonAction(sender: UIButton) {
        //self.popView = SyPopoverView.init(button: sender, viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isBackBar {
            self.navigationItem.leftBarButtonItem = leftBarButtonItemWithImage(image: sfImage(name: "arrow.backward",15))
        }else{
            self.navigationItem.leftBarButtonItem = nil
        }

        guard let windows: [UIView] = UIApplication.shared.keyWindow?.subviews else { return }
        if windows.count > 0 && (self.navigationController?.viewControllers.count ?? 0 == 1 || currentViewController()?.classForCoder == SyMusicPlayVC().classForCoder){
            var viewFrameY = screenHeight - 135
            if currentViewController()?.classForCoder == SyMusicPlayVC().classForCoder {
                viewFrameY = screenHeight
            }
            windows.forEach { (view) in
                if view.classForCoder == SyMusicPlayerShowView().classForCoder && userDefaultsForString(forKey: voicePlayKey) == "1" {
                    UIView.animate(withDuration: 0.5) {
                        view.alpha = 1
                        view.frame.origin.y = viewFrameY
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let windows: [UIView] = UIApplication.shared.keyWindow?.subviews else { return }
        if windows.count > 0 && self.navigationController?.viewControllers.count ?? 0 > 1{
            windows.forEach { (view) in
                if view.classForCoder == SyMusicPlayerShowView().classForCoder && userDefaultsForString(forKey: voicePlayKey) == "1" {
                    UIView.animate(withDuration: 0.5) {
                        view.alpha = 0
                        view.frame.origin.y = screenHeight
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //右滑返回
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏标题文字颜色
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white]
        
        self.view.layer.contents = UIImage(named: "item_cover06_icon")?.cgImage
        //初始化一个基于模糊效果的视觉效果视图
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.frame
        blurView.layer.masksToBounds = true
        self.view.addSubview(blurView)
    }
    
    //右滑返回手势
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //重写title的didSet方法
    override var title: String?{
        didSet{
            navItem.title = title
        }
    }
    
    //状态栏字体颜色，在info.plist中View controller-based status bar appearance 设置为NO， .default黑色，.lightContent白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

