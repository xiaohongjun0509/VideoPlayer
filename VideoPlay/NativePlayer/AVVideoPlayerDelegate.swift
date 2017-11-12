//
//  AVVideoPlayerDelegate.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/30.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import Foundation

@objc protocol AVVideoPlayerDelegate {
    @objc func videoPlayerStartToPlay()
    @objc func videoPlayerPause()
    @objc func videoPlayerPlayToEnd()
    @objc func videoPlayerFailToPlay()
    
}
