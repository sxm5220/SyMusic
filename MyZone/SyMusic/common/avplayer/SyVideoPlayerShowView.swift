//
//  SyVideoPlayerShowView.swift
//  wwsq
//
//  Created by 宋晓明 on 2019/1/10.
//  Copyright © 2019 wwsq. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

extension UIImage {
    
    // 将当前图片缩放到指定尺寸
    func scaleImageToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}


/** 计算文本尺寸 */
func textSizeWithString(_ str: String, font: UIFont, maxSize:CGSize) -> CGSize {
    let dict = [NSAttributedString.Key.font: font]
    let size = (str as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dict, context: nil).size
    return size
}

// 自适应屏幕宽度
func FIT_SCREEN_WIDTH(_ size: CGFloat) -> CGFloat {
    return size * screenWidth / 375.0
}
// 自适应屏幕高度
func FIT_SCREEN_HEIGHT(_ size: CGFloat) -> CGFloat {
    return size * screenHeight / 667.0
}
// 自适应屏幕字体大小
func AUTO_FONT(_ size: CGFloat) -> UIFont {
    let autoSize = size * screenWidth / 375.0
    return UIFont.systemFont(ofSize: autoSize)
}

protocol SyVideoPlayerShowViewDelegate: AnyObject {
    
    // 返回按钮点击代理
    func videoViewBackButtonClicked()
    // 右侧分享按钮
    func shareBtnClicked()
}

enum RotateDirection { // 屏幕旋转方向
    case left
    case right
    case up
}

enum DragDirection {
    case none // 无
    case horizontal // 水平
    case vertical // 竖直
}

enum ProgressChangeType { // 进度调节触发方式
    case panGuesture // 屏幕拖拽手势
    case sliderPan // 拖拽滑条
    case sliderTap // 点击滑条
}
class SyVideoPlayerShowView: UIView, UIGestureRecognizerDelegate {
    weak var delegate: SyVideoPlayerShowViewDelegate?
    var totalTime = 0 // 总时间
    var currentTime = 0 // 当前播放时间
    
    // MARK:- 控件
    lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    var playerItem: AVPlayerItem?
    var lastPlayerItem: AVPlayerItem?
    var playerLayer = AVPlayerLayer()
    let shareBtn = UIButton()//分享按钮
    fileprivate var backBtn = UIButton()
    fileprivate let progressView = UIProgressView()
    fileprivate let progressSlider = UISlider()
    fileprivate var systemSlider = UISlider()
    fileprivate let lightSlider = UISlider()
    fileprivate let volumeSlider = UISlider()
    fileprivate let startButton = UIButton()//开始暂停按钮
    fileprivate var loadingView = UIActivityIndicatorView()
    fileprivate var coverView = UIView()
    fileprivate let maxButton = UIButton()
    fileprivate var navView = UIView()//导航栏view
    fileprivate var toolBarView = UIView()
    fileprivate var leftTimeLabel = UILabel() //左侧时间
    fileprivate var rightTimeLabel = UILabel() //右侧时间
    
    // MARK:- 控件属性值
    fileprivate var contentView = UIView()
    fileprivate var customFarme = CGRect()
    fileprivate let navigationHeight: CGFloat = 64
    fileprivate let toolBarViewH: CGFloat = FIT_SCREEN_HEIGHT(40)
    fileprivate let Padding = FIT_SCREEN_WIDTH(10)
    fileprivate let ProgressColor = rgbWithValue(r: 255.0, g: 255.0, b: 255.0, alpha: 1.0) //进度条颜色
    fileprivate let ProgressTintColor = rgbWithValue(r: 221, g: 221, b: 221, alpha: 1) //缓冲颜色
    fileprivate let PlayFinishColor = rgbWithValue(r: 252, g: 106, b: 125, alpha: 1) //播放完成颜色
    fileprivate let initTimeString = "00:00"
    
