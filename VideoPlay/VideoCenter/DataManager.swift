//
//  DataManager.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/30.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices


class DataManager: NSObject {
    static let manager = DataManager.init()
    var taskLoaders:[String : TaskLoader]
    var loadingsRequest = NSMutableArray()
    var videoLength: Int64 = 0
    var dataDownloadOffset: Int64 = 0
    var contentData: Data = Data()
    var taskLoader: TaskLoader?
    
    
    override init() {
        self.taskLoaders = [String : TaskLoader]()
        super.init()
    }
   
}


extension DataManager: TaskLoaderDelegate {
    public func downloadTaskDidReceiveResponse(task: TaskLoader, response: URLResponse) {
        processLoadingRequest()
    }
    
    public func downloadTaskDidReceiveData(task: TaskLoader, data: Data) {
        self.processLoadingRequest()
    }
    
    @objc func downloadTaskDidFinishLoading(task: TaskLoader, error: Error?) {
        self.processLoadingRequest()
    }
}

extension DataManager: AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("--------shouldWaitForLoading-------\(loadingRequest.dataRequest?.requestedOffset) -- \(loadingRequest.dataRequest?.requestedLength) --- \(loadingRequest.dataRequest?.currentOffset)")
        print(loadingRequest)
        if self.loadingsRequest.contains(loadingRequest) == false {
            self.loadingsRequest.add(loadingRequest)
            self.requestRemoteData(loadingRequest)
        }
        return true
    }
    
  
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("--------cancel-------\(loadingRequest.dataRequest?.requestedOffset) -- \(loadingRequest.dataRequest?.requestedLength) --- \(loadingRequest.dataRequest?.currentOffset)")
        self.loadingsRequest.remove(loadingRequest)
        loadingRequest.finishLoading()
    }
    
    func requestRemoteData(_ loadingRequest: AVAssetResourceLoadingRequest) {
        if let offset = self.taskLoader?.localLoader.dataSize(), offset > 0 {
            self.processLoadingRequest()
        }
        
        if self.taskLoader == nil {
            taskLoader = TaskLoader.init(loadingRequest)
            taskLoader?.resourceLoadDelegate = DataManager.manager
            taskLoader?.loadData()
        }
    }
}


extension DataManager {
    public func processLoadingRequest() {
            var toDelete:[Any] = [Any]()
            self.loadingsRequest.forEach { [weak self] in
               
                let loadingRequest: AVAssetResourceLoadingRequest = $0 as! AVAssetResourceLoadingRequest
            
                guard let dataRequest = loadingRequest.dataRequest, let strongSelf = self else {
                    return
                }
                
                guard let localLoader = strongSelf.taskLoader?.localLoader else {
                    return
                }
                
                let downloadedSize: Int64 = Int64(localLoader.dataSize())
                
                if loadingRequest.contentInformationRequest != nil {
                    strongSelf.fillRequestContentInformation(loadingRequest.contentInformationRequest!, contentLength: (taskLoader?.videoTotalLength)!, contentType: "video/mp4")
                }
                
                let currentOffset = dataRequest.currentOffset
                let requestOffset =  dataRequest.requestedOffset
        
                let startOffset = max(requestOffset, currentOffset)
                
                if downloadedSize < startOffset {
                    return
                }
                
                let unreadBytes = downloadedSize - startOffset
                
                let numberOfBytesToResponde = min((dataRequest.requestedLength), Int(unreadBytes))
                
                let r = NSRange.init(location: (Int)(startOffset), length: numberOfBytesToResponde)
                if downloadedSize >= ((Int)(startOffset) + numberOfBytesToResponde),numberOfBytesToResponde > 0  {
                    
                    guard let data = localLoader.readData(range: r) else {
                        return
                    }
                    
                    loadingRequest.dataRequest?.respond(with: data)
                    
                    let endOffset = dataRequest.requestedOffset + Int64(dataRequest.requestedLength)
//                    print("range---\(r.location)--->\(r.length + r.location)---->\(downloadedSize)---endOffset:\(endOffset)")
                    let complished = downloadedSize >= endOffset
                    if complished {
                        loadingRequest.finishLoading()
                        toDelete.append(loadingRequest)
                        print("--------compliehed-------\(loadingRequest.dataRequest?.requestedOffset) -- \(loadingRequest.dataRequest?.requestedLength) --- \(loadingRequest.dataRequest?.currentOffset)")
                    }
                }
            }
            self.loadingsRequest.removeObjects(in: toDelete)
        }
    
    
    private func fillRequestContentInformation(_ contentInfoRequest: AVAssetResourceLoadingContentInformationRequest,
                                               contentLength: Int64,
                                               contentType: String) {
        
        contentInfoRequest.contentLength = contentLength
        contentInfoRequest.isByteRangeAccessSupported = true
        
        var videoType : String
        if contentType.characters.count > 0 {
            videoType = contentType
        } else {
            videoType = "video/mp4"
        }
        
        let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, videoType as CFString, nil)
        contentInfoRequest.contentType = typeIdentifier?.takeRetainedValue() as String?
    }
    
}
