//
//  SyRewardedVC.swift
//  SyMusic
//
//  Created by sxm on 2022/8/15.
//  Copyright © 2022 wwsq. All rights reserved.
//

import Foundation
import SnapKit
import GoogleMobileAds

class SyRewardedVC: SyBaseVC, GADFullScreenContentDelegate {
    
    enum RewardedGameState: NSInteger {
      case notStarted
      case playing
      case paused
      case ended
    }

    /// Constant for coin rewards.
    let gameOverReward = 1

    /// Starting time for game counter.
    let gameLength = 10

    /// Number of coins the user has earned.
    var coinCount = 0

    /// The rewarded video ad.
    var rewardedAd: GADRewardedAd?

    /// The countdown timer.
    var timer: Timer?

    /// The game counter.
    var counter = 10

    /// The state of the game.
    var gameState = RewardedGameState.notStarted

    /// The date that the timer was paused.
    var pauseDate: Date?

    /// The last fire date before a pause.
    var previousFireDate: Date?
    
    private lazy var gameTextLab: UILabel = {
        let lab = labWithAttributeCollection(text: "显示Ads", textColor: .red, font: UIFont.systemFont(ofSize: 16), textAlignment: .center)
        return lab
    }()
    
    private lazy var playAgainButton: UIButton = {
        let btn = labWithTitleAttributeCollection(title: "rewardedAd", titleColor: UIColor.white, backgroundColor: UIColor.black, cornerRadius: 20, tag: 0, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    @objc func btnAction(sender: UIButton) {
        if let ad = rewardedAd {
          ad.present(fromRootViewController: self) {
            let reward = ad.adReward
            print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            self.earnCoins(NSInteger(truncating: reward.amount))
            // TODO: Reward the user.
          }
        } else {
          let alert = UIAlertController(
            title: "Rewarded ad isn't available yet.",
            message: "The rewarded ad cannot be shown at this time",
            preferredStyle: .alert)
          let alertAction = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: { [weak self] action in
              self?.startRewardGame()
            })
          alert.addAction(alertAction)
          self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.gameTextLab)
        self.view.addSubview(self.playAgainButton)
        
        self.gameTextLab.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.height.equalTo(50)
            make.width.equalTo(100)
            make.centerX.equalTo(self.view)
        }
        
        self.playAgainButton.snp.makeConstraints { make in
            make.top.equalTo(self.gameTextLab.snp_bottomMargin)
            make.height.equalTo(40)
            make.width.equalTo(200)
            make.centerX.equalTo(self.view)
        }
        
        // Pause game when application is backgrounded.
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.applicationDidEnterBackground(_:)),
          name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Resume game when application is returned to foreground.
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.applicationDidBecomeActive(_:)),
          name: UIApplication.didBecomeActiveNotification, object: nil)

        
        self.startRewardGame()
    }
    
    fileprivate func startRewardGame() {
      gameState = .playing
      counter = gameLength
      playAgainButton.isHidden = true

      GADRewardedAd.load(
        withAdUnitID: googleRewardedVideoAdID, request: GADRequest()
      ) { (ad, error) in
        if let error = error {
          print("Rewarded ad failed to load with error: \(error.localizedDescription)")
          return
        }
        print("Loading Succeeded")
        self.rewardedAd = ad
        self.rewardedAd?.fullScreenContentDelegate = self
      }

        self.gameTextLab.text = String(counter)
      timer = Timer.scheduledTimer(
        timeInterval: 1.0,
        target: self,
        selector: #selector(self.timerFireMethod(_:)),
        userInfo: nil,
        repeats: true)
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
      // Pause the game if it is currently playing.
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

    @objc func applicationDidBecomeActive(_ notification: Notification) {
      // Resume the game if it is currently paused.
      if gameState != .paused {
        return
      }
      gameState = .playing

      // Calculate amount of time the app was paused.
      let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1

      // Set the timer to start firing again.
      timer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
    }
    
    @objc func timerFireMethod(_ timer: Timer) {
      counter -= 1
      if counter > 0 {
        gameTextLab.text = String(counter)
      } else {
        endRewardGame()
      }
    }
    
    fileprivate func earnCoins(_ coins: NSInteger) {
      coinCount += coins
//      coinCountLabel.text = "Coins: \(self.coinCount)"
        SyPrint("Coins: \(self.coinCount)")
    }

    fileprivate func endRewardGame() {
      gameState = .ended
      gameTextLab.text = "Game over!"
      playAgainButton.isHidden = false
      timer?.invalidate()
      timer = nil
      earnCoins(gameOverReward)
    }
    
    deinit {
      NotificationCenter.default.removeObserver(
        self,
        name: UIApplication.didEnterBackgroundNotification, object: nil)
      NotificationCenter.default.removeObserver(
        self,
        name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension SyRewardedVC {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Rewarded ad will be presented.")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Rewarded ad dismissed.")
    }

    func ad(
      _ ad: GADFullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
      print("Rewarded ad failed to present with error: \(error.localizedDescription).")
      let alert = UIAlertController(
        title: "Rewarded ad failed to present",
        message: "The reward ad could not be presented.",
        preferredStyle: .alert)
      let alertAction = UIAlertAction(
        title: "Drat",
        style: .cancel,
        handler: { [weak self] action in
          self?.startRewardGame()
        })
      alert.addAction(alertAction)
      self.present(alert, animated: true, completion: nil)
    }
}
