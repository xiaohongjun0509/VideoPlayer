//
//  TableViewCell.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/27.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell, VideoPlayable {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func addVideoPlayer(_ videoPlayer: AVVideoPlayer) {
        self.contentView.addSubview(videoPlayer)
    }
    
    func removeVideoPlayer(_ videoPlayer: AVVideoPlayer) {
        self.contentView.willRemoveSubview(videoPlayer)
    }

}