    // MARK:- 变量属性控制
    fileprivate var toolBarTimer: Timer?
    fileprivate var isFullScreen = false //是否是全屏
    fileprivate var firstPoint = CGPoint()
    fileprivate var secondPoint = CGPoint()
    fileprivate var isDragging = false // 是否正在拖拽进度条或者滑动屏幕进度
    fileprivate let DisapperAnimateDuration = 0.5
    fileprivate var dragDirection: DragDirection?
    
    
    // MARK:- 初始化
    init(frame: CGRect, contentView: UIView) {
        
        super.init(frame: frame)
        self.frame = frame
        self.contentView = contentView
        customFarme = frame
        backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerLayer.player = nil
        invalidateToolBarTimer()
    }
    
    // MARK:- UI
    fileprivate func makeUI() {
        
        makeSubViews()
//        makeNavBtns() // 返回、分享按钮
        makeLightAndVolumeSlider() // 亮度、声音滑动条
        makePlayButton() // 播放按钮
        makeLeftTimeLab() //左侧时间
        makeMaxButton() // 全屏按钮
        makeRightTimeLab() //右侧时间
        makeProgress() // 缓冲条
        makeSlider() // 滑动条
        createGesture() //创建点击手势
        invalidateToolBarTimer()
        startToolBarTimer() // 开启定时器
    }
    
    private func makeSubViews() {
        
        // 播放器layer
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        self.layer.addSublayer(playerLayer)
        
        // 播放器最上边的遮盖view
        coverView = UIView(frame:(CGRect(x: 0, y: playerLayer.frame.minY, width: playerLayer.frame.width, height: playerLayer.frame.height)))
        self.addSubview(coverView)
        
        // 顶部View条
        navView = UIView()
        navView.backgroundColor = UIColor.clear
        coverView.addSubview(navView)
        navView.snp.makeConstraints { make in
            //frame:(CGRect(x: 0, y: 0, width: coverView.width, height: navigationHeight))
            make.left.top.equalTo(0)
            make.width.equalTo(coverView.width)
            make.height.equalTo(navigationHeight)
        }
        
        // 底部进度条view
        toolBarView = UIView()
        toolBarView.backgroundColor = rgbWithValue(r: 0, g: 0, b: 0, alpha: 0.6)
        coverView.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { make in
            //frame: CGRect(x: 0, y: coverView.height-toolBarViewH, width: coverView.width, height: toolBarViewH)
            make.left.equalTo(0)
            make.top.equalTo(coverView.snp_bottomMargin).offset(-toolBarViewH)
            make.width.equalTo(coverView.width)
            make.height.equalTo(toolBarViewH)
        }
        
        // 菊花转
        loadingView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        loadingView.center = coverView.center
        self.addSubview(loadingView)
    }
    
    //MARK: - 添加子控件
    // 返回、分享按钮
    private func makeNavBtns() {
        
        makeBackButton()
        makeShareButton()
    }
    
