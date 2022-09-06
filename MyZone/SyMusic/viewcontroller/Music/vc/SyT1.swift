//
//  SyT1.swift
//  SyMusic
//
//  Created by sxm on 2022/8/12.
//  Copyright © 2022 wwsq. All rights reserved.
//

import Foundation
import SnapKit
import GoogleMobileAds
import UIKit

class SyT1: SyBaseVC {
    
    //手动开启Ads
    /// The game length.
    static let gameLength = 5

    /// The interstitial ad.
    var interstitial: GADInterstitialAd?

    /// The countdown timer.
    var timer: Timer?

    /// The amount of time left in the game.
    var timeLeft = gameLength

    /// The state of the game.
    var gameState = GameState.notStarted

    /// The date that the timer was paused.
    var pauseDate: Date?

    /// The last fire date before a pause.
    var previousFireDate: Date?
    
    private lazy var clickLab: UILabel = {
        let lab = labWithAttributeCollection(text: "显示Ads", textColor: .red, font: UIFont.systemFont(ofSize: 16), textAlignment: .center)
        return lab
    }()
    
    private lazy var playAgainButton: UIButton = {
        let btn = labWithTitleAttributeCollection(title: "开始", titleColor: UIColor.white, backgroundColor: UIColor.black, cornerRadius: 20, tag: 0, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    @objc func btnAction(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.startNewGame()
        case 1:
            self.refreshAdsFunc()
        case 2:
            self.navigationController?.pushViewController(SyRewardedVC(), animated: true)
        default:
            break
        }
        
    }
    
    //内嵌是ads
    var heightConstraint: NSLayoutConstraint?
    var adLoader: GADAdLoader!
    var nativeAdView: GADNativeAdView!
    
    private lazy var refreshButton: UIButton = {
        let btn = labWithTitleAttributeCollection(title: "刷新一下", titleColor: UIColor.white, backgroundColor: UIColor.black, cornerRadius: 20, tag: 1, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    private func refreshAdsFunc() {
        self.adLoader =  GADAdLoader(
          adUnitID: googleNativeAdID, rootViewController: self,
          adTypes: [.native], options: nil)
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
    }
    
    //rewardedAds 点击跳转
    private lazy var rewardedAdButton: UIButton = {
        let btn = labWithTitleAttributeCollection(title: "rewardedAd", titleColor: UIColor.white, backgroundColor: UIColor.black, cornerRadius: 20, tag: 2, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    //url =  https://apps.admob.com/v2/apps/4559410898/settings?utm_source=internal&utm_medium=et&utm_campaign=helpcentrecontextualopt&utm_term=http%3A%2F%2Fgoo.gl%2F6Xkfcf&subid=ww-ww-et-amhelpv4&pli=1
    //TODO: 在Google Admob（url) 中需要设置线上的应用，应用自动分配应用id

    //<key>GADApplicationIdentifier</key>
//    <string>ca-app-pub-9882771134185440~4559410898</string>
    private lazy var adsBannerView: GADBannerView = {
        let bannerView = GADBannerView()
        bannerView.adUnitID = googleBannerAdID //内测adsId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        return bannerView
    }()
    
    private lazy var adsBannerView2: GADBannerView = {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = googleBannerAdID //内测adsId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        return bannerView
    }()
    
    //打开VC每次重新刷新展示Ads
    private lazy var adsBannerView3: GADBannerView = {
        let bannerView = GADBannerView()
        bannerView.adUnitID = googleBannerAdID //内测adsId
        bannerView.rootViewController = self
        return bannerView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.adsBannerView)
        self.addBannerViewToView(self.adsBannerView2)
        self.view.addSubview(self.adsBannerView3)
        self.view.addSubview(self.clickLab)
        self.view.addSubview(self.playAgainButton)
        self.view.addSubview(self.rewardedAdButton)
        
        self.adsBannerView.snp.makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(50)
            make.width.equalTo(screenWidth)
        }
        
        self.adsBannerView3.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(60)
            make.height.equalTo(50)
            make.width.equalTo(screenWidth)
        }
        
        self.clickLab.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.height.equalTo(40)
            make.width.equalTo(150)
            make.left.equalTo(10)
        }
        
        self.playAgainButton.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.height.equalTo(40)
            make.width.equalTo(80)
            make.left.equalTo(200)
        }
        
        // Pause game when application enters background.
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.pauseGame),
          name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Resume game when application becomes active.
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.resumeGame),
          name: UIApplication.didBecomeActiveNotification, object: nil)

