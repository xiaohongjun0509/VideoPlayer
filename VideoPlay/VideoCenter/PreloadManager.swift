//
//  PreloadManager.swift
//  VideoPlayerKit
//
//  Created by xiaohongjun on 2017/11/3.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

let kPreloadCountLimit = 3

let kPreloadCount = 1 * 1024 * 1024 //preload 1M

class PreloadManager: NSObject {
    static let manager = PreloadManager()
    var preloadOperations = [String : TaskLoader]()
    let preloadQueue = DispatchQueue.init(label: "preload_queue")
    
    func preload(_ videoItem: PlayingItem) {
        self.preloadQueue.async {
            let taskLoader = TaskLoader.init(videoItem: videoItem)
            self.preloadOperations[videoItem.url] = taskLoader
            taskLoader.loadData()
        }
    }
    
    func cancel(_ videoItem: PlayingItem) {
        let task = preloadOperations[videoItem.url]
        task?.cancel()
    }
    
    func cancelAllPreloadOperations() {
        for (_, task) in preloadOperations.enumerated() {
            task.value.cancel()
        }
    }
}
