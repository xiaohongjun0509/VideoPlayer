//
//  ProgressBar.swift
//  VideoPlayerKit
//
//  Created by xiaohongjun on 2017/11/4.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit
import SnapKit


@objc protocol ProgressViewDelegate: NSObjectProtocol {
    @objc func progressViewDidClickFullScreenButton(enterFull: Bool)
    @objc func progressViewDidClickPlayButton(play: Bool)
    @objc func progressViewDidChangedProgress(_ progress: Float)
}

class ProgressView: UIView {
    
    weak var deleagte: ProgressViewDelegate?
    lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView.init()
//        progressBar.tintColor = UIColor.yellow
//        progressBar.trackTintColor = UIColor.blue
//        progressBar.progressTintColor = UIColor.red
        return progressBar
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.maximumTrackTintColor = UIColor.red
        slider.thumbTintColor = UIColor.red
        slider.addTarget(self, action: #selector(sliderChange(_ : )), for: .valueChanged)
        return slider
    }()
    
    var time: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    var fullScreenButton: UIButton = UIButton.init(type: UIButtonType.custom)
    
    var playButton = UIButton.init(type: UIButtonType.custom)
    
    deinit {
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        self.addSubview(playButton)
        playButton.addTarget(self, action: #selector(playOrPause(_ : )), for: .touchUpInside)
        playButton.setImage(UIImage.init(named: "play"), for: .selected)
        playButton.setImage(UIImage.init(named: "pause"), for: .normal)
        
        playButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self)
            maker.left.equalTo(self).offset(10)
            maker.size.equalTo(CGSize.init(width: 40, height: 40))
        }

        self.addSubview(fullScreenButton)
        fullScreenButton.addTarget(self, action: #selector(enterOrExitFullScreen(_ : )), for: .touchUpInside)
        fullScreenButton.setImage(UIImage.init(named: "enlarge"), for: .normal)
        fullScreenButton.setImage(UIImage.init(named: "shrink"), for: .selected)
        fullScreenButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self)
            maker.right.equalTo(self).offset(-10)
            maker.size.equalTo(CGSize.init(width: 40, height: 40))
        }
        
        self.addSubview(time)
        time.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self)
            maker.right.equalTo(self.fullScreenButton.snp.left).offset(-10)
            maker.size.equalTo(CGSize.init(width: 70, height: 40))
        }
        
        self.addSubview(slider)
        slider.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self)
            maker.right.equalTo(self.time.snp.left).offset(-10)
            maker.left.equalTo(self.playButton.snp.right).offset(10)
        }
        
        addProgresObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func enterOrExitFullScreen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.deleagte?.progressViewDidClickFullScreenButton(enterFull: sender.isSelected)
    }
    
    @objc func playOrPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.deleagte?.progressViewDidClickPlayButton(play: sender.isSelected)
    }
    
    func addProgresObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_ : )), name: NSNotification.Name.init(rawValue: "progress"), object: nil)
    }
    
    @objc func updateProgress(_ noti: Notification) {
        if  let userInfo = noti.userInfo, let duration: Int = userInfo["duration"] as? Int, let current: Int = userInfo["current"] as? Int {
            time.text = "\(String.timeForamt(current))/\(String.timeForamt(duration))"
            slider.value = Float(current) / Float(duration)
        }
    }
    
    @objc func sliderChange(_ slider: UISlider) {
        let progress = slider.value
        progressBar.progress = progress
        deleagte?.progressViewDidChangedProgress(progress)
    }
    
}

extension String {
    static func timeForamt(_ time: Int) -> String {
        
            let totalSeconds: Int = time
            let secCount = totalSeconds % 60 // 秒
            
            let totalMinutes = totalSeconds / 60
            let minCount = totalMinutes % 60 // 分
            
            let hourCount = totalMinutes / 60 // 时
            
            var timeString: String = ""
            
            if hourCount > 0 {
                timeString.append(timeComponentWithNum(hourCount))
                timeString.append(":")
            }
            timeString.append(timeComponentWithNum(minCount))
            timeString.append(":")
            timeString.append(timeComponentWithNum(secCount))
            
            return timeString
    }
    
    fileprivate static func timeComponentWithNum(_ num: Int) -> String {
        if num <= 0 {
            return "00"
        }
        
        if num <= 9 {
            return "0\(num)"
        }
        
        return "\(num)"
    }
}


