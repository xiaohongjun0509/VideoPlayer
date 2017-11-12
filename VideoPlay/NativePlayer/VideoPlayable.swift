//
//  VideoPlayable.swift
//  VideoPlayerKit
//
//  Created by xiaohongjun on 2017/11/10.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

@objc protocol VideoPlayable: NSObjectProtocol {
    @objc func addVideoPlayer(_ videoPlayer: AVVideoPlayer)
    @objc func removeVideoPlayer(_ videoPlayer: AVVideoPlayer)
}