//        self.startNewGame()
        
        guard
          let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
          assert(false, "Could not load nib file for adView")
        }
        setAdView(adView)
        self.nativeAdView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(self.playAgainButton.snp_bottomMargin).offset(20)
            make.height.equalTo(250)
            make.width.equalTo(screenWidth)
        }
        self.refreshButton.snp.makeConstraints { make in
            make.top.equalTo(self.nativeAdView.snp_bottomMargin).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(180)
            make.centerX.equalTo(self.view.centerX)
        }
        
        self.rewardedAdButton.snp.makeConstraints { make in
            make.top.equalTo(self.refreshButton.snp_bottomMargin).offset(30)
            make.height.equalTo(40)
            make.width.equalTo(180)
            make.centerX.equalTo(self.view)
        }
        
        self.refreshAdsFunc()
    }
    
    func setAdView(_ view: GADNativeAdView) {
      // Remove the previous ad view.
        nativeAdView = view
        self.view.addSubview(nativeAdView)
        self.view.addSubview(self.refreshButton)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - deinit

    deinit {
      NotificationCenter.default.removeObserver(
        self,
        name: UIApplication.didEnterBackgroundNotification, object: nil)
      NotificationCenter.default.removeObserver(
        self,
        name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

extension SyT1 {
    
    //adsBannerView2相关
    private func addBannerViewToView(_ bannerView: UIView) {
        self.adsBannerView2.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            self.positionBannerAtBottomOfSafeArea(self.adsBannerView2)
        }else{
            self.positionBannerAtBottomOfView(self.adsBannerView2)
        }
    }
    
    @available (iOS 11, *)
    private func positionBannerAtBottomOfSafeArea(_ bannerView: UIView) {
        let guide: UILayoutGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([self.adsBannerView2.centerXAnchor.constraint(equalTo: guide.centerXAnchor),self.adsBannerView2.bottomAnchor.constraint(equalTo: guide.bottomAnchor)])
    }
    
    private func positionBannerAtBottomOfView(_ bannerView: UIView) {
        self.view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        
        self.adsBannerView2.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
    }
}

extension SyT1 {
    
    override func viewWillTransition(
      to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
      coordinator.animate(alongsideTransition: { _ in
        self.loadBannerAd()
      })
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      // Note loadBannerAd is called in viewDidAppear as this is the first time that
      // the safe area is known. If safe area is not a concern (eg your app is locked
      // in portrait mode) the banner can be loaded in viewDidLoad.
        self.loadBannerAd()
    }
    
    //adsBannerView3相关
    func loadBannerAd() {

      // Here safe area is taken into account, hence the view frame is used after the
      // view has been laid out.
      let frame = { () -> CGRect in
        if #available(iOS 11.0, *) {
            return self.view.frame.inset(by: self.view.safeAreaInsets)
        } else {
            return self.view.frame
        }
      }()
      let viewWidth = frame.size.width

      // Here the current interface orientation is used. If the ad is being preloaded
      // for a future orientation change or different orientation, the function for the
      // relevant orientation should be used.
        self.adsBannerView3.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.adsBannerView3.load(GADRequest())
    }
}

extension SyT1: GADFullScreenContentDelegate {
    
    enum GameState: NSInteger {
      case notStarted
      case playing
      case paused
      case ended
    }
    
    // MARK: - Game Logic

    fileprivate func startNewGame() {
      loadInterstitial()

      gameState = .playing
        timeLeft = SyT1.gameLength
      playAgainButton.isHidden = true
      updateTimeLeft()
      timer = Timer.scheduledTimer(
        timeInterval: 1.0,
        target: self,
        selector: #selector(self.decrementTimeLeft(_:)),
        userInfo: nil,
        repeats: true)
    }

    fileprivate func loadInterstitial() {
      let request = GADRequest()
      GADInterstitialAd.load(
        withAdUnitID: googleInterstitialAdID, request: request
      ) { (ad, error) in
        if let error = error {
          print("Failed to load interstitial ad with error: \(error.localizedDescription)")
          return
        }
        self.interstitial = ad
        self.interstitial?.fullScreenContentDelegate = self
      }
    }

    fileprivate func updateTimeLeft() {
        self.clickLab.text = "\(timeLeft) 后显示Ads"
    }

    @objc func decrementTimeLeft(_ timer: Timer) {
      timeLeft -= 1
      updateTimeLeft()
      if timeLeft == 0 {
        endGame()
      }
    }

    @objc func pauseGame() {
      if gameState != .playing {
        return
      }
      gameState = .paused

      // Record the relevant pause times.
      pauseDate = Date()
      previousFireDate = timer?.fireDate

      // Prevent the timer from firing while app is in background.
      timer?.fireDate = Date.distantFuture
    }

    @objc func resumeGame() {
      if gameState != .paused {
        return
      }
      gameState = .playing

      // Calculate amount of time the app was paused.
      let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1

      // Set the timer to start firing again.
      timer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
    }

    fileprivate func endGame() {
      gameState = .ended
      timer?.invalidate()
      timer = nil

      let alert = UIAlertController(
        title: "Game Over",
        message: "You lasted \(SyT1.gameLength) seconds",
        preferredStyle: .alert)
      let alertAction = UIAlertAction(
        title: "OK",
        style: .cancel,
        handler: { [weak self] action in
          if let ad = self?.interstitial {
            ad.present(fromRootViewController: self!)
          } else {
            print("Ad wasn't ready")
          }
          self?.playAgainButton.isHidden = false
        })
      alert.addAction(alertAction)
      self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - GADFullScreenContentDelegate

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad will present full screen content.")
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)
    {
      print("Ad failed to present full screen content with error \(error.localizedDescription).")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
    }

}

//内嵌式，点击跳转到App Store
extension SyT1: GADVideoControllerDelegate {

  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    //videoStatusLabel.text = "Video playback has ended."
      SyPrint("Video playback has ended.")
  }
}

