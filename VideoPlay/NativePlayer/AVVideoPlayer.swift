//
//  AVVideoPlayer.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/29.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit
import AVKit

let AVPlayerQueue = DispatchQueue.init(label: "avplayerqueue_zero")
let AVPlayerLoadQueue = DispatchQueue.init(label: "AVPlayerLoadQueue")

let isPlaybackLikelyToKeepUp = "isPlaybackLikelyToKeepUp"
let isPlaybackBufferFull = "isPlaybackBufferFull"
let isPlaybackBufferEmpty = "isPlaybackBufferEmpty"
let status = "status"

class AVVideoPlayer: UIView {
    
    var videoItem: PlayingItem?
    
    var task: TaskLoader?

    var loadingsRequest = NSMutableArray()
    private var player: AVPlayer?
    
    var originalParentView: UIView?
    var originalViewFrame: CGRect = .zero
    
    
    var isFullScreen: Bool = false
    lazy var progressView: ProgressView = {
        let progressView = ProgressView()
        progressView.deleagte = self
        return progressView
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer.init(player: self.player)
        layer.frame = self.bounds
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blue
    }
    
    func addPlayerLayer() {
        self.layer.addSublayer(self.playerLayer)
        if self.progressView.superview == nil {
             addSubview(self.progressView)
            progressView.snp.makeConstraints({ (maker) in
                maker.left.right.equalTo(self)
                maker.height.equalTo(50)
                maker.bottom.equalTo(self.snp.bottom)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_ : )), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillBecomeActive(_ : )), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(deviceRotationChanged(_:)),name: NSNotification.Name.UIDeviceOrientationDidChange,object: nil)

    }
    
    @objc func appWillResignActive(_ notification: Notification) {
        self.pause()
    }
    
    @objc func appWillBecomeActive(_ notification: Notification) {
        
    }
    
    @objc func deviceRotationChanged(_ notification: Notification) {
        
    }
    
    func play(_ playingItem: PlayingItem?) {
       
        guard let videoItem = playingItem else {
            fatalError("invalid play item")
        }
        
        guard  let url = URL(string: videoItem.changeCustomSchema()) else {
            return
        }
        
        let asset = AVURLAsset(url: url, options: nil)
        asset.resourceLoader.setDelegate(DataManager.manager, queue: AVPlayerLoadQueue)
        let playItem = AVPlayerItem(asset: asset)
        
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .old], context: nil)
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.new, .old], context: nil)
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull), options: [.new, .old], context: nil)
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.new, .old], context: nil)
       
        self.player = AVPlayer(playerItem: playItem)
        self.player?.play()
        addPeriodicTimeObserver(player)
        addPlayerLayer()
    }
    
    
    func addBoundaryTimeObserver(_ asset: AVURLAsset) {
        var times = [NSValue]()
        var currentTime = kCMTimeZero
        // Divide the asset's duration into quarters.
        let interval = CMTimeMultiplyByFloat64(asset.duration, 0.25)
        
        // Build boundary times at 25%, 50%, 75%, 100%
        while currentTime < asset.duration {
            currentTime = currentTime + interval
            times.append(NSValue(time:currentTime))
        }
        let mainQueue = DispatchQueue.main
        // Add time observer
//        let timeObserverToken =
//            player?.addBoundaryTimeObserver(forTimes: times, queue: mainQueue) {
//                [weak self] time in
//                self.
//        }
    }
    
    func addPeriodicTimeObserver(_ player: AVPlayer?) {
        guard let player = player else {
            return
        }
        // Invoke callback every half second
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main
        
        // Add time observer
        _ =
            player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
                [weak self] time in
                if let currentItem = player.currentItem {
                    let userInfo = ["current": Int(currentItem.currentTime().value) / Int(currentItem.currentTime().timescale),
                                    "duration": Int(currentItem.duration.value) / Int(currentItem.duration.timescale)]
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "progress"), object: nil, userInfo: userInfo)
                }
        }
    }
    
    func pause() {
        self.player?.pause()
    }
    
    func resume() {
        self.player?.play()
    }
    
    func stop() {
        
    }
    
    func replay() {
        player?.seek(to: CMTimeMake(0, 0))
        player?.play()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath)
        if keyPath == status {
            
        } else if keyPath == isPlaybackLikelyToKeepUp {

        } else if keyPath == isPlaybackBufferFull {
            
        } else if keyPath == isPlaybackBufferEmpty {
            
        }
    }
    
    
    func enterFullScreen() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        self.originalParentView = self.superview
        self.originalViewFrame = self.frame//self.convert(self.frame, to: self.superview)
        keyWindow.addSubview(self)
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.layoutSubviews], animations: {
            self.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi * Double(0.5)))
            self.frame = keyWindow.bounds
            self.rotateStatusBar(true)
        }, completion: nil)
    }
    
    func exitFullScreen() {
        guard let parentView = self.originalParentView else { return }
        parentView.addSubview(self)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.layoutSubviews], animations: {
            self.transform = CGAffineTransform.init(rotationAngle: 0)
            self.frame = self.originalViewFrame
            self.rotateStatusBar(false)
        }, completion: nil)
    }
    
    func rotateStatusBar(_ fullScreen: Bool) {
        if fullScreen {
             UIApplication.shared.setStatusBarOrientation(.landscapeRight, animated: true)
        } else {
            UIApplication.shared.setStatusBarOrientation(.portrait, animated: true)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }
}


extension AVVideoPlayer: ProgressViewDelegate {
    @objc func progressViewDidClickFullScreenButton(enterFull: Bool) {
        if enterFull {
            if !self.isFullScreen {
                self.enterFullScreen()
                self.isFullScreen = true
            }
        } else {
            if self.isFullScreen {
                self.exitFullScreen()
                self.isFullScreen = false
            }
        }
    }
    
    @objc func progressViewDidClickPlayButton(play: Bool) {
        if play {
            self.pause()
        } else {
            self.resume()
        }
   }
    
    @objc func progressViewDidChangedProgress(_ progress: Float) {
        if let player = player, let duration = player.currentItem?.duration.value,
        let timeScale = player.currentItem?.duration.timescale {
            let toValue =  Double(duration) * Double(progress)
            print(toValue)
            let targetTime = CMTimeMake(Int64(toValue), timeScale)
            player.seek(to: targetTime)
        }
    }
}


