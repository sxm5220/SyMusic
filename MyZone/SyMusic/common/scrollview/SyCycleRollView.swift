//
//  SyCycleRollView.swift
//  wwsq
//
//  Created by 宋晓明 on 2018/4/20.
//  Copyright © 2018年 wwsq. All rights reserved.
//

import UIKit

public protocol SyCycleRollViewDelegate: NSObjectProtocol {
    func tapImage(_ cycleView: SyCycleRollView, currentImage: UIImage?, currentIndex: Int)
}

public class SyCycleRollView: UIView, UIScrollViewDelegate {
    //MARK: - private var
    //size
    fileprivate var kwidth: CGFloat = 0
    fileprivate var kheight: CGFloat = 0
    
    //index
    fileprivate var currentIndex: Int = 0
    fileprivate var nextIndex: Int = 0
    
    //subviews
    fileprivate lazy var scrollView: UIScrollView = {
        let rect = CGRect(x: 0, y: 0, width: kwidth, height: kheight)
        let view: UIScrollView = UIScrollView(frame: rect)
        view.contentSize = CGSize(width: kwidth*3, height: 0)
        view.contentOffset = CGPoint(x: kwidth, y: 0)
        view.decelerationRate = UIScrollView.DecelerationRate(rawValue: 3)
        view.isPagingEnabled = true
        //bounces为true时，用力快速滑动时，scrollView的contentOffset有偏差。
        view.bounces = false
        view.alwaysBounceHorizontal = false
        view.alwaysBounceVertical = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = UIColor.white
        view.delegate = self
        return view
    }()
    