extension SyT1: GADAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
//    refreshAdButton.isEnabled = true
  }
}

extension SyT1: GADNativeAdLoaderDelegate {

    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
//    refreshAdButton.isEnabled = true

    // Set ourselves as the native ad delegate to be notified of native ad events.
    nativeAd.delegate = self

    // Deactivate the height constraint that was set when the previous video ad loaded.
    heightConstraint?.isActive = false

    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

    // Some native ads will include a video asset, while others do not. Apps can use the
    // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
    // UI accordingly.
    let mediaContent = nativeAd.mediaContent
    if mediaContent.hasVideoContent {
      // By acting as the delegate to the GADVideoController, this ViewController receives messages
      // about events in the video lifecycle.
      mediaContent.videoController.delegate = self
//      videoStatusLabel.text = "Ad contains a video asset."
        SyPrint("Ad contains a video asset.")
    } else {
//      videoStatusLabel.text = "Ad does not contain a video."
        SyPrint("Ad does not contain a video.")
    }

    // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
    // ratio of the media it displays.
    if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
      heightConstraint = NSLayoutConstraint(
        item: mediaView,
        attribute: .height,
        relatedBy: .equal,
        toItem: mediaView,
        attribute: .width,
        multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
        constant: 0)
      heightConstraint?.isActive = true
    }

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    nativeAdView.bodyView?.isHidden = nativeAd.body == nil

    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    nativeAdView.iconView?.isHidden = nativeAd.icon == nil

    (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)

      
    nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

    (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
    nativeAdView.storeView?.isHidden = nativeAd.store == nil

    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
    nativeAdView.priceView?.isHidden = nativeAd.price == nil

    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
    nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    nativeAdView.callToActionView?.isUserInteractionEnabled = false

    // Associate the native ad view with the native ad object. This is
    // required to make the ad clickable.
    // Note: this should always be done after populating the ad views.
    nativeAdView.nativeAd = nativeAd

  }
}

// MARK: - GADNativeAdDelegate implementation
extension SyT1: GADNativeAdDelegate {

  func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }
}
