//
//  VideoCenter.swift
//  VideoPlayerKit
//
//  Created by xiaohongjun on 2017/11/10.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

class VideoCenter: NSObject {
    static let defaultCenter = VideoCenter()
    
    lazy var playerView: AVVideoPlayer = {
        let player = AVVideoPlayer.init(frame: .zero)
        return player
    }()
    
    func play(_ videoItem: PlayingItem) {
        self.playerView.play(videoItem)
    }
}
