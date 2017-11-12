//
//  CacheLoader.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/11/1.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//


///管理本地缓存

import UIKit

let localCacheQueue = DispatchQueue.init(label: "file_manager_queue")

class CacheLoader: NSObject {
    
    var fileName: String
    
    var downloadingSize = 0
    
    init(fileName: String) {
        self.fileName = fileName
        super.init()
    }

    
    var filePath: String {
       guard let folder = libraryCachePath() else {
            return ""
        }
        return folder + "/\(fileName)"
    }
    
    public func dataSize() -> Int64 {
        guard FileManager.default.fileExists(atPath: filePath) else {
            return 0
        }
        
        var dataSize: Int64?
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            dataSize = fileAttributes[FileAttributeKey.size] as? Int64
        } catch {
            print("Failed to read video cache")
        }
        return dataSize ?? 0
    }
    
    
    public func writeData(data: Data, offset: Int = 0) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        if let fileHandler = FileHandle(forWritingAtPath: filePath) {
            fileHandler.seekToEndOfFile()
            fileHandler.write(data)
        }
    }
    
    
    public func readData(range: NSRange) -> Data? {
        if let fileHandler = FileHandle(forReadingAtPath: filePath) {
            fileHandler.seek(toFileOffset: UInt64(range.location))
            let  videoData = fileHandler.readData(ofLength: range.length)
            return videoData
        }
        return nil
    }
    
    public func deleteFile() {
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                
            }
            print("删除文件\(fileName)")
        }
    }
    
    public func createFile() {
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            print("filepath:---> \(filePath)")
        }
    }
    
    
    func videoFileExist() -> Bool {
        var fileExist = false
        let fileManager = FileManager.default
        fileExist = fileManager.fileExists(atPath: filePath)
        return fileExist
    }
    
    private func libraryCachePath() -> String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
    }
    
}


extension CacheLoader: TaskLoaderDelegate {
    public func downloadTaskDidReceiveResponse(task: TaskLoader, response: URLResponse) {
        self.createFile()
    }
    
    public func downloadTaskDidReceiveData(task: TaskLoader, data: Data) {
        localCacheQueue.sync {
            self.writeData(data: data)
        }
    }
    
    public  func downloadTaskDidFinishLoading(task: TaskLoader, error: Error?) {
        print(filePath)
    }
}


