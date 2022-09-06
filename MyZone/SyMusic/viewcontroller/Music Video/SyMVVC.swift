//
//  SyMVVC.swift
//  SyMusic
//
//  Created by sxm on 2020/5/13.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import Lottie

internal let lottieDownload = "download_lot"

//需要查看Lottile动画时间点来确定开始和结束
enum ProgressKeyLottile: CGFloat {
    case start = 0
    case end = 180.0
    case complete = 210.0
}

extension SyMVVC: URLSessionDownloadDelegate {
    // handles download progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentDownloaded: CGFloat = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.progress(to: percentDownloaded)
        }
    }
    
    // finishes download
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        DispatchQueue.main.async {
            self.endDownload()
        }
    }
    
    // sets download progress
    
    private func progress(to progress: CGFloat) {
        
        // 1. We get the range of frames specific for the progress from 0-100%
        
        let progressRange = ProgressKeyLottile.end.rawValue - ProgressKeyLottile.start.rawValue
        
        // 2. Then, we get the exact frame for the current progress
        
        let progressFrame = progressRange * progress
        
        // 3. Then we add the start frame to the progress frame
        // Considering the example that we start in 140, and we moved 30 frames in the progress, we should show frame 170 (140+30)
        
        let currentFrame = progressFrame + ProgressKeyLottile.start.rawValue
        
        // 4. Manually setting the current animation frame
        
        self.lottieAnimation.currentFrame = currentFrame
        
        print("Downloading \((progress*100).rounded())%")
        
    }
}

class SyMVVC: SyBaseVC {

    private lazy var lottieAnimation: AnimationView = {
        let lot = AnimationView(name: lottieDownload)
        lot.contentMode = .scaleAspectFit
//      lot.play()
//      lot.loopMode = .loop //循环模式
//      lot.animationSpeed = 0.5 //动画速度
        return lot
    }()
    
    
    
    private lazy var downloadBtn: UIButton = {
        let btn = labWithTitleAttributeCollection(title: "开始下载", titleColor: .white, backgroundColor: .black, cornerRadius: 10, tag: 0, target: self, action: #selector(btnAction(sender:)))
        return btn
    }()
    
    @objc func btnAction(sender: UIButton) {
        self.startAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = strCommon(key: "sy_mv_title")
        
        self.view.addSubview(self.lottieAnimation)
        self.view.addSubview(self.downloadBtn)
        
        self.lottieAnimation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(200)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        self.downloadBtn.snp.makeConstraints { make in
            make.top.equalTo(self.lottieAnimation.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
    
    private func startAnimation() {
        self.lottieAnimation.play(fromFrame: 0, toFrame: ProgressKeyLottile.start.rawValue, loopMode: .none) { isfinish in
            self.startDownload()
        }
    }
    
    private func startDownload() {
        /*self.lottieAnimation.play(fromFrame: ProgressKeyLottile.start.rawValue, toFrame: ProgressKeyLottile.end.rawValue, loopMode: .none) { isfinish in
            self.endDownload()
        }*/
        // 1. URL to download from
          
          let url = URL(string: "https://96.f.1ting.com/local_to_cube_202004121813/96kmp3/zzzzzmp3/2016kNov/15F/15xxdi/05.mp3")!
          
          // 2. Setup download task and start download
          
          let configuration = URLSessionConfiguration.default
          
          let operationQueue = OperationQueue()
          
          let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
          
          let downloadTask = session.downloadTask(with: url)
          
          downloadTask.resume()
    }
    
    private func endDownload() {
        self.lottieAnimation.play(fromFrame: ProgressKeyLottile.end.rawValue, toFrame: ProgressKeyLottile.complete.rawValue, loopMode: .none)
    }
}
