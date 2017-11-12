//
//  DataFetcher.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/30.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

///从服务端获得缓存

import UIKit
import AVKit
import MobileCoreServices

@objc protocol TaskLoaderDelegate: NSObjectProtocol {
    @objc func downloadTaskDidReceiveResponse(task: TaskLoader, response: URLResponse) -> Void
    @objc func downloadTaskDidReceiveData(task: TaskLoader, data: Data) -> Void
    @objc func downloadTaskDidFinishLoading(task: TaskLoader, error: Error?) -> Void
}


let loaderQueue: OperationQueue = OperationQueue.init()

class TaskLoader: NSObject {
    var url: URL
    var task: URLSessionDataTask?
    var resourceLoadDelegate: TaskLoaderDelegate?
    var localDelegate: TaskLoaderDelegate?
    var offset: Int64 = 0
    var loadingRequet: AVAssetResourceLoadingRequest?
    var dataOffset: Int64 = 0
    var dataDownloadOffset: Int64 = 0
    var contentData: Data?
    var videoTotalLength: Int64 = 0
    var videoItem: PlayingItem?
    
    lazy var taskID: String = {
        return Utils.fileMD5(self.url.absoluteString) as String
    }()
    
    lazy var fileName: String = {
        return self.taskID
    }()
    
    lazy  var localLoader: CacheLoader = {
        return CacheLoader.init(fileName: self.fileName)
    }()
    
    
    
    init(videoItem: PlayingItem) {
        self.videoItem = videoItem
        self.url = URL(string: videoItem.url)!
        self.offset = videoItem.requestOffset
        super.init()
    }
    
    init(_ loadingRequest: AVAssetResourceLoadingRequest) {
        self.loadingRequet = loadingRequest
        self.url = (loadingRequest.request.url)!
        super.init()
    }
    
    public func loadData(_ offset: Int64? = nil, length: Int64? = nil) {
        var components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = "https"
        guard let url = components?.url else {
            return
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        var range = "";
        let downloadOffset = localLoader.dataSize()
        let requestOffset = (offset != nil ? max(downloadOffset, offset!) : downloadOffset)
        if  let requestLength = length, requestLength > downloadOffset {
            range = String.init(format:"bytes=%ld-%ld", requestOffset, requestLength)
        } else  {
            range = String.init(format:"bytes=%ld-", requestOffset)
        }
        request.addValue(range, forHTTPHeaderField: "Range")
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        let defaultSession =  URLSession.init(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        task = defaultSession.dataTask(with: request)
        task?.resume()
    }
    
    public func cancel() {
        task?.cancel()
    }
}

extension TaskLoader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 416 else {
            self.videoTotalLength = self.localLoader.dataSize()
            resourceLoadDelegate?.downloadTaskDidReceiveResponse(task: self, response: response)
            return
        }
        self.videoTotalLength = response.expectedContentLength
        localLoader.downloadTaskDidReceiveResponse(task: self, response: response)
        completionHandler(.allow)
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        localLoader.downloadTaskDidReceiveData(task: self, data: data)
        resourceLoadDelegate?.downloadTaskDidReceiveData(task: self, data: data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        localLoader.downloadTaskDidFinishLoading(task: self, error: error)
        self.resourceLoadDelegate?.downloadTaskDidFinishLoading(task: self, error: error)
    }
}