    // 返回按钮
    func makeBackButton() {
        
        backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "item_video_return_icon"), for: UIControl.State())
        backBtn.addTarget(self, action: #selector(backBtnDidClicked), for: UIControl.Event.touchUpInside)
        self.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            //frame:(CGRect(x: FIT_SCREEN_WIDTH(10), y: 20, width: FIT_SCREEN_WIDTH(25), height: FIT_SCREEN_WIDTH(25)))
            make.top.equalTo(20)
            make.left.width.height.equalTo(FIT_SCREEN_WIDTH(25))
            
        }
        backBtn.y = (navigationHeight - backBtn.height) * 0.5
    }
    
    //分享按钮
    private func makeShareButton() {
        
        shareBtn.setImage(UIImage(named: "item_video_share_icon"), for: UIControl.State.normal)
        shareBtn.addTarget(self, action: #selector(shareBtnClicked), for: UIControl.Event.touchUpInside)
        navView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { make in
            make.left.top.equalTo(0)
            make.right.equalTo(navView.width).offset(-FIT_SCREEN_WIDTH(10))
            make.width.equalTo(FIT_SCREEN_WIDTH(25))
            make.height.equalTo(FIT_SCREEN_HEIGHT(25))
            make.centerY.equalTo(backBtn.centerY)
        }
        //shareBtn.frame = CGRect(x: 0, y: 0, width: FIT_SCREEN_WIDTH(25), height: FIT_SCREEN_HEIGHT(25))
        //shareBtn.right = navView.width - FIT_SCREEN_WIDTH(10)
//        shareBtn.centerY = backBtn.centerY
        
    }
    
    // 播放、暂停按钮
    private func makePlayButton() {
        startButton.setBackgroundImage(UIImage(named: "item_video_pause_icon"), for: UIControl.State.selected)
        startButton.setBackgroundImage(UIImage(named: "item_video_play_icon"), for: UIControl.State())
        startButton.addTarget(self, action: #selector(startAction(_:)), for: UIControl.Event.touchUpInside)
        toolBarView.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.left.equalTo(Padding)
            make.top.equalTo(toolBarView.height/2.0).offset(-startButton.height/2.0)
            make.width.equalTo(FIT_SCREEN_WIDTH(15))
            make.height.equalTo(FIT_SCREEN_WIDTH(18))
            
        }
        //startButton.frame = CGRect(x: Padding, y: 0, width: FIT_SCREEN_WIDTH(15), height: FIT_SCREEN_WIDTH(18))
        //startButton.y = toolBarView.height/2.0 - startButton.height/2.0
        
    }
    
    // 亮度、声音滑动条
    private func makeLightAndVolumeSlider() {
        
        //设置亮度滑块
        lightSlider.isHidden = true
        lightSlider.minimumValue = 0
        lightSlider.maximumValue = 1
        lightSlider.value = Float(UIScreen.main.brightness)
        self.addSubview(lightSlider)
        
        // 系统
        let volumeView = MPVolumeView()
        volumeView.sizeToFit()
        self.addSubview(volumeView)
        volumeView.snp.makeConstraints { make in
            //frame: CGRect(x: -3000, y: -1000, width: 100, height: 100)
            make.left.equalTo(-3000)
            make.top.equalTo(-1000)
            make.width.height.equalTo(100)
        }
        for view in volumeView.subviews {
            if (view.superclass?.isSubclass(of: UISlider.classForCoder()) == true) {
                systemSlider = view as! UISlider
            }
        }
        systemSlider.isHidden = true
        systemSlider.autoresizesSubviews = false
        systemSlider.autoresizingMask = UIView.AutoresizingMask()
        self.addSubview(systemSlider)
        
        //设置声音滑块
        volumeSlider.isHidden = true
        volumeSlider.minimumValue = systemSlider.minimumValue
        volumeSlider.maximumValue = systemSlider.maximumValue
        volumeSlider.value = systemSlider.value
        self.addSubview(volumeSlider)
    }
    
    // 进度缓冲条
    private func makeProgress() {
        let progressX = leftTimeLabel.right + Padding
        progressView.trackTintColor = ProgressColor //进度条颜色
        progressView.progressTintColor = ProgressTintColor
        toolBarView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            // progressView.frame = CGRect(x: progressX, y: 0, width: rightTimeLabel.x - progressX - Padding, height: Padding)
            //progressView.centerY = startButton.centerY
            make.left.equalTo(progressX)
            make.top.equalTo(0)
            make.width.equalTo(rightTimeLabel.x - progressX - Padding)
            make.height.equalTo(Padding)
            make.centerY.equalTo(startButton.centerY)
        }
    }
    
    // 滑动条
    private func makeSlider() {
        
        toolBarView.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { make in
            //progressSlider.frame = CGRect(x: progressView.x - 2, y: 0, width: progressView.width + 4, height: toolBarViewH)
            //progressSlider.centerY = progressView.centerY
            make.left.equalTo(progressView.x).offset(-2)
            make.top.equalTo(0)
            make.width.equalTo(progressView.width + 4)
            make.height.equalTo(toolBarViewH)
            make.centerY.equalTo(progressView.centerY)
        }
        
        var image = UIImage(named: "item_video_round_icon") //红点
        image = image?.scaleImageToSize(size: CGSize(width: FIT_SCREEN_WIDTH(15), height: FIT_SCREEN_WIDTH(15)))
        progressSlider.setThumbImage(image, for: UIControl.State.normal)
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1 // 总共时长
        progressSlider.minimumTrackTintColor = PlayFinishColor
        progressSlider.maximumTrackTintColor = UIColor.clear
        progressSlider.addTarget(self, action: #selector(sliderIsDraging(slider:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderStartDrag(slider:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderEndDrag(slider:)), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderEndDrag(slider:)), for: .touchDragExit)
        progressSlider.addTarget(self, action: #selector(sliderEndDrag(slider:)), for: .touchDragOutside)
    }
    
    //左侧播放时间
    private func makeLeftTimeLab() {
        
        if leftTimeLabel.text == nil {
            leftTimeLabel.text = initTimeString
        }
        let totalTimeStr = rightTimeLabel.text ?? initTimeString//取总时长算宽度，避免开始时当前时间字符串长度小于总的
        let leftTimeWidth = textSizeWithString(totalTimeStr, font: leftTimeLabel.font, maxSize: CGSize(width: toolBarView.width, height: toolBarView.height)).width + FIT_SCREEN_WIDTH(5)
        leftTimeLabel.textColor = UIColor.white
        leftTimeLabel.font = AUTO_FONT(12.0)
        leftTimeLabel.textAlignment = NSTextAlignment.center
        toolBarView.addSubview(leftTimeLabel)
        leftTimeLabel.snp.makeConstraints { make in
            //leftTimeLabel.frame =  CGRect(x: 0, y: 0, width: leftTimeWidth, height: Padding)
//            leftTimeLabel.centerY = startButton.centerY
//            leftTimeLabel.x = startButton.right + Padding
            make.top.equalTo(0)
            make.left.equalTo(startButton.right).offset(Padding)
            make.width.equalTo(leftTimeWidth)
            make.height.equalTo(Padding)
            make.centerY.equalTo(startButton.centerY)
        }
    }
    
    //右侧播放时间
    private func makeRightTimeLab() {
        
        if rightTimeLabel.text == nil {
            rightTimeLabel.text = initTimeString
        }
        let totalTimeStr = rightTimeLabel.text
        let rightTimeWidth = textSizeWithString(totalTimeStr!, font: rightTimeLabel.font, maxSize: CGSize(width: toolBarView.width, height: toolBarView.height)).width + FIT_SCREEN_WIDTH(5)
        rightTimeLabel.textColor = UIColor.white
        rightTimeLabel.font = leftTimeLabel.font
        rightTimeLabel.textAlignment = NSTextAlignment.center
        toolBarView.addSubview(rightTimeLabel)
        rightTimeLabel.snp.makeConstraints { make in
            // rightTimeLabel.frame = CGRect(x: 0, y: 0, width: rightTimeWidth, height: Padding)
//            rightTimeLabel.centerY = startButton.centerY
//            rightTimeLabel.right = maxButton.x - Padding
            make.left.top.equalTo(0)
            make.right.equalTo(maxButton.left).offset(-Padding)
            make.width.equalTo(rightTimeWidth)
            make.height.equalTo(Padding)
            make.centerY.equalTo(startButton.centerY)
        }
    }
    
    // 全屏按钮
    private func makeMaxButton() {
        if isFullScreen == true {
            maxButton.setBackgroundImage(UIImage(named: "item_video_min_icon"), for: UIControl.State())
        } else {
            maxButton.setBackgroundImage(UIImage(named: "item_video_max_icon"), for: UIControl.State())
        }
        maxButton.addTarget(self, action: #selector(maxBtnClicked), for: UIControl.Event.touchUpInside)
        toolBarView.addSubview(maxButton)
//        maxButton.frame = CGRect(x: 0, y: 0, width: FIT_SCREEN_WIDTH(25), height: FIT_SCREEN_WIDTH(25))
//        maxButton.right = toolBarView.right - Padding
//        maxButton.y = toolBarView.height/2 - maxButton.height/2
        maxButton.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(toolBarView.height/2).offset(-maxButton.height/2)
            make.right.equalTo(toolBarView.right).offset(-Padding)
            make.width.height.equalTo(FIT_SCREEN_WIDTH(25))
        }
    }
    
    // 添加手势
    private func createGesture() {
        
        // 屏幕点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapGes(tap:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        // 屏幕滑动手势
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(viewPanGes(pan:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
}


extension SyVideoPlayerShowView {
    
    // MARK:- 手势
    // 代理方法
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view?.isKind(of: UISlider.self) == true {
            return false
        }
        return true
    }
    
    // 屏幕点击手势
    @objc func viewTapGes(tap: UITapGestureRecognizer) {
        
        if coverView.alpha == 1 {
            invalidateToolBarTimer()
            hiddenToolBar()
        } else if coverView.alpha == 0 {
            startToolBarTimer()
        }
    }
    
    // 屏幕滑动手势
    @objc func viewPanGes(pan: UIPanGestureRecognizer) {
        
        if pan.state == UIGestureRecognizer.State.began { // 开始拖动
            
            isDragging = true // 标记开始拖动
            pauseVideo() // 暂停播放
            dragDirection = DragDirection.none
            
            // 避免拖动过程中工具条自动消失
            invalidateToolBarTimer()
            showToolBar()
            
            firstPoint = pan.location(in: self)
            volumeSlider.value = systemSlider.value
            
        } else if pan.state == UIGestureRecognizer.State.ended { // 结束拖动
            
            isDragging = false // 标记拖动完成
            startToolBarTimer() // 开启工具条定时器
            playVideo() // 继续播放
            
        } else if pan.state == UIGestureRecognizer.State.changed { // 正在拖动
            
            secondPoint = pan.location(in: self)
            
            // 判断是左右滑动还是上下滑动
            let horValue = abs(firstPoint.x - secondPoint.x) // 水平方向
            let verValue = abs(firstPoint.y - secondPoint.y) // 竖直方向
            
            // 确定本次手势操作是水平滑动还是竖直滑动，避免一次手势操作中出现水平和竖直先后都出现的情况
            // 比如先向右滑动30，然后继续向上滑动50，就会出现一次手势操作中先调节视频进度又调节了音量
            if dragDirection == DragDirection.none {
                if horValue > verValue {
                    dragDirection = .horizontal
                } else {
                    dragDirection = .vertical
                }
            }
            
            if dragDirection == .horizontal { // 左右滑动
                // 调节视频的播放进度
                changeVideoProgress(changeType: .panGuesture)
                
            } else if dragDirection == .vertical { // 上下滑动
                // 调节音量或者亮度
                changeVolumeOrLight()
            }
            
            firstPoint = secondPoint
        }
    }
    
    // MARK: 滑条手势
    // 滑条开始拖动
    @objc func sliderStartDrag(slider: UISlider) {
        
        // 避免拖动过程中工具条自动消失
        invalidateToolBarTimer()
        showToolBar()
        
        isDragging = true // 标记开始拖动
        pauseVideo() // 暂停播放
    }
    
    // 滑条结束托送
    @objc func sliderEndDrag(slider: UISlider) {
        
        isDragging = false // 标记拖动完成
        startToolBarTimer() // 定时器，工具条消失
        playVideo() // 继续播放
    }
    
    // 滑条正在拖动
    @objc func sliderIsDraging(slider: UISlider) {
        
        if player.status == AVPlayer.Status.readyToPlay {
            // 改变视频进度
            changeVideoProgress(changeType: .sliderPan)
        }
    }
    
    
    // MARK: 控件相应事件
    // 播放暂停按钮方法
    @objc fileprivate func startAction(_ button: UIButton) {
        
        if button.isSelected == true {
            pauseVideo()
        } else {
            playVideo()
        }
    }
    
    // 全屏按钮响应事件
    @objc fileprivate func maxBtnClicked() {
        if isFullScreen == false {
            fullScreenWithDirection(RotateDirection.left)
        } else {
            originalScreen()
        }
    }
    
    // 返回按钮点击
    @objc fileprivate func backBtnDidClicked() {
        
//        UIApplication.shared.isStatusBarHidden = false
        if isFullScreen == true {
            // 全屏 返回半屏
            originalScreen()
            return
        }
        delegate?.videoViewBackButtonClicked()
        pauseVideo()
        removeFromSuperview()
    }
    
    //分享 按钮事件
    @objc fileprivate func shareBtnClicked() {
        
        if isFullScreen == true { //全屏分享时，要返回半屏
            originalScreen()
        }
        delegate?.shareBtnClicked()
    }
}


extension SyVideoPlayerShowView {
    
    // MARK:- 转屏
    // 半屏
    func originalScreen() {
        
        isFullScreen = false
//        UIApplication.shared.isStatusBarHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform.identity
        })
        self.frame = customFarme
        playerLayer.frame = CGRect(x: 0, y: 0, width: customFarme.size.width, height: customFarme.size.height)
        contentView.addSubview(self)
        
        _ = self.subviews.map (
            { $0.removeFromSuperview() }
        )
        makeUI()
    }
    
    // 全屏
    func fullScreenWithDirection(_ direction: RotateDirection) {
        
        isFullScreen = true
//        UIApplication.shared.isStatusBarHidden = true
        window?.addSubview(self)
        
        UIView.animate(withDuration: 0.25, animations: {
            if direction == RotateDirection.left {
                self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
            } else if direction == RotateDirection.right {
                self.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
            }
        })
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        playerLayer.frame = CGRect(x: 0, y: 0, width: screenHeight, height: screenWidth)
        
        _ = self.subviews.map (
            { $0.removeFromSuperview() }
        )
        makeUI()
    }
    
    // MARK: 刷新监听
    // 定时刷新监听
    func refreshShowValues() {
        
        let durationT = playerItem?.duration.value ?? 0
        let timescaleT = playerItem?.duration.timescale ?? 0
        if (TimeInterval(durationT) == 0) || (TimeInterval(timescaleT) == 0) {
            return
        }
        guard let currentT = playerItem?.currentTime() else {
            return
        }
        if CMTimeGetSeconds(currentT).isNaN {
            return
        }
        if isDragging == false { // 当没有正在拖动进度时，才刷新时间和进度条
            let currentTime = CMTimeGetSeconds(currentT)
            // 显示时间
            refreshTimeLabelValue(CMTimeMake(value: Int64(currentTime), timescale: 1))
            progressSlider.value = Float(TimeInterval(currentTime) / (TimeInterval(durationT) / TimeInterval(timescaleT)))
        }
        // 开始播放停止转子
        if (player.status == AVPlayer.Status.readyToPlay) {
            stopLoadingAnimation()
        } else {
            startLoadingAnimation()
        }
    }
    
    // 重新计算时间和滑条的frame
    func resizeTimeLabel() {
        
        guard let currentTime = playerItem?.currentTime() else {
            return
        }
        if CMTimeGetSeconds(currentTime).isNaN {
            return
        }
        let timeSecond = CMTimeGetSeconds(currentTime)
        let totalTimeStr = refreshTimeLabelValue(CMTimeMake(value: Int64(timeSecond), timescale: 1))
        
        let contantSize = CGSize(width: screenWidth, height: screenHeight)
        //左侧时间宽度
        let leftTimeWidth = textSizeWithString(totalTimeStr, font: leftTimeLabel.font, maxSize: contantSize).width
        leftTimeLabel.width = leftTimeWidth + FIT_SCREEN_WIDTH(5)
        leftTimeLabel.x = startButton.right + Padding
        //右侧时间宽度
        let rightTimeWidth = textSizeWithString(totalTimeStr, font: rightTimeLabel.font, maxSize: contantSize).width
        rightTimeLabel.width = rightTimeWidth + FIT_SCREEN_WIDTH(5)
        rightTimeLabel.right = maxButton.x - Padding
        // 进度条
        let progressX = leftTimeLabel.right + Padding
        progressView.x = progressX
        progressView.width = rightTimeLabel.x - progressX - Padding
        progressSlider.x = progressView.x - 2 //空隙补偿
        progressSlider.width = progressView.width + 4
    }
    
    // 刷新显示时间
    @discardableResult
    func refreshTimeLabelValue(_ time: CMTime) -> String {
        
        let timescale = playerItem?.duration.timescale ?? 0
        if Int64(timescale) == 0 || CMTimeGetSeconds(time).isNaN {
            invalidPlayURL()
            return String(format: "%02ld:%02ld", 0, 0)
        }
        
        // 当前时长进度progress
        let proMin = Int64(CMTimeGetSeconds(time)) / 60//当前分钟
        let proSec = Int64(CMTimeGetSeconds(time)) % 60//当前秒
        // duration 总时长
        let durationT = playerItem?.duration.value ?? 0
        let durMin = Int64(durationT) / Int64(timescale) / 60//总分钟
        let durSec = Int64(durationT) / Int64(timescale) % 60//总秒
        
        let leftTimeStr = String(format: "%02ld:%02ld", proMin, proSec )
        let rightTimeStr = String(format: "%02ld:%02ld", durMin, durSec )
        
        leftTimeLabel.text = leftTimeStr
        rightTimeLabel.text = rightTimeStr
        totalTime = Int(durMin * 60 + durSec)
        currentTime = Int(proMin * 60 + proSec)
        
        return rightTimeStr
    }
}


extension SyVideoPlayerShowView {
    
    // MARK: 控件逻辑处理方法
    // 计算缓冲进度
    fileprivate func availableDuration() -> TimeInterval {
        
        guard let timeRange = playerItem?.loadedTimeRanges.first?.timeRangeValue else {
            return 0
        }
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSeconds // 计算缓冲总进度
        return result
    }
    
    // 调节视频进度
    fileprivate func changeVideoProgress(changeType: ProgressChangeType) {
        
        let timescaleT = playerItem?.duration.timescale ?? 0
        if timescaleT == 0 {
            return
        }
        playerItem?.cancelPendingSeeks()
        
        if changeType == .panGuesture { // 通过屏幕手势拖拽
            progressSlider.value -= Float((firstPoint.x - secondPoint.x) / 300)
        }
        
        let durationT = playerItem?.duration.value ?? 0
        let total = Float64(durationT) / Float64(timescaleT)
        //计算出拖动的当前秒数
        let dragedSeconds = floorf(Float(total * Float64(progressSlider.value)))
        let dragedCMTime = CMTimeMake(value: Int64(dragedSeconds), timescale: 1)
        // 刷新时间
        refreshTimeLabelValue(dragedCMTime)
        // 刷新进度
        DispatchQueue.main.async {
            self.seekToVideo(Int(dragedSeconds))
        }
    }
    
    // 调节音量或者亮度
    fileprivate func changeVolumeOrLight() {
        
        var value = 0 as CGFloat
        if isFullScreen == true {
            value = self.height * 0.5
        } else {
            value = self.width * 0.5
        }
        
        //判断刚开始的点是左边还是右边
        if (firstPoint.x <= value) { // 左边调节屏幕亮度
            
            /* 手指上下移动的计算方式,根据y值,刚开始进度条在0位置,当手指向上移动300个点后,当手指向上移动N个点的距离后,
             当前的进度条的值就是N/300,300随开发者任意调整,数值越大,那么进度条到大1这个峰值需要移动的距离也变大,反之越小 */
            lightSlider.value += Float((firstPoint.y - secondPoint.y) / 300.0)
            UIScreen.main.brightness = CGFloat(lightSlider.value)
            
        } else { //右边调节音量
            systemSlider.value += Float((firstPoint.y - secondPoint.y) / 300.0)
            volumeSlider.value = systemSlider.value
        }
    }
}


extension SyVideoPlayerShowView {
    
    // MARK:- PlayerManager调用方法
    // 开始、继续播放
    func playVideo() {
        
        player.play()
        startButton.isSelected = true
    }
    
    // 暂停播放
    func pauseVideo() {
        
        player.pause()
        startButton.isSelected = false
    }
    
    // 调整视频进度
    func seekToVideo(_ startTime: Int) {
        
        let time = startTime < 0 ? 0 : startTime
        // 定位精度较差，但是性能比较高
        //player.seek(to: CMTimeMakeWithSeconds(Float64(time), 1))
        // 定位最为精确，但是性能很差
        player.seek(to: CMTimeMakeWithSeconds(Float64(time), preferredTimescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    // 无效的播放路径
    func invalidPlayURL() {
        
        player.replaceCurrentItem(with: nil)
        stopLoadingAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pauseVideo()
            self.leftTimeLabel.text = self.initTimeString
            self.rightTimeLabel.text = self.initTimeString
            self.progressSlider.value = 0
        }
    }
    
    // 启动转子
    func startLoadingAnimation() {
        loadingView.startAnimating()
    }
    
    // 停止转子
    func stopLoadingAnimation() {
        loadingView.stopAnimating()
    }
    
    // 设置缓冲条进度
    func setProgressValue() {
        
        let timeInterval = availableDuration() // 计算缓冲进度
        guard let duration = playerItem?.duration else {
            return
        }
        if CMTimeGetSeconds(duration).isNaN {
            return
        }
        let totalDuration = CMTimeGetSeconds(duration)
        if TimeInterval(totalDuration) == 0 {
            return
        }
        progressView.setProgress(Float(TimeInterval(timeInterval) / TimeInterval(totalDuration)), animated: false)
    }
    
    // 开启工具条消失的定时器
    func startToolBarTimer() {
        
        showToolBar() // 显示出工具条
        toolBarTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(hiddenToolBar), userInfo: nil, repeats: false) // 6秒后自动隐藏
        RunLoop.current.add(toolBarTimer!, forMode: RunLoop.Mode.default)
    }
    
    // 释放工具条消失的定时器
    func invalidateToolBarTimer() {
        toolBarTimer?.invalidate()
        toolBarTimer = nil
    }
    
    // 显示工具条
    func showToolBar() {
        
        if isFullScreen {
            UIView.animate(withDuration: DisapperAnimateDuration, animations: {
                self.coverView.alpha = 1
                self.backBtn.alpha = 1
            })
        } else {
            UIView.animate(withDuration: DisapperAnimateDuration, animations: {
                self.coverView.alpha = 1
            })
        }
    }
    
    // 隐藏、显示工具条
    @objc func hiddenToolBar() {
        
        if isFullScreen {
            UIView.animate(withDuration: DisapperAnimateDuration, animations: {
                self.coverView.alpha = 0
                self.backBtn.alpha = 0
            })
        } else {
            UIView.animate(withDuration: DisapperAnimateDuration, animations: {
                self.coverView.alpha = 0
            })
        }
    }
}