    fileprivate lazy var currentImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: kwidth, y: 0, width: kwidth, height: kheight))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    fileprivate lazy var nextImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: kwidth, y: 0, width: kwidth, height: kheight))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    fileprivate lazy var pageControl: UIPageControl = {
        let pageControl: UIPageControl = UIPageControl()
        pageControl.currentPage = currentIndex
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = { [unowned self] in
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(tapImageView))
        return tap
        }()
    
    //timer
    public var timer: Timer?
    
    fileprivate var downloader = SyImageDownloader()
    
    //MARK: - public api var
    open var imageModelArray = [SyCycleViewImageModel]() {
        didSet { updateCycleView() }
    }
    ///是否是自动循环轮播，默认为true
    open var isAutoCycle: Bool = true {
        didSet {
            if isAutoCycle {
                addTimer()
            } else {
                removeTimer()
            }
        }
    }
    
    ///自动轮播的时间间隔，默认是5s。如果设置这个参数，之前不是自动轮播，现在就变成了自动轮播
    open var autoScrollTimeInterval: TimeInterval = 5 {
        didSet { isAutoCycle = true }
    }
    
    ///默认是false，如果值为true，表示完全滚动到下一页才改变PageControl的currentPage
    open var isChangePageControlDelay = false
    
    ///处理图片点击事件的代理
    weak open var delegate: SyCycleRollViewDelegate?
    
    //MARK: - init cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.kwidth = frame.size.width
        self.kheight = frame.size.height
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    ///用于显示网络图片
    public init(frame: CGRect, imageUrlStringArray: [String]) {
        super.init(frame: frame)
        
        var modelArray = [SyCycleViewImageModel]()
        var model: SyCycleViewImageModel
        for item in imageUrlStringArray {
            model = SyCycleViewImageModel(imageUrlString: item)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    ///用于显示本地图片
    public init(frame: CGRect, localImageArray: [UIImage]) {
        super.init(frame: frame)
        
        var modelArray = [SyCycleViewImageModel]()
        var model: SyCycleViewImageModel
        for item in localImageArray {
            model = SyCycleViewImageModel(localImage: item)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    ///网络图片、本地图片混合显示
    public init(frame: CGRect, imageArray: [(urlString: String, localImage: UIImage)]) {
        super.init(frame: frame)
        
        var modelArray = [SyCycleViewImageModel]()
        var model: SyCycleViewImageModel
        for item in imageArray {
            model = SyCycleViewImageModel(imageUrlString: item.urlString,
                                          localImage: item.localImage)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    ///使用图片Model数组初始化轮播器
    public init(frame: CGRect, imageModelArray: [SyCycleViewImageModel]) {
        super.init(frame: frame)
        
        self.imageModelArray = imageModelArray
        
        commonInit()
    }
    
    deinit {
        removeTimer()
        removeNotification()
        scrollView.removeGestureRecognizer(tapGesture)
    }
    
    public func commonInit() {
        self.kwidth = frame.size.width
        self.kheight = frame.size.height
        
        configViews()
        addNotification()
        updateCycleView()
        //打开页面就开始滚动
        addTimer()
    }
    
    //MARK: - config views
    fileprivate func configViews() {
        //多于一张图片的时候才可以滚动
        scrollView.isScrollEnabled = self.imageModelArray.count > 1 ? true : false
        addSubview(scrollView)
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(nextImageView)
        addSubview(pageControl)
        
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - set layout 滚动圆点
    fileprivate func setPageControlLayout() {
        //pageControl
        pageControl.numberOfPages = imageModelArray.count
        pageControl.currentPage = currentIndex
        let size = pageControl.size(forNumberOfPages: pageControl.numberOfPages)
        let point = CGPoint(x: kwidth/2 - size.width/2, y: kheight - size.height / 2 - 10)
        pageControl.frame = CGRect(origin: point, size: size)
    }
    
    //MARK: - update model array and page control
    fileprivate func updateCycleView() {
        setImageModelArray()
        setPageControlLayout()
    }
    
    //MARK: - UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.x
        if offset < self.kwidth {  //right
            self.nextImageView.frame = CGRect(x: 0, y: 0, width: self.kwidth, height: self.kheight)
            self.nextIndex = (self.currentIndex - 1) < 0 ? self.imageModelArray.count - 1 : (self.currentIndex - 1)
            
            if self.isChangePageControlDelay == false {
                if offset <= 0.5 * self.kwidth {
                    self.pageControl.currentPage = self.nextIndex
                } else {
                    self.pageControl.currentPage = self.currentIndex
                }
            }
            
            if offset <= 0 {
                self.nextPage()
            }
        } else if offset > self.kwidth { //left
            self.nextImageView.frame = CGRect(x: 2*self.kwidth, y: 0, width: self.kwidth, height: self.kheight)
            self.nextIndex = (self.currentIndex + 1) > self.imageModelArray.count - 1 ? 0 : (self.currentIndex + 1)
            
            if self.isChangePageControlDelay == false {
                if offset <= 1.5 * self.kwidth {
                    self.pageControl.currentPage = self.currentIndex
                } else {
                    self.pageControl.currentPage = self.nextIndex
                }
            }
            
            if offset >= 2 * self.kwidth {
                self.nextPage()
            }
        }
        
        let model = self.imageModelArray[self.nextIndex]
        if model.localImage == nil && model.imageUrlString != nil {
            self.downloader.getImageWithUrl(urlString: model.imageUrlString!,
                                            completeClosure: { [unowned self](image) in
                                                if self.nextIndex ==
                                                    self.imageModelArray.firstIndex(of: model) {
                                                    self.nextImageView.image = image
                                                }
            })
        } else {
            //本地图片
            self.nextImageView.image = model.localImage
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    
    //MARK: - add/remove timer
    fileprivate func addTimer() {
        if isAutoCycle && imageModelArray.count > 1 {
            if timer != nil {
                removeTimer()
            }
            
            timer = Timer.xb_scheduledTimerWithTimeInterval(autoScrollTimeInterval,
                                                            isRepeat: true,
                                                            closure: { [unowned self] in
                                                                self.autoCycle()
            })
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        }
    }
    
    fileprivate func removeTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    //MARK: - add/remove notification
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //MARK: - action
    fileprivate func autoCycle() {
        scrollView.setContentOffset(CGPoint(x: 2*kwidth, y: 0), animated: true)
    }
    
    fileprivate func nextPage() {
        currentImageView.image = nextImageView.image
        scrollView.contentOffset = CGPoint(x: kwidth, y: 0)
        currentIndex = nextIndex
        pageControl.currentPage = currentIndex
    }
    
    fileprivate func setImageModelArray() {
        for model in imageModelArray {
            if model.localImage == nil && model.imageUrlString != nil {
                downloader.getImageWithUrl(urlString: model.imageUrlString!,
                                           completeClosure: { [unowned self](image) in
                                            if self.currentIndex ==
                                                self.imageModelArray.firstIndex(of: model) {
                                                self.currentImageView.image = image
                                            }
                })
            } else {
                if currentIndex == imageModelArray.firstIndex(of: model) {
                    currentImageView.image = model.localImage
                }
            }
        }
    }
    
    @objc func tapImageView() {
        if let delegate = self.delegate {
            delegate.tapImage(self,
                              currentImage: currentImageView.image,
                              currentIndex: currentIndex)
        }
    }
    
    @objc func stopTimer() {
        removeTimer()
    }
    
    @objc func startTimer() {
        addTimer()
    }
    
    public func pauseTimer() {
        if timer != nil {
            timer!.fireDate = NSDate.distantFuture
        }
    }
    
    public func goOnTimer() {
        if timer != nil {
            timer!.fireDate = NSDate.distantPast
        }
    }
    //MARK: - public api method
    
    ///修改PageControl的小圆点颜色值
    open func setPageControl(_ pageIndicatorTintColor: UIColor,
                             currentPageIndicatorTintColor: UIColor) {
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
    }
}
