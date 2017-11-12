//
//  PlayControl.swift
//  VideoPlayerKit
//
//  Created by xiaohongjun on 2017/11/3.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

@objc protocol PlayControlDelegate {
    @objc func playControlDidStart(playControl: PlayControl)
    @objc func playControlDidPause(playControl: PlayControl)
}


class PlayControl: UIView {
    weak var delegate: PlayControlDelegate?
    lazy var playButton: UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        return button
    }()
    
    
    @objc public func playOrPause(_ button: UIButton) {
        if button.isSelected == false {
            self.delegate?.playControlDidPause(playControl: self)
        } else {
            self.delegate?.playControlDidStart(playControl: self)
        }
        button.isSelected = !button.isSelected
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPlayButton()
        addObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addObserver() {
        
    }
    
    func addPlayButton() {
        self.addSubview(playButton)
        playButton.addTarget(self, action:#selector(playOrPause(_: )) , for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playButton.center = self.center
        self.playButton.sizeToFit()
    }
}





