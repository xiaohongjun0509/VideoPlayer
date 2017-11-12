//
//  ViewController.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/27.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var urls = NSMutableArray()
    
    var task: TaskLoader?
    var cacheLoader: CacheLoader?
    private lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: self.view.bounds, style: .plain)
        tb.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()

    var player: AVVideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urls.add("https://vv.ipstatp.com/a436c2b65df5413cbfdc0666b3d2cc96?__token__=exp=1509526302~acl=/a436c2b65df5413cbfdc0666b3d2cc96*~hmac=02344e6da283f3bcc4866a59c27f12120cc48013c52ddfec270c7d7b216157b3")
        urls.add("https://video-qncdn.quzhiboapp.com/SvXx3UIM.mp4")
        urls.add("https://video-qncdn.quzhiboapp.com/4nizv98L_02.mp4")
        urls.add("https://video-qncdn.quzhiboapp.com/4nizv98L_01.mp4")
        urls.add("https://video-qncdn.quzhiboapp.com/4nizv98L.mp4")
        urls.add("https://video-qncdn.quzhiboapp.com/s09dotBk.mp4")
        urls.add("http://data.vod.itc.cn/fake_path?pt=3&pg=1&prod=ad&new=/206/241/8u10WAzGoe3GhgjVeigpNB.mp4")
        self.view.backgroundColor = UIColor.red

        self.view.addSubview(VideoCenter.defaultCenter.playerView)
        let defaultCenter = VideoCenter.defaultCenter
        defaultCenter.playerView.frame = CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 200)
        defaultCenter.play(PlayingItem.init(["url" : urls.firstObject!]))
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        if let playableCell = cell as? VideoPlayable {
//            playableCell.addVideoPlayer(<#T##videoPlayer: AVVideoPlayer##AVVideoPlayer#>)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urls.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell {
//            return cell
//        }
        return UITableViewCell.init()
    }
}
